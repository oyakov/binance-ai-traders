# GitHub Secrets Setup Guide

Complete guide for configuring GitHub Actions secrets for automated deployment.

## Overview

This guide walks you through setting up all required GitHub Secrets for automated deployment to testnet and production environments.

## Prerequisites

- Repository administrator access
- SSH access to target VPS(s)
- SOPS and age installed locally (see `scripts/deployment/install-tools.ps1`)

---

## Step 1: Generate SSH Deployment Keys

### 1.1 Generate SSH Key Pair

On your **local machine**, generate a dedicated SSH key for GitHub Actions deployment:

```bash
ssh-keygen -t ed25519 -C "github-deploy" -f github-deploy-key
```

Press Enter three times (no passphrase for automated deployment).

This creates:
- `github-deploy-key` (private key - for GitHub Secret)
- `github-deploy-key.pub` (public key - for VPS)

### 1.2 Add Public Key to Testnet VPS

```bash
# Copy public key to testnet VPS
scp github-deploy-key.pub root@145.223.70.118:/tmp/

# SSH to VPS and install key
ssh root@145.223.70.118

# On VPS:
mkdir -p /home/binance-trader/.ssh
cat /tmp/github-deploy-key.pub >> /home/binance-trader/.ssh/authorized_keys
chmod 700 /home/binance-trader/.ssh
chmod 600 /home/binance-trader/.ssh/authorized_keys
chown -R binance-trader:binance-trader /home/binance-trader/.ssh
rm /tmp/github-deploy-key.pub
exit
```

### 1.3 Test SSH Key

```bash
ssh -i github-deploy-key binance-trader@145.223.70.118 whoami
# Should print: binance-trader
```

### 1.4 Repeat for Production VPS (if different)

If you have a separate production VPS, repeat steps 1.2-1.3 for that server.

---

## Step 2: Generate age Encryption Keys

### 2.1 Generate age Key for SOPS

```bash
age-keygen -o github-age-key.txt
```

Output will show:
```
# created: 2025-10-18T...
# public key: age1abcd...xyz
AGE-SECRET-KEY-1ABC...XYZ
```

**Save both the public key and secret key!**

### 2.2 Update SOPS Configuration

Edit `.sops.yaml` and add the age public key:

```yaml
creation_rules:
  - path_regex: testnet\.env$
    age: >-
      age1abcd...xyz  # Replace with YOUR public key
  - path_regex: production\.env$
    age: >-
      age1abcd...xyz  # Replace with YOUR public key (or use different key)
```

### 2.3 Encrypt Environment Files

```bash
# Create testnet.env from template
cp testnet.env.template testnet.env

# Fill in all values in testnet.env
# Then encrypt it
export SOPS_AGE_KEY_FILE=github-age-key.txt
sops -e testnet.env > testnet.env.enc

# Delete plaintext
rm testnet.env

# Commit encrypted file
git add testnet.env.enc .sops.yaml
git commit -m "Add encrypted testnet environment"
```

---

## Step 3: Add Secrets to GitHub Repository

### 3.1 Navigate to Repository Secrets

1. Go to your GitHub repository
2. Click **Settings** tab
3. In left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret**

### 3.2 Required Secrets for Testnet

Add these secrets one by one:

| Secret Name | Value | How to Get |
|-------------|-------|------------|
| `VPS_HOST` | `145.223.70.118` | Your testnet VPS IP address |
| `VPS_USER` | `binance-trader` | Deployment user on VPS |
| `VPS_SSH_KEY` | Contents of `github-deploy-key` | `cat github-deploy-key` |
| `SOPS_AGE_KEY` | Secret key from `github-age-key.txt` | Line starting with `AGE-SECRET-KEY-` |

**For VPS_SSH_KEY:**
```bash
# Copy entire private key including headers
cat github-deploy-key

# Output will be:
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
...
-----END OPENSSH PRIVATE KEY-----

# Copy ALL of this (including BEGIN/END lines) into the GitHub Secret
```

**For SOPS_AGE_KEY:**
```bash
# Copy the secret key line
cat github-age-key.txt | grep "AGE-SECRET-KEY"

# Output: AGE-SECRET-KEY-1ABC...XYZ
# Copy ONLY this line (not the public key or comments)
```

### 3.3 Optional Secrets

| Secret Name | Value | Purpose |
|-------------|-------|---------|
| `SLACK_WEBHOOK_URL` | Slack webhook URL | Deployment notifications |
| `DISCORD_WEBHOOK_URL` | Discord webhook URL | Deployment notifications |

### 3.4 Production Secrets (for manual production deployments)

If you have a production environment, add these additional secrets:

| Secret Name | Value | Notes |
|-------------|-------|-------|
| `PROD_VPS_HOST` | Production VPS IP | Different from testnet |
| `PROD_VPS_USER` | Production user | Usually same: `binance-trader` |
| `PROD_VPS_SSH_KEY` | Production SSH private key | Can be same or different |
| `PROD_SOPS_AGE_KEY` | Production age secret key | **Must be different from testnet!** |

---

## Step 4: Configure GitHub Environments

### 4.1 Create Production Environment

1. Go to **Settings** → **Environments**
2. Click **New environment**
3. Name: `production`
4. Click **Configure environment**

### 4.2 Add Environment Protection Rules

**Required reviewers:**
- Add yourself and/or team members who must approve production deployments
- Minimum: 1 reviewer

**Deployment branches:**
- Select **Selected branches**
- Add `main` branch

**Environment secrets:**
You can add production-specific secrets here that override repository secrets:
- `VPS_HOST` → Production VPS IP
- `VPS_USER` → Production user
- `VPS_SSH_KEY` → Production SSH key
- `SOPS_AGE_KEY` → Production age key

### 4.3 Create Testnet Environment (Optional)

Repeat for testnet if you want separate environment protection:
- Name: `testnet`
- No required reviewers (auto-deploy)
- Deployment branches: `develop`

---

## Step 5: Verify Setup

### 5.1 Check All Secrets Are Added

Go to **Settings** → **Secrets and variables** → **Actions**

You should see:
- VPS_HOST
- VPS_USER
- VPS_SSH_KEY
- SOPS_AGE_KEY
- (Optional) SLACK_WEBHOOK_URL
- (Optional) PROD_* secrets

### 5.2 Test SSH Connection from GitHub Actions

Create a test workflow to verify SSH works:

```yaml
name: Test SSH Connection
on: workflow_dispatch

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Setup SSH
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.VPS_SSH_KEY }}" > ~/.ssh/deploy_key
          chmod 600 ~/.ssh/deploy_key
          ssh-keyscan -H ${{ secrets.VPS_HOST }} >> ~/.ssh/known_hosts
      
      - name: Test Connection
        run: |
          ssh -i ~/.ssh/deploy_key ${{ secrets.VPS_USER }}@${{ secrets.VPS_HOST }} \
            "echo 'SSH connection successful!'"
```

Run this workflow manually from the Actions tab. If it succeeds, your SSH setup is correct!

### 5.3 Test SOPS Decryption

```yaml
name: Test SOPS Decryption
on: workflow_dispatch

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install SOPS and age
        run: |
          wget -q https://github.com/getsops/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64
          chmod +x sops-v3.8.1.linux.amd64
          sudo mv sops-v3.8.1.linux.amd64 /usr/local/bin/sops
          
          wget -q https://github.com/FiloSottile/age/releases/download/v1.1.1/age-v1.1.1-linux-amd64.tar.gz
          tar xzf age-v1.1.1-linux-amd64.tar.gz
          sudo mv age/age age/age-keygen /usr/local/bin/
      
      - name: Test Decryption
        run: |
          echo "${{ secrets.SOPS_AGE_KEY }}" > age-key.txt
          export SOPS_AGE_KEY_FILE=age-key.txt
          sops -d testnet.env.enc | head -5
          echo "Decryption successful!"
```

---

## Security Best Practices

### Do's ✅

- **Use separate age keys** for testnet and production
- **Rotate keys regularly** (every 90 days)
- **Use environment-specific secrets** for production
- **Require reviewers** for production deployments
- **Audit secret access** regularly in GitHub logs
- **Delete local private keys** after adding to GitHub (or store securely)

### Don'ts ❌

- **Never commit private keys** to repository
- **Never share age secret keys** via insecure channels
- **Never use same SSH key** for multiple environments
- **Never skip encryption** for environment files
- **Never commit decrypted .env files**

---

## Troubleshooting

### SSH Connection Fails

**Error:** `Permission denied (publickey)`

**Solution:**
```bash
# Verify key format
cat github-deploy-key | head -1
# Should be: -----BEGIN OPENSSH PRIVATE KEY-----

# Verify key is added to VPS
ssh root@145.223.70.118
cat /home/binance-trader/.ssh/authorized_keys
# Should contain your public key

# Check permissions
ls -la /home/binance-trader/.ssh/
# Should be: drwx------ (700) and -rw------- (600)
```

### SOPS Decryption Fails

**Error:** `failed to get the data key required to decrypt the SOPS file`

**Solution:**
```bash
# Verify age key format
echo "$SOPS_AGE_KEY" | head -c 20
# Should start with: AGE-SECRET-KEY-1

# Verify .sops.yaml has correct public key
grep "age:" .sops.yaml
# Should match the public key from age-keygen

# Test locally
export SOPS_AGE_KEY="AGE-SECRET-KEY-1..."
sops -d testnet.env.enc
# Should decrypt successfully
```

### Workflow Can't Find Secrets

**Error:** `secret VPS_HOST not found`

**Solution:**
- Verify secret name matches exactly (case-sensitive)
- Check secret is in repository secrets, not environment secrets
- If using environment, verify workflow references correct environment

---

## Key Rotation

### When to Rotate

- Every 90 days (scheduled)
- After team member leaves
- After security incident
- After key compromise suspected

### How to Rotate SSH Keys

1. Generate new SSH key pair
2. Add new public key to VPS (don't remove old yet)
3. Update `VPS_SSH_KEY` secret in GitHub
4. Test deployment with new key
5. Remove old public key from VPS

### How to Rotate age Keys

1. Generate new age key: `age-keygen -o new-age-key.txt`
2. Update `.sops.yaml` with new public key
3. Re-encrypt environment files:
   ```bash
   export SOPS_AGE_KEY_FILE=old-age-key.txt
   sops -d testnet.env.enc > testnet.env
   
   export SOPS_AGE_KEY_FILE=new-age-key.txt
   sops -e testnet.env > testnet.env.enc
   rm testnet.env
   ```
4. Update `SOPS_AGE_KEY` secret in GitHub
5. Commit updated `.sops.yaml` and `testnet.env.enc`
6. Test deployment

---

## Quick Reference

### Copy Private Key to Clipboard

**Windows PowerShell:**
```powershell
Get-Content github-deploy-key | Set-Clipboard
```

**Linux/Mac:**
```bash
cat github-deploy-key | pbcopy  # Mac
cat github-deploy-key | xclip   # Linux
```

### View Current Secrets

Go to: `https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions`

### Test Deployment

Push to `develop` branch to trigger automatic testnet deployment.

---

## Next Steps

After completing this setup:

1. ✅ All secrets added to GitHub
2. ✅ Environments configured with protection rules
3. ✅ SSH and SOPS tested successfully
4. 📋 Review deployment workflows in `.github/workflows/`
5. 📋 Test automatic deployment by pushing to `develop`
6. 📋 Test manual production deployment workflow
7. 📋 Set up monitoring for deployment notifications

**Ready to deploy!** Push to `develop` branch to trigger your first automated deployment.

