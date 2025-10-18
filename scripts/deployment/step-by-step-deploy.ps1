<#
.SYNOPSIS
    Step-by-step deployment helper with copy/paste commands

.DESCRIPTION
    Interactive guide that generates commands to copy/paste.
    Avoids password automation issues on Windows.

.EXAMPLE
    .\step-by-step-deploy.ps1
#>

param(
    [string]$VpsIp = "145.223.70.118",
    [string]$DeploymentUser = "binance-trader"
)

$ColorGreen = "`e[32m"
$ColorYellow = "`e[33m"
$ColorCyan = "`e[36m"
$ColorBlue = "`e[34m"
$ColorReset = "`e[0m"

Clear-Host

Write-Host ""
Write-Host "================================================================" -ForegroundColor Blue
Write-Host "                                                                " -ForegroundColor Blue
Write-Host "   Binance AI Traders - Step-by-Step Deployment                " -ForegroundColor Blue
Write-Host "   VPS: $VpsIp                                         " -ForegroundColor Blue
Write-Host "                                                                " -ForegroundColor Blue
Write-Host "================================================================" -ForegroundColor Blue
Write-Host ""

Write-Host "This script will guide you through the deployment process with"
Write-Host "easy copy/paste commands for Windows."
Write-Host ""
Write-Host "Press Enter to start..." -ForegroundColor Yellow
Read-Host

function Show-Step {
    param(
        [int]$Number,
        [string]$Title,
        [string]$Description,
        [string[]]$Commands,
        [string]$Notes
    )
    
    Write-Host "`n" -NoNewline
    Write-Host "===============================================================" -ForegroundColor Cyan
    Write-Host "Step $Number`: $Title" -ForegroundColor Green
    Write-Host "===============================================================" -ForegroundColor Cyan
    Write-Host "`n$Description`n"
    
    if ($Commands) {
        Write-Host "Commands to run:" -ForegroundColor Yellow
        Write-Host ""
        foreach ($cmd in $Commands) {
            Write-Host "  $cmd" -ForegroundColor White
        }
    }
    
    if ($Notes) {
        Write-Host ""
        Write-Host "Note: $Notes" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Press Enter when complete..." -ForegroundColor Yellow
    Read-Host
}

# Step 1: SSH Keys
Show-Step -Number 1 -Title "Generate SSH Keys" `
    -Description "Generate ED25519 SSH key pair for secure authentication." `
    -Commands @(
        "ssh-keygen -t ed25519 -C `"binance-vps-$VpsIp`" -f $HOME\.ssh\vps_binance"
    ) `
    -Notes "Press Enter three times (no passphrase for automation)"

# Step 2: Copy public key
$pubKeyPath = "$HOME\.ssh\vps_binance.pub"
if (Test-Path $pubKeyPath) {
    $pubKey = Get-Content $pubKeyPath
    Set-Clipboard $pubKey
    
    Show-Step -Number 2 -Title "Upload SSH Public Key" `
        -Description "Your public key has been COPIED TO CLIPBOARD.`nNow paste it on the VPS." `
        -Commands @(
            "ssh root@$VpsIp",
            "mkdir -p ~/.ssh",
            "echo `"PASTE_KEY_HERE`" >> ~/.ssh/authorized_keys",
            "chmod 600 ~/.ssh/authorized_keys",
            "exit"
        ) `
        -Notes "Use Shift+Insert or Right-click to paste in SSH terminal"
} else {
    Write-Host "SSH key not found. Make sure Step 1 completed successfully." -ForegroundColor Yellow
    exit 1
}

# Step 3: Test SSH Key Auth
Show-Step -Number 3 -Title "Test SSH Key Authentication" `
    -Description "Verify you can connect without password." `
    -Commands @(
        "ssh -i $HOME\.ssh\vps_binance root@$VpsIp whoami"
    ) `
    -Notes "Should print 'root' without asking for password"

# Step 4: Create VPS setup script
Show-Step -Number 4 -Title "Create VPS Setup Script" `
    -Description "Creating setup script for VPS configuration..." `
    -Notes "Script will be created in deployment folder"

$setupScript = @'
#!/bin/bash
set -e

echo "Starting VPS setup..."

# Update system
echo "▶ Updating system..."
sudo dnf update -y
sudo dnf install -y epel-release

# Install tools
echo "▶ Installing tools..."
sudo dnf install -y git curl wget nano vim htop net-tools firewalld fail2ban

# Create deployment user
echo "▶ Creating deployment user..."
DEPLOY_USER="binance-trader"
DEPLOY_PASS="BinanceStrong$(openssl rand -hex 8)!"

if ! id "$DEPLOY_USER" &>/dev/null; then
    sudo useradd -m -s /bin/bash "$DEPLOY_USER"
    echo "$DEPLOY_USER:$DEPLOY_PASS" | sudo chpasswd
    sudo usermod -aG wheel "$DEPLOY_USER"
    echo "✓ User created: $DEPLOY_USER"
    echo "  Password: $DEPLOY_PASS"
    echo "  Save this password!"
fi

# Setup SSH for deployment user
echo "▶ Setting up SSH..."
sudo mkdir -p /home/$DEPLOY_USER/.ssh
sudo cp ~/.ssh/authorized_keys /home/$DEPLOY_USER/.ssh/
sudo chown -R $DEPLOY_USER:$DEPLOY_USER /home/$DEPLOY_USER/.ssh
sudo chmod 700 /home/$DEPLOY_USER/.ssh
sudo chmod 600 /home/$DEPLOY_USER/.ssh/authorized_keys

# Install Docker
echo "▶ Installing Docker..."
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $DEPLOY_USER

# Configure firewall
echo "▶ Configuring firewall..."
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --permanent --add-port=22/tcp
sudo firewall-cmd --permanent --add-port=2222/tcp
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

# Setup fail2ban
echo "▶ Setting up fail2ban..."
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Create app directory
echo "▶ Creating application directory..."
sudo mkdir -p /opt/binance-traders
sudo chown -R $DEPLOY_USER:$DEPLOY_USER /opt/binance-traders

# SELinux permissive for Docker
echo "▶ Configuring SELinux..."
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

echo ""
echo "✓ VPS Setup Complete!"
echo ""
echo "Deployment User: $DEPLOY_USER"
echo "Password: $DEPLOY_PASS (SAVE THIS!)"
echo "Application Dir: /opt/binance-traders"
echo ""
'@

$setupScriptPath = "scripts\deployment\vps-setup-centos.sh"
$setupScript | Out-File -FilePath $setupScriptPath -Encoding UTF8 -NoNewline

Write-Host "Setup script created: $setupScriptPath" -ForegroundColor Green

# Step 5: Upload and run setup script
$setupScriptPath = Resolve-Path $setupScriptPath
Show-Step -Number 5 -Title "Upload and Run VPS Setup" `
    -Description "Upload the setup script and execute it on the VPS." `
    -Commands @(
        "scp -i $HOME\.ssh\vps_binance `"$setupScriptPath`" root@${VpsIp}:/tmp/setup.sh",
        "ssh -i $HOME\.ssh\vps_binance root@$VpsIp",
        "chmod +x /tmp/setup.sh",
        "sudo /tmp/setup.sh | tee setup.log",
        "# SAVE THE PASSWORD SHOWN!",
        "exit"
    ) `
    -Notes "The script will show the deployment user password - SAVE IT!"

# Step 6: Setup age encryption
Show-Step -Number 6 -Title "Generate Age Encryption Keys" `
    -Description "Create encryption keys for secrets management." `
    -Commands @(
        "age-keygen -o age-key.txt",
        "# Copy the public key shown (age1...)"
    ) `
    -Notes "If age not installed: choco install age"

# Step 7: Configure SOPS
Show-Step -Number 7 -Title "Configure SOPS" `
    -Description "Update SOPS configuration with your age public key." `
    -Commands @(
        "notepad .sops.yaml",
        "# Replace age1xxxx with your actual public key from previous step"
    ) `
    -Notes "The public key starts with 'age1...'"

# Step 8: Generate secrets
Show-Step -Number 8 -Title "Generate Secrets" `
    -Description "Generate strong passwords and API keys." `
    -Commands @(
        ".\scripts\security\setup-secrets.ps1 -GenerateApiKeys",
        "# Copy the generated values"
    )

# Step 9: Create environment file
Show-Step -Number 9 -Title "Create Environment File" `
    -Description "Create testnet.env from template and fill in values." `
    -Commands @(
        "Copy-Item testnet.env.template testnet.env",
        "notepad testnet.env",
        "# Fill in:",
        "#   - Binance API keys",
        "#   - Generated passwords from step 8",
        "#   - Your domain name"
    )

# Step 10: Encrypt secrets
Show-Step -Number 10 -Title "Encrypt Secrets" `
    -Description "Encrypt the environment file with SOPS." `
    -Commands @(
        ".\scripts\security\encrypt-secrets.ps1",
        "Remove-Item testnet.env -Force",
        "# Plaintext deleted, encrypted version (testnet.env.enc) is safe"
    )

# Step 11: Upload to VPS
Show-Step -Number 11 -Title "Upload Application to VPS" `
    -Description "Transfer the entire application to VPS." `
    -Commands @(
        "scp -i $HOME\.ssh\vps_binance age-key.txt $DeploymentUser@${VpsIp}:~/",
        "scp -i $HOME\.ssh\vps_binance -r . $DeploymentUser@${VpsIp}:/opt/binance-traders/",
        "# This may take several minutes..."
    ) `
    -Notes "Excludes target/ and node_modules/ automatically via .gitignore"

# Step 12: Deploy on VPS
Show-Step -Number 12 -Title "Deploy Application" `
    -Description "Execute deployment on the VPS." `
    -Commands @(
        "ssh -i $HOME\.ssh\vps_binance $DeploymentUser@$VpsIp",
        "cd /opt/binance-traders",
        "export SOPS_AGE_KEY_FILE=`$HOME/age-key.txt",
        "sops -d testnet.env.enc > testnet.env",
        "chmod 600 testnet.env",
        "chmod +x scripts/deployment/quick-deploy.sh",
        "./scripts/deployment/quick-deploy.sh",
        "# Wait for deployment to complete..."
    )

# Step 13: Verify
Show-Step -Number 13 -Title "Verify Deployment" `
    -Description "Check that all services are running correctly." `
    -Commands @(
        "# On VPS (should still be connected):",
        "docker compose -f docker-compose-testnet.yml ps",
        "curl http://localhost/health",
        "docker compose -f docker-compose-testnet.yml logs nginx-gateway-testnet"
    )

# Step 14: Create SSH config
Show-Step -Number 14 -Title "Create SSH Config" `
    -Description "Add convenient SSH alias." `
    -Commands @(
        "notepad $HOME\.ssh\config",
        "# Add these lines:",
        "# Host binance-vps",
        "#     HostName $VpsIp",
        "#     User $DeploymentUser",
        "#     IdentityFile $HOME\.ssh\vps_binance",
        "#     Port 22"
    ) `
    -Notes "After this, you can connect with: ssh binance-vps"


# Final message
Write-Host " 
Write-Host =============================================================== -ForegroundColor Cyan
Write-Host   Deployment Guide Complete! -ForegroundColor Green
Write-Host =============================================================== -ForegroundColor Cyan
Write-Host 

Write-Host What is Next: -ForegroundColor Yellow
Write-Host 

Write-Host 1. Access Your Services: -ForegroundColor Green
Write-Host    - Health: http://145.223.70.118/health
Write-Host    - Grafana: http://145.223.70.118/grafana/
Write-Host    - API: http://145.223.70.118/api/
Write-Host 

Write-Host 2. Setup Domain and TLS: -ForegroundColor Green
Write-Host    - Point your domain to 145.223.70.118
Write-Host    - Run: sudo certbot certonly --standalone -d your-domain.com
Write-Host    - Copy certificates to nginx/ssl/
Write-Host 

Write-Host 3. Harden SSH: -ForegroundColor Green
Write-Host    - Change SSH port to 2222
Write-Host    - Disable password authentication
Write-Host    - Disable root login
Write-Host 

Write-Host 4. Monitor Security: -ForegroundColor Green
Write-Host    - Grafana Security Dashboard: http://145.223.70.118/grafana/d/security-monitoring
Write-Host    - Prometheus Alerts: http://145.223.70.118/prometheus/alerts
Write-Host 

Write-Host 5. Run Security Tests: -ForegroundColor Green
Write-Host    scripts\security\test-security-controls.ps1 -RemoteHost 145.223.70.118
Write-Host 

Write-Host Documentation: -ForegroundColor Yellow
Write-Host - Full Guide: scripts/deployment/DEPLOYMENT_GUIDE.md
Write-Host - Security Guide: binance-ai-traders/guides/PUBLIC_DEPLOYMENT_SECURITY_GUIDE.md
Write-Host - VPS Setup: binance-ai-traders/guides/VPS_SETUP_GUIDE.md
Write-Host 

Write-Host You are ready to deploy! -ForegroundColor Green
Write-Host 

exit 0
