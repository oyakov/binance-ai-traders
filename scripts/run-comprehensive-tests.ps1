# Comprehensive System Testing Script for Binance AI Traders
# This script runs all Postman collections using Newman for automated testing

param(
    [string]$Environment = "testnet",
    [string]$ReportPath = ".\test-reports",
    [switch]$SkipHealthCheck,
    [switch]$SkipMonitoring,
    [switch]$Continuous,
    [int]$IntervalMinutes = 5,
    [switch]$Verbose
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Color functions for output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message" -ForegroundColor $Color
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "✅ $Message" "Green"
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "❌ $Message" "Red"
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "⚠️ $Message" "Yellow"
}

function Write-Info {
    param([string]$Message)
    Write-ColorOutput "ℹ️ $Message" "Cyan"
}

# Check prerequisites
function Test-Prerequisites {
    Write-Info "Checking prerequisites..."
    
    # Check if Newman is installed
    try {
        $newmanVersion = newman --version 2>$null
        Write-Success "Newman version: $newmanVersion"
    }
    catch {
        Write-Error "Newman is not installed. Please install it with: npm install -g newman"
        exit 1
    }
    
    # Check if Docker is running
    try {
        docker version 2>$null | Out-Null
        Write-Success "Docker is running"
    }
    catch {
        Write-Error "Docker is not running. Please start Docker Desktop"
        exit 1
    }
    
    # Check if required files exist
    $requiredFiles = @(
        "postman\Binance-AI-Traders-Testnet-Environment.json",
        "postman\Binance-AI-Traders-Comprehensive-Test-Collection.json",
        "postman\Binance-AI-Traders-Monitoring-Tests.json",
        "docker-compose-testnet.yml"
    )
    
    foreach ($file in $requiredFiles) {
        if (!(Test-Path $file)) {
            Write-Error "Required file not found: $file"
            exit 1
        }
    }
    
    Write-Success "All prerequisites met"
}

# Start system services
function Start-SystemServices {
    Write-Info "Starting system services..."
    
    # Stop any existing containers
    Write-Info "Stopping existing containers..."
    docker-compose -f docker-compose-testnet.yml down 2>$null
    
    # Start services
    Write-Info "Starting testnet services..."
    docker-compose -f docker-compose-testnet.yml up -d
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to start services"
        exit 1
    }
    
    Write-Success "Services started successfully"
    
    # Wait for services to be ready
    Write-Info "Waiting for services to be ready..."
    Start-Sleep -Seconds 60
    
    # Check service health
    Write-Info "Checking service health..."
    $services = @(
        @{Name="Trading Service"; Port=8083; Path="/actuator/health"},
        @{Name="Data Collection"; Port=8086; Path="/actuator/health"},
        @{Name="PostgreSQL"; Port=5433; Path="/"},
        @{Name="Elasticsearch"; Port=9202; Path="/_cluster/health"},
        @{Name="Kafka"; Port=9095; Path="/"},
        @{Name="Prometheus"; Port=9091; Path="/-/healthy"},
        @{Name="Grafana"; Port=3001; Path="/api/health"}
    )
    
    $healthyServices = 0
    foreach ($service in $services) {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:$($service.Port)$($service.Path)" -UseBasicParsing -TimeoutSec 10 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                Write-Success "$($service.Name) is healthy"
                $healthyServices++
            } else {
                Write-Warning "$($service.Name) returned status $($response.StatusCode)"
            }
        }
        catch {
            Write-Warning "$($service.Name) is not responding: $($_.Exception.Message)"
        }
    }
    
    if ($healthyServices -lt 4) {
        Write-Error "Not enough services are healthy ($healthyServices/7). Please check the logs."
        Write-Info "Run 'docker-compose -f docker-compose-testnet.yml logs' to see service logs"
        exit 1
    }
    
    Write-Success "System is ready for testing"
}

# Create report directory
function Initialize-ReportDirectory {
    if (!(Test-Path $ReportPath)) {
        New-Item -ItemType Directory -Path $ReportPath -Force | Out-Null
        Write-Success "Created report directory: $ReportPath"
    }
}

# Run Newman tests
function Invoke-NewmanTest {
    param(
        [string]$CollectionPath,
        [string]$EnvironmentPath,
        [string]$TestName,
        [string]$Folder = $null,
        [string]$OutputFile
    )
    
    Write-Info "Running $TestName..."
    
    $newmanCommand = "newman run `"$CollectionPath`" -e `"$EnvironmentPath`" --reporters cli,html --reporter-html-export `"$OutputFile`""
    
    if ($Folder) {
        $newmanCommand += " --folder `"$Folder`""
    }
    
    if ($Verbose) {
        $newmanCommand += " --verbose"
    }
    
    Write-Info "Executing: $newmanCommand"
    
    try {
        Invoke-Expression $newmanCommand
        if ($LASTEXITCODE -eq 0) {
            Write-Success "$TestName completed successfully"
            return $true
        } else {
            Write-Error "$TestName failed with exit code $LASTEXITCODE"
            return $false
        }
    }
    catch {
        Write-Error "$TestName failed with error: $($_.Exception.Message)"
        return $false
    }
}

# Main execution function
function Start-ComprehensiveTesting {
    Write-Info "Starting comprehensive system testing for Binance AI Traders"
    Write-Info "Environment: $Environment"
    Write-Info "Report Path: $ReportPath"
    
    # Check prerequisites
    Test-Prerequisites
    
    # Initialize report directory
    Initialize-ReportDirectory
    
    # Start system services
    Start-SystemServices
    
    # Define test configurations
    $tests = @()
    
    if (!$SkipHealthCheck) {
        $tests += @{
            Name = "System Health Checks"
            Collection = "postman\Binance-AI-Traders-Comprehensive-Test-Collection.json"
            Environment = "postman\Binance-AI-Traders-Testnet-Environment.json"
            Folder = "1. System Health Checks"
            OutputFile = "$ReportPath\health-check-report.html"
        }
    }
    
    $tests += @{
        Name = "Comprehensive System Tests"
        Collection = "postman\Binance-AI-Traders-Comprehensive-Test-Collection.json"
        Environment = "postman\Binance-AI-Traders-Testnet-Environment.json"
        OutputFile = "$ReportPath\comprehensive-test-report.html"
    }
    
    if (!$SkipMonitoring) {
        $tests += @{
            Name = "Monitoring and Metrics Tests"
            Collection = "postman\Binance-AI-Traders-Monitoring-Tests.json"
            Environment = "postman\Binance-AI-Traders-Testnet-Environment.json"
            OutputFile = "$ReportPath\monitoring-test-report.html"
        }
    }
    
    # Run tests
    $testResults = @()
    $overallSuccess = $true
    
    foreach ($test in $tests) {
        $result = Invoke-NewmanTest -CollectionPath $test.Collection -EnvironmentPath $test.Environment -TestName $test.Name -Folder $test.Folder -OutputFile $test.OutputFile
        $testResults += @{
            Name = $test.Name
            Success = $result
            OutputFile = $test.OutputFile
        }
        
        if (!$result) {
            $overallSuccess = $false
        }
    }
    
    # Generate summary report
    Write-Info "Generating test summary..."
    $summaryReport = "$ReportPath\test-summary-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
    
    $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Binance AI Traders - Test Summary</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }
        .test-result { margin: 10px 0; padding: 10px; border-radius: 5px; }
        .success { background-color: #d4edda; border-left: 5px solid #28a745; }
        .failure { background-color: #f8d7da; border-left: 5px solid #dc3545; }
        .info { background-color: #d1ecf1; border-left: 5px solid #17a2b8; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Binance AI Traders - Test Summary</h1>
        <p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
        <p>Environment: $Environment</p>
        <p>Overall Status: $(if ($overallSuccess) { '<span style="color: green;">✅ PASSED</span>' } else { '<span style="color: red;">❌ FAILED</span>' })</p>
    </div>
    
    <h2>Test Results</h2>
"@
    
    foreach ($result in $testResults) {
        $statusClass = if ($result.Success) { "success" } else { "failure" }
        $statusIcon = if ($result.Success) { "✅" } else { "❌" }
        
        $htmlContent += @"
    <div class="test-result $statusClass">
        <h3>$statusIcon $($result.Name)</h3>
        <p>Status: $(if ($result.Success) { 'PASSED' } else { 'FAILED' })</p>
        <p>Report: <a href="$($result.OutputFile)">View Detailed Report</a></p>
    </div>
"@
    }
    
    $htmlContent += @"
    
    <div class="info">
        <h3>System Information</h3>
        <p>Test Environment: $Environment</p>
        <p>Report Directory: $ReportPath</p>
        <p>Test Execution Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
    </div>
</body>
</html>
"@
    
    $htmlContent | Out-File -FilePath $summaryReport -Encoding UTF8
    Write-Success "Test summary generated: $summaryReport"
    
    # Display results
    Write-Info "Test Results Summary:"
    foreach ($result in $testResults) {
        $status = if ($result.Success) { "✅ PASSED" } else { "❌ FAILED" }
        Write-Info "  $($result.Name): $status"
    }
    
    if ($overallSuccess) {
        Write-Success "All tests completed successfully!"
    } else {
        Write-Error "Some tests failed. Please check the detailed reports."
    }
    
    # Open summary report if on Windows
    if ($IsWindows -or $env:OS -eq "Windows_NT") {
        Start-Process $summaryReport
    }
    
    return $overallSuccess
}

# Continuous monitoring function
function Start-ContinuousMonitoring {
    Write-Info "Starting continuous monitoring (every $IntervalMinutes minutes)..."
    Write-Info "Press Ctrl+C to stop"
    
    while ($true) {
        try {
            Write-Info "Running monitoring tests..."
            $result = Invoke-NewmanTest -CollectionPath "postman\Binance-AI-Traders-Monitoring-Tests.json" -EnvironmentPath "postman\Binance-AI-Traders-Testnet-Environment.json" -TestName "Continuous Monitoring" -OutputFile "$ReportPath\continuous-monitoring-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
            
            if ($result) {
                Write-Success "Monitoring cycle completed successfully"
            } else {
                Write-Error "Monitoring cycle failed"
            }
            
            Write-Info "Waiting $IntervalMinutes minutes before next cycle..."
            Start-Sleep -Seconds ($IntervalMinutes * 60)
        }
        catch {
            Write-Error "Continuous monitoring error: $($_.Exception.Message)"
            Write-Info "Waiting 1 minute before retry..."
            Start-Sleep -Seconds 60
        }
    }
}

# Main execution
try {
    if ($Continuous) {
        Start-ContinuousMonitoring
    } else {
        $success = Start-ComprehensiveTesting
        if ($success) {
            exit 0
        } else {
            exit 1
        }
    }
}
catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
    exit 1
}
finally {
    if (!$Continuous) {
        Write-Info "Test execution completed"
    }
}
