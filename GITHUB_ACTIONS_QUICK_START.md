# GitHub Actions CI/CD - Quick Start Guide

**Ready to deploy!** Follow these 3 simple steps to activate automatic deployments.

---

## ⚡ 3-Step Quick Start

### Step 1: Generate Keys (5 minutes)

```powershell
# Generate SSH deployment key
ssh-keygen -t ed25519 -C "github-deploy" -f $HOME\.ssh\github-deploy-key

# Generate age encryption key
age-keygen -o $HOME\github-age-key.txt

# View your keys
Get-Content $HOME\.ssh\github-deploy-key.pub
Get-Content $HOME\github-age-key.txt
```

**Save both keys!** You'll need them in the next steps.

### Step 2: Add SSH Key to VPS (3 minutes)

```powershell
# Copy public key to VPS
$pubKey = Get-Content $HOME\.ssh\github-deploy-key.pub
ssh binance-trader@145.223.70.118 "echo '$pubKey' >> ~/.ssh/authorized_keys"

# Test connection
ssh -i $HOME\.ssh\github-deploy-key binance-trader@145.223.70.118 whoami
# Should print: binance-trader
```

### Step 3: Add Secrets to GitHub (10 minutes)

1. Go to: https://github.com/YOUR_USERNAME/binance-ai-traders/settings/secrets/actions
2. Click **New repository secret**
3. Add these 4 secrets:

| Secret Name | Value | Where to Get It |
|-------------|-------|-----------------|
| `VPS_HOST` | `145.223.70.118` | Your VPS IP |
| `VPS_USER` | `binance-trader` | Deployment user |
| `VPS_SSH_KEY` | Private key content | `cat $HOME\.ssh\github-deploy-key` |
| `SOPS_AGE_KEY` | Age secret key | Line starting with `AGE-SECRET-KEY-` from `$HOME\github-age-key.txt` |

**For VPS_SSH_KEY:** Copy the ENTIRE private key including `-----BEGIN OPENSSH PRIVATE KEY-----` and `-----END OPENSSH PRIVATE KEY-----`

**For SOPS_AGE_KEY:** Copy ONLY the line starting with `AGE-SECRET-KEY-1...`

---

## ✅ Test Your Setup (5 minutes)

### Test 1: Automatic Testnet Deployment

```bash
# Make a small test change
echo "# Test deployment" >> README.md

# Commit and push to develop
git checkout develop
git add README.md
git commit -m "Test: GitHub Actions deployment"
git push origin develop

# Watch deployment
# Go to: https://github.com/YOUR_USERNAME/binance-ai-traders/actions
# You should see "Deploy to Testnet" workflow running
```

**Expected time:** 10-15 minutes

**Result:** Your code automatically deployed to http://145.223.70.118/

### Test 2: Manual Production Workflow

```text
1. Go to: https://github.com/YOUR_USERNAME/binance-ai-traders/actions
2. Click: "Deploy to Production (Manual)"
3. Click: "Run workflow"
4. Fill in:
   - Environment: testnet (for testing)
   - Action: status
   - Confirm: YES
5. Click: "Run workflow"

This checks VPS status without deploying anything.
```

---

## 🎉 You're Ready!

**What happens now:**

- ✅ Every push to `develop` → automatic testnet deployment
- ✅ Manual production deployment available in Actions tab
- ✅ All tests run before deployment
- ✅ Security scanning enabled
- ✅ Automatic rollback on failure
- ✅ Full audit trail

---

## 📚 Complete Documentation

| Document | What It Covers |
|----------|----------------|
| `.github/SECRETS_SETUP.md` | Detailed secrets setup with screenshots |
| `.github/CICD_OPERATIONS.md` | Daily operations, monitoring, troubleshooting |
| `.github/BRANCH_PROTECTION.md` | Branch protection and environment setup |
| `scripts/deployment/EMERGENCY_COMMANDS.md` | Quick reference for emergencies |
| `GITHUB_ACTIONS_IMPLEMENTATION_COMPLETE.md` | Full implementation summary |

---

## 🔧 Manual Deployment (Backup)

If GitHub Actions is unavailable, use manual scripts:

```powershell
# Full deployment
.\scripts\deployment\manual-deploy-full.ps1 -Environment testnet

# Quick restart
.\scripts\deployment\quick-restart.ps1 -Environment testnet

# Rollback
.\scripts\deployment\rollback.ps1 -Environment testnet

# Diagnostics
.\scripts\deployment\diagnose.ps1 -Environment testnet
```

---

## 🚨 Common Issues

### "SSH Permission Denied"

**Fix:** Check VPS_SSH_KEY includes full private key with headers

### "SOPS Decryption Failed"

**Fix:** Verify SOPS_AGE_KEY matches the public key in `.sops.yaml`

### "Workflow Not Triggering"

**Fix:** Push to `develop` branch (not `main`). Check paths-ignore in workflow.

---

## 🎯 Production Deployment Setup

When ready for production:

1. **Generate separate production keys:**
   ```powershell
   ssh-keygen -t ed25519 -f $HOME\.ssh\prod-deploy-key
   age-keygen -o $HOME\prod-age-key.txt
   ```

2. **Add production secrets:**
   - `PROD_VPS_HOST`: Production VPS IP
   - `PROD_VPS_USER`: Production user
   - `PROD_VPS_SSH_KEY`: Production SSH private key
   - `PROD_SOPS_AGE_KEY`: Production age secret key

3. **Set up environment protection:**
   - Go to Settings → Environments
   - Create `production` environment
   - Add required reviewers
   - Configure deployment branches

4. **Deploy to production:**
   - Actions → Deploy to Production (Manual)
   - Environment: production
   - Action: deploy
   - Confirm: YES
   - Approve when requested

---

## 💡 Pro Tips

**Daily Workflow:**
```bash
# Work on feature
git checkout -b feature/my-feature
# Make changes
git commit -m "Add new feature"
git push origin feature/my-feature

# Create PR to develop
# After approval, merge
# Automatic deployment to testnet starts!

# Test on testnet: http://145.223.70.118/

# When ready, create PR from develop to main
# After approval, manually deploy to production
```

**Monitoring:**
- Testnet Grafana: http://145.223.70.118/grafana/
- Testnet Health: http://145.223.70.118/health
- GitHub Actions: https://github.com/YOUR_REPO/actions

**Emergency:**
- See `scripts/deployment/EMERGENCY_COMMANDS.md`
- Contact DevOps team
- Use manual deployment scripts

---

## ✨ What's Next?

1. ✅ **Setup Complete** - You just finished this!
2. ⏭️ **Test Deployment** - Push a test change
3. ⏭️ **Configure Branch Protection** - See `.github/BRANCH_PROTECTION.md`
4. ⏭️ **Train Team** - Share documentation
5. ⏭️ **Setup Production** - Add production secrets
6. ⏭️ **Deploy to Production** - Use manual workflow

---

**Need help?** See `.github/CICD_OPERATIONS.md` for complete guide.

**Questions?** Check `GITHUB_ACTIONS_IMPLEMENTATION_COMPLETE.md` for all details.

**Ready!** Push to `develop` and watch the magic happen! 🚀

