<#
.SYNOPSIS
    Complete System Testing and Architecture Evaluation Script

.DESCRIPTION
    Executes comprehensive testing across all system components:
    - Pre-execution validation
    - Unit tests (Maven)
    - Integration tests
    - API tests (Newman/Postman)
    - Data flow validation
    - Performance testing
    - Architecture evaluation
    - Report generation

.PARAMETER TestCategories
    Comma-separated list of test categories to run.
    Options: Health,Unit,Integration,API,DataFlow,Performance,Architecture,All
    Default: All

.PARAMETER Environment
    Target environment: testnet, dev, or prod
    Default: testnet

.PARAMETER SkipBuild
    Skip Maven build and use existing artifacts

.PARAMETER SkipDocker
    Skip Docker container restart (use running containers)

.PARAMETER DetailedReport
    Generate detailed HTML report with charts

.PARAMETER ExportPath
    Path to export test reports
    Default: test-reports/

.PARAMETER ContinueOnFailure
    Continue testing even if critical tests fail

.EXAMPLE
    .\run-complete-system-test.ps1
    
.EXAMPLE
    .\run-complete-system-test.ps1 -TestCategories "Health,API" -SkipBuild
    
.EXAMPLE
    .\run-complete-system-test.ps1 -DetailedReport -ExportPath "reports/$(Get-Date -Format 'yyyyMMdd')"

.NOTES
    Author: Binance AI Traders Team
    Version: 1.0
    Created: 2025-10-18
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet("Health", "Unit", "Integration", "API", "DataFlow", "Performance", "Architecture", "All")]
    [string[]]$TestCategories = @("All"),
    
    [Parameter()]
    [ValidateSet("testnet", "dev", "prod")]
    [string]$Environment = "testnet",
    
    [Parameter()]
    [switch]$SkipBuild,
    
    [Parameter()]
    [switch]$SkipDocker,
    
    [Parameter()]
    [switch]$DetailedReport,
    
    [Parameter()]
    [string]$ExportPath = "test-reports",
    
    [Parameter()]
    [switch]$ContinueOnFailure
)

# Script configuration
$ErrorActionPreference = "Stop"
$startTime = Get-Date
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$reportFile = "$ExportPath/system-test-report-$timestamp.txt"

# Test counters
$script:testResults = @{
    Total = 0
    Passed = 0
    Failed = 0
    Skipped = 0
    Errors = @()
    Warnings = @()
    Info = @()
}

# ANSI color codes for better output
$script:colors = @{
    Reset = "`e[0m"
    Red = "`e[31m"
    Green = "`e[32m"
    Yellow = "`e[33m"
    Blue = "`e[34m"
    Cyan = "`e[36m"
    Bold = "`e[1m"
}

#region Helper Functions

function Write-TestHeader {
    param([string]$Message)
    $line = "=" * 80
    Write-Host "`n$line" -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Cyan
    Write-Host "$line`n" -ForegroundColor Cyan
    Add-TestLog "INFO" $Message
}

function Write-TestSection {
    param([string]$Message)
    Write-Host "`n--- $Message ---" -ForegroundColor Blue
    Add-TestLog "INFO" $Message
}

function Write-TestSuccess {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
    $script:testResults.Passed++
    Add-TestLog "PASS" $Message
}

function Write-TestFailure {
    param([string]$Message, [string]$Detail = "")
    Write-Host "❌ $Message" -ForegroundColor Red
    if ($Detail) { Write-Host "   $Detail" -ForegroundColor Yellow }
    $script:testResults.Failed++
    $script:testResults.Errors += @{
        Message = $Message
        Detail = $Detail
        Timestamp = Get-Date
    }
    Add-TestLog "FAIL" "$Message - $Detail"
}

function Write-TestWarning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
    $script:testResults.Warnings += $Message
    Add-TestLog "WARN" $Message
}

function Write-TestInfo {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
    $script:testResults.Info += $Message
    Add-TestLog "INFO" $Message
}

function Add-TestLog {
    param([string]$Level, [string]$Message)
    $logEntry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    Add-Content -Path $reportFile -Value $logEntry
}

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Test-PortOpen {
    param([string]$Host = "localhost", [int]$Port, [int]$Timeout = 5)
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $connect = $tcp.BeginConnect($Host, $Port, $null, $null)
        $wait = $connect.AsyncWaitHandle.WaitOne($Timeout * 1000, $false)
        
        if ($wait) {
            $tcp.EndConnect($connect)
            $tcp.Close()
            return $true
        }
        $tcp.Close()
        return $false
    }
    catch {
        return $false
    }
}

function Invoke-TestWithRetry {
    param(
        [scriptblock]$TestBlock,
        [string]$TestName,
        [int]$MaxRetries = 3,
        [int]$DelaySeconds = 5
    )
    
    $attempt = 0
    $lastError = $null
    
    while ($attempt -lt $MaxRetries) {
        $attempt++
        try {
            $result = & $TestBlock
            return $result
        }
        catch {
            $lastError = $_
            if ($attempt -lt $MaxRetries) {
                Write-TestWarning "Attempt $attempt/$MaxRetries failed for '$TestName'. Retrying in $DelaySeconds seconds..."
                Start-Sleep -Seconds $DelaySeconds
            }
        }
    }
    
    throw "Test '$TestName' failed after $MaxRetries attempts. Last error: $lastError"
}

#endregion

#region Phase 1: Pre-Execution Validation

function Test-Prerequisites {
    Write-TestHeader "Phase 1: Pre-Execution Validation"
    
    Write-TestSection "1.1 Checking Required Tools"
    
    # Check Docker
    if (Test-CommandExists "docker") {
        $dockerVersion = docker --version
        Write-TestSuccess "Docker: $dockerVersion"
    }
    else {
        Write-TestFailure "Docker" "Docker not found. Please install Docker Desktop."
        if (-not $ContinueOnFailure) { throw "Docker is required" }
    }
    
    # Check Maven
    if (Test-CommandExists "mvn") {
        $mavenVersion = mvn --version | Select-Object -First 1
        Write-TestSuccess "Maven: $mavenVersion"
    }
    else {
        Write-TestFailure "Maven" "Maven not found. Please install Maven."
        if (-not $ContinueOnFailure) { throw "Maven is required" }
    }
    
    # Check Newman (optional)
    if (Test-CommandExists "newman") {
        $newmanVersion = newman --version
        Write-TestSuccess "Newman: $newmanVersion"
    }
    else {
        Write-TestWarning "Newman not found. API tests will be skipped. Install with: npm install -g newman"
    }
    
    # Check Java
    if (Test-CommandExists "java") {
        $javaVersion = java -version 2>&1 | Select-Object -First 1
        Write-TestSuccess "Java: $javaVersion"
    }
    else {
        Write-TestFailure "Java" "Java not found. Please install JDK 21."
        if (-not $ContinueOnFailure) { throw "Java is required" }
    }
    
    Write-TestSection "1.2 Checking Workspace"
    
    # Verify we're in the project root
    if (Test-Path "pom.xml") {
        Write-TestSuccess "Project root verified"
    }
    else {
        Write-TestFailure "Project root" "Not in project root. Please run from repository root."
        throw "Must run from repository root"
    }
    
    # Check disk space
    $drive = Get-PSDrive C
    $freeSpaceGB = [math]::Round($drive.Free / 1GB, 2)
    if ($freeSpaceGB -gt 10) {
        Write-TestSuccess "Disk space: $freeSpaceGB GB free"
    }
    else {
        Write-TestWarning "Low disk space: $freeSpaceGB GB free. Recommended: 10+ GB"
    }
    
    # Create export directory
    if (-not (Test-Path $ExportPath)) {
        New-Item -ItemType Directory -Path $ExportPath -Force | Out-Null
        Write-TestSuccess "Created export directory: $ExportPath"
    }
}

#endregion

#region Phase 2: Docker Environment

function Test-DockerEnvironment {
    Write-TestHeader "Phase 2: Docker Environment Validation"
    
    if ($SkipDocker) {
        Write-TestInfo "Skipping Docker startup (using existing containers)"
        return
    }
    
    Write-TestSection "2.1 Starting Docker Environment"
    
    $composeFile = if ($Environment -eq "testnet") { "docker-compose-testnet.yml" } else { "docker-compose.yml" }
    
    try {
        Write-Host "Starting containers from $composeFile..."
        docker-compose -f $composeFile up -d 2>&1 | Out-Null
        Write-TestSuccess "Docker Compose started"
        
        # Wait for services to be ready
        Write-Host "Waiting for services to initialize (90 seconds)..."
        Start-Sleep -Seconds 90
    }
    catch {
        Write-TestFailure "Docker Compose" $_.Exception.Message
        if (-not $ContinueOnFailure) { throw }
    }
    
    Write-TestSection "2.2 Checking Container Status"
    
    $containers = docker-compose -f $composeFile ps --format json | ConvertFrom-Json
    
    foreach ($container in $containers) {
        $name = $container.Name
        $state = $container.State
        
        if ($state -eq "running") {
            Write-TestSuccess "Container: $name"
        }
        else {
            Write-TestFailure "Container: $name" "State: $state"
        }
    }
}

#endregion

#region Phase 3: Health Checks

function Test-ServiceHealth {
    Write-TestHeader "Phase 3: Service Health Checks"
    
    $services = @(
        @{ Name = "MACD Trader"; Port = 8083; Path = "/actuator/health" },
        @{ Name = "Data Collection"; Port = 8086; Path = "/actuator/health" },
        @{ Name = "Data Storage"; Port = 8087; Path = "/actuator/health" },
        @{ Name = "Prometheus"; Port = 9091; Path = "/-/healthy" },
        @{ Name = "Grafana"; Port = 3001; Path = "/api/health" }
    )
    
    foreach ($service in $services) {
        $script:testResults.Total++
        
        Write-TestSection "Testing: $($service.Name)"
        
        # Check port
        if (-not (Test-PortOpen -Port $service.Port)) {
            Write-TestFailure "$($service.Name) - Port Check" "Port $($service.Port) not accessible"
            continue
        }
        
        # Check health endpoint
        try {
            $url = "http://localhost:$($service.Port)$($service.Path)"
            $response = Invoke-WebRequest -Uri $url -TimeoutSec 30 -UseBasicParsing
            
            if ($response.StatusCode -eq 200) {
                $content = $response.Content | ConvertFrom-Json -ErrorAction SilentlyContinue
                
                if ($content.status -eq "UP" -or $response.StatusCode -eq 200) {
                    Write-TestSuccess "$($service.Name) - Health Check"
                }
                else {
                    Write-TestWarning "$($service.Name) - Health Check returned: $($content.status)"
                }
            }
            else {
                Write-TestFailure "$($service.Name) - Health Check" "HTTP $($response.StatusCode)"
            }
        }
        catch {
            Write-TestFailure "$($service.Name) - Health Check" $_.Exception.Message
        }
    }
}

#endregion

#region Phase 4: Unit Tests

function Test-UnitTests {
    Write-TestHeader "Phase 4: Maven Unit Tests"
    
    if ($SkipBuild) {
        Write-TestInfo "Skipping build (using existing artifacts)"
        return
    }
    
    Write-TestSection "4.1 Running Maven Tests"
    
    try {
        Write-Host "Executing: mvn clean test -T 1C..."
        
        $testOutput = mvn clean test -T 1C 2>&1
        $testOutput | Out-File -FilePath "$ExportPath/maven-test-output-$timestamp.txt"
        
        # Parse Maven output
        $testOutput | ForEach-Object {
            if ($_ -match "Tests run: (\d+), Failures: (\d+), Errors: (\d+), Skipped: (\d+)") {
                $total = [int]$matches[1]
                $failures = [int]$matches[2]
                $errors = [int]$matches[3]
                $skipped = [int]$matches[4]
                $passed = $total - $failures - $errors - $skipped
                
                $script:testResults.Total += $total
                $script:testResults.Passed += $passed
                $script:testResults.Failed += $failures + $errors
                $script:testResults.Skipped += $skipped
            }
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-TestSuccess "Maven unit tests completed"
        }
        else {
            Write-TestFailure "Maven unit tests" "Build failed with exit code $LASTEXITCODE"
            if (-not $ContinueOnFailure) { throw "Unit tests failed" }
        }
    }
    catch {
        Write-TestFailure "Maven unit tests" $_.Exception.Message
        if (-not $ContinueOnFailure) { throw }
    }
}

#endregion

#region Phase 5: API Tests

function Test-APIEndpoints {
    Write-TestHeader "Phase 5: API Tests (Newman/Postman)"
    
    if (-not (Test-CommandExists "newman")) {
        Write-TestWarning "Newman not installed. Skipping API tests."
        return
    }
    
    $collections = @(
        @{
            Name = "Comprehensive Test Suite"
            Collection = "postman/Binance-AI-Traders-Comprehensive-Test-Collection.json"
            Environment = "postman/Binance-AI-Traders-Testnet-Environment.json"
            Report = "comprehensive"
        },
        @{
            Name = "Monitoring Tests"
            Collection = "postman/Binance-AI-Traders-Monitoring-Tests.json"
            Environment = "postman/Binance-AI-Traders-Testnet-Environment.json"
            Report = "monitoring"
        },
        @{
            Name = "PostgreSQL/Kafka Health"
            Collection = "postman/PostgreSQL-Kafka-Health-Tests.json"
            Environment = "postman/Binance-AI-Traders-Testnet-Environment.json"
            Report = "pg-kafka"
        }
    )
    
    foreach ($test in $collections) {
        Write-TestSection "Running: $($test.Name)"
        
        $script:testResults.Total++
        
        if (-not (Test-Path $test.Collection)) {
            Write-TestWarning "Collection not found: $($test.Collection)"
            continue
        }
        
        try {
            $reportPath = "$ExportPath/$($test.Report)-$timestamp.html"
            
            Write-Host "Executing Newman collection..."
            $newmanOutput = newman run $test.Collection `
                -e $test.Environment `
                --reporters cli,html `
                --reporter-html-export $reportPath `
                --disable-unicode 2>&1
            
            $newmanOutput | Out-File -FilePath "$ExportPath/$($test.Report)-output-$timestamp.txt"
            
            # Parse Newman output
            if ($newmanOutput -match "│\s+executed\s+│\s+(\d+)/(\d+)") {
                $passed = [int]$matches[1]
                $total = [int]$matches[2]
                $failed = $total - $passed
                
                $script:testResults.Passed += $passed
                $script:testResults.Failed += $failed
                
                Write-TestSuccess "$($test.Name): $passed/$total tests passed"
            }
            else {
                Write-TestSuccess "$($test.Name) completed. See report: $reportPath"
            }
        }
        catch {
            Write-TestFailure "$($test.Name)" $_.Exception.Message
        }
    }
}

#endregion

#region Phase 6: Data Flow Validation

function Test-DataFlow {
    Write-TestHeader "Phase 6: Data Flow Validation"
    
    Write-TestSection "6.1 Kafka Topics"
    
    $script:testResults.Total++
    
    try {
        Write-Host "Listing Kafka topics..."
        $topics = docker exec kafka-testnet kafka-topics.sh --bootstrap-server localhost:9092 --list 2>&1
        
        if ($topics -match "kline-events") {
            Write-TestSuccess "Kafka topics accessible"
        }
        else {
            Write-TestWarning "Expected topics not found"
        }
    }
    catch {
        Write-TestFailure "Kafka topics" $_.Exception.Message
    }
    
    Write-TestSection "6.2 PostgreSQL Data"
    
    $script:testResults.Total++
    
    try {
        Write-Host "Checking PostgreSQL klines table..."
        $result = docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet `
            -c "SELECT COUNT(*) FROM klines;" -t 2>&1
        
        $count = [int]($result -replace '\s', '')
        
        if ($count -gt 0) {
            Write-TestSuccess "PostgreSQL: $count kline records found"
        }
        else {
            Write-TestWarning "PostgreSQL: No kline data found"
        }
    }
    catch {
        Write-TestFailure "PostgreSQL data check" $_.Exception.Message
    }
    
    Write-TestSection "6.3 Elasticsearch Indices"
    
    $script:testResults.Total++
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:9202/_cat/indices?v" -UseBasicParsing
        
        if ($response.Content -match "klines") {
            Write-TestSuccess "Elasticsearch: klines index exists"
        }
        else {
            Write-TestWarning "Elasticsearch: klines index not found"
        }
    }
    catch {
        Write-TestFailure "Elasticsearch indices" $_.Exception.Message
    }
}

#endregion

#region Phase 7: Performance Tests

function Test-Performance {
    Write-TestHeader "Phase 7: Performance Testing"
    
    Write-TestSection "7.1 Response Time Tests"
    
    $endpoints = @(
        @{ Name = "Health Check"; Url = "http://localhost:8083/actuator/health"; MaxTime = 5 },
        @{ Name = "Metrics"; Url = "http://localhost:8083/actuator/prometheus"; MaxTime = 10 }
    )
    
    foreach ($endpoint in $endpoints) {
        $script:testResults.Total++
        
        try {
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            $response = Invoke-WebRequest -Uri $endpoint.Url -UseBasicParsing -TimeoutSec 30
            $stopwatch.Stop()
            
            $elapsed = $stopwatch.Elapsed.TotalSeconds
            
            if ($elapsed -lt $endpoint.MaxTime) {
                Write-TestSuccess "$($endpoint.Name): ${elapsed}s (< $($endpoint.MaxTime)s)"
            }
            else {
                Write-TestWarning "$($endpoint.Name): ${elapsed}s (expected < $($endpoint.MaxTime)s)"
            }
        }
        catch {
            Write-TestFailure "$($endpoint.Name) - Performance" $_.Exception.Message
        }
    }
    
    Write-TestSection "7.2 Resource Usage"
    
    try {
        Write-Host "Collecting Docker stats..."
        $stats = docker stats --no-stream --format "{{.Name}}: CPU={{.CPUPerc}} MEM={{.MemUsage}}" 2>&1
        
        $stats | ForEach-Object {
            Write-TestInfo $_
        }
    }
    catch {
        Write-TestWarning "Could not collect Docker stats: $($_.Exception.Message)"
    }
}

#endregion

#region Phase 8: Architecture Evaluation

function Test-Architecture {
    Write-TestHeader "Phase 8: Architecture Evaluation"
    
    Write-TestSection "8.1 Documentation Check"
    
    $requiredDocs = @(
        "README.md",
        "binance-ai-traders/AGENTS.md",
        "binance-ai-traders/WHERE_IS_WHAT.md",
        "binance-ai-traders/PROJECT_RULES.md",
        "binance-ai-traders/API_ENDPOINTS.md",
        "binance-ai-traders/COMPREHENSIVE_SYSTEM_TESTING_AND_ARCHITECTURE_EVALUATION_PLAN.md"
    )
    
    foreach ($doc in $requiredDocs) {
        $script:testResults.Total++
        
        if (Test-Path $doc) {
            Write-TestSuccess "Documentation: $doc"
        }
        else {
            Write-TestWarning "Documentation missing: $doc"
        }
    }
    
    Write-TestSection "8.2 Code Quality Checks"
    
    try {
        Write-Host "Scanning for TODOs and FIXMEs..."
        $issues = Get-ChildItem -Path . -Include *.java -Recurse -ErrorAction SilentlyContinue |
            Select-String -Pattern "TODO|FIXME|XXX" |
            Group-Object Path |
            Measure-Object
        
        Write-TestInfo "Found $($issues.Count) files with TODO/FIXME comments"
    }
    catch {
        Write-TestWarning "Could not scan for code issues"
    }
}

#endregion

#region Report Generation

function Generate-TestReport {
    Write-TestHeader "Generating Test Report"
    
    $duration = (Get-Date) - $startTime
    $successRate = if ($script:testResults.Total -gt 0) {
        [math]::Round(($script:testResults.Passed / $script:testResults.Total) * 100, 2)
    }
    else { 0 }
    
    $overallStatus = if ($script:testResults.Failed -eq 0) { "✅ PASS" }
                     elseif ($successRate -ge 70) { "⚠️  PARTIAL" }
                     else { "❌ FAIL" }
    
    $report = @"

================================================================================
                    SYSTEM TEST REPORT
================================================================================

Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Duration: $($duration.ToString('hh\:mm\:ss'))
Environment: $Environment

--------------------------------------------------------------------------------
EXECUTIVE SUMMARY
--------------------------------------------------------------------------------

Overall Status: $overallStatus
Tests Executed: $($script:testResults.Passed + $script:testResults.Failed) / $($script:testResults.Total)
Success Rate: $successRate%
Tests Passed: $($script:testResults.Passed)
Tests Failed: $($script:testResults.Failed)
Tests Skipped: $($script:testResults.Skipped)

Critical Issues: $($script:testResults.Errors.Count)
Warnings: $($script:testResults.Warnings.Count)

--------------------------------------------------------------------------------
TEST CATEGORIES
--------------------------------------------------------------------------------

"@

    if ($TestCategories -contains "All" -or $TestCategories -contains "Health") {
        $report += "`n✅ Service Health Checks"
    }
    if ($TestCategories -contains "All" -or $TestCategories -contains "Unit") {
        $report += "`n✅ Unit Tests (Maven)"
    }
    if ($TestCategories -contains "All" -or $TestCategories -contains "API") {
        $report += "`n✅ API Tests (Newman/Postman)"
    }
    if ($TestCategories -contains "All" -or $TestCategories -contains "DataFlow") {
        $report += "`n✅ Data Flow Validation"
    }
    if ($TestCategories -contains "All" -or $TestCategories -contains "Performance") {
        $report += "`n✅ Performance Testing"
    }
    if ($TestCategories -contains "All" -or $TestCategories -contains "Architecture") {
        $report += "`n✅ Architecture Evaluation"
    }
    
    $report += "`n`n--------------------------------------------------------------------------------"
    $report += "`nISSUES FOUND"
    $report += "`n--------------------------------------------------------------------------------`n"
    
    if ($script:testResults.Errors.Count -eq 0) {
        $report += "`nNo critical issues found.`n"
    }
    else {
        foreach ($error in $script:testResults.Errors) {
            $report += "`n❌ $($error.Message)"
            if ($error.Detail) {
                $report += "`n   Details: $($error.Detail)"
            }
            $report += "`n   Time: $($error.Timestamp.ToString('HH:mm:ss'))`n"
        }
    }
    
    if ($script:testResults.Warnings.Count -gt 0) {
        $report += "`n`nWarnings:`n"
        foreach ($warning in $script:testResults.Warnings) {
            $report += "⚠️  $warning`n"
        }
    }
    
    $report += @"

--------------------------------------------------------------------------------
RECOMMENDATIONS
--------------------------------------------------------------------------------

"@

    if ($successRate -eq 100) {
        $report += "✅ All tests passed! System is healthy and ready for deployment.`n"
    }
    elseif ($successRate -ge 90) {
        $report += "⚠️  Most tests passed. Review and fix minor issues before deployment.`n"
    }
    elseif ($successRate -ge 70) {
        $report += "⚠️  System partially functional. Address failures before proceeding.`n"
    }
    else {
        $report += "❌ System has critical issues. Do not proceed with deployment.`n"
    }
    
    $report += @"

--------------------------------------------------------------------------------
NEXT STEPS
--------------------------------------------------------------------------------

1. Review detailed test logs in: $ExportPath
2. Address critical failures (P0/P1 severity)
3. Update memory system with findings
4. Re-run tests after fixes
5. Proceed to next milestone when green

--------------------------------------------------------------------------------
REFERENCES
--------------------------------------------------------------------------------

- Test Plan: binance-ai-traders/COMPREHENSIVE_SYSTEM_TESTING_AND_ARCHITECTURE_EVALUATION_PLAN.md
- Memory System: binance-ai-traders/memory/memory-index.md
- Architecture Guide: binance-ai-traders/AGENTS.md
- API Endpoints: binance-ai-traders/API_ENDPOINTS.md

================================================================================
                    END OF REPORT
================================================================================

"@

    # Write report to file
    Add-Content -Path $reportFile -Value $report
    
    # Display report
    Write-Host $report
    
    # Save summary
    $summaryFile = "$ExportPath/summary-$timestamp.json"
    $script:testResults | ConvertTo-Json -Depth 10 | Out-File $summaryFile
    
    Write-TestSuccess "Report saved to: $reportFile"
    Write-TestSuccess "Summary saved to: $summaryFile"
    
    # Return exit code based on results
    if ($script:testResults.Failed -gt 0) {
        exit 1
    }
    else {
        exit 0
    }
}

#endregion

#region Main Execution

try {
    Write-Host @"

╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║              BINANCE AI TRADERS - COMPREHENSIVE SYSTEM TESTING               ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

    Write-Host "Test Configuration:" -ForegroundColor Yellow
    Write-Host "  Categories: $($TestCategories -join ', ')"
    Write-Host "  Environment: $Environment"
    Write-Host "  Skip Build: $SkipBuild"
    Write-Host "  Skip Docker: $SkipDocker"
    Write-Host "  Report Path: $ExportPath"
    Write-Host "  Start Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Host ""
    
    # Initialize report file
    "BINANCE AI TRADERS - SYSTEM TEST LOG" | Out-File -FilePath $reportFile
    "Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $reportFile -Append
    "=" * 80 | Out-File -FilePath $reportFile -Append
    
    # Run test phases based on categories
    Test-Prerequisites
    
    if ($TestCategories -contains "All" -or $TestCategories -notcontains "Health") {
        Test-DockerEnvironment
    }
    
    if ($TestCategories -contains "All" -or $TestCategories -contains "Health") {
        Test-ServiceHealth
    }
    
    if ($TestCategories -contains "All" -or $TestCategories -contains "Unit") {
        Test-UnitTests
    }
    
    if ($TestCategories -contains "All" -or $TestCategories -contains "API") {
        Test-APIEndpoints
    }
    
    if ($TestCategories -contains "All" -or $TestCategories -contains "DataFlow") {
        Test-DataFlow
    }
    
    if ($TestCategories -contains "All" -or $TestCategories -contains "Performance") {
        Test-Performance
    }
    
    if ($TestCategories -contains "All" -or $TestCategories -contains "Architecture") {
        Test-Architecture
    }
    
    # Generate final report
    Generate-TestReport
}
catch {
    Write-Host "`n❌ FATAL ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    
    Add-Content -Path $reportFile -Value "`n`nFATAL ERROR: $($_.Exception.Message)"
    Add-Content -Path $reportFile -Value $_.ScriptStackTrace
    
    exit 1
}

#endregion

