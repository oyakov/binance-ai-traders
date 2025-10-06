#!/usr/bin/env pwsh
# Complete Kline Monitoring Setup

Write-Host "=== Complete Kline Monitoring Setup ===" -ForegroundColor Green

# Step 1: Start simple monitoring stack
Write-Host "`n1. Starting monitoring stack..." -ForegroundColor Yellow
docker-compose -f monitoring/docker-compose.grafana-simple.yml up -d

# Wait for services
Write-Host "Waiting for services to start..." -ForegroundColor Cyan
Start-Sleep -Seconds 30

# Step 2: Import dashboards
Write-Host "`n2. Importing dashboards..." -ForegroundColor Yellow
.\import-kline-dashboards.ps1

# Step 3: Check service status
Write-Host "`n3. Checking service status..." -ForegroundColor Yellow
docker-compose -f monitoring/docker-compose.grafana-simple.yml ps

Write-Host "`n=== Kline Monitoring Setup Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Grafana: http://localhost:3001 (admin/admin)" -ForegroundColor Cyan
Write-Host "📈 Prometheus: http://localhost:9090" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Open Grafana and explore the kline dashboards" -ForegroundColor White
Write-Host "2. Implement metrics in your applications (see docs/monitoring/kline-metrics-implementation.md)" -ForegroundColor White
Write-Host "3. Start data collection to see live data in dashboards" -ForegroundColor White
Write-Host ""
Write-Host "🎯 To test data collection:" -ForegroundColor Yellow
Write-Host "   .\simple-kline-monitor.ps1" -ForegroundColor White
