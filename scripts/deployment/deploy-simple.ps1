# Simple Deployment Guide
# VPS: 145.223.70.118
# User: binance-trader

param(
    [string]$VpsIp = "145.223.70.118"
)

Write-Host ""
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host " Binance AI Traders - Deployment Guide" -ForegroundColor Green
Write-Host " Target VPS: $VpsIp" -ForegroundColor Green
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "PREREQUISITES:" -ForegroundColor Yellow
Write-Host "  1. SOPS installed (run install-tools.ps1 as Administrator)"
Write-Host "  2. age installed (run install-tools.ps1 as Administrator)"
Write-Host "  3. SSH client available"
Write-Host ""

$continue = Read-Host "Press Enter to continue (or Ctrl+C to exit)"

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " Step 1: Generate SSH Keys" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Run this command:" -ForegroundColor Yellow
Write-Host "  ssh-keygen -t ed25519 -C binance-vps -f `$HOME\.ssh\vps_binance" -ForegroundColor White
Write-Host ""
Write-Host "Press Enter three times (no passphrase)" -ForegroundColor Gray
Write-Host ""
$null = Read-Host "Press Enter when done"

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " Step 2: Upload SSH Key to VPS" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

$pubKeyPath = "$HOME\.ssh\vps_binance.pub"
if (Test-Path $pubKeyPath) {
    $pubKey = Get-Content $pubKeyPath
    Set-Clipboard $pubKey
    Write-Host "Your SSH public key has been COPIED TO CLIPBOARD!" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "ERROR: SSH key not found at $pubKeyPath" -ForegroundColor Red
    Write-Host "Please run Step 1 first." -ForegroundColor Yellow
    exit 1
}

Write-Host "Now connect to VPS and paste the key:" -ForegroundColor Yellow
Write-Host "  ssh root@$VpsIp" -ForegroundColor White
Write-Host "  mkdir -p ~/.ssh" -ForegroundColor White
Write-Host "  echo PASTE_KEY_HERE >> ~/.ssh/authorized_keys" -ForegroundColor White
Write-Host "  chmod 600 ~/.ssh/authorized_keys" -ForegroundColor White
Write-Host "  exit" -ForegroundColor White
Write-Host ""
Write-Host "Use Shift+Insert or Right-Click to paste in SSH terminal" -ForegroundColor Gray
Write-Host ""
$null = Read-Host "Press Enter when done"

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " Step 3: Test SSH Key Authentication" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Run this command:" -ForegroundColor Yellow
Write-Host "  ssh -i `$HOME\.ssh\vps_binance root@$VpsIp whoami" -ForegroundColor White
Write-Host ""
Write-Host "Should print 'root' without asking for password" -ForegroundColor Gray
Write-Host ""
$null = Read-Host "Press Enter when verified"

Write-Host ""
Write-Host "===================================================================" -ForegroundColor Green
Write-Host " Basic Setup Complete!" -ForegroundColor Green
Write-Host "===================================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Run VPS setup (creates user, installs Docker, etc)"
Write-Host "  2. Generate and encrypt secrets"
Write-Host "  3. Upload application files"
Write-Host "  4. Deploy with Docker Compose"
Write-Host ""

Write-Host "For complete guide, see:" -ForegroundColor Cyan
Write-Host "  scripts/deployment/DEPLOYMENT_GUIDE.md"
Write-Host ""

Write-Host "To install tools (SOPS & age), run AS ADMINISTRATOR:" -ForegroundColor Yellow
Write-Host "  .\scripts\deployment\install-tools.ps1"
Write-Host ""

exit 0

