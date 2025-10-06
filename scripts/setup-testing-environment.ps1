# Setup Testing Environment for Binance AI Traders
# This script installs Newman and sets up the testing environment

param(
    [switch]$Force,
    [switch]$SkipNodeInstall
)

Write-Host "Setting up testing environment for Binance AI Traders..." -ForegroundColor Green

# Check if Node.js is installed
if (!$SkipNodeInstall) {
    try {
        $nodeVersion = node --version 2>$null
        Write-Host "✅ Node.js version: $nodeVersion" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Node.js is not installed. Please install Node.js first." -ForegroundColor Red
        Write-Host "Download from: https://nodejs.org/" -ForegroundColor Yellow
        exit 1
    }
}

# Install Newman globally
Write-Host "Installing Newman..." -ForegroundColor Yellow
try {
    if ($Force) {
        npm install -g newman --force
    } else {
        npm install -g newman
    }
    Write-Host "✅ Newman installed successfully" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to install Newman: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Install Newman HTML reporter
Write-Host "Installing Newman HTML reporter..." -ForegroundColor Yellow
try {
    if ($Force) {
        npm install -g newman-reporter-html --force
    } else {
        npm install -g newman-reporter-html
    }
    Write-Host "✅ Newman HTML reporter installed successfully" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to install Newman HTML reporter: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Verify installation
Write-Host "Verifying installation..." -ForegroundColor Yellow
try {
    $newmanVersion = newman --version
    Write-Host "✅ Newman version: $newmanVersion" -ForegroundColor Green
}
catch {
    Write-Host "❌ Newman verification failed" -ForegroundColor Red
    exit 1
}

# Create test reports directory
$reportsDir = ".\test-reports"
if (!(Test-Path $reportsDir)) {
    New-Item -ItemType Directory -Path $reportsDir -Force | Out-Null
    Write-Host "✅ Created test reports directory: $reportsDir" -ForegroundColor Green
}

# Check if required files exist
Write-Host "Checking required files..." -ForegroundColor Yellow
$requiredFiles = @(
    "postman\Binance-AI-Traders-Testnet-Environment.json",
    "postman\Binance-AI-Traders-Comprehensive-Test-Collection.json",
    "postman\Binance-AI-Traders-Monitoring-Tests.json",
    "docker-compose-testnet.yml"
)

$allFilesExist = $true
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ Found: $file" -ForegroundColor Green
    } else {
        Write-Host "❌ Missing: $file" -ForegroundColor Red
        $allFilesExist = $false
    }
}

if (!$allFilesExist) {
    Write-Host "❌ Some required files are missing. Please ensure all Postman collections and Docker Compose files are present." -ForegroundColor Red
    exit 1
}

# Test Newman with a simple collection
Write-Host "Testing Newman with a simple request..." -ForegroundColor Yellow
$testCollection = @"
{
  "info": {
    "name": "Test Collection",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Test Request",
      "request": {
        "method": "GET",
        "url": "https://httpbin.org/get"
      },
      "event": [
        {
          "listen": "test",
          "script": {
            "exec": [
              "pm.test('Status code is 200', function () {",
              "    pm.response.to.have.status(200);",
              "});"
            ]
          }
        }
      ]
    }
  ]
}
"@

$testCollection | Out-File -FilePath ".\test-collection.json" -Encoding UTF8

try {
    newman run .\test-collection.json --reporters cli
    Write-Host "✅ Newman test successful" -ForegroundColor Green
}
catch {
    Write-Host "❌ Newman test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Cleanup test file
Remove-Item ".\test-collection.json" -ErrorAction SilentlyContinue

Write-Host "`n🎉 Testing environment setup complete!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Start the system: docker-compose -f docker-compose-testnet.yml up -d" -ForegroundColor White
Write-Host "2. Run tests: .\scripts\run-comprehensive-tests.ps1" -ForegroundColor White
Write-Host "3. View reports in: .\test-reports\" -ForegroundColor White
Write-Host "`nFor continuous monitoring: .\scripts\run-comprehensive-tests.ps1 -Continuous" -ForegroundColor Cyan
