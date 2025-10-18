<#
.SYNOPSIS
    Full manual deployment script (GitHub Actions backup)

.DESCRIPTION
    Complete manual deployment with all safety checks, backups, and rollback capability.
    Use this when GitHub Actions is unavailable or for emergency deployments.

.PARAMETER Environment
    Target environment (testnet or production)

.PARAMETER Action
    Deployment action (deploy, restart, rollback)

.PARAMETER SkipBackup
    Skip creating backup before deployment

.PARAMETER SkipHealthCheck
    Skip health verification after deployment

.EXAMPLE
    .\manual-deploy-full.ps1 -Environment testnet -Action deploy

.EXAMPLE
    .\manual-deploy-full.ps1 -Environment production -Action deploy

.NOTES
    Requires: SSH keys configured, SOPS, age
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('testnet', 'production')]
    [string]$Environment,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('deploy', 'restart', 'rollback')]
    [string]$Action = 'deploy',
    
    [switch]$SkipBackup,
    [switch]$SkipHealthCheck,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Configuration
$Config = @{
    testnet = @{
        VpsHost = "145.223.70.118"
        VpsUser = "binance-trader"
        SshKeyPath = "$HOME\.ssh\vps_binance"
        ComposeFile = "docker-compose-testnet.yml"
        EnvFile = "testnet.env"
    }
    production = @{
        VpsHost = $env:PROD_VPS_HOST
        VpsUser = $env:PROD_VPS_USER
        SshKeyPath = "$HOME\.ssh\prod_binance"
        ComposeFile = "docker-compose-testnet.yml"  # Update for production
        EnvFile = "production.env"
    }
}

$env:DEPLOYMENT_ENV = $Environment
$cfg = $Config[$Environment]

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " Manual Deployment - $Environment" -ForegroundColor Green
Write-Host " Action: $Action" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# Create logs directory
$logDir = "logs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = "$logDir\deployment-$Environment-$timestamp.log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $logMessage = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage
}

function Test-Prerequisites {
    Write-Log "Checking prerequisites..."
    
    # Check SSH key
    if (-not (Test-Path $cfg.SshKeyPath)) {
        Write-Log "SSH key not found: $($cfg.SshKeyPath)" "ERROR"
        Write-Host "Generate SSH key with: ssh-keygen -t ed25519 -f $($cfg.SshKeyPath)" -ForegroundColor Yellow
        exit 1
    }
    Write-Log "SSH key found" "OK"
    
    # Check SOPS
    try {
        $null = sops --version
        Write-Log "SOPS installed" "OK"
    } catch {
        Write-Log "SOPS not installed" "ERROR"
        Write-Host "Install with: choco install sops" -ForegroundColor Yellow
        exit 1
    }
    
    # Check age
    try {
        $null = age --version
        Write-Log "age installed" "OK"
    } catch {
        Write-Log "age not installed" "ERROR"
        Write-Host "Install with: .\scripts\deployment\install-tools.ps1" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Log "All prerequisites met" "OK"
}

function Test-VpsConnectivity {
    Write-Log "Testing VPS connectivity..."
    
    try {
        $result = ssh -i $cfg.SshKeyPath -o ConnectTimeout=10 -o StrictHostKeyChecking=no `
            "$($cfg.VpsUser)@$($cfg.VpsHost)" "echo 'connected'"
        
        if ($result -eq "connected") {
            Write-Log "VPS connection successful" "OK"
            return $true
        }
    } catch {
        Write-Log "VPS connection failed: $_" "ERROR"
        return $false
    }
    
    return $false
}

function Get-VpsStatus {
    Write-Log "Checking VPS status..."
    
    $status = ssh -i $cfg.SshKeyPath -o StrictHostKeyChecking=no `
        "$($cfg.VpsUser)@$($cfg.VpsHost)" @'
echo "Hostname: $(hostname)"
echo "Uptime: $(uptime -p)"
echo "Disk: $(df -h /opt/binance-traders | tail -1 | awk '{print $4 " free"}')"
echo "Memory: $(free -h | grep Mem | awk '{print $4 " free"}')"
echo "Docker: $(systemctl is-active docker)"
'@
    
    Write-Log "VPS Status:"
    $status | ForEach-Object { Write-Log "  $_" }
}

function Backup-CurrentState {
    if ($SkipBackup) {
        Write-Log "Skipping backup (SkipBackup flag set)" "WARN"
        return
    }
    
    Write-Log "Creating backup..."
    
    $backupId = Get-Date -Format "yyyyMMdd_HHmmss"
    
    ssh -i $cfg.SshKeyPath -o StrictHostKeyChecking=no `
        "$($cfg.VpsUser)@$($cfg.VpsHost)" @"
set -e
mkdir -p /opt/binance-traders/backups

if [ -f /opt/binance-traders/$($cfg.ComposeFile) ]; then
    cp /opt/binance-traders/$($cfg.ComposeFile) \
       /opt/binance-traders/backups/docker-compose-$backupId.yml
    echo "Backup created: backups/docker-compose-$backupId.yml"
else
    echo "No existing deployment to backup"
fi

# List recent backups
echo "Recent backups:"
ls -lht /opt/binance-traders/backups/ | head -5
"@
    
    Write-Log "Backup completed: $backupId" "OK"
}

function Deploy-Application {
    Write-Log "Starting deployment..."
    
    # Build application
    Write-Log "Building application..."
    mvn clean package -DskipTests -T 1C
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Maven build failed" "ERROR"
        exit 1
    }
    Write-Log "Build completed" "OK"
    
    # Build Docker images
    Write-Log "Building Docker images..."
    docker compose -f $cfg.ComposeFile build
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Docker build failed" "ERROR"
        exit 1
    }
    Write-Log "Docker images built" "OK"
    
    # Save images
    Write-Log "Saving Docker images..."
    $images = docker compose -f $cfg.ComposeFile config | Select-String "image:" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    docker save $images -o images.tar
    Write-Log "Images saved to images.tar" "OK"
    
    # Decrypt secrets
    Write-Log "Decrypting secrets..."
    $env:SOPS_AGE_KEY_FILE = "$HOME\age-key.txt"
    if (-not (Test-Path $env:SOPS_AGE_KEY_FILE)) {
        Write-Log "Age key file not found: $env:SOPS_AGE_KEY_FILE" "ERROR"
        exit 1
    }
    
    sops -d "$($cfg.EnvFile).enc" > $cfg.EnvFile
    Write-Log "Secrets decrypted" "OK"
    
    # Transfer files
    Write-Log "Transferring files to VPS..."
    
    # Use rsync for application files
    Write-Host "Transferring application files..." -ForegroundColor Yellow
    $rsyncArgs = @(
        "-avz"
        "--delete"
        "-e", "ssh -i $($cfg.SshKeyPath) -o StrictHostKeyChecking=no"
        "--exclude", ".git"
        "--exclude", "target"
        "--exclude", "node_modules"
        "--exclude", "*.log"
        "--exclude", "images.tar"
        "."
        "$($cfg.VpsUser)@$($cfg.VpsHost):/opt/binance-traders/"
    )
    
    & rsync @rsyncArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Log "File transfer failed" "ERROR"
        exit 1
    }
    Write-Log "Application files transferred" "OK"
    
    # Transfer images
    Write-Host "Transferring Docker images..." -ForegroundColor Yellow
    scp -i $cfg.SshKeyPath -o StrictHostKeyChecking=no `
        images.tar "$($cfg.VpsUser)@$($cfg.VpsHost):/tmp/"
    Write-Log "Docker images transferred" "OK"
    
    # Transfer environment
    scp -i $cfg.SshKeyPath -o StrictHostKeyChecking=no `
        $cfg.EnvFile "$($cfg.VpsUser)@$($cfg.VpsHost):/opt/binance-traders/"
    Write-Log "Environment file transferred" "OK"
    
    # Deploy on VPS
    Write-Log "Deploying on VPS..."
    
    ssh -i $cfg.SshKeyPath -o StrictHostKeyChecking=no `
        "$($cfg.VpsUser)@$($cfg.VpsHost)" @"
set -e
cd /opt/binance-traders

echo 'Loading Docker images...'
docker load -i /tmp/images.tar
rm /tmp/images.tar

echo 'Stopping existing services...'
docker compose -f $($cfg.ComposeFile) down || true

echo 'Starting services...'
docker compose -f $($cfg.ComposeFile) --env-file $($cfg.EnvFile) up -d

echo 'Waiting for services to start...'
sleep 30

echo 'Deployment complete!'
docker compose -f $($cfg.ComposeFile) ps
"@
    
    Write-Log "Deployment completed" "OK"
    
    # Cleanup local files
    Remove-Item images.tar -ErrorAction SilentlyContinue
    Remove-Item $cfg.EnvFile -ErrorAction SilentlyContinue
}

function Test-Deployment {
    if ($SkipHealthCheck) {
        Write-Log "Skipping health check (SkipHealthCheck flag set)" "WARN"
        return $true
    }
    
    Write-Log "Verifying deployment..."
    
    Start-Sleep -Seconds 15
    
    $healthCheck = ssh -i $cfg.SshKeyPath -o StrictHostKeyChecking=no `
        "$($cfg.VpsUser)@$($cfg.VpsHost)" @"
set -e
cd /opt/binance-traders

# Health endpoint check
if curl -f http://localhost/health > /dev/null 2>&1; then
    echo 'HEALTH_OK'
else
    echo 'HEALTH_FAILED'
    docker compose -f $($cfg.ComposeFile) logs --tail=50
    exit 1
fi

# Container count check
RUNNING=\$(docker compose -f $($cfg.ComposeFile) ps --services --filter 'status=running' | wc -l)
echo "CONTAINERS_RUNNING:\$RUNNING"

if [ "\$RUNNING" -ge 8 ]; then
    echo 'CONTAINERS_OK'
else
    echo 'CONTAINERS_FAILED'
    docker compose -f $($cfg.ComposeFile) ps
    exit 1
fi
"@
    
    if ($healthCheck -match "HEALTH_OK" -and $healthCheck -match "CONTAINERS_OK") {
        Write-Log "Health checks passed" "OK"
        return $true
    } else {
        Write-Log "Health checks failed" "ERROR"
        return $false
    }
}

function Invoke-Rollback {
    Write-Log "Initiating rollback..." "WARN"
    
    ssh -i $cfg.SshKeyPath -o StrictHostKeyChecking=no `
        "$($cfg.VpsUser)@$($cfg.VpsHost)" @"
set -e
cd /opt/binance-traders

# Find most recent backup
LATEST_BACKUP=\$(ls -t backups/docker-compose-*.yml | head -1)

if [ -z "\$LATEST_BACKUP" ]; then
    echo 'No backups found!'
    exit 1
fi

echo "Rolling back to: \$LATEST_BACKUP"

docker compose -f $($cfg.ComposeFile) down
cp "\$LATEST_BACKUP" $($cfg.ComposeFile)
docker compose -f $($cfg.ComposeFile) --env-file $($cfg.EnvFile) up -d

sleep 20
echo 'Rollback complete'
docker compose -f $($cfg.ComposeFile) ps
"@
    
    Write-Log "Rollback completed" "OK"
}

# Main execution
try {
    Write-Log "=== Starting Manual Deployment ===" "INFO"
    Write-Log "Environment: $Environment"
    Write-Log "Action: $Action"
    Write-Log "VPS: $($cfg.VpsHost)"
    
    # Pre-flight checks
    Test-Prerequisites
    
    if (-not (Test-VpsConnectivity)) {
        Write-Log "Cannot connect to VPS" "ERROR"
        exit 1
    }
    
    Get-VpsStatus
    
    # Confirm deployment
    if (-not $Force) {
        Write-Host ""
        $confirm = Read-Host "Proceed with deployment? (yes/no)"
        if ($confirm -ne "yes") {
            Write-Log "Deployment cancelled by user" "WARN"
            exit 0
        }
    }
    
    # Execute action
    switch ($Action) {
        "deploy" {
            Backup-CurrentState
            Deploy-Application
            
            if (-not (Test-Deployment)) {
                Write-Log "Deployment verification failed. Initiating rollback..." "ERROR"
                Invoke-Rollback
                
                if (Test-Deployment) {
                    Write-Log "Rollback successful" "OK"
                } else {
                    Write-Log "Rollback also failed. Manual intervention required!" "CRITICAL"
                    exit 1
                }
                exit 1
            }
            
            Write-Log "Deployment successful!" "OK"
        }
        
        "restart" {
            Write-Log "Restarting services..."
            & "$PSScriptRoot\quick-restart.ps1" -Environment $Environment
        }
        
        "rollback" {
            Invoke-Rollback
            Test-Deployment
        }
    }
    
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host " Deployment Complete!" -ForegroundColor Green
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Log file: $logFile"
    Write-Host "VPS: $($cfg.VpsHost)"
    Write-Host "Health: http://$($cfg.VpsHost)/health"
    Write-Host "Grafana: http://$($cfg.VpsHost)/grafana/"
    Write-Host ""
    
} catch {
    Write-Log "Deployment failed: $_" "ERROR"
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Red
    Write-Host " Deployment Failed!" -ForegroundColor Red
    Write-Host "================================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "Log file: $logFile"
    Write-Host ""
    Write-Host "Emergency commands:" -ForegroundColor Yellow
    Write-Host "  Rollback: .\scripts\deployment\rollback.ps1 -Environment $Environment"
    Write-Host "  Diagnose: .\scripts\deployment\diagnose.ps1 -Environment $Environment"
    Write-Host ""
    exit 1
}

