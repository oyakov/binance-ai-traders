# Public Deployment Security Guide for M1 Testnet

## Overview

This guide provides comprehensive security instructions for deploying the binance-ai-traders M1 testnet on a self-hosted VPS or dedicated server for public access. The deployment uses a defense-in-depth approach with multiple security layers.

## Deployment Architecture

```
Internet (Public)
    ↓
VPS Firewall (80/443 only)
    ↓
Nginx Reverse Proxy (TLS termination, rate limiting, security headers)
    ↓
Internal Docker Network (services isolated)
    ↓
Services:
  - binance-trader-macd (8080 internal)
  - binance-data-collection (8080 internal)
  - binance-data-storage (8081 internal)
  - Grafana (3000 internal)
  - Prometheus (9090 internal)
  - PostgreSQL (5432 internal, TLS)
  - Kafka (authenticated, TLS)
  - Elasticsearch (RBAC, TLS)
```

## VPS Access Security

### Initial Access (Password-Based)
When first provisioning the VPS:

1. **Access via IP + Username/Password**
   ```bash
   ssh username@<VPS_IP>
   # Enter password when prompted
   ```

2. **Immediate Security Actions**
   - Change default password immediately
   - Update all system packages
   - Install fail2ban for brute-force protection
   - Configure firewall (allow only SSH, HTTP, HTTPS)

### Transition to SSH Key Authentication

**Generate SSH Key Pair (on local machine):**
```powershell
# Generate ED25519 key (more secure than RSA)
ssh-keygen -t ed25519 -C "binance-trader-deployment" -f ~/.ssh/vps_binance_trader

# Or RSA 4096 if ED25519 not supported
ssh-keygen -t rsa -b 4096 -C "binance-trader-deployment" -f ~/.ssh/vps_binance_trader
```

**Copy Public Key to VPS:**
```bash
# Method 1: Using ssh-copy-id
ssh-copy-id -i ~/.ssh/vps_binance_trader.pub username@<VPS_IP>

# Method 2: Manual copy (if ssh-copy-id not available)
type ~/.ssh/vps_binance_trader.pub | ssh username@<VPS_IP> "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

**Test SSH Key Access:**
```bash
ssh -i ~/.ssh/vps_binance_trader username@<VPS_IP>
```

**Disable Password Authentication (only after verifying key works):**
```bash
# On VPS, edit SSH config
sudo nano /etc/ssh/sshd_config

# Set these values:
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
Port 2222  # Change default SSH port
ChallengeResponseAuthentication no
UsePAM no

# Restart SSH service
sudo systemctl restart sshd
```

### SSH Hardening Best Practices

**1. Change Default SSH Port**
```bash
# Edit /etc/ssh/sshd_config
Port 2222  # Use non-standard port

# Update firewall
sudo ufw allow 2222/tcp
sudo ufw delete allow 22/tcp
```

**2. Install and Configure fail2ban**
```bash
sudo apt-get install fail2ban -y

# Create jail.local
sudo nano /etc/fail2ban/jail.local
```

Add configuration:
```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
destemail = your-email@example.com
sendername = Fail2Ban-VPS

[sshd]
enabled = true
port = 2222
logpath = /var/log/auth.log
maxretry = 3
bantime = 7200
```

```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

**3. Two-Factor Authentication (Recommended)**
```bash
# Install Google Authenticator
sudo apt-get install libpam-google-authenticator -y

# Run setup
google-authenticator
```

## Secrets Management Strategy

### Overview
All sensitive credentials (API keys, passwords, certificates) are encrypted using **Mozilla SOPS** with **age** encryption.

### Architecture
```
Developer Machine:
  - Generate secrets → testnet.env (plaintext, never committed)
  - Encrypt → testnet.env.enc (committed to git)
  
VPS Deployment:
  - Transfer age private key securely (one-time)
  - Decrypt testnet.env.enc → testnet.env (runtime only)
  - Docker Compose reads testnet.env
  - Delete plaintext after deployment
```

### Setup Process

**1. Install SOPS and age (on local machine)**
```powershell
# Install SOPS
choco install sops -y

# Install age
choco install age -y
```

**2. Generate age Key Pair**
```powershell
# Generate encryption key
age-keygen -o age-key.txt

# Output will show:
# Public key: age1xxxxxxxxxx...
# Private key saved to age-key.txt

# IMPORTANT: Store age-key.txt securely (password manager, encrypted USB)
```

**3. Create .sops.yaml Configuration**
```yaml
creation_rules:
  - path_regex: testnet\.env$
    age: age1xxxxxxxxxx...  # Your public key
```

**4. Generate Strong Secrets**
```powershell
# Run secret generation script
.\scripts\security\setup-secrets.ps1
```

This generates:
- PostgreSQL password (32 chars, alphanumeric + symbols)
- Grafana admin password (32 chars)
- Elasticsearch password (32 chars)
- API authentication tokens
- Kafka SASL credentials

**5. Encrypt Environment File**
```powershell
# Encrypt testnet.env
.\scripts\security\encrypt-secrets.ps1

# Creates testnet.env.enc (safe to commit)
# Delete testnet.env from local machine
```

**6. Deploy to VPS**
```bash
# Copy encrypted file to VPS
scp testnet.env.enc username@<VPS_IP>:/opt/binance-traders/

# Copy age private key (secure channel only)
scp age-key.txt username@<VPS_IP>:/opt/binance-traders/.secrets/

# Set strict permissions on VPS
chmod 600 /opt/binance-traders/.secrets/age-key.txt
chmod 600 /opt/binance-traders/testnet.env.enc

# Decrypt on VPS (runtime only)
export SOPS_AGE_KEY_FILE=/opt/binance-traders/.secrets/age-key.txt
sops -d testnet.env.enc > testnet.env
chmod 600 testnet.env
```

### Secret Rotation

Rotate secrets every 90 days or immediately after:
- Suspected compromise
- Team member departure
- Security incident

```powershell
# Run rotation script
.\scripts\security\rotate-secrets.ps1
```

## Network Security Setup

### 1. VPS Firewall Configuration

**Ubuntu/Debian (UFW):**
```bash
# Reset firewall
sudo ufw --force reset

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (custom port)
sudo ufw allow 2222/tcp comment 'SSH'

# Allow HTTP/HTTPS
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'

# Block all other inbound ports
sudo ufw deny 5432/tcp comment 'Block PostgreSQL'
sudo ufw deny 9092/tcp comment 'Block Kafka'
sudo ufw deny 9200/tcp comment 'Block Elasticsearch'
sudo ufw deny 3000/tcp comment 'Block Grafana'

# Enable firewall
sudo ufw enable

# Verify rules
sudo ufw status verbose
```

**Windows Server (PowerShell):**
```powershell
# Run firewall setup script
.\scripts\security\setup-firewall.ps1
```

### 2. Nginx Reverse Proxy with TLS

Nginx acts as the single public entry point with:
- TLS 1.3 encryption
- Rate limiting (10 requests/minute per IP)
- Security headers
- Request size limits
- Proxy to internal services only

**Directory Structure:**
```
nginx/
├── nginx.conf          # Main configuration
├── conf.d/
│   └── api-gateway.conf  # Routing rules
└── ssl/
    ├── cert.pem        # TLS certificate
    └── key.pem         # Private key
```

**Obtain TLS Certificate:**
```bash
# Option 1: Let's Encrypt (Recommended for production)
sudo apt-get install certbot -y
sudo certbot certonly --standalone -d your-domain.com

# Certificate will be at:
# /etc/letsencrypt/live/your-domain.com/fullchain.pem
# /etc/letsencrypt/live/your-domain.com/privkey.pem

# Copy to nginx directory
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem nginx/ssl/key.pem

# Option 2: Self-signed (Testnet only)
openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
  -keyout nginx/ssl/key.pem \
  -out nginx/ssl/cert.pem \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=your-domain.com"
```

**Automatic Certificate Renewal:**
```bash
# Add cron job for Let's Encrypt renewal
sudo crontab -e

# Add line:
0 3 * * * certbot renew --quiet && systemctl reload nginx
```

### 3. Internal Service Communication

All services communicate on internal Docker network only:
- No direct public access
- Service-to-service communication via Docker network
- Database connections use TLS
- Kafka uses SASL/SCRAM + TLS

## Application Security Controls

### 1. API Authentication

All API endpoints require authentication via:
- **API Key Header:** `X-API-Key: <token>`
- **Rate Limiting:** 10 requests/minute per IP
- **Request Validation:** Input sanitization, size limits

**Generate API Keys:**
```powershell
.\scripts\security\setup-secrets.ps1 -GenerateApiKeys
```

**API Key Format:**
```
btai_testnet_<random_32_chars>
Example: btai_testnet_k8h3j9d2f7g5m1n4p6q9r2s5t8v1w4x7
```

### 2. Service Endpoints Protection

**Public Endpoints (via Nginx):**
- `/health` - Basic health check (no auth)
- `/api/v1/*` - All API endpoints (auth required)
- `/grafana/*` - Monitoring dashboards (auth required)

**Internal Endpoints (no public access):**
- `/actuator/*` - Spring Boot actuator
- `/metrics` - Prometheus metrics
- Database ports
- Kafka ports

### 3. Grafana Security

- Strong admin password (generated)
- No anonymous access
- Authentication required for all dashboards
- Behind reverse proxy only
- Session timeout: 24 hours

### 4. Database Security

**PostgreSQL:**
- Strong password (32 chars)
- TLS required for all connections
- Network access from Docker network only
- Regular backups encrypted at rest

**Elasticsearch:**
- RBAC enabled
- Strong password
- TLS for HTTP API
- Index-level access control

**Redis (if added):**
- Password authentication
- No dangerous commands (FLUSHALL, CONFIG)
- Persistence enabled

## Monitoring and Incident Response

### Security Monitoring Dashboard

Access: `https://your-domain.com/grafana/d/security-monitoring`

**Metrics Tracked:**
- Failed authentication attempts (alert if >10/min)
- Rate limit violations (alert if >50/hour)
- Unusual API access patterns
- Certificate expiration (alert 30 days before)
- Service health security indicators
- Disk space usage (alert at 80%)
- Memory/CPU anomalies

### Alert Configuration

**Critical Alerts (Immediate Response):**
- Service down >5 minutes
- Database connection lost
- Failed authentication spike (>50/min)
- Disk space >90%
- Memory usage >95%

**Warning Alerts (Monitor):**
- Service restart
- High error rate (>5% requests)
- Certificate expires in 30 days
- Unusual traffic patterns

### Incident Response Procedure

**1. Detection**
- Automated alert via Grafana
- Manual observation
- External report

**2. Assessment**
- Classify severity (Critical/High/Medium/Low)
- Identify affected services
- Determine scope

**3. Containment**
- Isolate affected services
- Block malicious IPs at firewall
- Rotate compromised credentials

**4. Eradication**
- Remove malicious actors
- Patch vulnerabilities
- Update configurations

**5. Recovery**
- Restore from backups if needed
- Restart services
- Verify system integrity

**6. Post-Incident**
- Document incident
- Update security controls
- Team review meeting

See `INCIDENT_RESPONSE_GUIDE.md` for detailed procedures.

## Deployment Checklist

### Pre-Deployment Security Checklist

- [ ] VPS access secured with SSH keys
- [ ] Password authentication disabled
- [ ] fail2ban installed and configured
- [ ] Firewall configured (only 22, 80, 443 open)
- [ ] All secrets generated and encrypted with SOPS
- [ ] No plaintext secrets in git repository
- [ ] TLS certificates obtained and installed
- [ ] Strong passwords for all services (32+ chars)
- [ ] Nginx reverse proxy configured
- [ ] Docker daemon hardened
- [ ] Automatic security updates enabled
- [ ] Backup strategy implemented
- [ ] Monitoring dashboards configured
- [ ] Alert rules configured
- [ ] Incident response procedures documented
- [ ] Team trained on security procedures

### Deployment Steps

1. **Prepare VPS**
   ```bash
   # Update system
   sudo apt-get update && sudo apt-get upgrade -y
   
   # Install dependencies
   sudo apt-get install docker.io docker-compose fail2ban ufw -y
   
   # Configure firewall
   sudo ufw enable
   ```

2. **Transfer Application**
   ```bash
   # Clone repository
   git clone https://github.com/your-repo/binance-ai-traders.git
   cd binance-ai-traders
   ```

3. **Setup Secrets**
   ```bash
   # Decrypt environment file
   export SOPS_AGE_KEY_FILE=/opt/binance-traders/.secrets/age-key.txt
   sops -d testnet.env.enc > testnet.env
   chmod 600 testnet.env
   ```

4. **Deploy Services**
   ```bash
   # Start services
   docker-compose -f docker-compose-testnet.yml --env-file testnet.env up -d
   
   # Verify health
   ./scripts/security/test-security-controls.ps1
   ```

5. **Verify Security**
   - Run security test suite
   - Verify no direct service access
   - Test authentication enforcement
   - Verify TLS on all public endpoints
   - Check firewall rules
   - Test rate limiting

### Post-Deployment Verification

```bash
# Test external access (should work)
curl https://your-domain.com/health

# Test direct service access (should fail)
curl http://your-domain.com:8083/actuator/health  # Should timeout

# Test authentication (should return 401)
curl https://your-domain.com/api/v1/macd/signals

# Test with authentication (should work)
curl -H "X-API-Key: your-api-key" https://your-domain.com/api/v1/macd/signals

# Verify TLS
openssl s_client -connect your-domain.com:443 -tls1_3

# Check open ports (only 22, 80, 443 should be open)
nmap -p- your-domain.com
```

## Ongoing Security Maintenance

### Daily Tasks
- Check Grafana security dashboard
- Review failed authentication logs
- Verify all services healthy
- Check disk space

### Weekly Tasks
- Review security alerts
- Check for system updates
- Review access logs
- Backup verification

### Monthly Tasks
- Review and update firewall rules
- Audit user accounts
- Security patch assessment
- Review incident response procedures
- Test backup restoration

### Quarterly Tasks
- Rotate all secrets and credentials
- Security audit and penetration testing
- Review and update security policies
- Team security training

## Security Best Practices

### DO:
✅ Use SSH keys (never passwords)
✅ Encrypt all secrets with SOPS
✅ Use TLS for all public endpoints
✅ Enable automatic security updates
✅ Monitor security metrics
✅ Rotate secrets every 90 days
✅ Backup encrypted data regularly
✅ Document all changes
✅ Use strong passwords (32+ chars)
✅ Enable rate limiting

### DON'T:
❌ Never commit plaintext secrets to git
❌ Never use default passwords
❌ Never expose service ports directly
❌ Never disable TLS in production
❌ Never ignore security alerts
❌ Never skip security updates
❌ Never grant root SSH access
❌ Never use weak passwords
❌ Never deploy without testing
❌ Never disable firewall

## Compliance and Regulations

### Data Protection
- Encrypt data at rest (database backups)
- Encrypt data in transit (TLS 1.3)
- Secure credential storage (SOPS)
- Access logging enabled
- Regular security audits

### Audit Trail
- All API requests logged
- Authentication attempts logged
- Configuration changes logged
- Access logs retained 90 days
- Incident logs retained indefinitely

## Emergency Contacts

**Security Incident:**
- Email: security@your-organization.com
- Phone: +1-XXX-XXX-XXXX
- On-call rotation documented

**VPS Provider Support:**
- Support portal URL
- Emergency phone number
- SLA response times

## References

- [SECURITY_HARDENING_GUIDE.md](SECURITY_HARDENING_GUIDE.md) - Detailed hardening procedures
- [VPS_SETUP_GUIDE.md](VPS_SETUP_GUIDE.md) - VPS initial setup
- [INCIDENT_RESPONSE_GUIDE.md](INCIDENT_RESPONSE_GUIDE.md) - Incident handling
- [SECURITY_VERIFICATION_CHECKLIST.md](SECURITY_VERIFICATION_CHECKLIST.md) - Verification procedures
- [TESTNET_LAUNCH_GUIDE.md](TESTNET_LAUNCH_GUIDE.md) - Deployment procedures

## Document Information

**Version:** 1.0  
**Last Updated:** 2025-10-18  
**Status:** Production Ready  
**Owner:** Security Team  
**Review Schedule:** Quarterly

---

**⚠️ SECURITY NOTICE:** This document contains security-sensitive information. Distribute only to authorized personnel. Do not commit this document with actual secrets or credentials.

