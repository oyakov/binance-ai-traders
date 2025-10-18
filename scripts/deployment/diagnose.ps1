<#
.SYNOPSIS
    Diagnostic script for deployment troubleshooting

.DESCRIPTION
    Collects comprehensive diagnostics from VPS:
    - Service status
    - Container logs
    - Resource usage
    - Health endpoints
    - Firewall status

.PARAMETER Environment
    Target environment (testnet or production)

.PARAMETER Service
    Specific service to diagnose (optional)

.PARAMETER SaveReport
    Save report to file

.EXAMPLE
    .\diagnose.ps1 -Environment testnet

.EXAMPLE
    .\diagnose.ps1 -Environment testnet -Service binance-trader-macd-testnet -SaveReport
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('testnet', 'production')]
    [string]$Environment,
    
    [Parameter(Mandatory=$false)]
    [string]$Service,
    
    [switch]$SaveReport
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
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " Diagnostic Report - $Environment" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# Collect diagnostics
$report = ssh -i $cfg.SshKeyPath -o StrictHostKeyChecking=no `
    "$($cfg.VpsUser)@$($cfg.VpsHost)" @"
echo '==============================================================='
echo ' System Information'
echo '==============================================================='
echo 'Hostname: '\$(hostname)
echo 'Uptime: '\$(uptime -p)
echo 'Kernel: '\$(uname -r)
echo 'Date: '\$(date)
echo ''

echo '==============================================================='
echo ' Resource Usage'
echo '==============================================================='
echo 'Disk Usage:'
df -h /opt/binance-traders 2>/dev/null || df -h /
echo ''
echo 'Memory Usage:'
free -h
echo ''
echo 'Top processes by memory:'
ps aux --sort=-%mem | head -10
echo ''

echo '==============================================================='
echo ' Docker Status'
echo '==============================================================='
echo 'Docker service: '\$(systemctl is-active docker)
echo 'Docker version: '\$(docker --version)
echo 'Docker compose version: '\$(docker compose version)
echo ''

echo '==============================================================='
echo ' Container Status'
echo '==============================================================='
cd /opt/binance-traders
docker compose -f $($cfg.ComposeFile) ps
echo ''

echo '==============================================================='
echo ' Container Resource Usage'
echo '==============================================================='
docker stats --no-stream
echo ''

echo '==============================================================='
echo ' Health Checks'
echo '==============================================================='
echo 'Main health endpoint:'
curl -s -w '\nHTTP Status: %{http_code}\n' http://localhost/health || echo 'FAILED'
echo ''

echo 'Storage health:'
curl -s http://localhost:8087/health 2>/dev/null || echo 'Not accessible'
echo ''

echo 'Collection health:'
curl -s http://localhost:8086/health 2>/dev/null || echo 'Not accessible'
echo ''

echo 'Trader health:'
curl -s http://localhost:8083/health 2>/dev/null || echo 'Not accessible'
echo ''

echo '==============================================================='
echo ' Network Status'
echo '==============================================================='
echo 'Listening ports:'
sudo ss -tulpn | grep LISTEN | grep -E '(80|443|8080|8083|8086|8087|5432|9092)'
echo ''

echo 'Firewall status:'
sudo firewall-cmd --list-all 2>/dev/null || echo 'firewalld not running'
echo ''

echo '==============================================================='
echo ' Recent Logs (last 50 lines)'
echo '==============================================================='
if [ -n "$Service" ]; then
    docker compose -f $($cfg.ComposeFile) logs --tail=50 $Service
else
    docker compose -f $($cfg.ComposeFile) logs --tail=50
fi
echo ''

echo '==============================================================='
echo ' Docker Events (last 20)'
echo '==============================================================='
docker events --since 1h --until 1s 2>/dev/null | tail -20 || echo 'No recent events'
echo ''

echo '==============================================================='
echo ' Disk Space Issues'
echo '==============================================================='
echo 'Docker disk usage:'
docker system df
echo ''
echo 'Large files in /opt/binance-traders:'
du -sh /opt/binance-traders/* 2>/dev/null | sort -h | tail -10
echo ''

echo '==============================================================='
echo ' Common Issues Check'
echo '==============================================================='

# Check for OOM kills
if dmesg | grep -i 'out of memory' | tail -5 > /dev/null 2>&1; then
    echo 'WARNING: Out of memory events detected'
    dmesg | grep -i 'out of memory' | tail -5
else
    echo 'No recent OOM events'
fi
echo ''

# Check for disk full
DISK_USAGE=\$(df -h /opt/binance-traders | tail -1 | awk '{print \$5}' | sed 's/%//')
if [ "\$DISK_USAGE" -gt 90 ]; then
    echo "WARNING: Disk usage is \${DISK_USAGE}%"
else
    echo "Disk usage OK: \${DISK_USAGE}%"
fi
echo ''

# Check for failed containers
FAILED=\$(docker compose -f $($cfg.ComposeFile) ps --filter 'status=exited' --format '{{.Name}}')
if [ -n "\$FAILED" ]; then
    echo 'WARNING: Failed containers detected:'
    echo "\$FAILED"
else
    echo 'No failed containers'
fi
echo ''

echo '==============================================================='
echo ' Suggestions'
echo '==============================================================='

if [ "\$DISK_USAGE" -gt 90 ]; then
    echo '- Clean up disk space: docker system prune -a'
fi

if [ -n "\$FAILED" ]; then
    echo '- Check failed container logs'
    echo '- Restart failed services: docker compose restart'
fi

echo 'Done.'
"@

# Display report
Write-Host $report

# Save report if requested
if ($SaveReport) {
    $reportFile = "logs\diagnostics-$Environment-$timestamp.txt"
    
    if (-not (Test-Path "logs")) {
        New-Item -ItemType Directory -Path "logs" | Out-Null
    }
    
    $report | Out-File -FilePath $reportFile -Encoding UTF8
    
    Write-Host ""
    Write-Host "Report saved to: $reportFile" -ForegroundColor Green
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " Diagnostic Complete" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# Provide actionable suggestions
Write-Host "Quick actions:" -ForegroundColor Yellow
Write-Host "  Restart services: .\scripts\deployment\quick-restart.ps1 -Environment $Environment"
Write-Host "  View live logs: ssh $($cfg.VpsUser)@$($cfg.VpsHost) 'docker compose -f /opt/binance-traders/$($cfg.ComposeFile) logs -f'"
Write-Host "  Rollback: .\scripts\deployment\rollback.ps1 -Environment $Environment"
Write-Host ""

