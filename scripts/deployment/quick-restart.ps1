<#
.SYNOPSIS
    Quick service restart without full deployment

.DESCRIPTION
    Restart Docker services on VPS without transferring files.
    Fast recovery for service crashes or configuration changes.

.PARAMETER Environment
    Target environment (testnet or production)

.PARAMETER Service
    Specific service to restart (optional, restarts all if not specified)

.EXAMPLE
    .\quick-restart.ps1 -Environment testnet

.EXAMPLE
    .\quick-restart.ps1 -Environment testnet -Service binance-trader-macd-testnet
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('testnet', 'production')]
    [string]$Environment,
    
    [Parameter(Mandatory=$false)]
    [string]$Service
)

$ErrorActionPreference = "Stop"

# Configuration
$Config = @{
    testnet = @{
        VpsHost = "145.223.70.118"
        VpsUser = "binance-trader"
        SshKeyPath = "$HOME\.ssh\vps_binance"
        ComposeFile = "docker-compose-testnet.yml"
    }
    production = @{
        VpsHost = $env:PROD_VPS_HOST
        VpsUser = $env:PROD_VPS_USER
        SshKeyPath = "$HOME\.ssh\prod_binance"
        ComposeFile = "docker-compose-testnet.yml"
    }
}

$cfg = $Config[$Environment]

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " Quick Restart - $Environment" -ForegroundColor Green
if ($Service) {
    Write-Host " Service: $Service" -ForegroundColor Green
} else {
    Write-Host " Service: All services" -ForegroundColor Green
}
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# Test SSH connection
Write-Host "Testing connection..." -ForegroundColor Yellow
try {
    $test = ssh -i $cfg.SshKeyPath -o ConnectTimeout=5 -o StrictHostKeyChecking=no `
        "$($cfg.VpsUser)@$($cfg.VpsHost)" "echo 'ok'"
    
    if ($test -ne "ok") {
        Write-Host "Cannot connect to VPS" -ForegroundColor Red
        exit 1
    }
    Write-Host "Connected successfully" -ForegroundColor Green
} catch {
    Write-Host "Connection failed: $_" -ForegroundColor Red
    exit 1
}

# Restart services
Write-Host ""
Write-Host "Restarting services..." -ForegroundColor Yellow

$serviceArg = if ($Service) { $Service } else { "" }

$result = ssh -i $cfg.SshKeyPath -o StrictHostKeyChecking=no `
    "$($cfg.VpsUser)@$($cfg.VpsHost)" @"
set -e
cd /opt/binance-traders

echo 'Current status:'
docker compose -f $($cfg.ComposeFile) ps $serviceArg

echo ''
echo 'Restarting services...'
docker compose -f $($cfg.ComposeFile) restart $serviceArg

echo ''
echo 'Waiting for services to be ready...'
sleep 20

echo ''
echo 'New status:'
docker compose -f $($cfg.ComposeFile) ps $serviceArg

echo ''
echo 'Checking health...'
if curl -f http://localhost/health > /dev/null 2>&1; then
    echo 'Health check: OK'
else
    echo 'Health check: FAILED'
    echo 'Recent logs:'
    docker compose -f $($cfg.ComposeFile) logs --tail=20 $serviceArg
    exit 1
fi
"@

Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host " Restart Complete!" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "View logs: ssh $($cfg.VpsUser)@$($cfg.VpsHost) 'cd /opt/binance-traders && docker compose logs -f'"
Write-Host ""

