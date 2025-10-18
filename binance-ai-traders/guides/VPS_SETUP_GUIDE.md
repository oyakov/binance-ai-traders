# VPS Setup Guide for Binance AI Traders

## Overview

This guide provides step-by-step instructions for setting up a secure VPS (Virtual Private Server) or dedicated server for deploying the binance-ai-traders M1 testnet in a public environment.

## Prerequisites

- VPS with minimum specifications:
  - **CPU:** 4 cores
  - **RAM:** 8GB minimum, 16GB recommended
  - **Storage:** 100GB SSD
  - **OS:** Centos 9.3
  - **Network:** Public IP address, 1Gbps connection
- Initial root or sudo access
- VPS provider control panel access

## Phase 1: Initial VPS Provisioning

### 1.1 First Login with Password

When you receive your VPS credentials:

```bash
# Connect with password (first time)
ssh root@<VPS_IP>
# or
ssh username@<VPS_IP>

# Enter password when prompted
```

### 1.2 Immediate Security Steps

**Update System Packages:**
```bash
# Update package lists
sudo apt-get update

# Upgrade all packages
sudo apt-get upgrade -y

# Upgrade distribution
sudo apt-get dist-upgrade -y

# Install essential security tools
sudo apt-get install -y \
    ufw \
    fail2ban \
    unattended-upgrades \
    apt-listchanges \
    vim \
    curl \
    wget \
    git \
    htop \
    net-tools
```

**Change Default Password (if using root):**
```bash
passwd
# Enter new strong password (32+ characters)
```

### 1.3 Create Non-Root User

```bash
# Create deployment user
adduser binance-trader
# Enter strong password and details

# Add to sudo group
usermod -aG sudo binance-trader

# Verify sudo access
su - binance-trader
sudo whoami  # Should output: root
```

## Phase 2: SSH Hardening

### 2.1 Generate SSH Key Pair (Local Machine)

**On your local Windows machine:**
```powershell
# Create .ssh directory if not exists
mkdir -Force $HOME\.ssh

# Generate ED25519 key (recommended)
ssh-keygen -t ed25519 -C "binance-trader-vps" -f $HOME\.ssh\vps_binance_trader

# If ED25519 not supported, use RSA 4096
ssh-keygen -t rsa -b 4096 -C "binance-trader-vps" -f $HOME\.ssh\vps_binance_trader

# This creates two files:
# - vps_binance_trader (private key - NEVER share)
# - vps_binance_trader.pub (public key - safe to share)
```

**Set correct permissions on private key:**
```powershell
# Windows PowerShell
icacls $HOME\.ssh\vps_binance_trader /inheritance:r
icacls $HOME\.ssh\vps_binance_trader /grant:r "$($env:USERNAME):(R)"
```

### 2.2 Copy Public Key to VPS

**Method 1: Using ssh-copy-id (if available)**
```powershell
# From local machine
ssh-copy-id -i $HOME\.ssh\vps_binance_trader.pub binance-trader@<VPS_IP>
```

**Method 2: Manual copy (Windows)**
```powershell
# Copy public key content
Get-Content $HOME\.ssh\vps_binance_trader.pub | Set-Clipboard

# Connect to VPS with password
ssh binance-trader@<VPS_IP>

# On VPS, create .ssh directory
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Create authorized_keys file
nano ~/.ssh/authorized_keys
# Paste the public key content (Ctrl+Shift+V)
# Save and exit (Ctrl+X, Y, Enter)

# Set correct permissions
chmod 600 ~/.ssh/authorized_keys

# Exit VPS
exit
```

### 2.3 Test SSH Key Authentication

```powershell
# From local machine, test key-based auth
ssh -i $HOME\.ssh\vps_binance_trader binance-trader@<VPS_IP>

# Should login without password prompt
```

**Create SSH config for convenience:**
```powershell
# Edit SSH config
notepad $HOME\.ssh\config
```

Add configuration:
```
Host binance-vps
    HostName <VPS_IP>
    User binance-trader
    IdentityFile ~\.ssh\vps_binance_trader
    Port 22
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

Now you can connect with:
```powershell
ssh binance-vps
```

### 2.4 Configure SSH Server Security

**On VPS, edit SSH configuration:**
```bash
sudo nano /etc/ssh/sshd_config
```

**Recommended SSH configuration:**
```bash
# Change SSH port (use non-standard port)
Port 2222

# Authentication
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no
PermitEmptyPasswords no

# Key authentication only
AuthenticationMethods publickey

# Limit user access
AllowUsers binance-trader

# Security settings
MaxAuthTries 3
MaxSessions 2
LoginGraceTime 30
ClientAliveInterval 300
ClientAliveCountMax 2

# Disable unused features
X11Forwarding no
AllowAgentForwarding no
AllowTcpForwarding no
PermitTunnel no

# Logging
SyslogFacility AUTH
LogLevel VERBOSE

# Strong cryptography
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
```

**Test configuration before restarting:**
```bash
sudo sshd -t
# Should output: no errors
```

**Restart SSH service:**
```bash
sudo systemctl restart sshd
```

**Important:** Keep your current SSH session open and test in a new terminal:
```powershell
# Update port in SSH config if changed
ssh -p 2222 -i $HOME\.ssh\vps_binance_trader binance-trader@<VPS_IP>
```

Only close the original session after confirming the new connection works!

## Phase 3: Firewall Configuration

### 3.1 Configure UFW (Uncomplicated Firewall)

```bash
# Reset firewall to default
sudo ufw --force reset

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (use your custom port)
sudo ufw allow 2222/tcp comment 'SSH'

# Allow HTTP/HTTPS
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'

# Deny direct access to service ports
sudo ufw deny 5432/tcp comment 'Block PostgreSQL'
sudo ufw deny 9092/tcp comment 'Block Kafka'
sudo ufw deny 9200/tcp comment 'Block Elasticsearch'
sudo ufw deny 3000/tcp comment 'Block Grafana'
sudo ufw deny 8080/tcp comment 'Block Services'
sudo ufw deny 8081/tcp comment 'Block Services'
sudo ufw deny 8083/tcp comment 'Block Services'

# Enable firewall
sudo ufw enable

# Verify status
sudo ufw status verbose

# Check numbered rules
sudo ufw status numbered
```

**Enable logging:**
```bash
sudo ufw logging medium
```

**View logs:**
```bash
sudo tail -f /var/log/ufw.log
```

## Phase 4: Fail2Ban Setup

### 4.1 Install and Configure fail2ban

```bash
# Install fail2ban
sudo apt-get install fail2ban -y

# Copy default config
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Edit configuration
sudo nano /etc/fail2ban/jail.local
```

**Configure jail.local:**
```ini
[DEFAULT]
# Ban settings
bantime = 7200        # 2 hours
findtime = 600        # 10 minutes
maxretry = 3          # 3 attempts
banaction = ufw       # Use UFW for banning

# Email notifications (optional)
destemail = admin@your-domain.com
sendername = Fail2Ban-BinanceVPS
mta = sendmail

# Action shortcuts
action = %(action_mwl)s

[sshd]
enabled = true
port = 2222           # Your SSH port
logpath = /var/log/auth.log
maxretry = 3
bantime = 7200
findtime = 600

[nginx-limit-req]
enabled = true
filter = nginx-limit-req
port = http,https
logpath = /var/log/nginx/error.log
maxretry = 5
findtime = 600
bantime = 3600

[nginx-noscript]
enabled = true
port = http,https
filter = nginx-noscript
logpath = /var/log/nginx/access.log
maxretry = 6
bantime = 3600

[nginx-badbots]
enabled = true
port = http,https
filter = nginx-badbots
logpath = /var/log/nginx/access.log
maxretry = 2
bantime = 86400       # 24 hours

[nginx-noproxy]
enabled = true
port = http,https
filter = nginx-noproxy
logpath = /var/log/nginx/access.log
maxretry = 2
bantime = 86400
```

**Start fail2ban:**
```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Check status
sudo fail2ban-client status

# Check specific jail
sudo fail2ban-client status sshd
```

### 4.2 Monitor Fail2Ban

```bash
# View banned IPs
sudo fail2ban-client status sshd

# Unban an IP
sudo fail2ban-client set sshd unbanip <IP_ADDRESS>

# View fail2ban logs
sudo tail -f /var/log/fail2ban.log
```

## Phase 5: Automatic Security Updates

### 5.1 Configure Unattended Upgrades

```bash
# Configure unattended-upgrades
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
```

**Configuration:**
```
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};

Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Automatic-Reboot-Time "03:00";
Unattended-Upgrade::SyslogEnable "true";
Unattended-Upgrade::Mail "admin@your-domain.com";
Unattended-Upgrade::MailReport "on-change";
```

**Enable automatic updates:**
```bash
sudo nano /etc/apt/apt.conf.d/20auto-upgrades
```

```
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
```

**Test configuration:**
```bash
sudo unattended-upgrades --dry-run --debug
```

## Phase 6: Docker Installation

### 6.1 Install Docker and Docker Compose

```bash
# Remove old versions
sudo apt-get remove docker docker-engine docker.io containerd runc

# Install dependencies
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Verify installation
sudo docker --version
sudo docker compose version
```

### 6.2 Configure Docker Security

```bash
# Add user to docker group
sudo usermod -aG docker binance-trader

# Create Docker daemon configuration
sudo mkdir -p /etc/docker
sudo nano /etc/docker/daemon.json
```

**Docker daemon.json:**
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "live-restore": true,
  "userland-proxy": false,
  "no-new-privileges": true,
  "icc": false,
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 64000,
      "Soft": 64000
    }
  }
}
```

**Restart Docker:**
```bash
sudo systemctl restart docker

# Verify Docker is running
sudo systemctl status docker

# Test Docker
docker run hello-world
```

### 6.3 Docker Security Best Practices

```bash
# Enable Docker security scanning (optional)
sudo apt-get install -y docker-scan-plugin

# Scan images for vulnerabilities
docker scan <image-name>
```

## Phase 7: System Hardening

### 7.1 Disable Unused Services

```bash
# List all services
systemctl list-unit-files --type=service

# Disable unused services (examples)
sudo systemctl disable bluetooth.service
sudo systemctl disable cups.service
sudo systemctl disable avahi-daemon.service

# Remove unnecessary packages
sudo apt-get autoremove -y
```

### 7.2 Kernel Security Parameters

```bash
# Edit sysctl configuration
sudo nano /etc/sysctl.conf
```

**Add security parameters:**
```bash
# IP Forwarding (needed for Docker)
net.ipv4.ip_forward = 1

# Prevent IP spoofing
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Disable ICMP redirect acceptance
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

# Disable source packet routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# Enable TCP SYN Cookie Protection
net.ipv4.tcp_syncookies = 1

# Enable bad error message protection
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Log Martian packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Reduce swappiness
vm.swappiness = 10

# File system hardening
fs.suid_dumpable = 0
kernel.randomize_va_space = 2
```

**Apply changes:**
```bash
sudo sysctl -p
```

### 7.3 Set File Permissions

```bash
# Secure sensitive files
sudo chmod 644 /etc/passwd
sudo chmod 644 /etc/group
sudo chmod 000 /etc/shadow
sudo chmod 000 /etc/gshadow

# Secure SSH directory
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

## Phase 8: Monitoring and Logging

### 8.1 Configure System Logging

```bash
# Install rsyslog (usually pre-installed)
sudo apt-get install rsyslog -y

# Configure log rotation
sudo nano /etc/logrotate.d/rsyslog
```

```
/var/log/syslog
/var/log/auth.log
{
    rotate 7
    daily
    missingok
    notifempty
    compress
    delaycompress
    postrotate
        /usr/lib/rsyslog/rsyslog-rotate
    endscript
}
```

### 8.2 Enable Audit Logging

```bash
# Install auditd
sudo apt-get install auditd -y

# Enable and start
sudo systemctl enable auditd
sudo systemctl start auditd

# View audit logs
sudo ausearch -m avc -ts recent
```

### 8.3 Monitor System Resources

```bash
# Install monitoring tools
sudo apt-get install -y htop iotop nethogs

# View real-time resource usage
htop

# Monitor network connections
sudo nethogs

# Check disk I/O
sudo iotop
```

## Phase 9: Backup Configuration

### 9.1 Setup Automated Backups

```bash
# Create backup directory
sudo mkdir -p /backups/binance-traders

# Create backup script
sudo nano /usr/local/bin/backup-binance-traders.sh
```

**Backup script:**
```bash
#!/bin/bash
BACKUP_DIR="/backups/binance-traders"
DATE=$(date +%Y%m%d_%H%M%S)

# Backup Docker volumes
docker run --rm \
  -v binance-ai-traders_postgres_testnet_data:/data \
  -v $BACKUP_DIR:/backup \
  alpine tar czf /backup/postgres_$DATE.tar.gz /data

# Backup configuration
tar czf $BACKUP_DIR/config_$DATE.tar.gz \
  /opt/binance-traders/docker-compose-testnet.yml \
  /opt/binance-traders/testnet.env.enc \
  /opt/binance-traders/nginx/

# Remove backups older than 30 days
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete

echo "Backup completed: $DATE"
```

**Make executable and add to cron:**
```bash
sudo chmod +x /usr/local/bin/backup-binance-traders.sh

# Add to crontab (daily at 2 AM)
sudo crontab -e
0 2 * * * /usr/local/bin/backup-binance-traders.sh >> /var/log/binance-backup.log 2>&1
```

## Phase 10: Final Verification

### 10.1 Security Verification Checklist

```bash
# Run comprehensive security check
sudo apt-get install -y lynis
sudo lynis audit system

# Check open ports
sudo ss -tulpn

# Verify firewall
sudo ufw status verbose

# Check fail2ban
sudo fail2ban-client status

# Verify SSH configuration
sudo sshd -T

# Check Docker security
docker info | grep -i security
```

### 10.2 Performance Baseline

```bash
# CPU info
lscpu

# Memory info
free -h

# Disk info
df -h

# Network interfaces
ip addr

# Test network speed
sudo apt-get install speedtest-cli -y
speedtest-cli
```

## Ongoing Maintenance

### Daily Tasks
- Check system logs: `sudo journalctl -p err -S today`
- Monitor resource usage: `htop`
- Check fail2ban status: `sudo fail2ban-client status`

### Weekly Tasks
- Review security logs: `sudo cat /var/log/auth.log | grep Failed`
- Check disk space: `df -h`
- Review Docker logs: `docker compose logs --tail 100`

### Monthly Tasks
- Update system: `sudo apt-get update && sudo apt-get upgrade`
- Review and rotate logs
- Test backup restoration
- Security audit with lynis

## Troubleshooting

### SSH Connection Issues

```bash
# Check SSH service
sudo systemctl status sshd

# View SSH logs
sudo tail -f /var/log/auth.log

# Test SSH config
sudo sshd -t

# Restart SSH
sudo systemctl restart sshd
```

### Firewall Issues

```bash
# Temporarily disable (CAUTION!)
sudo ufw disable

# Re-enable
sudo ufw enable

# Reset firewall
sudo ufw reset
```

### Docker Issues

```bash
# Check Docker service
sudo systemctl status docker

# View Docker logs
sudo journalctl -u docker -f

# Restart Docker
sudo systemctl restart docker
```

## Emergency Access

If you lose SSH access:

1. **Use VPS provider console** (KVM/VNC access)
2. **Reset firewall:** `sudo ufw disable`
3. **Check SSH config:** `sudo nano /etc/ssh/sshd_config`
4. **Temporarily enable password auth** (for recovery only)
5. **Fix issues and re-enable key-based auth**

## Document Information

**Version:** 1.0  
**Last Updated:** 2025-10-18  
**Tested On:** Ubuntu 22.04 LTS  
**Owner:** Infrastructure Team

---

**Next Steps:** After completing this setup, proceed to [PUBLIC_DEPLOYMENT_SECURITY_GUIDE.md](PUBLIC_DEPLOYMENT_SECURITY_GUIDE.md) for application deployment.

