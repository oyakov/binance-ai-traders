<#
.SYNOPSIS
    Test security controls for binance-ai-traders deployment

.DESCRIPTION
    Comprehensive security validation script that tests all security controls
    including secrets protection, network security, authentication, and firewall rules.

.PARAMETER RemoteHost
    Remote VPS hostname or IP address for external tests

.PARAMETER SshPort
    SSH port number (default: 2222)

.PARAMETER Domain
    Domain name for HTTPS tests (default: localhost)

.EXAMPLE
    .\test-security-controls.ps1
    Runs local security tests

.EXAMPLE
    .\test-security-controls.ps1 -RemoteHost "your-vps.com" -Domain "your-domain.com"
    Runs tests against remote deployment

.NOTES
    Author: Binance AI Traders Security Team
    Version: 1.0
    Requires: curl, Docker
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$RemoteHost = "localhost",
    
    [Parameter()]
    [int]$SshPort = 2222,
    
    [Parameter()]
    [string]$Domain = "localhost"
)

# Set strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Colors for output
$ColorReset = "`e[0m"
$ColorGreen = "`e[32m"
$ColorYellow = "`e[33m"
$ColorRed = "`e[31m"
$ColorCyan = "`e[36m"

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = $ColorReset
    )
    Write-Host "${Color}${Message}${ColorReset}"
}

function Test-Security {
    param(
        [string]$TestName,
        [scriptblock]$TestBlock
    )
    
    Write-Host -NoNewline "  Testing $TestName... "
    
    try {
        $result = & $TestBlock
        if ($result) {
            Write-ColorOutput "✓ PASS" $ColorGreen
            return $true
        } else {
            Write-ColorOutput "✗ FAIL" $ColorRed
            return $false
        }
    } catch {
        Write-ColorOutput "✗ ERROR: $_" $ColorRed
        return $false
    }
}

# Counters
$totalTests = 0
$passedTests = 0
$failedTests = 0

# Main script
Write-ColorOutput "`n═══════════════════════════════════════════════════════" $ColorCyan
Write-ColorOutput "  Binance AI Traders - Security Control Tests" $ColorCyan
Write-ColorOutput "═══════════════════════════════════════════════════════`n" $ColorCyan

Write-ColorOutput "Test Configuration:" $ColorYellow
Write-ColorOutput "  Remote Host: $RemoteHost" $ColorCyan
Write-ColorOutput "  SSH Port: $SshPort" $ColorCyan
Write-ColorOutput "  Domain: $Domain`n" $ColorCyan

# ============================================================================
# Test Category 1: Secrets Protection
# ============================================================================
Write-ColorOutput "`n[1/6] Secrets Protection Tests" $ColorCyan
Write-ColorOutput "─────────────────────────────────────────────────────" $ColorCyan

$totalTests++
if (Test-Security "No plaintext testnet.env exists" {
    -not (Test-Path "testnet.env")
}) { $passedTests++ } else { $failedTests++ }

$totalTests++
if (Test-Security "Encrypted testnet.env.enc exists" {
    Test-Path "testnet.env.enc"
}) { $passedTests++ } else { $failedTests++ }

$totalTests++
if (Test-Security ".gitignore blocks .env files" {
    $gitignore = Get-Content ".gitignore" -Raw
    $gitignore -match "\*.env" -or $gitignore -match "testnet\.env"
}) { $passedTests++ } else { $failedTests++ }

$totalTests++
if (Test-Security "SOPS configuration exists" {
    Test-Path ".sops.yaml"
}) { $passedTests++ } else { $failedTests++ }

$totalTests++
if (Test-Security "Environment template exists" {
    Test-Path "testnet.env.template"
}) { $passedTests++ } else { $failedTests++ }

# ============================================================================
# Test Category 2: Network Security
# ============================================================================
Write-ColorOutput "`n[2/6] Network Security Tests" $ColorCyan
Write-ColorOutput "─────────────────────────────────────────────────────" $ColorCyan

$totalTests++
if (Test-Security "Nginx configuration exists" {
    Test-Path "nginx/nginx.conf"
}) { $passedTests++ } else { $failedTests++ }

$totalTests++
if (Test-Security "API gateway configuration exists" {
    Test-Path "nginx/conf.d/api-gateway.conf"
}) { $passedTests++ } else { $failedTests++ }

$totalTests++
if (Test-Security "SSL directory exists" {
    Test-Path "nginx/ssl"
}) { $passedTests++ } else { $failedTests++ }

$totalTests++
if (Test-Security "Docker Compose uses expose instead of ports for services" {
    $composeContent = Get-Content "docker-compose-testnet.yml" -Raw
    # Check that services use 'expose:' and not public 'ports:'
    $hasExpose = $composeContent -match "expose:"
    $noPublicPorts = -not ($composeContent -match "8083:8080" -or $composeContent -match "3001:3000")
    $hasExpose -and $noPublicPorts
}) { $passedTests++ } else { $failedTests++ }

$totalTests++
if (Test-Security "Nginx gateway service exists in Docker Compose" {
    $composeContent = Get-Content "docker-compose-testnet.yml" -Raw
    $composeContent -match "nginx-gateway"
}) { $passedTests++ } else { $failedTests++ }

# ============================================================================
# Test Category 3: Docker Security
# ============================================================================
Write-ColorOutput "`n[3/6] Docker Security Tests" $ColorCyan
Write-ColorOutput "─────────────────────────────────────────────────────" $ColorCyan

$totalTests++
if (Test-Security "No default passwords in Docker Compose" {
    $composeContent = Get-Content "docker-compose-testnet.yml" -Raw
    -not ($composeContent -match "testnet_password" -or 
          $composeContent -match "testnet_admin" -or
          $composeContent -match "F4vS8U6mvUXST5TVbQbnMlUL4jOpQiI1Iy8QlVqXpVNMAxplu8pamFDZLB5mpOwU")
}) { $passedTests++ } else { $failedTests++ }

$totalTests++
if (Test-Security "Security options configured (no-new-privileges)" {
    $composeContent = Get-Content "docker-compose-testnet.yml" -Raw
    $composeContent -match "no-new-privileges"
}) { $passedTests++ } else { $failedTests++ }

$totalTests++
if (Test-Security "Services use environment variable references" {
    $composeContent = Get-Content "docker-compose-testnet.yml" -Raw
    ($composeContent -match '\$\{POSTGRES_PASSWORD\}') -and
    ($composeContent -match '\$\{BINANCE_API_KEY\}')
}) { $passedTests++ } else { $failedTests++ }

# ============================================================================
# Test Category 4: Documentation
# ============================================================================
Write-ColorOutput "`n[4/6] Security Documentation Tests" $ColorCyan
Write-ColorOutput "─────────────────────────────────────────────────────" $ColorCyan

$totalTests++
if (Test-Security "Public deployment security guide exists" {
    Test-Path "binance-ai-traders/guides/PUBLIC_DEPLOYMENT_SECURITY_GUIDE.md"
}) { $passedTests++ } else { $failedTests++ }

$totalTests++
if (Test-Security "VPS setup guide exists" {
    Test-Path "binance-ai-traders/guides/VPS_SETUP_GUIDE.md"
}) { $passedTests++ } else { $failedTests++ }

$totalTests++
if (Test-Security "Incident response guide exists" {
    Test-Path "binance-ai-traders/guides/INCIDENT_RESPONSE_GUIDE.md"
}) { $passedTests++ } else { $failedTests++ }

$totalTests++
if (Test-Security "Security verification checklist exists" {
    Test-Path "binance-ai-traders/guides/SECURITY_VERIFICATION_CHECKLIST.md"
}) { $passedTests++ } else { $failedTests++ }

# ============================================================================
# Test Category 5: Security Scripts
# ============================================================================
Write-ColorOutput "`n[5/6] Security Scripts Tests" $ColorCyan
Write-ColorOutput "─────────────────────────────────────────────────────" $ColorCyan

$totalTests++
if (Test-Security "Setup secrets script exists" {
    Test-Path "scripts/security/setup-secrets.ps1"
}) { $passedTests++ } else { $failedTests++ }

$totalTests++
if (Test-Security "Encrypt secrets script exists" {
    Test-Path "scripts/security/encrypt-secrets.ps1"
}) { $passedTests++ } else { $failedTests++ }

$totalTests++
if (Test-Security "Decrypt secrets script exists" {
    Test-Path "scripts/security/decrypt-secrets.ps1"
}) { $passedTests++ } else { $failedTests++ }

$totalTests++
if (Test-Security "Rotate secrets script exists" {
    Test-Path "scripts/security/rotate-secrets.ps1"
}) { $passedTests++ } else { $failedTests++ }

# ============================================================================
# Test Category 6: External Security (if remote host specified)
# ============================================================================
if ($RemoteHost -ne "localhost") {
    Write-ColorOutput "`n[6/6] External Security Tests (Remote: $RemoteHost)" $ColorCyan
    Write-ColorOutput "─────────────────────────────────────────────────────" $ColorCyan
    
    $totalTests++
    if (Test-Security "HTTPS health endpoint accessible" {
        try {
            $response = Invoke-WebRequest -Uri "https://$Domain/health" -UseBasicParsing -TimeoutSec 10
            $response.StatusCode -eq 200
        } catch {
            $false
        }
    }) { $passedTests++ } else { $failedTests++ }
    
    $totalTests++
    if (Test-Security "API requires authentication" {
        try {
            # This should fail with 401
            $response = Invoke-WebRequest -Uri "https://$Domain/api/v1/macd/signals" -UseBasicParsing -TimeoutSec 10 -ErrorAction SilentlyContinue
            $false  # Should have thrown error
        } catch {
            $_.Exception.Response.StatusCode.value__ -eq 401
        }
    }) { $passedTests++ } else { $failedTests++ }
    
    $totalTests++
    if (Test-Security "Direct service ports blocked (8083)" {
        try {
            $response = Invoke-WebRequest -Uri "http://$RemoteHost:8083/actuator/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
            $false  # Should timeout/fail
        } catch {
            $true  # Connection should be refused/timeout
        }
    }) { $passedTests++ } else { $failedTests++ }
    
    $totalTests++
    if (Test-Security "HTTP redirects to HTTPS" {
        try {
            $response = Invoke-WebRequest -Uri "http://$Domain" -MaximumRedirection 0 -UseBasicParsing -ErrorAction SilentlyContinue
            $false
        } catch {
            $_.Exception.Response.StatusCode.value__ -eq 301 -or
            $_.Exception.Response.StatusCode.value__ -eq 302
        }
    }) { $passedTests++ } else { $failedTests++ }
} else {
    Write-ColorOutput "`n[6/6] External Security Tests" $ColorCyan
    Write-ColorOutput "─────────────────────────────────────────────────────" $ColorCyan
    Write-ColorOutput "  ⚠ Skipped (specify -RemoteHost for external tests)" $ColorYellow
}

# ============================================================================
# Results Summary
# ============================================================================
Write-ColorOutput "`n═══════════════════════════════════════════════════════" $ColorCyan
Write-ColorOutput "  Test Results Summary" $ColorCyan
Write-ColorOutput "═══════════════════════════════════════════════════════`n" $ColorCyan

$passRate = [math]::Round(($passedTests / $totalTests) * 100, 1)

Write-ColorOutput "Total Tests: $totalTests" $ColorCyan
Write-ColorOutput "Passed: $passedTests" $ColorGreen
Write-ColorOutput "Failed: $failedTests" $(if ($failedTests -gt 0) { $ColorRed } else { $ColorGreen })
Write-ColorOutput "Pass Rate: $passRate%`n" $(if ($passRate -ge 90) { $ColorGreen } elseif ($passRate -ge 70) { $ColorYellow } else { $ColorRed })

if ($failedTests -eq 0) {
    Write-ColorOutput "✓ All security controls validated successfully!" $ColorGreen
    Write-ColorOutput "System is ready for deployment.`n" $ColorGreen
    exit 0
} elseif ($passRate -ge 90) {
    Write-ColorOutput "⚠ Minor issues detected. Review failed tests." $ColorYellow
    Write-ColorOutput "Address issues before production deployment.`n" $ColorYellow
    exit 1
} else {
    Write-ColorOutput "✗ Critical security issues detected!" $ColorRed
    Write-ColorOutput "DO NOT DEPLOY until all issues are resolved.`n" $ColorRed
    exit 1
}


