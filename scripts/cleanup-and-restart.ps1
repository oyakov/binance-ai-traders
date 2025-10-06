# Cleanup and Restart Script for Binance AI Traders
# This script performs a complete cleanup and restart of the entire system

param(
    [switch]$Force,
    [switch]$SkipBackup,
    [switch]$SkipDataCleanup,
    [switch]$SkipImageCleanup,
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

# Function to stop all running containers
function Stop-AllContainers {
    Write-Info "Stopping all running containers..."
    
    try {
        # Stop all containers
        docker stop $(docker ps -q) 2>$null
        Write-Success "All containers stopped"
    }
    catch {
        Write-Warning "No containers were running or error stopping containers: $($_.Exception.Message)"
    }
}

# Function to remove all containers
function Remove-AllContainers {
    Write-Info "Removing all containers..."
    
    try {
        # Remove all containers
        docker rm $(docker ps -aq) 2>$null
        Write-Success "All containers removed"
    }
    catch {
        Write-Warning "No containers to remove or error removing containers: $($_.Exception.Message)"
    }
}

# Function to remove all images
function Remove-AllImages {
    if ($SkipImageCleanup) {
        Write-Info "Skipping image cleanup as requested"
        return
    }
    
    Write-Info "Removing all Docker images..."
    
    try {
        # Remove all images
        docker rmi $(docker images -q) -f 2>$null
        Write-Success "All Docker images removed"
    }
    catch {
        Write-Warning "No images to remove or error removing images: $($_.Exception.Message)"
    }
}

# Function to clean up volumes
function Remove-AllVolumes {
    Write-Info "Cleaning up Docker volumes..."
    
    try {
        # Remove all volumes
        docker volume rm $(docker volume ls -q) 2>$null
        Write-Success "All Docker volumes removed"
    }
    catch {
        Write-Warning "No volumes to remove or error removing volumes: $($_.Exception.Message)"
    }
}

# Function to clean up networks
function Remove-AllNetworks {
    Write-Info "Cleaning up Docker networks..."
    
    try {
        # Remove custom networks (keep default ones)
        $customNetworks = docker network ls --filter "type=custom" -q
        if ($customNetworks) {
            docker network rm $customNetworks 2>$null
            Write-Success "Custom Docker networks removed"
        } else {
            Write-Info "No custom networks to remove"
        }
    }
    catch {
        Write-Warning "Error removing networks: $($_.Exception.Message)"
    }
}

# Function to clean up system data
function Clean-SystemData {
    if ($SkipDataCleanup) {
        Write-Info "Skipping data cleanup as requested"
        return
    }
    
    Write-Info "Cleaning up system data..."
    
    # Clean up test reports
    if (Test-Path ".\test-reports") {
        Remove-Item ".\test-reports" -Recurse -Force
        Write-Success "Test reports cleaned up"
    }
    
    # Clean up logs
    if (Test-Path ".\testnet_logs") {
        Remove-Item ".\testnet_logs" -Recurse -Force
        Write-Success "Test logs cleaned up"
    }
    
    # Clean up testnet reports
    if (Test-Path ".\testnet_reports") {
        Remove-Item ".\testnet_reports" -Recurse -Force
        Write-Success "Testnet reports cleaned up"
    }
    
    # Clean up data directories
    $dataDirs = @(".\data", ".\kafka-data")
    foreach ($dir in $dataDirs) {
        if (Test-Path $dir) {
            Remove-Item $dir -Recurse -Force
            Write-Success "Data directory cleaned up: $dir"
        }
    }
    
    # Clean up Maven target directories
    $mavenDirs = Get-ChildItem -Path "." -Directory -Name "target" -Recurse
    foreach ($dir in $mavenDirs) {
        Remove-Item $dir -Recurse -Force
        Write-Success "Maven target directory cleaned up: $dir"
    }
}

# Function to backup important data
function Backup-ImportantData {
    if ($SkipBackup) {
        Write-Info "Skipping backup as requested"
        return
    }
    
    Write-Info "Creating backup of important data..."
    
    $backupDir = ".\backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    
    # Backup configuration files
    $configFiles = @(
        "testnet.env",
        "docker-compose-testnet.yml",
        "docker-compose.yml"
    )
    
    foreach ($file in $configFiles) {
        if (Test-Path $file) {
            Copy-Item $file $backupDir
            Write-Success "Backed up: $file"
        }
    }
    
    # Backup monitoring configuration
    if (Test-Path ".\monitoring") {
        Copy-Item ".\monitoring" "$backupDir\monitoring" -Recurse
        Write-Success "Backed up monitoring configuration"
    }
    
    Write-Success "Backup created in: $backupDir"
}

# Function to perform Docker system cleanup
function Invoke-DockerSystemCleanup {
    Write-Info "Performing Docker system cleanup..."
    
    try {
        # Remove unused containers, networks, images, and build cache
        docker system prune -a -f --volumes
        Write-Success "Docker system cleanup completed"
    }
    catch {
        Write-Warning "Docker system cleanup failed: $($_.Exception.Message)"
    }
}

# Function to rebuild and start services
function Start-SystemServices {
    Write-Info "Building and starting system services..."
    
    # Build all services
    Write-Info "Building Maven projects..."
    try {
        mvn clean install -DskipTests
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Maven build failed"
            return $false
        }
        Write-Success "Maven build completed"
    }
    catch {
        Write-Error "Maven build failed: $($_.Exception.Message)"
        return $false
    }
    
    # Start services
    Write-Info "Starting Docker Compose services..."
    try {
        docker-compose -f docker-compose-testnet.yml up -d --build
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to start services"
            return $false
        }
        Write-Success "Services started successfully"
    }
    catch {
        Write-Error "Failed to start services: $($_.Exception.Message)"
        return $false
    }
    
    return $true
}

# Function to wait for services to be ready
function Wait-ForServices {
    Write-Info "Waiting for services to be ready..."
    
    $maxWaitTime = 300 # 5 minutes
    $waitInterval = 10 # 10 seconds
    $elapsedTime = 0
    
    $services = @(
        @{Name="Trading Service"; Port=8083; Path="/actuator/health"},
        @{Name="Data Collection"; Port=8086; Path="/actuator/health"},
        @{Name="PostgreSQL"; Port=5433; Path="/"},
        @{Name="Elasticsearch"; Port=9202; Path="/_cluster/health"},
        @{Name="Kafka"; Port=9095; Path="/"},
        @{Name="Prometheus"; Port=9091; Path="/-/healthy"},
        @{Name="Grafana"; Port=3001; Path="/api/health"}
    )
    
    while ($elapsedTime -lt $maxWaitTime) {
        $healthyServices = 0
        
        foreach ($service in $services) {
            try {
                $response = Invoke-WebRequest -Uri "http://localhost:$($service.Port)$($service.Path)" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
                if ($response.StatusCode -eq 200) {
                    $healthyServices++
                }
            }
            catch {
                # Service not ready yet
            }
        }
        
        if ($healthyServices -ge 4) {
            Write-Success "Services are ready ($healthyServices/7 healthy)"
            return $true
        }
        
        Write-Info "Waiting for services... ($healthyServices/7 healthy) - Elapsed: $elapsedTime seconds"
        Start-Sleep -Seconds $waitInterval
        $elapsedTime += $waitInterval
    }
    
    Write-Warning "Services may not be fully ready after $maxWaitTime seconds"
    return $false
}

# Function to verify system health
function Test-SystemHealth {
    Write-Info "Verifying system health..."
    
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
    Write-Info "System health: $healthyServices/$totalServices services healthy ($healthPercentage%)"
    
    if ($healthyServices -ge 4) {
        Write-Success "System is operational"
        return $true
    } else {
        Write-Error "System is not fully operational"
        return $false
    }
}

# Function to display system status
function Show-SystemStatus {
    Write-Info "System Status Summary:"
    Write-Info "===================="
    
    # Docker containers status
    Write-Info "Docker Containers:"
    try {
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    }
    catch {
        Write-Warning "Could not retrieve container status"
    }
    
    # Docker images
    Write-Info "`nDocker Images:"
    try {
        docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    }
    catch {
        Write-Warning "Could not retrieve image status"
    }
    
    # Disk usage
    Write-Info "`nDisk Usage:"
    try {
        docker system df
    }
    catch {
        Write-Warning "Could not retrieve disk usage"
    }
}

# Main execution function
function Start-CompleteCleanupAndRestart {
    Write-Info "Starting complete system cleanup and restart..."
    Write-Info "Force mode: $Force"
    Write-Info "Skip backup: $SkipBackup"
    Write-Info "Skip data cleanup: $SkipDataCleanup"
    Write-Info "Skip image cleanup: $SkipImageCleanup"
    
    if (!$Force) {
        $confirmation = Read-Host "This will completely clean up and restart the system. Continue? (y/N)"
        if ($confirmation -ne "y" -and $confirmation -ne "Y") {
            Write-Info "Operation cancelled by user"
            return
        }
    }
    
    try {
        # Step 1: Backup important data
        Backup-ImportantData
        
        # Step 2: Stop all containers
        Stop-AllContainers
        
        # Step 3: Remove all containers
        Remove-AllContainers
        
        # Step 4: Remove all images
        Remove-AllImages
        
        # Step 5: Clean up volumes
        Remove-AllVolumes
        
        # Step 6: Clean up networks
        Remove-AllNetworks
        
        # Step 7: Clean up system data
        Clean-SystemData
        
        # Step 8: Docker system cleanup
        Invoke-DockerSystemCleanup
        
        # Step 9: Rebuild and start services
        $startSuccess = Start-SystemServices
        if (!$startSuccess) {
            Write-Error "Failed to start services"
            return
        }
        
        # Step 10: Wait for services to be ready
        $servicesReady = Wait-ForServices
        if (!$servicesReady) {
            Write-Warning "Services may not be fully ready"
        }
        
        # Step 11: Verify system health
        $systemHealthy = Test-SystemHealth
        
        # Step 12: Display system status
        Show-SystemStatus
        
        if ($systemHealthy) {
            Write-Success "System cleanup and restart completed successfully!"
            Write-Info "You can now run tests with: .\scripts\run-comprehensive-tests.ps1"
        } else {
            Write-Warning "System restart completed but some services may not be fully operational"
            Write-Info "Check service logs with: docker-compose -f docker-compose-testnet.yml logs"
        }
        
    }
    catch {
        Write-Error "Cleanup and restart failed: $($_.Exception.Message)"
        Write-Info "You may need to manually clean up the system"
    }
}

# Main execution
try {
    Start-CompleteCleanupAndRestart
}
catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
    exit 1
}
finally {
    Write-Info "Cleanup and restart script completed"
}
