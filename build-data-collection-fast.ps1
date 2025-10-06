# Fast build script for binance-data-collection-testnet
# This script optimizes Docker builds for faster rebuilds

param(
    [switch]$NoCache = $false,
    [switch]$Clean = $false,
    [switch]$Verbose = $false
)

Write-Host "🚀 Fast Build Script for binance-data-collection-testnet" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

# Set working directory
Set-Location -Path "C:\Projects\binance-ai-traders"

# Build arguments
$buildArgs = @()

if ($NoCache) {
    Write-Host "⚠️  Building without cache..." -ForegroundColor Yellow
    $buildArgs += "--no-cache"
}

if ($Clean) {
    Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Blue
    docker-compose -f docker-compose-testnet.yml down binance-data-collection-testnet
    docker rmi $(docker images -q binance-ai-traders_binance-data-collection-testnet) 2>$null
}

# Check if we can use BuildKit for faster builds
$useBuildKit = $env:DOCKER_BUILDKIT
if (-not $useBuildKit) {
    Write-Host "💡 Tip: Set DOCKER_BUILDKIT=1 for even faster builds" -ForegroundColor Cyan
    Write-Host "   Run: `$env:DOCKER_BUILDKIT=1" -ForegroundColor Cyan
}

# Build with optimized settings
Write-Host "🔨 Building binance-data-collection-testnet..." -ForegroundColor Blue

$buildCommand = "docker-compose -f docker-compose-testnet.yml build"
if ($buildArgs.Count -gt 0) {
    $buildCommand += " " + ($buildArgs -join " ")
}
$buildCommand += " binance-data-collection-testnet"

if ($Verbose) {
    Write-Host "Command: $buildCommand" -ForegroundColor Gray
}

# Execute build
$startTime = Get-Date
Invoke-Expression $buildCommand
$endTime = Get-Date
$buildTime = $endTime - $startTime

Write-Host "✅ Build completed in $($buildTime.TotalSeconds.ToString('F1')) seconds" -ForegroundColor Green

# Show image size
$imageSize = docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | Select-String "binance-data-collection-testnet"
if ($imageSize) {
    Write-Host "📦 Image size: $($imageSize.Line.Split()[2])" -ForegroundColor Cyan
}

# Optional: Start the service
$startService = Read-Host "🚀 Start the service now? (y/N)"
if ($startService -eq "y" -or $startService -eq "Y") {
    Write-Host "Starting binance-data-collection-testnet..." -ForegroundColor Blue
    docker-compose -f docker-compose-testnet.yml up -d binance-data-collection-testnet
    
    # Wait a moment and check health
    Start-Sleep -Seconds 5
    $health = docker-compose -f docker-compose-testnet.yml ps binance-data-collection-testnet
    Write-Host "Service status:" -ForegroundColor Cyan
    Write-Host $health -ForegroundColor White
}

Write-Host "`n💡 Build optimization tips:" -ForegroundColor Yellow
Write-Host "   • Use --no-cache only when dependencies change" -ForegroundColor Gray
Write-Host "   • Use --clean to remove old images and start fresh" -ForegroundColor Gray
Write-Host "   • Set DOCKER_BUILDKIT=1 for faster builds" -ForegroundColor Gray
Write-Host "   • The .dockerignore file excludes unnecessary files" -ForegroundColor Gray
Write-Host "   • Dependencies are cached in a separate layer" -ForegroundColor Gray
