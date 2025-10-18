# Emergency Commands Quick Reference

One-page reference for common emergency scenarios. Keep this open during incidents.

---

## Scenario 1: Services Down - Need Immediate Restart

###  GitHub Actions (Preferred)

1. Go to: https://github.com/YOUR_REPO/actions
2. Click: **Deploy to Production (Manual)**
3. Run workflow:
   - Action: `restart`
   - Confirm: `YES`
4. Wait 2-3 minutes

### PowerShell (If GitHub Down)

```powershell
.\scripts\deployment\quick-restart.ps1 -Environment production
```

### Direct SSH (Last Resort)

```bash
ssh binance-trader@145.223.70.118
cd /opt/binance-traders
docker compose -f docker-compose-testnet.yml restart
docker compose ps
curl http://localhost/health
```

**Time to recovery:** 2-5 minutes

---

## Scenario 2: Bad Deployment - Need Rollback

### GitHub Actions

1. Go to Actions → **Deploy to Production (Manual)**
2. Run workflow:
   - Action: `rollback`
   - Rollback tag: (find in deployment logs)
   - Confirm: `YES`
3. Approve when requested

### PowerShell

```powershell
.\scripts\deployment\rollback.ps1 -Environment production
# Select backup from list
# Type YES to confirm
```

### Direct SSH

```bash
ssh binance-trader@145.223.70.118
cd /opt/binance-traders

# List backups
ls -lht backups/

# Restore (replace TIMESTAMP)
docker compose down
cp backups/docker-compose-TIMESTAMP.yml docker-compose-testnet.yml
docker compose --env-file testnet.env up -d

# Verify
sleep 20
curl http://localhost/health
```

**Time to recovery:** 5-10 minutes

---

## Scenario 3: GitHub Actions Failing - Need Manual Deploy

### PowerShell

```powershell
.\scripts\deployment\manual-deploy-full.ps1 -Environment production
# Follow prompts
# Type 'yes' to confirm
```

### Steps It Performs

1. Checks prerequisites (SSH, SOPS, age)
2. Tests VPS connectivity
3. Backs up current state
4. Builds application
5. Transfers files
6. Deploys to VPS
7. Verifies health
8. Rolls back if health check fails

**Time to deploy:** 15-20 minutes

---

## Scenario 4: Need to Check What's Wrong

### Quick Diagnostics (PowerShell)

```powershell
.\scripts\deployment\diagnose.ps1 -Environment production -SaveReport
```

### What It Shows

- System resources (disk, memory, CPU)
- Docker container status
- Recent logs (last 50 lines)
- Health check results
- Firewall status
- Common issues detected

### Manual SSH Diagnostics

```bash
ssh binance-trader@145.223.70.118

# Container status
docker compose -f /opt/binance-traders/docker-compose-testnet.yml ps

# Recent logs
docker compose logs --tail=100

# Health check
curl http://localhost/health

# Resource usage
docker stats --no-stream
df -h
free -h

# Firewall
sudo firewall-cmd --list-all
```

**Time:** 2-5 minutes

---

## Scenario 5: Complete System Failure - Rebuild from Scratch

### If VPS is Accessible

```bash
# On local machine
scp scripts/deployment/emergency-vps-setup.sh root@145.223.70.118:/tmp/
ssh root@145.223.70.118
bash /tmp/emergency-vps-setup.sh
# Save displayed password!

# Then deploy
.\scripts\deployment\manual-deploy-full.ps1 -Environment production
```

### If Starting Fresh VPS

```bash
# Copy script to VPS
ssh root@NEW_VPS_IP 'bash -s' < scripts/deployment/emergency-vps-setup.sh

# Update IP in configuration
# Then deploy
.\scripts\deployment\manual-deploy-full.ps1 -Environment production
```

**Time:** 30-45 minutes

---

## Quick Health Checks

### From Local Machine

```powershell
# Testnet
curl http://145.223.70.118/health

# Production
curl http://YOUR_PROD_IP/health
```

### From VPS

```bash
ssh binance-trader@145.223.70.118

# Health endpoint
curl http://localhost/health

# Individual services
curl http://localhost:8087/health  # storage
curl http://localhost:8086/health  # collection
curl http://localhost:8083/health  # trader

# Container status
docker compose ps

# Quick logs check
docker compose logs --tail=20
```

---

## Service-Specific Restarts

### Restart Single Service

**PowerShell:**
```powershell
.\scripts\deployment\quick-restart.ps1 -Environment production -Service binance-trader-macd-testnet
```

**SSH:**
```bash
ssh binance-trader@145.223.70.118
cd /opt/binance-traders
docker compose restart binance-trader-macd-testnet
docker compose logs -f binance-trader-macd-testnet
```

### Restart Multiple Services

```bash
ssh binance-trader@145.223.70.118
cd /opt/binance-traders

# Restart backend services
docker compose restart \
  binance-trader-macd-testnet \
  binance-data-collection-testnet \
  binance-data-storage-testnet

# Check status
docker compose ps
```

---

## Common Issues and Fixes

### Issue: Container Won't Start

```bash
# Check logs
docker compose logs <container-name>

# Check configuration
docker compose config

# Force recreate
docker compose up -d --force-recreate <container-name>
```

### Issue: Out of Disk Space

```bash
# Check disk usage
df -h

# Clean Docker
docker system prune -a
docker volume prune

# Clean old logs
find /opt/binance-traders -name "*.log" -mtime +7 -delete
```

### Issue: Out of Memory

```bash
# Check memory
free -h

# Find memory hogs
docker stats --no-stream

# Restart memory-heavy service
docker compose restart <service-name>
```

### Issue: Can't Connect to VPS

```bash
# Check if VPS is up
ping 145.223.70.118

# Try different port (if SSH port changed)
ssh -p 2222 binance-trader@145.223.70.118

# Check from VPS provider console
# (Use VPS provider's web console)
```

### Issue: Service Responding Slowly

```bash
# Check resource usage
docker stats

# Check network
docker compose logs nginx-gateway-testnet

# Restart if needed
docker compose restart
```

---

## Emergency Contacts and Resources

### Documentation

| Document | Purpose |
|----------|---------|
| `DEPLOYMENT_GUIDE.md` | Complete deployment reference |
| `.github/CICD_OPERATIONS.md` | CI/CD operations |
| `.github/SECRETS_SETUP.md` | Secrets configuration |
| `guides/INCIDENT_RESPONSE_GUIDE.md` | Incident procedures |

### Quick Links

- **GitHub Actions:** https://github.com/YOUR_REPO/actions
- **Testnet Grafana:** http://145.223.70.118/grafana/
- **Testnet Prometheus:** http://145.223.70.118/prometheus/
- **Testnet Health:** http://145.223.70.118/health

### SSH Access

**Testnet:**
```bash
ssh binance-trader@145.223.70.118
# Key: ~/.ssh/vps_binance
```

**Production:**
```bash
ssh binance-trader@YOUR_PROD_IP
# Key: ~/.ssh/prod_binance
```

---

## Decision Tree

```
Is service down?
├─ YES → Try quick restart (Scenario 1)
│   ├─ Works? → Monitor closely, investigate cause
│   └─ Fails? → Check diagnostics (Scenario 4)
│       ├─ Recent deployment? → Rollback (Scenario 2)
│       ├─ Disk full? → Clean disk space
│       ├─ OOM? → Restart services, add more memory
│       └─ Still failing? → Manual deploy (Scenario 3)
│
└─ NO → Is performance bad?
    ├─ YES → Check diagnostics (Scenario 4)
    │   ├─ High memory? → Restart specific service
    │   ├─ High CPU? → Check for infinite loops in logs
    │   └─ Slow response? → Check network/database
    │
    └─ NO → Is deployment failing?
        ├─ GitHub Actions failing? → Use manual deploy (Scenario 3)
        ├─ Health check failing? → Check logs, rollback if needed
        └─ Build failing? → Fix code, try again
```

---

## Escalation

**When to escalate:**
- Production down >15 minutes
- Cannot rollback
- Data loss suspected
- Security breach suspected
- Multiple recovery attempts failed

**Who to contact:**
1. DevOps Lead
2. CTO/Engineering Manager
3. Security Team (if security-related)

**What to provide:**
- Current status
- Steps already taken
- Error messages/logs
- Time of incident
- Impact assessment

---

## Post-Incident Checklist

After resolving issue:

- [ ] Services fully operational
- [ ] Health checks passing
- [ ] Monitoring shows normal metrics
- [ ] Root cause identified
- [ ] Incident documented
- [ ] Team notified of resolution
- [ ] Post-mortem scheduled (if major incident)
- [ ] Preventive measures identified

---

**Remember:** Stay calm, follow procedures, communicate clearly, document everything.

**This is a quick reference - see full documentation for detailed procedures.**

