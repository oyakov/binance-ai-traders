# CI/CD Operations Guide

Complete guide for operating the GitHub Actions CI/CD pipeline.

## Quick Start

### Automatic Deployments

**Testnet:** Push to `develop` branch
```bash
git checkout develop
git merge feature/my-feature
git push origin develop
# Automatic deployment to testnet VPS starts
```

**Monitor:** https://github.com/YOUR_REPO/actions

### Manual Production Deployment

1. Go to **Actions** tab
2. Select **Deploy to Production (Manual)** workflow
3. Click **Run workflow**
4. Fill in:
   - Environment: `production`
   - Action: `deploy`
   - Confirm: `YES`
5. Click **Run workflow**
6. Wait for approval request
7. Review and approve deployment

---

## Monitoring Deployments

### View Running Workflows

**GitHub UI:**
1. Go to repository
2. Click **Actions** tab
3. See all workflow runs

**Check specific deployment:**
- Click on workflow run
- View each step's logs
- Check deployment summary

### Workflow Status

**Status indicators:**
- 🟡 Yellow dot: In progress
- ✅ Green checkmark: Success
- ❌ Red X: Failed
- ⏸️ Gray circle: Waiting (approval needed)

### Real-time Logs

Click on any step to see live logs:
```
▶ Setup SSH
  Creating SSH directory...
  ✓ SSH configured

▶ Deploy on VPS
  Stopping services...
  Starting services...
  ✓ Deployment complete
```

---

## Deployment Types

### 1. Automatic Testnet Deployment

**Trigger:** Push to `develop`

**Process:**
1. Code pushed to `develop`
2. Workflow starts automatically
3. Builds application
4. Runs tests
5. Builds Docker images
6. Transfers to VPS
7. Deploys services
8. Verifies health

**Duration:** 10-15 minutes

**Monitoring:**
- GitHub Actions tab
- Deployment summary
- VPS health endpoint

### 2. Manual Production Deployment

**Trigger:** Manual via GitHub UI

**Process:**
1. Trigger workflow manually
2. Select action (deploy/restart/rollback/status)
3. Type "YES" to confirm
4. Workflow requests approval
5. Reviewer approves
6. Deployment proceeds
7. Health verification

**Duration:** 15-20 minutes + approval time

**Requires:** 1-2 approvals from designated reviewers

### 3. Quick Restart

**Trigger:** Manual workflow

**Action:** `restart`

**Use when:**
- Services crashed
- Configuration change
- Memory leak suspected

**Duration:** 2-3 minutes

### 4. Rollback

**Trigger:** Manual workflow

**Action:** `rollback`

**Use when:**
- Bad deployment
- Critical bug introduced
- Services not working

**Duration:** 5-10 minutes

**Requires:** Backup ID from previous deployment

### 5. Status Check

**Trigger:** Manual workflow

**Action:** `status`

**Use when:**
- Checking system health
- Investigating issues
- Before major deployment

**Duration:** 1 minute

---

## Approving Deployments

### Who Can Approve

Configured in **Settings** → **Environments** → **production**

Typical approvers:
- DevOps Lead
- Security Lead
- CTO/Tech Lead (for major changes)

### Approval Process

1. **Notification:**
   - Email notification
   - GitHub notification
   - Slack/Discord (if configured)

2. **Review:**
   - Check test results (all green?)
   - Review code changes (safe?)
   - Check deployment plan (makes sense?)
   - Verify timing (good time to deploy?)

3. **Decision:**
   - **Approve:** Deployment proceeds
   - **Reject:** Deployment cancelled
   - **Comment:** Ask questions

4. **Action:**
   - Click notification link
   - Or go to Actions → Workflow run
   - Click **Review deployments**
   - Select environment
   - Comment (optional)
   - Click **Approve and deploy** or **Reject**

### Approval Checklist

Before approving production deployment:

- [ ] All tests passed
- [ ] Security scan passed
- [ ] Code reviewed and approved
- [ ] Database migrations tested
- [ ] Breaking changes documented
- [ ] Rollback plan ready
- [ ] Team notified
- [ ] Good timing (not Friday evening!)

---

## Viewing Deployment History

### Recent Deployments

**GitHub UI:**
1. Go to **Actions** tab
2. Filter by workflow:
   - `deploy-testnet.yml`
   - `deploy-production-manual.yml`
3. See all past runs

### Deployment Details

Click any workflow run to see:
- Trigger (push/manual)
- Actor (who triggered it)
- Commit (what was deployed)
- Duration
- Status (success/failed)
- Full logs
- Artifacts (if any)

### Deployment Artifacts

Some workflows save artifacts:
- Test reports
- Security scan results
- Build logs

**Download:**
1. Click workflow run
2. Scroll to **Artifacts** section
3. Click artifact name to download

---

## Rollback Procedures

### Via GitHub Actions

**Quick rollback:**
1. Go to **Actions**
2. Select **Deploy to Production (Manual)**
3. Click **Run workflow**
4. Action: `rollback`
5. Rollback tag: (backup timestamp)
6. Confirm: `YES`
7. Approve when requested

**Find backup ID:**
1. Check deployment summary from previous successful run
2. Or SSH to VPS: `ls -lh /opt/binance-traders/backups/`

### Via Manual Scripts

**If GitHub Actions is down:**

```powershell
# Local machine
.\scripts\deployment\rollback.ps1 -Environment production
```

Follows interactive prompts to select backup and rollback.

---

## Handling Failed Deployments

### Automatic Rollback

For `deploy` action, workflow automatically:
1. Checks health after deployment
2. If health check fails:
   - Triggers automatic rollback
   - Restores previous version
   - Verifies rollback success

### Manual Intervention

If automatic rollback fails:

1. **Check logs:**
   - GitHub Actions workflow logs
   - VPS container logs: `docker compose logs`

2. **Diagnose:**
   ```powershell
   .\scripts\deployment\diagnose.ps1 -Environment production
   ```

3. **Quick fixes:**
   - Restart services: `.\scripts\deployment\quick-restart.ps1`
   - Manual rollback: `.\scripts\deployment\rollback.ps1`

4. **Emergency:**
   - SSH to VPS
   - Check services: `docker compose ps`
   - View logs: `docker compose logs -f`
   - Manual rollback: `docker compose down && docker compose up -d`

### Common Failure Causes

**Build failures:**
- Maven compilation error
- Docker build failure
- Solution: Fix code, push new commit

**Transfer failures:**
- SSH connection timeout
- Disk space full
- Solution: Check VPS connectivity, free up space

**Deployment failures:**
- Container won't start
- Database migration failed
- Health check failed
- Solution: Check logs, rollback, fix issue

**Health check failures:**
- Service not responding
- Database connection failed
- External API unreachable
- Solution: Check service logs, verify configs

---

## Updating Secrets

### When to Update

- Every 90 days (scheduled rotation)
- After team member leaves
- After suspected breach
- When adding new service

### How to Update

1. **Generate new secrets:**
   ```powershell
   .\scripts\security\setup-secrets.ps1 -GenerateApiKeys
   ```

2. **Update GitHub Secrets:**
   - Go to **Settings** → **Secrets and variables** → **Actions**
   - Click secret name
   - Click **Update**
   - Paste new value
   - Click **Update secret**

3. **Update environment file:**
   ```powershell
   # Edit testnet.env with new values
   # Re-encrypt
   sops -e testnet.env > testnet.env.enc
   
   # Commit
   git add testnet.env.enc
   git commit -m "Update secrets"
   git push
   ```

4. **Deploy with new secrets:**
   - Automatic: Push triggers deployment
   - Or manual: Trigger production deployment workflow

### Rotating All Secrets

Use the **Rotate Secrets** workflow:

1. Go to **Actions**
2. Select **Rotate Secrets**
3. Click **Run workflow**
4. Select what to rotate:
   - `database_passwords`
   - `api_keys`
   - `age_keys`
   - `all`
5. Confirm: `YES`
6. Workflow generates new secrets
7. Follow instructions in workflow summary to update GitHub Secrets

---

## Debugging Failed Workflows

### Check Workflow Logs

1. Go to **Actions**
2. Click failed workflow run
3. Click failed job
4. Click failed step
5. Read error message

### Common Issues

**SSH connection failed:**
```
Permission denied (publickey)
```
**Solution:** Check `VPS_SSH_KEY` secret is correct

**SOPS decryption failed:**
```
failed to get the data key
```
**Solution:** Check `SOPS_AGE_KEY` secret matches `.sops.yaml`

**Docker build failed:**
```
Error building image
```
**Solution:** Check Dockerfile syntax, Maven build succeeded

**Health check failed:**
```
Health check: FAILED
```
**Solution:** Check service logs on VPS, verify configuration

### Re-running Failed Workflows

1. Go to failed workflow run
2. Click **Re-run jobs** (top right)
3. Select:
   - **Re-run failed jobs** (just failed steps)
   - **Re-run all jobs** (full workflow)

---

## Best Practices

### Deployment Timing

**Good times:**
- Mid-morning (10 AM - 12 PM)
- Mid-week (Tuesday - Thursday)
- After thorough testing
- When team is available

**Bad times:**
- Friday afternoon/evening
- Before holidays
- Late night (unless planned maintenance)
- During peak traffic

### Testing Before Deployment

Always verify:
1. All tests pass locally
2. Code reviewed and approved
3. Tested on testnet first
4. Database migrations tested
5. Rollback plan ready

### Communication

**Before deployment:**
- Notify team in Slack/Discord
- Update status page (if public)
- Confirm timing with stakeholders

**During deployment:**
- Monitor workflow progress
- Watch for errors
- Be ready to rollback

**After deployment:**
- Verify services healthy
- Monitor error rates
- Announce completion
- Document any issues

### Monitoring Post-Deployment

**First 15 minutes:**
- Watch Grafana dashboards
- Check error logs
- Verify critical features work
- Monitor response times

**First hour:**
- Check metrics trends
- Review user feedback
- Monitor resource usage
- Check for errors

**First day:**
- Review daily metrics
- Check for edge cases
- Monitor performance
- Gather team feedback

---

## Emergency Procedures

### GitHub Actions Down

**If GitHub is unavailable:**

Use manual deployment scripts:
```powershell
# Full deployment
.\scripts\deployment\manual-deploy-full.ps1 -Environment production

# Or quick restart
.\scripts\deployment\quick-restart.ps1 -Environment production

# Or rollback
.\scripts\deployment\rollback.ps1 -Environment production
```

See `scripts/deployment/EMERGENCY_COMMANDS.md` for quick reference.

### VPS Down

1. **Check VPS provider status**
2. **Try to connect:** `ssh binance-trader@145.223.70.118`
3. **If accessible:**
   ```bash
   docker compose ps
   docker compose logs
   docker compose restart
   ```
4. **If not accessible:**
   - Contact VPS provider
   - Check firewall rules
   - Verify network connectivity

### Critical Service Failure

1. **Immediate:**
   ```powershell
   .\scripts\deployment\diagnose.ps1 -Environment production -SaveReport
   ```

2. **Quick fix:**
   ```powershell
   .\scripts\deployment\quick-restart.ps1 -Environment production
   ```

3. **If still failing:**
   ```powershell
   .\scripts\deployment\rollback.ps1 -Environment production
   ```

4. **If rollback fails:**
   - SSH to VPS
   - Manual container restart
   - Check logs for root cause
   - Escalate to team

---

## Metrics and Monitoring

### Deployment Metrics

Track in Grafana:
- Deployment frequency
- Success rate
- Rollback rate
- Time to deploy
- Time to recover

### Key Indicators

**Healthy CI/CD:**
- >95% deployment success rate
- <5% rollback rate
- <15 minutes deployment time
- <10 minutes rollback time

**Red flags:**
- Multiple failed deployments
- Frequent rollbacks
- Long deployment times
- Repeated same errors

---

## Support and Escalation

### Getting Help

1. **Check documentation:**
   - This guide
   - `DEPLOYMENT_GUIDE.md`
   - `EMERGENCY_COMMANDS.md`

2. **Check workflow logs:**
   - GitHub Actions logs
   - VPS container logs

3. **Run diagnostics:**
   ```powershell
   .\scripts\deployment\diagnose.ps1
   ```

4. **Ask team:**
   - Slack #devops channel
   - Tag @devops-team

### Escalation Path

1. **Level 1:** DevOps team member
2. **Level 2:** DevOps lead
3. **Level 3:** CTO/Engineering lead

**Escalate immediately if:**
- Production down >15 minutes
- Data loss suspected
- Security breach suspected
- Cannot rollback

---

## Quick Reference

### Deployment Commands

```bash
# Testnet (automatic)
git push origin develop

# Production (manual)
# GitHub UI: Actions → Deploy to Production → Run workflow

# Quick restart
# GitHub UI: Actions → Deploy to Production → Action: restart

# Rollback
# GitHub UI: Actions → Deploy to Production → Action: rollback
```

### Emergency Commands

```powershell
# Diagnose
.\scripts\deployment\diagnose.ps1 -Environment production

# Quick restart
.\scripts\deployment\quick-restart.ps1 -Environment production

# Rollback
.\scripts\deployment\rollback.ps1 -Environment production

# Full manual deploy (if GitHub down)
.\scripts\deployment\manual-deploy-full.ps1 -Environment production
```

### Useful Links

- Actions: https://github.com/YOUR_REPO/actions
- Secrets: https://github.com/YOUR_REPO/settings/secrets/actions
- Environments: https://github.com/YOUR_REPO/settings/environments
- VPS Grafana: http://145.223.70.118/grafana/
- VPS Health: http://145.223.70.118/health

---

**Need help?** See `scripts/deployment/EMERGENCY_COMMANDS.md` for quick troubleshooting.

