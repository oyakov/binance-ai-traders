# SQL Diagnostics Runner
# This script runs all SQL diagnostic tools and provides a comprehensive system analysis

Write-Host "=== Binance AI Traders - SQL Diagnostics Runner ===" -ForegroundColor Green
Write-Host "Timestamp: $(Get-Date)" -ForegroundColor Yellow
Write-Host ""

# Database connection parameters
$DB_HOST = "postgres-testnet"
$DB_USER = "testnet_user"
$DB_NAME = "binance_trader_testnet"

# Function to run SQL script
function Invoke-SQLDiagnostic {
    param(
        [string]$ScriptName,
        [string]$Description
    )
    
    Write-Host "=== $Description ===" -ForegroundColor Cyan
    Write-Host "Running: $ScriptName" -ForegroundColor White
    Write-Host ""
    
    try {
        $scriptPath = "scripts/sql-diagnostics/$ScriptName"
        if (Test-Path $scriptPath) {
            $result = docker exec $DB_HOST psql -U $DB_USER -d $DB_NAME -f "/app/$scriptPath" 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host $result -ForegroundColor White
                Write-Host "✅ $ScriptName completed successfully" -ForegroundColor Green
            } else {
                Write-Host "❌ Error running $ScriptName" -ForegroundColor Red
                Write-Host $result -ForegroundColor Red
            }
        } else {
            Write-Host "⚠️ Script not found: $scriptPath" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "❌ Exception running $ScriptName : $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Press any key to continue to next diagnostic..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Write-Host ""
}

# Function to run quick database check
function Test-DatabaseConnection {
    Write-Host "=== Database Connection Test ===" -ForegroundColor Cyan
    
    try {
        $result = docker exec $DB_HOST psql -U $DB_USER -d $DB_NAME -c "SELECT 'Database connection successful' as status, NOW() as timestamp;"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Database connection successful" -ForegroundColor Green
            Write-Host $result -ForegroundColor White
        } else {
            Write-Host "❌ Database connection failed" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "❌ Database connection error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
}

# Function to show system summary
function Show-SystemSummary {
    Write-Host "=== System Summary ===" -ForegroundColor Cyan
    
    try {
        # Get basic database info
        $dbInfo = docker exec $DB_HOST psql -U $DB_USER -d $DB_NAME -c "SELECT pg_database.datname as database_name, pg_size_pretty(pg_database_size(pg_database.datname)) as database_size FROM pg_database WHERE datname = '$DB_NAME';"
        Write-Host "Database Information:" -ForegroundColor White
        Write-Host $dbInfo -ForegroundColor White
        
        # Get kline data count
        $klineCount = docker exec $DB_HOST psql -U $DB_USER -d $DB_NAME -c "SELECT COUNT(*) as total_klines FROM kline;"
        Write-Host "Kline Data:" -ForegroundColor White
        Write-Host $klineCount -ForegroundColor White
        
        # Get connection count
        $connCount = docker exec $DB_HOST psql -U $DB_USER -d $DB_NAME -c "SELECT state, COUNT(*) as connection_count FROM pg_stat_activity WHERE datname = '$DB_NAME' GROUP BY state;"
        Write-Host "Active Connections:" -ForegroundColor White
        Write-Host $connCount -ForegroundColor White
        
    }
    catch {
        Write-Host "❌ Error getting system summary: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
}

# Main execution
Write-Host "Starting comprehensive SQL diagnostics..." -ForegroundColor Green
Write-Host ""

# Test database connection first
Test-DatabaseConnection

# Show system summary
Show-SystemSummary

# Run all diagnostic scripts
Write-Host "Running all diagnostic scripts..." -ForegroundColor Green
Write-Host ""

Invoke-SQLDiagnostic -ScriptName "01-database-health-check.sql" -Description "Database Health Check"
Invoke-SQLDiagnostic -ScriptName "02-kline-data-analysis.sql" -Description "Kline Data Analysis"
Invoke-SQLDiagnostic -ScriptName "03-performance-monitoring.sql" -Description "Performance Monitoring"

Write-Host "=== Diagnostics Complete ===" -ForegroundColor Green
Write-Host "All SQL diagnostic tools have been executed." -ForegroundColor White
Write-Host "Review the output above for any issues or recommendations." -ForegroundColor White
Write-Host ""
Write-Host "For detailed analysis, check the individual SQL files:" -ForegroundColor Cyan
Write-Host "- scripts/sql-diagnostics/01-database-health-check.sql" -ForegroundColor White
Write-Host "- scripts/sql-diagnostics/02-kline-data-analysis.sql" -ForegroundColor White
Write-Host "- scripts/sql-diagnostics/03-performance-monitoring.sql" -ForegroundColor White
Write-Host ""
Write-Host "For documentation, see: scripts/sql-diagnostics/README.md" -ForegroundColor Cyan
