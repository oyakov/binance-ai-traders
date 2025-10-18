# Deployment Scripts

Automated deployment scripts for binance-ai-traders VPS deployment.

## Quick Start

### Recommended: Step-by-Step Interactive Guide

```powershell
.\scripts\deployment\step-by-step-deploy.ps1
```

**Best for:** First-time deployment, Windows users, learning the process

This script:
- ✓ Guides you through each step
- ✓ Generates copy/paste commands
- ✓ Works around Windows SSH password limitations
- ✓ Provides clear instructions
- ✓ Validates each step before proceeding

### Alternative: Partially Automated

```powershell
.\scripts\deployment\deploy-to-vps-automated.ps1 -VpsPassword "your-password"
```

**Best for:** Experienced users, repeat deployments

This script:
- ✓ Automates SSH key generation
- ✓ Creates VPS setup scripts
- ✓ Guides through manual steps
- ⚠ Requires manual SSH commands (Windows limitation)

## Files

### PowerShell Scripts (Run on Local Machine)

| File | Purpose | Usage |
|------|---------|-------|
| `step-by-step-deploy.ps1` | Interactive deployment guide | `.\step-by-step-deploy.ps1` |
| `deploy-to-vps-automated.ps1` | Partially automated deployment | `.\deploy-to-vps-automated.ps1 -VpsPassword "pass"` |

### Bash Scripts (Run on VPS)

| File | Purpose | Usage |
|------|---------|-------|
| `quick-deploy.sh` | Deploy application on VPS | `./quick-deploy.sh` |
| `vps-setup-centos.sh` | VPS initial setup (CentOS 9.3) | Auto-generated |

### Documentation

| File | Purpose |
|------|---------|
| `DEPLOYMENT_GUIDE.md` | Complete deployment reference |
| `README.md` | This file |

## Deployment Flow

```
┌─────────────────────────────────────────────────────────────┐
│ Local Machine (Windows)                                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Run step-by-step-deploy.ps1                            │
│     ├─ Generate SSH keys                                   │
│     ├─ Create VPS setup script                             │
│     └─ Generate commands to copy/paste                     │
│                                                             │
│  2. Generate & encrypt secrets                             │
│     ├─ age-keygen                                          │
│     ├─ setup-secrets.ps1                                   │
│     └─ encrypt-secrets.ps1                                 │
│                                                             │
│  3. Upload to VPS                                          │
│     ├─ scp age-key.txt                                     │
│     └─ scp -r . (entire repository)                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ VPS (CentOS 9.3)                                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  4. Run vps-setup-centos.sh                                │
│     ├─ Install Docker, fail2ban, tools                     │
│     ├─ Create deployment user                              │
│     ├─ Configure firewall (firewalld)                      │
│     └─ Setup application directory                         │
│                                                             │
│  5. Run quick-deploy.sh                                    │
│     ├─ Decrypt secrets (SOPS)                              │
│     ├─ Pull/build Docker images                            │
│     ├─ Generate TLS certificates                           │
│     └─ Start all services                                  │
│                                                             │
│  6. Verify deployment                                      │
│     ├─ docker compose ps                                   │
│     ├─ curl http://localhost/health                        │
│     └─ Check Grafana                                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Prerequisites

### Local Machine

- ✓ Windows 10/11 with PowerShell 7+
- ✓ OpenSSH client (`ssh`, `scp` commands)
- ✓ SOPS: `choco install sops`
- ✓ age: `choco install age`
- ✓ Git (for repository)

### VPS

- ✓ CentOS 9.3 (or RHEL-based)
- ✓ Fresh installation
- ✓ Root access
- ✓ Public IP address
- ✓ Ports 80, 443 accessible

## Current VPS Configuration

**Default Target VPS:**
- IP: 145.223.70.118
- OS: CentOS 9.3
- Initial User: root
- Deployment User: binance-trader (created by script)

To deploy to a different VPS, pass parameters:
```powershell
.\step-by-step-deploy.ps1 -VpsIp "1.2.3.4" -DeploymentUser "myuser"
```

## Security Features

All scripts implement enterprise-grade security:

- ✓ SSH key authentication (no passwords)
- ✓ Mozilla SOPS encryption for secrets
- ✓ Firewall configuration (firewalld)
- ✓ fail2ban for SSH protection
- ✓ Non-root deployment user
- ✓ Docker security options
- ✓ TLS/HTTPS for all endpoints
- ✓ Nginx reverse proxy
- ✓ API key authentication
- ✓ Rate limiting
- ✓ Security monitoring & alerts

## Common Issues

### 1. SSH Password Authentication

**Problem:** Windows doesn't easily support SSH password automation

**Solution:** Use `step-by-step-deploy.ps1` which guides you through manual SSH commands

### 2. SOPS Not Found

**Problem:** `sops: command not found`

**Solution:** 
```powershell
choco install sops
```

### 3. age Not Found

**Problem:** `age: command not found`

**Solution:**
```powershell
choco install age
```

### 4. Docker Permission Denied on VPS

**Problem:** `permission denied while trying to connect to the Docker daemon`

**Solution:**
```bash
# After VPS setup, logout and login again
exit
ssh binance-vps

# Or add user to docker group manually
sudo usermod -aG docker $USER
```

### 5. Firewall Blocking Services

**Problem:** Can't access services externally

**Solution:**
```bash
# Check firewall rules
sudo firewall-cmd --list-all

# Temporarily disable for testing
sudo systemctl stop firewalld

# Re-enable after fixing
sudo systemctl start firewalld
```

## Post-Deployment

### 1. Configure Domain

```bash
# Point DNS A record to VPS IP
# Wait for propagation (check with: nslookup your-domain.com)

# Obtain Let's Encrypt certificate
sudo certbot certonly --standalone -d your-domain.com

# Copy to nginx
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem /opt/binance-traders/nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem /opt/binance-traders/nginx/ssl/key.pem

# Restart nginx
docker compose -f docker-compose-testnet.yml restart nginx-gateway-testnet
```

### 2. Harden SSH

```bash
sudo nano /etc/ssh/sshd_config

# Change:
Port 2222
PermitRootLogin no
PasswordAuthentication no

# Test and restart
sudo sshd -t
sudo systemctl restart sshd
```

### 3. Run Security Tests

```powershell
# From local machine
.\scripts\security\test-security-controls.ps1 -RemoteHost 145.223.70.118 -Domain your-domain.com
```

### 4. Setup Monitoring

- Access Grafana: https://your-domain.com/grafana/
- View Security Dashboard: https://your-domain.com/grafana/d/security-monitoring
- Check Prometheus Alerts: https://your-domain.com/prometheus/alerts

## Support

For detailed information, see:

- **Full Deployment Guide:** `DEPLOYMENT_GUIDE.md` (in this directory)
- **Security Guide:** `binance-ai-traders/guides/PUBLIC_DEPLOYMENT_SECURITY_GUIDE.md`
- **VPS Setup:** `binance-ai-traders/guides/VPS_SETUP_GUIDE.md`
- **Incident Response:** `binance-ai-traders/guides/INCIDENT_RESPONSE_GUIDE.md`
- **Security Checklist:** `binance-ai-traders/guides/SECURITY_VERIFICATION_CHECKLIST.md`

## Quick Commands Reference

```powershell
# Start deployment
.\scripts\deployment\step-by-step-deploy.ps1

# Connect to VPS
ssh binance-vps

# View logs on VPS
docker compose -f docker-compose-testnet.yml logs -f

# Restart service on VPS
docker compose -f docker-compose-testnet.yml restart <service-name>

# Run security tests
.\scripts\security\test-security-controls.ps1 -RemoteHost 145.223.70.118
```

---

**Ready to deploy?** Run `.\step-by-step-deploy.ps1` to get started! 🚀

