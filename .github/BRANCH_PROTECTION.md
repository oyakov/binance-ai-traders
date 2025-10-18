# Branch Protection Configuration Guide

Configure branch protection rules and deployment environments for secure CI/CD workflow.

## Overview

This guide covers:
- Branch protection rules for `develop` and `main`
- Deployment environment setup
- Required reviewers and checks
- Best practices for team collaboration

---

## Branch Protection Rules

### Configure `develop` Branch

1. Go to repository **Settings** → **Branches**
2. Click **Add branch protection rule**
3. Branch name pattern: `develop`

**Configure these settings:**

**Protect matching branches:**
- ✅ Require a pull request before merging
  - ✅ Require approvals: **1**
  - ✅ Dismiss stale pull request approvals when new commits are pushed
  - ✅ Require review from Code Owners (if CODEOWNERS file exists)

**Require status checks to pass before merging:**
- ✅ Require status checks to pass
  - ✅ Require branches to be up to date before merging
  - Select status checks:
    - `Build Application`
    - `Run Tests`
    - `Build Docker Images`
    - `Security Scanning`

**Other settings:**
- ✅ Require conversation resolution before merging
- ✅ Do not allow bypassing the above settings

**Who can push:**
- Restrict pushes: Maintainers and administrators only

---

### Configure `main` Branch

1. Go to repository **Settings** → **Branches**
2. Click **Add branch protection rule**
3. Branch name pattern: `main`

**Configure these settings:**

**Protect matching branches:**
- ✅ Require a pull request before merging
  - ✅ Require approvals: **2** (more stringent for production)
  - ✅ Dismiss stale pull request approvals when new commits are pushed
  - ✅ Require review from Code Owners
  - ✅ Require approval of the most recent reviewable push

**Require status checks to pass before merging:**
- ✅ Require status checks to pass
  - ✅ Require branches to be up to date before merging
  - Select all status checks from `develop` plus:
    - `Integration Tests`
    - `Security Scanning`

**Additional protections:**
- ✅ Require deployments to succeed before merging (if using deployment gates)
- ✅ Require conversation resolution before merging
- ✅ Require signed commits (recommended for production)
- ✅ Do not allow bypassing the above settings

**Who can push:**
- Restrict pushes: Administrators only
- Allow force pushes: **Never**
- Allow deletions: **Never**

---

## Deployment Environments

### Create Testnet Environment

1. Go to **Settings** → **Environments**
2. Click **New environment**
3. Name: `testnet`

**Configure:**

**Deployment branches:**
- Select **Selected branches**
- Add rule: `develop`

**Environment secrets:**
(Optional - overrides repository secrets)
- `VPS_HOST`: 145.223.70.118
- `VPS_USER`: binance-trader
- `VPS_SSH_KEY`: Testnet SSH key
- `SOPS_AGE_KEY`: Testnet age key

**Protection rules:**
- Wait timer: **0 minutes** (immediate deployment)
- Required reviewers: **None** (automatic deployment)

---

### Create Production Environment

1. Go to **Settings** → **Environments**
2. Click **New environment**
3. Name: `production`

**Configure:**

**Deployment branches:**
- Select **Selected branches**
- Add rule: `main`

**Environment secrets:**
- `PROD_VPS_HOST`: Production VPS IP
- `PROD_VPS_USER`: Production user
- `PROD_VPS_SSH_KEY`: Production SSH key
- `PROD_SOPS_AGE_KEY`: Production age key

**Protection rules:**
- Required reviewers: **Select team members** (minimum 1-2)
- Wait timer: **5 minutes** (allows abort if needed)
- Prevent self-review: ✅ Enabled

**Environment protection:**
- Only allow deployments from protected branches
- Prevent administrator bypass

---

## Rulesets (GitHub's New Feature)

If using GitHub Rulesets (Beta):

### Testnet Ruleset

**Target:** Branch `develop`

**Rules:**
1. Require pull request
   - Required approvals: 1
   - Dismiss stale reviews: Yes

2. Require status checks
   - Build and Test workflow
   - Security scan

3. Block force pushes
4. Require linear history (optional)

### Production Ruleset

**Target:** Branch `main`

**Rules:**
1. Require pull request
   - Required approvals: 2
   - Dismiss stale reviews: Yes
   - Require fresh approval after changes

2. Require status checks
   - All checks from develop
   - Integration tests
   - Security scan pass

3. Block force pushes
4. Block deletions
5. Require signed commits
6. Restrict who can push: Admins only

---

## CODEOWNERS File

Create `.github/CODEOWNERS` for automatic reviewer assignment:

```
# Global owners
* @your-github-username

# Backend services
binance-trader-macd/**          @backend-team-lead
binance-data-collection/**      @backend-team-lead
binance-data-storage/**         @backend-team-lead

# Infrastructure
docker-compose*.yml             @devops-team
nginx/**                        @devops-team
.github/workflows/**            @devops-team

# Security-sensitive files
.github/workflows/deploy-*.yml  @security-lead @devops-team
scripts/security/**             @security-lead
.sops.yaml                      @security-lead

# Documentation
*.md                            @documentation-team
```

---

## Workflow Permissions

### Configure Actions Permissions

1. Go to **Settings** → **Actions** → **General**

**Actions permissions:**
- Select: **Allow all actions and reusable workflows**
  - Or: **Allow actions created by GitHub and verified creators**

**Workflow permissions:**
- Select: **Read repository contents and packages permissions**
  - ✅ Allow GitHub Actions to create and approve pull requests (if needed for automation)

**Fork pull request workflows:**
- ✅ Require approval for first-time contributors
- ✅ Require approval for all outside collaborators

---

## Team Configuration

### Create Teams

1. Go to **Organization** → **Teams** (or configure collaborators for personal repos)

**Recommended teams:**

**Backend Team**
- Access: Write
- Areas: Java services, APIs

**DevOps Team**
- Access: Maintain
- Areas: CI/CD, infrastructure, deployments

**Security Team**
- Access: Maintain
- Areas: Security configs, secrets, monitoring

### Assign Team Permissions

**Repository permissions:**
- Backend Team: Write
- DevOps Team: Maintain
- Security Team: Maintain
- Admins: Admin

**Branch protections:**
- `develop`: Backend + DevOps review required
- `main`: DevOps + Security review required

---

## Status Checks

### Required Status Checks

Configure these checks to pass before merge:

**For `develop` branch:**
- ✅ `build / Build Application`
- ✅ `test / Run Tests`
- ✅ `docker-build / Build Docker Images`
- ✅ `security-scan / Security Scanning`

**For `main` branch:**
- ✅ All checks from `develop`
- ✅ `integration-test / Integration Tests`
- ✅ Manual approval for production deployment

### Configuring Status Checks

1. After setting up workflows, push a test PR
2. Wait for checks to complete
3. Go to branch protection settings
4. Under "Require status checks", select the checks that appeared

---

## Deployment Approvals

### Setup Deployment Reviewers

**For Production Environment:**

1. Go to **Settings** → **Environments** → **production**
2. Under **Deployment protection rules**:
   - Add required reviewers:
     - DevOps Lead
     - Security Lead
     - (Optional) CTO/Tech Lead for critical deployments
3. Configure:
   - ✅ Prevent administrators from bypassing required reviews
   - Wait timer: 5-10 minutes

**Approval Process:**
1. Developer triggers manual production deployment
2. Workflow pauses and requests approval
3. Reviewers receive notification
4. One reviewer checks:
   - Test results pass
   - No critical security issues
   - Deployment plan reviewed
5. Reviewer approves deployment
6. Workflow continues automatically

---

## Best Practices

### Branch Strategy

**Branches:**
- `main`: Production-ready code only
- `develop`: Integration branch for features
- `feature/*`: Individual feature branches
- `hotfix/*`: Emergency production fixes

**Workflow:**
```
feature/new-api
    ↓ (PR + 1 approval)
develop
    ↓ (PR + 2 approvals)
main
```

### Pull Request Guidelines

**Required in PR:**
- Clear description of changes
- Link to issue/ticket
- Test results
- Breaking changes noted
- Migration steps (if database changes)

**Review checklist:**
- Code quality and standards
- Test coverage
- Security considerations
- Performance impact
- Documentation updated

### Deployment Guidelines

**Testnet (Automatic):**
- Deploys on merge to `develop`
- No approval needed
- Runs all tests first

**Production (Manual):**
- Manual trigger only
- Requires 1-2 approvals
- Full test suite must pass
- Security scan must pass
- Can rollback automatically on failure

---

## Troubleshooting

### Status Checks Not Appearing

**Problem:** Can't find status checks in branch protection

**Solution:**
1. Push a PR that triggers the workflow
2. Wait for workflow to complete
3. Refresh branch protection settings
4. Status checks will appear in list

### Deployment Blocked

**Problem:** Can't deploy to production

**Solution:**
1. Check environment protection rules
2. Verify you have deployment branch permissions
3. Ensure required reviewers are configured
4. Check if wait timer is active

### Can't Merge PR

**Problem:** PR blocked despite passing tests

**Solution:**
1. Ensure branch is up to date with base branch
2. Check all required status checks passed
3. Verify required number of approvals
4. Check conversation resolution requirement

---

## Quick Reference

### Enable Branch Protection (CLI)

```bash
# Using GitHub CLI
gh api repos/:owner/:repo/branches/develop/protection \
  -X PUT \
  -f required_status_checks='{"strict":true,"contexts":["build","test"]}' \
  -f enforce_admins=true \
  -f required_pull_request_reviews='{"required_approving_review_count":1}'
```

### Check Current Protection

```bash
gh api repos/:owner/:repo/branches/develop/protection
```

---

## Next Steps

After configuring branch protection:

1. ✅ Test with a sample PR to `develop`
2. ✅ Verify all status checks run
3. ✅ Test deployment approval workflow
4. ✅ Document process for team
5. ✅ Train team on new workflow
6. ✅ Monitor for issues in first week

**Ready!** Your repository is now protected with proper CI/CD gates.

