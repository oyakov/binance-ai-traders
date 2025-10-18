<#
.SYNOPSIS
    Rollback to previous deployment

.DESCRIPTION
    Rollback services to a previous backup version.
    Lists available backups and restores selected version.

.PARAMETER Environment
    Target environment (testnet or production)

.PARAMETER BackupId
    Backup timestamp/ID to restore (optional, prompts if not provided)

.EXAMPLE
    .\rollback.ps1 -Environment testnet

.EXAMPLE
    .\rollback.ps1 -Environment testnet -BackupId 20251018_120000
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('testnet', 'production')]
    [string]$Environment,
    
    [Parameter(Mandatory=$false)]
    [string]$BackupId
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
        ComposeFile = "docker-compose-testnet.yml"
        EnvFile = "production.env"
    }
}

$cfg = $Config[$Environment]

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " Rollback Deployment - $Environment" -ForegroundColor Yellow
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# List available backups
Write-Host "Available backups:" -ForegroundColor Yellow
$backups = ssh -i $cfg.SshKeyPath -o StrictHostKeyChecking=no `
    "$($cfg.VpsUser)@$($cfg.VpsHost)" @"
cd /opt/binance-traders
if [ -d backups ]; then
    ls -lht backups/docker-compose-*.yml | head -10
else
    echo 'No backups directory found'
    exit 1
fi
"@

Write-Host $backups

# Select backup if not provided
if (-not $BackupId) {
    Write-Host ""
    $BackupId = Read-Host "Enter backup ID to restore (timestamp from filename)"
    
    if (-not $BackupId) {
        Write-Host "No backup ID provided. Exiting." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "WARNING: This will:" -ForegroundColor Yellow
Write-Host "  1. Stop all current services"
Write-Host "  2. Restore configuration from backup: $BackupId"
Write-Host "  3. Restart services with old configuration"
Write-Host ""
$confirm = Read-Host "Type 'YES' to proceed with rollback"

if ($confirm -ne "YES") {
    Write-Host "Rollback cancelled" -ForegroundColor Yellow
    exit 0
}

# Create backup of current state before rollback
Write-Host ""
Write-Host "Creating backup of current state..." -ForegroundColor Yellow
$currentBackupId = Get-Date -Format "yyyyMMdd_HHmmss"

ssh -i $cfg.SshKeyPath -o StrictHostKeyChecking=no `
    "$($cfg.VpsUser)@$($cfg.VpsHost)" @"
cd /opt/binance-traders
if [ -f $($cfg.ComposeFile) ]; then
    cp $($cfg.ComposeFile) backups/docker-compose-before-rollback-$currentBackupId.yml
    echo 'Current state backed up: before-rollback-$currentBackupId'
fi
"@

# Perform rollback
Write-Host ""
Write-Host "Performing rollback..." -ForegroundColor Yellow

ssh -i $cfg.SshKeyPath -o StrictHostKeyChecking=no `
    "$($cfg.VpsUser)@$($cfg.VpsHost)" @"
set -e
cd /opt/binance-traders

ROLLBACK_FILE="backups/docker-compose-$BackupId.yml"

if [ ! -f "\$ROLLBACK_FILE" ]; then
    echo "ERROR: Rollback file not found: \$ROLLBACK_FILE"
    exit 1
fi

echo 'Stopping current services...'
docker compose -f $($cfg.ComposeFile) down

echo 'Restoring backup...'
cp "\$ROLLBACK_FILE" $($cfg.ComposeFile)

echo 'Starting services with restored configuration...'
docker compose -f $($cfg.ComposeFile) --env-file $($cfg.EnvFile) up -d

echo 'Waiting for services to start...'
sleep 30

echo 'Checking service status...'
docker compose -f $($cfg.ComposeFile) ps
"@

# Verify rollback
Write-Host ""
Write-Host "Verifying rollback..." -ForegroundColor Yellow

$verification = ssh -i $cfg.SshKeyPath -o StrictHostKeyChecking=no `
    "$($cfg.VpsUser)@$($cfg.VpsHost)" @"
set -e
cd /opt/binance-traders

# Health check
if curl -f http://localhost/health > /dev/null 2>&1; then
    echo 'HEALTH_OK'
else
    echo 'HEALTH_FAILED'
    exit 1
fi

# Container check
RUNNING=\$(docker compose -f $($cfg.ComposeFile) ps --services --filter 'status=running' | wc -l)
if [ "\$RUNNING" -ge 8 ]; then
    echo 'CONTAINERS_OK'
else
    echo 'CONTAINERS_FAILED'
    docker compose -f $($cfg.ComposeFile) ps
    exit 1
fi
"@

if ($verification -match "HEALTH_OK" -and $verification -match "CONTAINERS_OK") {
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host " Rollback Successful!" -ForegroundColor Green
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Rolled back to: $BackupId"
    Write-Host "Current state backed up as: before-rollback-$currentBackupId"
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Red
    Write-Host " Rollback Verification Failed!" -ForegroundColor Red
    Write-Host "================================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Services may not be fully operational."
    Write-Host "Check logs: ssh $($cfg.VpsUser)@$($cfg.VpsHost) 'docker compose logs'"
    Write-Host ""
    exit 1
}

