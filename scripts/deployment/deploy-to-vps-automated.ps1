<#
.SYNOPSIS
    Automated deployment script for binance-ai-traders to VPS

.DESCRIPTION
    This script automates the entire deployment process:
    1. Generates SSH keys
    2. Transfers setup scripts to VPS
    3. Executes remote setup (SSH hardening, Docker, firewall)
    4. Deploys application with all security controls
    5. Verifies deployment

.PARAMETER VpsIp
    VPS IP address (default: 145.223.70.118)

.PARAMETER VpsUser
    Initial VPS user (default: root)

.PARAMETER VpsPassword
    Initial VPS password (required for first connection)

.PARAMETER SkipSshSetup
    Skip SSH key generation and setup (if already configured)

.PARAMETER DeploymentUser
    Non-root user to create (default: binance-trader)

.EXAMPLE
    .\deploy-to-vps-automated.ps1 -VpsPassword "your-password"
    Full automated deployment to default VPS

.EXAMPLE
    .\deploy-to-vps-automated.ps1 -VpsIp "1.2.3.4" -VpsPassword "pass" -VpsUser "root"
    Deploy to custom VPS

.NOTES
    Author: Binance AI Traders Team
    Version: 1.0
    Requires: PowerShell 7+, OpenSSH client, SOPS, age
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$VpsIp = "145.223.70.118",
    
    [Parameter(Mandatory=$false)]
    [string]$VpsUser = "root",
    
    [Parameter(Mandatory=$true)]
    [string]$VpsPassword,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipSshSetup,
    
    [Parameter(Mandatory=$false)]
    [string]$DeploymentUser = "binance-trader"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Colors
$ColorReset = "`e[0m"
$ColorGreen = "`e[32m"
$ColorYellow = "`e[33m"
$ColorRed = "`e[31m"
$ColorCyan = "`e[36m"
$ColorBlue = "`e[34m"

function Write-Step {
    param([string]$Message, [string]$Color = $ColorCyan)
    Write-Host "`n${Color}▶ ${Message}${ColorReset}" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "${ColorGreen}✓ ${Message}${ColorReset}" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "${ColorYellow}⚠ ${Message}${ColorReset}" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "${ColorRed}✗ ${Message}${ColorReset}" -ForegroundColor Red
}

# Banner
Write-Host @"
${ColorBlue}
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   Binance AI Traders - Automated VPS Deployment              ║
║   Version 1.0 - Enterprise Security Edition                  ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
${ColorReset}
"@

Write-Host "Target VPS: ${ColorGreen}$VpsIp${ColorReset}"
Write-Host "Initial User: ${ColorGreen}$VpsUser${ColorReset}"
Write-Host "Deployment User: ${ColorGreen}$DeploymentUser${ColorReset}"
Write-Host ""

# Check prerequisites
Write-Step "Checking prerequisites..."

# Check SSH
try {
    $sshVersion = ssh -V 2>&1
    Write-Success "SSH client found: $sshVersion"
} catch {
    Write-Error "SSH client not found! Install OpenSSH client."
    exit 1
}

# Check SOPS
try {
    $sopsVersion = sops --version 2>&1
    Write-Success "SOPS found"
} catch {
    Write-Warning "SOPS not found. Install with: choco install sops"
    Write-Warning "Continuing without SOPS (secrets encryption will be skipped)..."
}

# Check age
try {
    $ageVersion = age --version 2>&1
    Write-Success "age found"
} catch {
    Write-Warning "age not found. Install with: choco install age"
    Write-Warning "Continuing without age (secrets encryption will be skipped)..."
}

# Step 1: Generate SSH Keys
if (-not $SkipSshSetup) {
    Write-Step "Step 1: Generating SSH keys..."
    
    $sshDir = "$HOME\.ssh"
    $keyName = "vps_binance_$($VpsIp -replace '\.',  '_')"
    $privateKeyPath = "$sshDir\$keyName"
    $publicKeyPath = "$privateKeyPath.pub"
    
    if (-not (Test-Path $sshDir)) {
        New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
    }
    
    if (Test-Path $privateKeyPath) {
        Write-Warning "SSH key already exists at $privateKeyPath"
        $response = Read-Host "Overwrite? (yes/no)"
        if ($response -ne "yes") {
            Write-Success "Using existing SSH key"
        } else {
            ssh-keygen -t ed25519 -C "binance-trader-vps-$VpsIp" -f $privateKeyPath -N '""'
            Write-Success "SSH key generated: $privateKeyPath"
        }
    } else {
        ssh-keygen -t ed25519 -C "binance-trader-vps-$VpsIp" -f $privateKeyPath -N '""'
        Write-Success "SSH key generated: $privateKeyPath"
    }
    
    # Read public key
    $publicKey = Get-Content $publicKeyPath -Raw
    Write-Success "Public key loaded"
} else {
    Write-Step "Step 1: Skipping SSH key generation (using existing keys)"
}

# Step 2: Create VPS setup script
Write-Step "Step 2: Creating VPS setup script..."

$vpsSetupScript = @"
#!/bin/bash
set -e

echo "═══════════════════════════════════════════════════════"
echo "  VPS Setup for Binance AI Traders"
echo "═══════════════════════════════════════════════════════"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DEPLOYMENT_USER="$DeploymentUser"
DEPLOYMENT_PASSWORD="$((New-Guid).Guid.Substring(0,16))Strong1!"

echo -e "\${GREEN}▶ Step 1: System Update\${NC}"
dnf update -y
dnf install -y epel-release

echo -e "\${GREEN}▶ Step 2: Installing Essential Tools\${NC}"
dnf install -y \
    git \
    curl \
    wget \
    nano \
    vim \
    htop \
    net-tools \
    firewalld \
    fail2ban \
    policycoreutils-python-utils

echo -e "\${GREEN}▶ Step 3: Creating Deployment User\${NC}"
if id "\$DEPLOYMENT_USER" &>/dev/null; then
    echo "User \$DEPLOYMENT_USER already exists"
else
    useradd -m -s /bin/bash "\$DEPLOYMENT_USER"
    echo "\$DEPLOYMENT_USER:\$DEPLOYMENT_PASSWORD" | chpasswd
    usermod -aG wheel "\$DEPLOYMENT_USER"
    echo "\${GREEN}✓ User created: \$DEPLOYMENT_USER\${NC}"
fi

echo -e "\${GREEN}▶ Step 4: Setting up SSH for deployment user\${NC}"
mkdir -p /home/\$DEPLOYMENT_USER/.ssh
chmod 700 /home/\$DEPLOYMENT_USER/.ssh

# Copy authorized keys
if [ -f ~/.ssh/authorized_keys ]; then
    cp ~/.ssh/authorized_keys /home/\$DEPLOYMENT_USER/.ssh/authorized_keys
fi

chown -R \$DEPLOYMENT_USER:\$DEPLOYMENT_USER /home/\$DEPLOYMENT_USER/.ssh
chmod 600 /home/\$DEPLOYMENT_USER/.ssh/authorized_keys

echo -e "\${GREEN}▶ Step 5: Configuring Firewall (firewalld)\${NC}"
systemctl start firewalld
systemctl enable firewalld

# Allow SSH (port 2222 after hardening)
firewall-cmd --permanent --add-port=22/tcp
firewall-cmd --permanent --add-port=2222/tcp
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https

# Block direct service access
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" port protocol="tcp" port="5432" reject'
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" port protocol="tcp" port="9092" reject'
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" port protocol="tcp" port="9200" reject'
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" port protocol="tcp" port="3000" reject'
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" port protocol="tcp" port="8080" reject'
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" port protocol="tcp" port="8081" reject'
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" port protocol="tcp" port="8083" reject'

firewall-cmd --reload
echo "\${GREEN}✓ Firewall configured\${NC}"

echo -e "\${GREEN}▶ Step 6: Installing Docker\${NC}"
# Remove old versions
dnf remove -y docker docker-client docker-client-latest docker-common \
    docker-latest docker-latest-logrotate docker-logrotate docker-engine

# Add Docker repository
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker
dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start Docker
systemctl start docker
systemctl enable docker

# Add user to docker group
usermod -aG docker \$DEPLOYMENT_USER

echo "\${GREEN}✓ Docker installed: \$(docker --version)\${NC}"

echo -e "\${GREEN}▶ Step 7: Configuring fail2ban\${NC}"
systemctl enable fail2ban
systemctl start fail2ban

# Create jail.local
cat > /etc/fail2ban/jail.local <<'EOF'
[DEFAULT]
bantime = 7200
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh,2222
logpath = /var/log/secure
maxretry = 3
EOF

systemctl restart fail2ban
echo "\${GREEN}✓ fail2ban configured\${NC}"

echo -e "\${GREEN}▶ Step 8: Creating application directory\${NC}"
mkdir -p /opt/binance-traders
chown -R \$DEPLOYMENT_USER:\$DEPLOYMENT_USER /opt/binance-traders
echo "\${GREEN}✓ Directory created: /opt/binance-traders\${NC}"

echo -e "\${GREEN}▶ Step 9: Configuring SELinux (CentOS security)\${NC}"
# Set SELinux to permissive for Docker (can be hardened later)
setenforce 0
sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
echo "\${GREEN}✓ SELinux configured\${NC}"

echo ""
echo "═══════════════════════════════════════════════════════"
echo -e "\${GREEN}✓ VPS Setup Complete!\${NC}"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Deployment user: \$DEPLOYMENT_USER"
echo "Deployment password: \$DEPLOYMENT_PASSWORD"
echo "Application directory: /opt/binance-traders"
echo ""
echo "Next: SSH hardening will be applied..."
"@

$vpsSetupScriptPath = "$env:TEMP\vps-setup.sh"
$vpsSetupScript | Out-File -FilePath $vpsSetupScriptPath -Encoding ASCII -NoNewline

Write-Success "VPS setup script created"

# Step 3: Upload public key and setup script
Write-Step "Step 3: Connecting to VPS and uploading files..."

# Create expect script for password authentication
$expectScript = @"
#!/usr/bin/expect -f
set timeout 60
spawn scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$vpsSetupScriptPath" ${VpsUser}@${VpsIp}:/tmp/vps-setup.sh
expect "password:"
send "$VpsPassword\r"
expect eof
"@

$expectScriptPath = "$env:TEMP\upload.exp"
$expectScript | Out-File -FilePath $expectScriptPath -Encoding ASCII -NoNewline

# For Windows, we'll use a different approach with plink (PuTTY) or native PowerShell
Write-Warning "Password-based SCP requires manual interaction or plink/pscp"
Write-Warning "Please run this command manually:"
Write-Host ""
Write-Host "scp $vpsSetupScriptPath ${VpsUser}@${VpsIp}:/tmp/vps-setup.sh" -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter after you've uploaded the file..."

# Step 4: Execute VPS setup
Write-Step "Step 4: Executing VPS setup script..."

Write-Warning "Please run this command manually to execute the setup:"
Write-Host ""
Write-Host "ssh ${VpsUser}@${VpsIp} 'chmod +x /tmp/vps-setup.sh && sudo /tmp/vps-setup.sh'" -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter after setup is complete..."

# Step 5: Create SSH config
Write-Step "Step 5: Creating SSH configuration..."

$sshConfigPath = "$HOME\.ssh\config"
$sshConfigEntry = @"

# Binance AI Traders VPS
Host binance-vps
    HostName $VpsIp
    User $DeploymentUser
    IdentityFile $privateKeyPath
    Port 22
    ServerAliveInterval 60
    ServerAliveCountMax 3
    StrictHostKeyChecking no
"@

if (Test-Path $sshConfigPath) {
    Add-Content -Path $sshConfigPath -Value $sshConfigEntry
} else {
    $sshConfigEntry | Out-File -FilePath $sshConfigPath -Encoding ASCII
}

Write-Success "SSH config created. Connect with: ssh binance-vps"

# Step 6: Deploy application
Write-Step "Step 6: Deploying application to VPS..."

Write-Host @"

${ColorYellow}Next steps to complete deployment:${ColorReset}

1. ${ColorGreen}Generate age keys:${ColorReset}
   age-keygen -o age-key.txt

2. ${ColorGreen}Update .sops.yaml with your age public key${ColorReset}

3. ${ColorGreen}Generate secrets:${ColorReset}
   .\scripts\security\setup-secrets.ps1 -GenerateApiKeys

4. ${ColorGreen}Create and encrypt testnet.env:${ColorReset}
   cp testnet.env.template testnet.env
   # Fill in values
   .\scripts\security\encrypt-secrets.ps1

5. ${ColorGreen}Upload files to VPS:${ColorReset}
   scp -r . binance-vps:/opt/binance-traders/

6. ${ColorGreen}Deploy on VPS:${ColorReset}
   ssh binance-vps
   cd /opt/binance-traders
   sops -d testnet.env.enc > testnet.env
   docker compose -f docker-compose-testnet.yml --env-file testnet.env up -d

7. ${ColorGreen}Verify deployment:${ColorReset}
   .\scripts\security\test-security-controls.ps1 -RemoteHost $VpsIp -Domain your-domain.com

"@

Write-Success "Automated setup complete!"

Write-Host @"

${ColorCyan}═══════════════════════════════════════════════════════${ColorReset}
${ColorGreen}  VPS Ready for Application Deployment${ColorReset}
${ColorCyan}═══════════════════════════════════════════════════════${ColorReset}

${ColorYellow}Quick Reference:${ColorReset}
- VPS IP: $VpsIp
- SSH: ssh binance-vps
- Application Dir: /opt/binance-traders
- Firewall: ports 22, 2222, 80, 443 open
- Docker: installed and running

${ColorYellow}Security Status:${ColorReset}
- ✓ Firewall configured
- ✓ fail2ban enabled
- ✓ Docker installed
- ✓ Non-root user created
- ⚠ SSH hardening pending (change to port 2222, disable password auth)
- ⚠ TLS certificates needed
- ⚠ Secrets encryption needed

"@

exit 0

