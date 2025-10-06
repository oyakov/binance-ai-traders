# Quick Cleanup Script for Binance AI Traders
# This script performs a quick cleanup and restart

Write-Host "Performing quick system cleanup and restart..." -ForegroundColor Green

# Stop and remove containers
Write-Host "Stopping and removing containers..." -ForegroundColor Yellow
docker-compose -f docker-compose-testnet.yml down -v

# Remove any orphaned containers
Write-Host "Removing orphaned containers..." -ForegroundColor Yellow
docker container prune -f

# Remove unused volumes
Write-Host "Removing unused volumes..." -ForegroundColor Yellow
docker volume prune -f

# Remove unused networks
Write-Host "Removing unused networks..." -ForegroundColor Yellow
docker network prune -f

# Clean up system data
Write-Host "Cleaning up system data..." -ForegroundColor Yellow
if (Test-Path ".\test-reports") { Remove-Item ".\test-reports" -Recurse -Force }
if (Test-Path ".\testnet_logs") { Remove-Item ".\testnet_logs" -Recurse -Force }
if (Test-Path ".\testnet_reports") { Remove-Item ".\testnet_reports" -Recurse -Force }
if (Test-Path ".\data") { Remove-Item ".\data" -Recurse -Force }
if (Test-Path ".\kafka-data") { Remove-Item ".\kafka-data" -Recurse -Force }

# Clean Maven target directories
Write-Host "Cleaning Maven target directories..." -ForegroundColor Yellow
Get-ChildItem -Path "." -Directory -Name "target" -Recurse | ForEach-Object { Remove-Item $_ -Recurse -Force }

# Rebuild and start services
Write-Host "Rebuilding and starting services..." -ForegroundColor Yellow
docker-compose -f docker-compose-testnet.yml up -d --build

# Wait for services
Write-Host "Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

# Check service status
Write-Host "Checking service status..." -ForegroundColor Yellow
docker-compose -f docker-compose-testnet.yml ps

Write-Host "Quick cleanup and restart completed!" -ForegroundColor Green
Write-Host "You can now run tests with: .\scripts\run-comprehensive-tests.ps1" -ForegroundColor Cyan
