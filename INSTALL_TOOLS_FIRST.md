# ⚠️ Install Required Tools First!

Before running the deployment script, you need to install **SOPS** and **age** for secrets encryption.

## Quick Install (Recommended)

### Step 1: Run as Administrator

1. **Close your current PowerShell window**
2. **Right-click PowerShell icon**
3. **Select "Run as Administrator"**
4. Navigate to project:
   ```powershell
   cd C:\Projects\binance-ai-traders
   ```

### Step 2: Run Installation Script

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\scripts\deployment\install-tools.ps1
```

This script will:
- ✅ Clean up Chocolatey lock files
- ✅ Install SOPS via Chocolatey  
- ✅ Download and install age from GitHub (v1.1.1)
- ✅ Add age to system PATH
- ✅ Verify both tools installed correctly

### Step 3: Restart PowerShell

**Important!** After installation:
1. Close the Administrator PowerShell
2. Open a **NEW** normal PowerShell (not admin)
3. Test the tools:
   ```powershell
   sops --version
   age --version
   ```

Both commands should display version information.

---

## Alternative: Manual Installation

If the script doesn't work, install manually:

### SOPS (via Chocolatey - requires admin)

```powershell
# Remove Chocolatey lock files first
Remove-Item "C:\ProgramData\chocolatey\lib\998192b223a7e8576088e8ca4d22da7826387c75" -Force -ErrorAction SilentlyContinue
Remove-Item "C:\ProgramData\chocolatey\lib-bad" -Recurse -Force -ErrorAction SilentlyContinue

# Install SOPS
choco install sops -y --force
```

### age (Manual Download - requires admin)

1. **Download age** from GitHub:
   - URL: https://github.com/FiloSottile/age/releases/download/v1.1.1/age-v1.1.1-windows-amd64.zip

2. **Extract the ZIP file**
   - Extract to a temporary folder

3. **Copy files** to `C:\Program Files\age\`:
   ```powershell
   New-Item -ItemType Directory -Path "C:\Program Files\age" -Force
   # Copy age.exe and age-keygen.exe to this directory
   ```

4. **Add to PATH** (as Administrator):
   ```powershell
   $installPath = "C:\Program Files\age"
   $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
   [Environment]::SetEnvironmentVariable("Path", "$currentPath;$installPath", "Machine")
   ```

5. **Restart PowerShell** and test:
   ```powershell
   age --version
   ```

---

## Why These Tools?

### SOPS (Secrets OPerationS)
- Encrypts environment files (testnet.env)
- Industry-standard secrets management
- Safe to commit encrypted files to git

### age (Actually Good Encryption)
- Modern, secure encryption tool
- Used by SOPS for file encryption
- Simple and auditable

---

## After Installation

Once both tools are installed and verified:

```powershell
# Open normal PowerShell (not admin)
cd C:\Projects\binance-ai-traders

# Run deployment script
.\scripts\deployment\step-by-step-deploy.ps1
```

---

## Troubleshooting

### "SOPS: command not found"
- Run PowerShell as Administrator
- Run: `choco install sops -y --force`
- Restart PowerShell

### "age: command not found" 
- Check if age is in PATH:
  ```powershell
  $env:Path
  ```
- Should include `C:\Program Files\age`
- If not, restart PowerShell or restart computer

### Chocolatey Lock Errors
- Delete lock files:
  ```powershell
  Remove-Item "C:\ProgramData\chocolatey\lib\998192b223a7e8576088e8ca4d22da7826387c75" -Force
  Remove-Item "C:\ProgramData\chocolatey\lib-bad" -Recurse -Force
  ```
- Try again

### Permission Denied
- **You MUST run PowerShell as Administrator**
- Right-click PowerShell → "Run as Administrator"

---

## Need Help?

If installation fails:

1. **Check admin privileges**: Run PowerShell as Administrator
2. **Check internet connection**: Downloads require internet
3. **Check antivirus**: May block downloads (temporarily disable)
4. **Manual fallback**: Use manual installation steps above

---

**After successful installation, proceed to:** `.\scripts\deployment\step-by-step-deploy.ps1`

