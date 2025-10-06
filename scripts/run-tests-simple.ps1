# Simple Test Runner for Binance AI Traders
# This script runs the comprehensive tests using Newman

param(
    [switch]$SkipHealthCheck,
    [switch]$SkipMonitoring,
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
    
    # Check if required files exist
    $requiredFiles = @(
        "postman\Binance-AI-Traders-Testnet-Environment.json",
        "postman\Binance-AI-Traders-Comprehensive-Test-Collection.json",
        "postman\Binance-AI-Traders-Monitoring-Tests.json"
    )
    
    $allFilesExist = $true
    foreach ($file in $requiredFiles) {
        if (Test-Path $file) {
            Write-Success "Found: $file"
        } else {
            Write-Error "Missing: $file"
            $allFilesExist = $false
        }
    }
    
    if (!$allFilesExist) {
        Write-Error "Some required files are missing. Please ensure all Postman collections are present."
        exit 1
    }
    
    Write-Success "All prerequisites met"
}

# Create report directory
function Initialize-ReportDirectory {
    $reportPath = ".\test-reports"
    if (!(Test-Path $reportPath)) {
        New-Item -ItemType Directory -Path $reportPath -Force | Out-Null
        Write-Success "Created report directory: $reportPath"
    }
    return $reportPath
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

# Check service health
function Test-ServiceHealth {
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
    $totalServices = $services.Count
    
    foreach ($service in $services) {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:$($service.Port)$($service.Path)" -UseBasicParsing -TimeoutSec 10
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
    
    $healthPercentage = [math]::Round(($healthyServices / $totalServices) * 100, 2)
    Write-Info "System health: $healthyServices/$totalServices services healthy ($healthPercentage percent)"
    
    if ($healthyServices -ge 4) {
        Write-Success "System is operational"
        return $true
    } else {
        Write-Error "System is not fully operational"
        return $false
    }
}

# Main execution function
function Start-ComprehensiveTesting {
    Write-Info "Starting comprehensive system testing for Binance AI Traders"
    
    # Check prerequisites
    Test-Prerequisites
    
    # Initialize report directory
    $reportPath = Initialize-ReportDirectory
    
    # Check service health
    $systemHealthy = Test-ServiceHealth
    if (!$systemHealthy) {
        Write-Warning "System is not fully healthy, but continuing with tests..."
    }
    
    # Define test configurations
    $tests = @()
    
    if (!$SkipHealthCheck) {
        $tests += @{
            Name = "System Health Checks"
            Collection = "postman\Binance-AI-Traders-Comprehensive-Test-Collection.json"
            Environment = "postman\Binance-AI-Traders-Testnet-Environment.json"
            Folder = "1. System Health Checks"
            OutputFile = "$reportPath\health-check-report.html"
        }
    }
    
    $tests += @{
        Name = "Comprehensive System Tests"
        Collection = "postman\Binance-AI-Traders-Comprehensive-Test-Collection.json"
        Environment = "postman\Binance-AI-Traders-Testnet-Environment.json"
        OutputFile = "$reportPath\comprehensive-test-report.html"
    }
    
    if (!$SkipMonitoring) {
        $tests += @{
            Name = "Monitoring and Metrics Tests"
            Collection = "postman\Binance-AI-Traders-Monitoring-Tests.json"
            Environment = "postman\Binance-AI-Traders-Testnet-Environment.json"
            OutputFile = "$reportPath\monitoring-test-report.html"
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
    
    # Display results
    Write-Info "Test Results Summary:"
    foreach ($result in $testResults) {
        $status = if ($result.Success) { "✅ PASSED" } else { "❌ FAILED" }
        Write-Info "  $($result.Name): $status"
    }
    
    if ($overallSuccess) {
        Write-Success "All tests completed successfully!"
    } else {
        Write-Error "Some tests failed. Please check the detailed reports in $reportPath"
    }
    
    return $overallSuccess
}

# Main execution
try {
    $success = Start-ComprehensiveTesting
    if ($success) {
        exit 0
    } else {
        exit 1
    }
}
catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
    exit 1
}
finally {
    Write-Info "Test execution completed"
}
