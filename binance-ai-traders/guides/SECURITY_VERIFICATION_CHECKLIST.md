# Security Verification Checklist

## Overview

This comprehensive checklist ensures all security controls are properly implemented before deploying binance-ai-traders to production. Each item must be verified and checked off before proceeding to deployment.

## Pre-Deployment Security Checklist

### 1. VPS and Infrastructure Security

#### SSH Access
- [ ] SSH key authentication configured and tested
- [ ] Password authentication disabled (`PasswordAuthentication no`)
- [ ] Root login disabled (`PermitRootLogin no`)
- [ ] SSH port changed from default 22 (e.g., to 2222)
- [ ] SSH key stored securely (encrypted USB or password manager)
- [ ] SSH config tested from multiple locations
- [ ] Backup access method documented
- [ ] SSH connection timeout configured (`ClientAliveInterval 300`)

#### Firewall Configuration
- [ ] UFW (Uncomplicated Firewall) enabled
- [ ] Only required ports open (SSH, 80, 443)
- [ ] All service ports blocked from public access (5432, 9092, 9200, 8080, 8081, 8083, 3000, 9090)
- [ ] Firewall rules tested and verified
- [ ] Firewall logging enabled
- [ ] Default policies set (deny incoming, allow outgoing)

#### fail2ban Protection
- [ ] fail2ban installed and running
- [ ] SSH jail configured and enabled
- [ ] Nginx jails configured (limit-req, noscript, badbots, noproxy)
- [ ] Ban time set appropriately (7200 seconds or more)
- [ ] Max retry set to 3 or less
- [ ] fail2ban logs being monitored
- [ ] Test ban/unban functionality

#### System Hardening
- [ ] Automatic security updates enabled (`unattended-upgrades`)
- [ ] System fully updated (`apt-get update && apt-get upgrade`)
- [ ] Unnecessary services disabled
- [ ] Kernel security parameters configured (`/etc/sysctl.conf`)
- [ ] File permissions secured (shadow file, SSH keys)
- [ ] Audit logging enabled (`auditd`)
- [ ] Minimal packages installed (attack surface reduced)

### 2. Secrets Management

#### SOPS and age Encryption
- [ ] Mozilla SOPS installed (`sops --version`)
- [ ] age encryption tool installed (`age --version`)
- [ ] age key pair generated (`age-keygen`)
- [ ] age public key added to `.sops.yaml`
- [ ] age private key stored securely (encrypted storage)
- [ ] `.sops.yaml` committed to repository
- [ ] age private key NEVER committed to repository

#### Environment File Security
- [ ] `testnet.env` created from template
- [ ] All placeholder values replaced with real secrets
- [ ] Strong passwords generated (32+ characters)
- [ ] `testnet.env` encrypted to `testnet.env.enc`
- [ ] Encryption verified (`sops -d testnet.env.enc`)
- [ ] Plaintext `testnet.env` deleted from local machine
- [ ] `testnet.env.enc` committed to repository
- [ ] `.gitignore` configured to block plaintext `.env` files

#### Binance API Keys
- [ ] Testnet API keys obtained from https://testnet.binance.vision
- [ ] API keys have appropriate permissions (trading, reading)
- [ ] API keys restricted to testnet URLs only
- [ ] Mainnet keys NEVER used in testnet environment
- [ ] API keys stored in encrypted `testnet.env.enc`
- [ ] API key rotation schedule established (90 days)

#### Database Credentials
- [ ] PostgreSQL password generated (32+ characters, alphanumeric + symbols)
- [ ] Password stored in encrypted `testnet.env.enc`
- [ ] No default passwords used (`testnet_password` replaced)
- [ ] Password complexity verified
- [ ] Database credentials never logged or displayed

#### Service Passwords
- [ ] Grafana admin password generated (32+ characters)
- [ ] Elasticsearch password generated (if security enabled)
- [ ] Kafka SASL password generated (if authentication enabled)
- [ ] All passwords stored in encrypted `testnet.env.enc`
- [ ] Password rotation schedule documented

#### API Authentication Tokens
- [ ] API keys generated for application authentication
- [ ] API keys follow format: `btai_testnet_<32-random-chars>`
- [ ] Different API keys for admin, monitoring, and read-only access
- [ ] Prometheus bearer token generated (64 characters)
- [ ] Session secret generated (64 characters hex)
- [ ] All tokens stored in encrypted `testnet.env.enc`

### 3. Network Security

#### TLS/SSL Certificates
- [ ] TLS certificate obtained (Let's Encrypt or commercial CA)
- [ ] Certificate installed in `nginx/ssl/cert.pem`
- [ ] Private key installed in `nginx/ssl/key.pem`
- [ ] Certificate chain complete (fullchain.pem)
- [ ] Private key permissions set to 600
- [ ] Certificate expiration date documented (renewal in 60 days)
- [ ] Automatic renewal configured (certbot cron job)
- [ ] TLS 1.2+ only (no SSLv3, TLS 1.0, TLS 1.1)
- [ ] Strong cipher suites configured
- [ ] Test TLS configuration: https://www.ssllabs.com/ssltest/

#### Nginx Reverse Proxy
- [ ] Nginx configuration validated (`nginx -t`)
- [ ] Nginx running and accessible on port 80/443
- [ ] HTTP redirects to HTTPS verified
- [ ] Rate limiting configured (10 requests/minute per IP)
- [ ] Rate limiting tested and functional
- [ ] Security headers present (X-Frame-Options, CSP, HSTS)
- [ ] Request size limits configured (10KB max)
- [ ] Nginx logs being written and rotated
- [ ] Error pages customized (401, 403, 404, 429, 500)
- [ ] Direct service port access blocked (test from external)

#### Service Port Exposure
- [ ] No services exposing public ports in `docker-compose-testnet.yml`
- [ ] All services use `expose` instead of `ports` (except nginx)
- [ ] Test: Cannot access services directly from external network
  - [ ] Port 8083 (trader-macd) blocked
  - [ ] Port 8086 (data-collection) blocked
  - [ ] Port 8087 (data-storage) blocked
  - [ ] Port 3000 (Grafana) blocked
  - [ ] Port 9090 (Prometheus) blocked
  - [ ] Port 5432 (PostgreSQL) blocked
  - [ ] Port 9092 (Kafka) blocked
  - [ ] Port 9200 (Elasticsearch) blocked

#### Internal Network Isolation
- [ ] Docker network `testnet-network` configured
- [ ] Inter-container communication isolated to Docker network
- [ ] No inter-container communication enabled by default (`icc: false`)
- [ ] Services can communicate internally via service names

### 4. Application Security

#### Authentication and Authorization
- [ ] API authentication required for all `/api/*` endpoints
- [ ] X-API-Key header validation implemented
- [ ] Invalid API keys return 401 Unauthorized
- [ ] Grafana authentication enabled (anonymous access disabled)
- [ ] Prometheus requires bearer token authentication
- [ ] Test: Unauthenticated requests rejected

#### API Security
- [ ] Input validation on all API endpoints
- [ ] Request size limits enforced (10KB)
- [ ] SQL injection protection (parameterized queries)
- [ ] XSS protection headers configured
- [ ] CSRF protection enabled for state-changing operations
- [ ] API versioning in place (`/api/v1/`)
- [ ] Error messages don't leak sensitive information

#### Endpoint Protection
- [ ] `/actuator/*` endpoints blocked from public access
- [ ] `/metrics` endpoint blocked from public access
- [ ] `/health` endpoint public but rate-limited
- [ ] Internal endpoints accessible only via Docker network
- [ ] WebSocket connections secured (if applicable)

### 5. Database and Data Security

#### PostgreSQL Security
- [ ] Strong password configured (from encrypted env file)
- [ ] Database accessible only from Docker network
- [ ] SSL/TLS connection available (optional for testnet)
- [ ] Database user has minimal required permissions
- [ ] Regular backups configured and tested
- [ ] Backup encryption verified
- [ ] Connection pooling configured appropriately

#### Elasticsearch Security
- [ ] Elasticsearch security enabled (if production)
- [ ] Strong password configured
- [ ] RBAC (Role-Based Access Control) configured
- [ ] TLS enabled for HTTP API (if production)
- [ ] Index-level access control configured
- [ ] Elasticsearch accessible only from Docker network

#### Data Protection
- [ ] Sensitive data encrypted at rest (backup encryption)
- [ ] Database backups tested and verified
- [ ] Backup retention policy implemented (30 days)
- [ ] Backup storage secured
- [ ] Data recovery procedure tested

### 6. Container Security

#### Docker Security
- [ ] Docker daemon configured with security settings (`/etc/docker/daemon.json`)
- [ ] User namespaces enabled (if applicable)
- [ ] No new privileges flag set (`no-new-privileges:true`)
- [ ] Containers run with minimal privileges
- [ ] Read-only file systems where possible
- [ ] Resource limits set (CPU, memory)
- [ ] Container images scanned for vulnerabilities
- [ ] Docker socket not exposed to containers

#### Image Security
- [ ] Base images from trusted sources
- [ ] Images regularly updated
- [ ] No secrets in Docker images or layers
- [ ] Image scan results reviewed (Trivy, Grype)
- [ ] Multi-stage builds used to minimize image size
- [ ] Non-root users in containers (where applicable)

### 7. Monitoring and Logging

#### Security Monitoring
- [ ] Grafana security monitoring dashboard configured
- [ ] Security metrics being collected
- [ ] Failed authentication attempts monitored
- [ ] Rate limit violations tracked
- [ ] Unusual traffic patterns detected
- [ ] Certificate expiration alerts configured (30 days)

#### Logging
- [ ] All services logging to appropriate destinations
- [ ] Nginx access logs configured and rotating
- [ ] Nginx error logs configured
- [ ] Application logs configured
- [ ] Structured logging enabled (JSON format)
- [ ] Log retention policy implemented (90 days)
- [ ] Sensitive data not logged (passwords, API keys)
- [ ] Log aggregation configured (if applicable)

#### Alerting
- [ ] Critical alerts configured (service down, high error rate)
- [ ] Warning alerts configured (high resource usage)
- [ ] Alert notification channels configured (email, Slack)
- [ ] Alert escalation procedures documented
- [ ] Alert testing completed
- [ ] On-call rotation established (if applicable)

### 8. Backup and Recovery

#### Backup Configuration
- [ ] Automated backup scripts configured
- [ ] Daily backups scheduled (cron job)
- [ ] Backup includes database data
- [ ] Backup includes configuration files
- [ ] Backup includes TLS certificates
- [ ] Backup encryption verified
- [ ] Backup storage location secured

#### Recovery Testing
- [ ] Backup restoration tested successfully
- [ ] Recovery time objective (RTO) documented
- [ ] Recovery point objective (RPO) documented
- [ ] Disaster recovery procedure documented
- [ ] Recovery testing scheduled quarterly

### 9. Documentation and Procedures

#### Security Documentation
- [ ] PUBLIC_DEPLOYMENT_SECURITY_GUIDE.md reviewed
- [ ] VPS_SETUP_GUIDE.md followed
- [ ] INCIDENT_RESPONSE_GUIDE.md reviewed
- [ ] SECURITY_VERIFICATION_CHECKLIST.md (this document) completed
- [ ] All documentation up to date

#### Operational Procedures
- [ ] Deployment procedure documented
- [ ] Rollback procedure documented
- [ ] Secret rotation procedure documented
- [ ] Backup restoration procedure documented
- [ ] Incident response procedure documented
- [ ] Emergency contact list updated

#### Training
- [ ] Team trained on security procedures
- [ ] Team trained on incident response
- [ ] Team trained on secret management
- [ ] Emergency procedures reviewed with team

### 10. Compliance and Policy

#### Security Policies
- [ ] Access control policy documented
- [ ] Password policy documented and enforced
- [ ] Data retention policy documented
- [ ] Incident response policy documented
- [ ] Change management policy followed

#### Audit and Review
- [ ] Security audit completed (if required)
- [ ] Penetration testing scheduled/completed
- [ ] Vulnerability scan completed
- [ ] Third-party security review (if required)
- [ ] Compliance requirements verified (if applicable)

## Post-Deployment Verification

### Immediate (Within 1 Hour)

- [ ] All services started successfully
- [ ] Health checks passing
- [ ] No errors in logs
- [ ] Monitoring dashboard shows healthy status
- [ ] External access test: `curl https://your-domain.com/health`
- [ ] Authentication test: Verify API key required
- [ ] TLS test: Verify HTTPS working correctly
- [ ] Rate limiting test: Verify throttling works

### Within 24 Hours

- [ ] No security alerts triggered
- [ ] No failed authentication spikes
- [ ] Service performance normal
- [ ] Trading operations functioning
- [ ] Backup completed successfully
- [ ] Monitoring data collecting properly
- [ ] Log aggregation functioning

### Within 1 Week

- [ ] No security incidents
- [ ] All alerts functioning correctly
- [ ] Backup restoration verified
- [ ] Secret rotation tested
- [ ] Performance metrics baseline established
- [ ] Team familiar with operational procedures

## Security Testing Commands

### External Security Tests

```bash
# Test public ports (from external network)
nmap -p- your-domain.com
# Should show only 80, 443, and custom SSH port

# Test TLS configuration
openssl s_client -connect your-domain.com:443 -tls1_3

# Test HTTP to HTTPS redirect
curl -I http://your-domain.com
# Should return 301 redirect

# Test health endpoint (no auth required)
curl https://your-domain.com/health
# Should return 200 OK

# Test API without authentication (should fail)
curl https://your-domain.com/api/v1/macd/signals
# Should return 401 Unauthorized

# Test API with authentication (should work)
curl -H "X-API-Key: your-api-key" https://your-domain.com/api/v1/macd/signals
# Should return data

# Test rate limiting
for i in {1..20}; do curl https://your-domain.com/api/v1/health; done
# Should get 429 Too Many Requests

# Test direct service access (should fail)
curl http://your-domain.com:8083/actuator/health
# Should timeout or be refused
```

### Internal Security Tests (on VPS)

```bash
# Verify firewall rules
sudo ufw status verbose

# Check fail2ban status
sudo fail2ban-client status sshd

# Verify no plaintext secrets
grep -r "password" /opt/binance-traders/*.env
# Should find no files

# Check Docker security
docker info | grep -i security

# Verify container isolation
docker inspect testnet-network

# Check file permissions
ls -la /opt/binance-traders/nginx/ssl/
# Private key should be 600
```

## Sign-Off

### Pre-Deployment Sign-Off

I certify that all items in this security checklist have been completed and verified:

**Security Engineer:**
- Name: ___________________
- Signature: ___________________
- Date: ___________________

**Technical Lead:**
- Name: ___________________
- Signature: ___________________
- Date: ___________________

**Incident Commander:**
- Name: ___________________
- Signature: ___________________
- Date: ___________________

### Post-Deployment Sign-Off

I certify that post-deployment verification has been completed:

**Operations Lead:**
- Name: ___________________
- Signature: ___________________
- Date: ___________________

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-10-18 | Initial version | Security Team |

---

**Document Classification:** Internal Use Only  
**Review Schedule:** Before each deployment  
**Last Reviewed:** 2025-10-18


