# Automated Deployment Guide

## Quick Start - Automated Deployment to 145.223.70.118

Your VPS is ready for automated deployment! Follow these steps:

### Prerequisites

**On Your Local Machine:**
- PowerShell 7+
- OpenSSH client
- SOPS (`choco install sops`)
- age (`choco install age`)
- Git

### Step 1: Run Automated Deployment Script

```powershell
# From repository root
cd C:\Projects\binance-ai-traders

# Run automated deployment
.\scripts\deployment\deploy-to-vps-automated.ps1 -VpsPassword "6Shmjl022X"
```

This script will:
- ✓ Generate SSH keys
- ✓ Create VPS setup script
- ✓ Guide you through manual steps (SSH password limitations on Windows)
- ✓ Create SSH config for easy access

### Step 2: Complete VPS Setup

The script will prompt you to run these commands manually:

```powershell
# Upload setup script (when prompted)
scp C:\Users\YourUser\AppData\Local\Temp\vps-setup.sh root@145.223.70.118:/tmp/

# Execute setup script (when prompted)
ssh root@145.223.70.118 "chmod +x /tmp/vps-setup.sh && sudo /tmp/vps-setup.sh"
```

**What the VPS setup does:**
- Updates system packages (CentOS 9.3)
- Installs Docker, fail2ban, firewalld
- Creates deployment user (binance-trader)
- Configures firewall (allows 22, 2222, 80, 443)
- Blocks direct service port access
- Sets up application directory

### Step 3: Generate and Encrypt Secrets

```powershell
# Generate age encryption keys
age-keygen -o age-key.txt
# Save the public key shown (age1...)

# Update .sops.yaml with your age public key
notepad .sops.yaml
# Replace age1xxxx... with your actual public key

# Generate strong passwords and API keys
.\scripts\security\setup-secrets.ps1 -GenerateApiKeys

# Create testnet.env from template
cp testnet.env.template testnet.env

# Edit testnet.env and fill in:
# - Binance testnet API keys
# - Generated passwords (from setup-secrets.ps1)
# - Domain name
notepad testnet.env

# Encrypt secrets
.\scripts\security\encrypt-secrets.ps1

# Delete plaintext (encrypted version is safe)
Remove-Item testnet.env
```

### Step 4: Upload Application to VPS

```powershell
# After VPS setup is complete, connect with SSH keys
ssh binance-vps
# Should connect without password!

# Exit and upload files from local machine
exit

# Upload entire repository
scp -r . binance-vps:/opt/binance-traders/

# Or use rsync for faster transfer
# rsync -avz --exclude 'target' --exclude 'node_modules' . binance-vps:/opt/binance-traders/
```

### Step 5: Deploy Application on VPS

```bash
# Connect to VPS
ssh binance-vps

# Navigate to application directory
cd /opt/binance-traders

# Set age key for decryption
export SOPS_AGE_KEY_FILE=$HOME/age-key.txt

# Copy your age-key.txt to VPS first:
# On local machine: scp age-key.txt binance-vps:~/

# Decrypt secrets
sops -d testnet.env.enc > testnet.env
chmod 600 testnet.env

# Run quick deployment script
chmod +x scripts/deployment/quick-deploy.sh
./scripts/deployment/quick-deploy.sh
```

### Step 6: Verify Deployment

```bash
# Check all services are running
docker compose -f docker-compose-testnet.yml ps

# Test health endpoint
curl http://localhost/health

# View logs
docker compose -f docker-compose-testnet.yml logs -f nginx-gateway-testnet
```

### Step 7: Configure Domain and TLS

**Option A: Let's Encrypt (Recommended for production)**

```bash
# Install certbot
sudo dnf install -y certbot

# Stop nginx temporarily
docker compose -f docker-compose-testnet.yml stop nginx-gateway-testnet

# Obtain certificate
sudo certbot certonly --standalone -d your-domain.com

# Copy certificates
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem nginx/ssl/key.pem
sudo chown binance-trader:binance-trader nginx/ssl/*.pem

# Restart nginx
docker compose -f docker-compose-testnet.yml start nginx-gateway-testnet

# Setup auto-renewal
sudo crontab -e
# Add: 0 3 * * * certbot renew --quiet && docker compose -f /opt/binance-traders/docker-compose-testnet.yml restart nginx-gateway-testnet
```

**Option B: Self-signed (Testnet only)**

The quick-deploy.sh script already generates a self-signed certificate if none exists.

### Step 8: Harden SSH (After Everything Works)

```bash
# On VPS, edit SSH config
sudo nano /etc/ssh/sshd_config

# Change these lines:
Port 2222
PermitRootLogin no
PasswordAuthentication no

# Test config
sudo sshd -t

# Restart SSH
sudo systemctl restart sshd

# Update firewall
sudo firewall-cmd --permanent --remove-port=22/tcp
sudo firewall-cmd --reload
```

**Update local SSH config:**

```powershell
# Edit SSH config
notepad $HOME\.ssh\config

# Change Port from 22 to 2222 in binance-vps entry
```

### Step 9: Run Security Tests

```powershell
# On local machine
.\scripts\security\test-security-controls.ps1 -RemoteHost 145.223.70.118 -Domain your-domain.com

# Import Postman collection
# File: postman/Security-Tests-Collection.json
# Update variables: base_url, domain, API keys
# Run all tests
```

### Step 10: Access Services

**Grafana Security Dashboard:**
```
https://your-domain.com/grafana/d/security-monitoring
Username: admin
Password: (from testnet.env GF_SECURITY_ADMIN_PASSWORD)
```

**Prometheus Alerts:**
```
https://your-domain.com/prometheus/alerts
(requires authentication with API key)
```

## Troubleshooting

### SSH Connection Issues

```bash
# If you get locked out:
# 1. Use VPS provider console/KVM access
# 2. Temporarily re-enable password auth
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd
```

### Docker Issues

```bash
# Check Docker status
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Check logs
docker compose -f docker-compose-testnet.yml logs
```

### Service Not Starting

```bash
# Check specific service logs
docker compose -f docker-compose-testnet.yml logs <service-name>

# Restart specific service
docker compose -f docker-compose-testnet.yml restart <service-name>

# Force rebuild
docker compose -f docker-compose-testnet.yml up -d --build <service-name>
```

### Firewall Issues

```bash
# Check firewall status
sudo firewall-cmd --list-all

# Temporarily disable (CAUTION!)
sudo systemctl stop firewalld

# Re-enable
sudo systemctl start firewalld
```

## Quick Reference

**VPS Details:**
- IP: 145.223.70.118
- User: binance-trader
- SSH: `ssh binance-vps` (after setup)
- App Dir: /opt/binance-traders

**Key Files:**
- docker-compose-testnet.yml - Service definitions
- testnet.env.enc - Encrypted secrets (safe to commit)
- nginx/nginx.conf - Reverse proxy config
- age-key.txt - Encryption key (NEVER commit!)

**Useful Commands:**
```bash
# Start services
docker compose -f docker-compose-testnet.yml up -d

# Stop services
docker compose -f docker-compose-testnet.yml down

# View logs
docker compose -f docker-compose-testnet.yml logs -f

# Restart single service
docker compose -f docker-compose-testnet.yml restart nginx-gateway-testnet

# Check health
curl http://localhost/health

# View running containers
docker ps

# Check firewall
sudo firewall-cmd --list-all
```

## Support

Refer to complete documentation:
- `binance-ai-traders/guides/PUBLIC_DEPLOYMENT_SECURITY_GUIDE.md`
- `binance-ai-traders/guides/VPS_SETUP_GUIDE.md`
- `binance-ai-traders/guides/SECURITY_VERIFICATION_CHECKLIST.md`

---

**Next:** After deployment, monitor the Grafana security dashboard and review Prometheus alerts regularly!

