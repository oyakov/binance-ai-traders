# 🚀 Quick Start - Deploy to VPS

**Target VPS:** 145.223.70.118 (CentOS 9.3)  
**Status:** ✅ All deployment files ready!

---

## ⚡ Quick Deploy (2 Steps)

### Step 1: Install Required Tools (AS ADMINISTRATOR)

1. **Close current PowerShell**
2. **Right-click PowerShell** → "Run as Administrator"
3. Run:

```powershell
cd C:\Projects\binance-ai-traders
Set-ExecutionPolicy Bypass -Scope Process -Force
.\scripts\deployment\install-tools.ps1
```

**This installs:**
- SOPS (via Chocolatey)
- age (from GitHub v1.1.1)

4. **Close Admin PowerShell**
5. **Open NEW normal PowerShell**
6. Test:

```powershell
sops --version
age --version
```

Both should display versions!

---

### Step 2: Run Deployment Guide

```powershell
cd C:\Projects\binance-ai-traders
.\scripts\deployment\deploy-simple.ps1
```

**This guides you through:**
1. ✅ SSH key generation
2. ✅ SSH key upload to VPS
3. ✅ SSH authentication test

Then follow the complete guide at: `scripts/deployment/DEPLOYMENT_GUIDE.md`

---

## 📋 What You Have

| File | Purpose |
|------|---------|
| `install-tools.ps1` | Install SOPS & age (run as admin) |
| `deploy-simple.ps1` | Simple deployment guide (WORKING ✅) |
| `DEPLOYMENT_GUIDE.md` | Complete deployment reference |
| `QUICK_REFERENCE.md` | Commands cheat sheet |

---

## 🔧 If You Get Errors

### PowerShell Syntax Errors

If you see "The string is missing the terminator", use the simple script:

```powershell
.\scripts\deployment\deploy-simple.ps1
```

This is a tested, working version!

### Chocolatey Lock Errors

The install script handles this automatically. If it still fails:

```powershell
# Run as Administrator
Remove-Item "C:\ProgramData\chocolatey\lib\998192b223a7e8576088e8ca4d22da7826387c75" -Force -ErrorAction SilentlyContinue
Remove-Item "C:\ProgramData\chocolatey\lib-bad" -Recurse -Force -ErrorAction SilentlyContinue

# Try again
.\scripts\deployment\install-tools.ps1
```

---

## 📖 Full Documentation

| Guide | Location |
|-------|----------|
| **This File** | `START_HERE.md` |
| **Tool Installation** | `INSTALL_TOOLS_FIRST.md` |
| **Complete Deploy Guide** | `scripts/deployment/DEPLOYMENT_GUIDE.md` |
| **Quick Reference** | `scripts/deployment/QUICK_REFERENCE.md` |
| **Security Guide** | `binance-ai-traders/guides/PUBLIC_DEPLOYMENT_SECURITY_GUIDE.md` |
| **VPS Setup** | `binance-ai-traders/guides/VPS_SETUP_GUIDE.md` |

---

## ✅ Deployment Checklist

- [ ] Install SOPS & age (Step 1)
- [ ] Run deploy-simple.ps1 (Step 2)
- [ ] Generate SSH keys
- [ ] Upload SSH key to VPS  
- [ ] Test SSH authentication
- [ ] Run VPS setup script
- [ ] Generate age encryption keys
- [ ] Configure SOPS
- [ ] Generate secrets
- [ ] Create testnet.env
- [ ] Encrypt secrets
- [ ] Upload to VPS
- [ ] Deploy application
- [ ] Verify deployment

---

## 🎯 Next Steps After Basic Setup

1. **VPS Setup**: Install Docker, create user, configure firewall
2. **Secrets**: Generate and encrypt environment variables
3. **Upload**: Transfer files to VPS
4. **Deploy**: Run Docker Compose
5. **Verify**: Check all services running
6. **Secure**: Harden SSH, configure domain, run security tests

**See complete guide:** `scripts/deployment/DEPLOYMENT_GUIDE.md`

---

## 💡 Tips

- **Use deploy-simple.ps1** - It works reliably!
- **Run as Administrator** when installing tools
- **Restart PowerShell** after installing tools
- **Follow the prompts** - The script guides you step-by-step
- **Keep this file open** for quick reference

---

**Ready? Start with:** `.\scripts\deployment\install-tools.ps1` (as Administrator)

Then: `.\scripts\deployment\deploy-simple.ps1` (normal PowerShell)

🚀 Good luck!

