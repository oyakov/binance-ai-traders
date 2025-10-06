# Basic Test Runner for Binance AI Traders
Write-Host "Starting comprehensive system testing..." -ForegroundColor Green

# Check if Newman is installed
try {
    $newmanVersion = newman --version 2>$null
    Write-Host "Newman version: $newmanVersion" -ForegroundColor Green
}
catch {
    Write-Host "Newman is not installed. Please install it with: npm install -g newman" -ForegroundColor Red
    exit 1
}

# Create report directory
if (!(Test-Path ".\test-reports")) {
    New-Item -ItemType Directory -Path ".\test-reports" -Force | Out-Null
    Write-Host "Created report directory: .\test-reports" -ForegroundColor Green
}

# Check service health
Write-Host "Checking service health..." -ForegroundColor Yellow
$healthyServices = 0
$totalServices = 7

$services = @(
    @{Name="Trading Service"; Port=8083; Path="/actuator/health"},
    @{Name="Data Collection"; Port=8086; Path="/actuator/health"},
    @{Name="PostgreSQL"; Port=5433; Path="/"},
    @{Name="Elasticsearch"; Port=9202; Path="/_cluster/health"},
    @{Name="Kafka"; Port=9095; Path="/"},
    @{Name="Prometheus"; Port=9091; Path="/-/healthy"},
    @{Name="Grafana"; Port=3001; Path="/api/health"}
)

foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$($service.Port)$($service.Path)" -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $($service.Name) is healthy" -ForegroundColor Green
            $healthyServices++
        } else {
            Write-Host "⚠️ $($service.Name) returned status $($response.StatusCode)" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "❌ $($service.Name) is not responding" -ForegroundColor Red
    }
}

$healthPercentage = [math]::Round(($healthyServices / $totalServices) * 100, 2)
Write-Host "System health: $healthyServices/$totalServices services healthy ($healthPercentage percent)" -ForegroundColor Cyan

# Run comprehensive tests
Write-Host "Running comprehensive system tests..." -ForegroundColor Yellow
$testResult = $true

try {
    newman run "postman\Binance-AI-Traders-Comprehensive-Test-Collection.json" -e "postman\Binance-AI-Traders-Testnet-Environment.json" --reporters cli,html --reporter-html-export ".\test-reports\comprehensive-test-report.html"
    if ($LASTEXITCODE -ne 0) {
        $testResult = $false
    }
}
catch {
    Write-Host "Comprehensive tests failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResult = $false
}

# Run monitoring tests
Write-Host "Running monitoring and metrics tests..." -ForegroundColor Yellow
try {
    newman run "postman\Binance-AI-Traders-Monitoring-Tests.json" -e "postman\Binance-AI-Traders-Testnet-Environment.json" --reporters cli,html --reporter-html-export ".\test-reports\monitoring-test-report.html"
    if ($LASTEXITCODE -ne 0) {
        $testResult = $false
    }
}
catch {
    Write-Host "Monitoring tests failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResult = $false
}

# Display results
if ($testResult) {
    Write-Host "✅ All tests completed successfully!" -ForegroundColor Green
    Write-Host "Reports generated in: .\test-reports\" -ForegroundColor Cyan
} else {
    Write-Host "❌ Some tests failed. Please check the detailed reports in .\test-reports\" -ForegroundColor Red
}

Write-Host "Test execution completed" -ForegroundColor White
