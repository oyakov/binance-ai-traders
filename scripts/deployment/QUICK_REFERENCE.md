# Deployment Quick Reference Card

**VPS:** 145.223.70.118 (CentOS 9.3)  
**Initial Access:** root / 6Shmjl022X  
**Deployment User:** binance-trader

---

## 🚀 Start Here

```powershell
cd C:\Projects\binance-ai-traders
.\scripts\deployment\step-by-step-deploy.ps1
```

---

## 📋 Deployment Checklist

- [ ] 1. Generate SSH keys
- [ ] 2. Upload public key to VPS
- [ ] 3. Test SSH key auth
- [ ] 4. Run VPS setup script
- [ ] 5. Generate age keys
- [ ] 6. Configure SOPS
- [ ] 7. Generate secrets
- [ ] 8. Create testnet.env
- [ ] 9. Encrypt secrets
- [ ] 10. Upload to VPS
- [ ] 11. Deploy application
- [ ] 12. Verify deployment
- [ ] 13. Configure domain
- [ ] 14. Harden SSH

---

## 🔑 Key Commands

### Local Machine

```powershell
# Generate SSH keys
ssh-keygen -t ed25519 -C "binance-vps" -f ~/.ssh/vps_binance

# Generate age keys
age-keygen -o age-key.txt

# Generate secrets
.\scripts\security\setup-secrets.ps1 -GenerateApiKeys

# Encrypt secrets
.\scripts\security\encrypt-secrets.ps1

# Upload to VPS
scp -i ~/.ssh/vps_binance -r . binance-trader@145.223.70.118:/opt/binance-traders/

# Test security
.\scripts\security\test-security-controls.ps1 -RemoteHost 145.223.70.118
```

### VPS

```bash
# Connect
ssh -i ~/.ssh/vps_binance binance-trader@145.223.70.118

# Deploy application
cd /opt/binance-traders
export SOPS_AGE_KEY_FILE=$HOME/age-key.txt
sops -d testnet.env.enc > testnet.env
chmod 600 testnet.env
./scripts/deployment/quick-deploy.sh

# Check status
docker compose -f docker-compose-testnet.yml ps

# View logs
docker compose -f docker-compose-testnet.yml logs -f

# Restart service
docker compose -f docker-compose-testnet.yml restart <service-name>

# Stop all
docker compose -f docker-compose-testnet.yml down

# Start all
docker compose -f docker-compose-testnet.yml up -d
```

---

## 🔐 Security Setup

### Install Tools (Local)

```powershell
choco install openssh
choco install sops
choco install age
```

### VPS Firewall (firewalld)

```bash
# Check status
sudo firewall-cmd --list-all

# Add port
sudo firewall-cmd --permanent --add-port=<port>/tcp
sudo firewall-cmd --reload

# Block port
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" port protocol="tcp" port="<port>" reject'
sudo firewall-cmd --reload
```

### SSH Hardening

```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Change these lines:
Port 2222
PermitRootLogin no
PasswordAuthentication no

# Test config
sudo sshd -t

# Restart SSH
sudo systemctl restart sshd
```

---

## 🌐 Service URLs

### After Domain Configuration

- **Health Check:** https://your-domain.com/health
- **Grafana:** https://your-domain.com/grafana/
- **Security Dashboard:** https://your-domain.com/grafana/d/security-monitoring
- **Prometheus:** https://your-domain.com/prometheus/
- **API:** https://your-domain.com/api/

### Before Domain (IP-based)

- **Health Check:** http://145.223.70.118/health
- **Grafana:** http://145.223.70.118/grafana/

---

## 🔧 Troubleshooting

### Can't Connect to VPS

```bash
# Test connection
ping 145.223.70.118

# Test SSH
ssh -v -i ~/.ssh/vps_binance binance-trader@145.223.70.118

# If locked out, use VPS console via hosting provider
```

### Docker Issues

```bash
# Check Docker status
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Check container logs
docker logs <container-name>

# Remove all containers and start fresh
docker compose -f docker-compose-testnet.yml down -v
docker compose -f docker-compose-testnet.yml up -d
```

### SOPS Decryption Failed

```bash
# Check age key
echo $SOPS_AGE_KEY_FILE
cat $SOPS_AGE_KEY_FILE

# Set age key
export SOPS_AGE_KEY_FILE=$HOME/age-key.txt

# Verify encrypted file
sops -d testnet.env.enc
```

### Service Not Starting

```bash
# Check logs
docker compose -f docker-compose-testnet.yml logs <service-name>

# Check environment variables
docker compose -f docker-compose-testnet.yml config

# Force rebuild
docker compose -f docker-compose-testnet.yml up -d --build <service-name>
```

### Firewall Blocking

```bash
# Temporarily disable (TESTING ONLY!)
sudo systemctl stop firewalld

# Re-enable
sudo systemctl start firewalld

# Check if port is open
sudo ss -tulpn | grep <port>
```

---

## 📊 Health Checks

```bash
# Quick health check
curl http://localhost/health

# Check all containers
docker compose -f docker-compose-testnet.yml ps

# Check specific service health
curl http://localhost:8087/health  # storage
curl http://localhost:8086/health  # collection
curl http://localhost:8083/health  # trader

# Check Prometheus targets
curl http://localhost:9090/api/v1/targets

# Check Grafana
curl http://localhost:3000/api/health
```

---

## 🎯 Quick Fixes

### Reset Everything

```bash
cd /opt/binance-traders
docker compose -f docker-compose-testnet.yml down -v
docker compose -f docker-compose-testnet.yml up -d
```

### Regenerate TLS Certificates

```bash
cd /opt/binance-traders
openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
  -keyout nginx/ssl/key.pem \
  -out nginx/ssl/cert.pem \
  -subj "/C=US/ST=State/L=City/O=BinanceTraders/CN=testnet.local"
docker compose -f docker-compose-testnet.yml restart nginx-gateway-testnet
```

### View Service Resource Usage

```bash
docker stats
```

### Clean Docker System

```bash
# Remove unused images
docker image prune -a

# Remove unused volumes
docker volume prune

# Remove everything unused
docker system prune -a --volumes
```

---

## 📚 Documentation

| Document | Location |
|----------|----------|
| **Deployment Guide** | `scripts/deployment/DEPLOYMENT_GUIDE.md` |
| **Scripts README** | `scripts/deployment/README.md` |
| **Security Guide** | `binance-ai-traders/guides/PUBLIC_DEPLOYMENT_SECURITY_GUIDE.md` |
| **VPS Setup** | `binance-ai-traders/guides/VPS_SETUP_GUIDE.md` |
| **Security Checklist** | `binance-ai-traders/guides/SECURITY_VERIFICATION_CHECKLIST.md` |
| **Incident Response** | `binance-ai-traders/guides/INCIDENT_RESPONSE_GUIDE.md` |

---

## 🆘 Emergency Contacts

### If Services Go Down

1. Check Docker status: `docker compose ps`
2. Check logs: `docker compose logs -f`
3. Check firewall: `sudo firewall-cmd --list-all`
4. Check disk space: `df -h`
5. Check memory: `free -h`
6. Restart services: `docker compose restart`

### If Security Breach Suspected

1. **Immediately:** Stop all services
   ```bash
   docker compose -f docker-compose-testnet.yml down
   ```

2. **Collect logs:**
   ```bash
   docker compose logs > /tmp/incident-logs.txt
   sudo journalctl -u docker > /tmp/docker-system.log
   sudo cat /var/log/secure > /tmp/ssh-auth.log
   ```

3. **Follow incident response guide:**
   See `binance-ai-traders/guides/INCIDENT_RESPONSE_GUIDE.md`

---

## ✅ Verification

### After Deployment

```bash
# 1. All containers running
docker compose -f docker-compose-testnet.yml ps

# 2. Health endpoints respond
curl http://localhost/health

# 3. No exposed ports (except 80, 443, 22)
sudo ss -tulpn | grep LISTEN

# 4. Firewall active
sudo firewall-cmd --state

# 5. fail2ban running
sudo systemctl status fail2ban

# 6. Grafana accessible
curl http://localhost:3000/api/health

# 7. Prometheus targets up
curl http://localhost:9090/api/v1/targets
```

---

**Keep this card open during deployment!** 📌

For full details, see: `scripts/deployment/DEPLOYMENT_GUIDE.md`

