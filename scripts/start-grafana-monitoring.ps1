#!/usr/bin/env pwsh
# Start Grafana Monitoring for Kline Data

Write-Host "=== Starting Grafana Kline Monitoring ===" -ForegroundColor Green

# Start Prometheus and Grafana
Write-Host "`nStarting monitoring stack..." -ForegroundColor Yellow
docker-compose -f monitoring/docker-compose.grafana-testnet.yml up -d

# Wait for services
Write-Host "Waiting for services to be ready..." -ForegroundColor Cyan
Start-Sleep -Seconds 30

# Check service status
Write-Host "`nChecking service status..." -ForegroundColor Yellow
docker-compose -f monitoring/docker-compose.grafana-testnet.yml ps

Write-Host "`n=== Monitoring Stack Started ===" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Grafana: http://localhost:3001 (admin/admin)" -ForegroundColor Cyan
Write-Host "📈 Prometheus: http://localhost:9090" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Available Dashboards:" -ForegroundColor Yellow
Write-Host "   • Kline Data Master Dashboard" -ForegroundColor White
Write-Host "   • Kline Collection Overview" -ForegroundColor White
Write-Host "   • Live Price Charts" -ForegroundColor White
Write-Host "   • Kline Streaming Monitor" -ForegroundColor White
Write-Host "   • Kline Storage Monitor" -ForegroundColor White
Write-Host "   • Kline Alerts and Health" -ForegroundColor White

Write-Host "`n🎯 To test data collection:" -ForegroundColor Yellow
Write-Host "   .\simple-kline-monitor.ps1" -ForegroundColor White
