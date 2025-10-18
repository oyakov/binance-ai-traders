#!/bin/bash
#
# Emergency VPS Setup Script for CentOS 9.3
# Sets up a fresh VPS with all required components
#
# Usage: ssh root@VPS 'bash -s' < emergency-vps-setup.sh
# Or: scp emergency-vps-setup.sh root@VPS:/tmp/ && ssh root@VPS 'bash /tmp/emergency-vps-setup.sh'
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
DEPLOYMENT_USER="binance-trader"
DEPLOYMENT_PASSWORD="BinanceStrong$(openssl rand -hex 8)!"
APP_DIR="/opt/binance-traders"

echo -e "${CYAN}================================================================${NC}"
echo -e "${GREEN} Emergency VPS Setup for Binance AI Traders${NC}"
echo -e "${GREEN} CentOS 9.3 / RHEL-based systems${NC}"
echo -e "${CYAN}================================================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}ERROR: This script must be run as root${NC}"
    exit 1
fi

echo -e "${GREEN}Step 1: System Update${NC}"
dnf update -y
dnf install -y epel-release

echo -e "${GREEN}Step 2: Installing Essential Tools${NC}"
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
    policycoreutils-python-utils \
    tar \
    unzip \
    openssl

echo -e "${GREEN}Step 3: Creating Deployment User${NC}"
if id "$DEPLOYMENT_USER" &>/dev/null; then
    echo -e "${YELLOW}User $DEPLOYMENT_USER already exists${NC}"
else
    useradd -m -s /bin/bash "$DEPLOYMENT_USER"
    echo "$DEPLOYMENT_USER:$DEPLOYMENT_PASSWORD" | chpasswd
    usermod -aG wheel "$DEPLOYMENT_USER"
    
    echo -e "${GREEN}User created: $DEPLOYMENT_USER${NC}"
    echo -e "${YELLOW}Password: $DEPLOYMENT_PASSWORD${NC}"
    echo -e "${YELLOW}SAVE THIS PASSWORD!${NC}"
fi

echo -e "${GREEN}Step 4: Setting up SSH for Deployment User${NC}"
mkdir -p /home/$DEPLOYMENT_USER/.ssh
chmod 700 /home/$DEPLOYMENT_USER/.ssh

# Copy root's authorized_keys if they exist
if [ -f /root/.ssh/authorized_keys ]; then
    cp /root/.ssh/authorized_keys /home/$DEPLOYMENT_USER/.ssh/
    echo -e "${GREEN}Copied SSH keys from root${NC}"
fi

chown -R $DEPLOYMENT_USER:$DEPLOYMENT_USER /home/$DEPLOYMENT_USER/.ssh
chmod 600 /home/$DEPLOYMENT_USER/.ssh/authorized_keys 2>/dev/null || true

echo -e "${GREEN}Step 5: Installing Docker${NC}"
# Remove old versions
dnf remove -y docker docker-client docker-client-latest docker-common \
    docker-latest docker-latest-logrotate docker-logrotate docker-engine 2>/dev/null || true

# Add Docker repository
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker
dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Add deployment user to docker group
usermod -aG docker $DEPLOYMENT_USER

echo -e "${GREEN}Docker installed: $(docker --version)${NC}"

echo -e "${GREEN}Step 6: Configuring Firewall (firewalld)${NC}"
systemctl start firewalld
systemctl enable firewalld

# Allow SSH (both default and custom port)
firewall-cmd --permanent --add-port=22/tcp
firewall-cmd --permanent --add-port=2222/tcp

# Allow HTTP/HTTPS
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https

# Block direct access to service ports
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" port protocol="tcp" port="5432" reject'
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" port protocol="tcp" port="9092" reject'
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" port protocol="tcp" port="9200" reject'
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" port protocol="tcp" port="3000" reject'
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" port protocol="tcp" port="8080" reject'
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" port protocol="tcp" port="8081" reject'
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" port protocol="tcp" port="8083" reject'

firewall-cmd --reload
echo -e "${GREEN}Firewall configured${NC}"

echo -e "${GREEN}Step 7: Setting up fail2ban${NC}"
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
echo -e "${GREEN}fail2ban configured${NC}"

echo -e "${GREEN}Step 8: Creating Application Directory${NC}"
mkdir -p $APP_DIR
chown -R $DEPLOYMENT_USER:$DEPLOYMENT_USER $APP_DIR

mkdir -p $APP_DIR/nginx/ssl
mkdir -p $APP_DIR/nginx/conf.d
mkdir -p $APP_DIR/backups
chown -R $DEPLOYMENT_USER:$DEPLOYMENT_USER $APP_DIR

echo -e "${GREEN}Application directory created: $APP_DIR${NC}"

echo -e "${GREEN}Step 9: Generating Self-Signed TLS Certificates${NC}"
openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
    -keyout $APP_DIR/nginx/ssl/key.pem \
    -out $APP_DIR/nginx/ssl/cert.pem \
    -subj "/C=US/ST=State/L=City/O=BinanceTraders/CN=testnet.local" \
    2>/dev/null

chown -R $DEPLOYMENT_USER:$DEPLOYMENT_USER $APP_DIR/nginx/ssl
chmod 600 $APP_DIR/nginx/ssl/key.pem

echo -e "${GREEN}Self-signed certificates generated${NC}"
echo -e "${YELLOW}For production, replace with Let's Encrypt certificates${NC}"

echo -e "${GREEN}Step 10: Configuring SELinux${NC}"
# Set SELinux to permissive for Docker (can be hardened later)
setenforce 0 2>/dev/null || true
sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config 2>/dev/null || true
echo -e "${GREEN}SELinux configured (permissive mode for Docker)${NC}"

echo -e "${GREEN}Step 11: System Hardening${NC}"

# Disable unnecessary services
systemctl disable postfix 2>/dev/null || true
systemctl stop postfix 2>/dev/null || true

# Update kernel parameters for Docker and networking
cat >> /etc/sysctl.conf <<EOF

# Binance AI Traders optimizations
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
vm.max_map_count = 262144
EOF

sysctl -p || true

echo -e "${GREEN}System hardening applied${NC}"

echo -e "${GREEN}Step 12: Installing Monitoring Tools${NC}"
dnf install -y sysstat iotop iftop
systemctl enable sysstat
systemctl start sysstat

echo -e "${GREEN}Step 13: Setting up Log Rotation${NC}"
cat > /etc/logrotate.d/binance-traders <<'EOF'
/opt/binance-traders/logs/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 binance-trader binance-trader
}
EOF

echo ""
echo -e "${CYAN}================================================================${NC}"
echo -e "${GREEN} VPS Setup Complete!${NC}"
echo -e "${CYAN}================================================================${NC}"
echo ""
echo -e "${GREEN}Summary:${NC}"
echo "  - OS: $(cat /etc/redhat-release)"
echo "  - Docker: $(docker --version)"
echo "  - Docker Compose: $(docker compose version)"
echo "  - Deployment User: $DEPLOYMENT_USER"
echo "  - Password: $DEPLOYMENT_PASSWORD"
echo "  - Application Directory: $APP_DIR"
echo "  - Firewall: Enabled (ports 22, 2222, 80, 443 open)"
echo "  - fail2ban: Enabled"
echo "  - TLS Certificates: Self-signed (replace for production)"
echo ""
echo -e "${YELLOW}IMPORTANT: Save the deployment password above!${NC}"
echo ""
echo -e "${GREEN}Next Steps:${NC}"
echo "  1. Upload SSH public key to /home/$DEPLOYMENT_USER/.ssh/authorized_keys"
echo "  2. Transfer application files to $APP_DIR"
echo "  3. Deploy with: docker compose -f docker-compose-testnet.yml up -d"
echo "  4. Configure domain and Let's Encrypt certificates"
echo "  5. Harden SSH (change port, disable password auth)"
echo ""
echo -e "${GREEN}Quick Commands:${NC}"
echo "  - Test Docker: docker run hello-world"
echo "  - Check firewall: firewall-cmd --list-all"
echo "  - View fail2ban status: fail2ban-client status"
echo "  - Switch to deployment user: su - $DEPLOYMENT_USER"
echo ""
echo -e "${CYAN}================================================================${NC}"

