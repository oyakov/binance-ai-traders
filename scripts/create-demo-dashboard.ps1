#!/usr/bin/env pwsh
# Create a Demo Dashboard with Available Metrics

Write-Host "=== Creating Demo Dashboard ===" -ForegroundColor Green

# Create a simple demo dashboard that shows available Prometheus metrics
$demoDashboard = @{
    dashboard = @{
        id = $null
        title = "Kline Demo Dashboard"
        tags = @("kline", "demo", "testnet")
        style = "dark"
        timezone = "browser"
        panels = @(
            @{
                id = 1
                title = "Prometheus Status"
                type = "stat"
                targets = @(
                    @{
                        expr = "up{job=\"prometheus\"}"
                        refId = "A"
                    }
                )
                fieldConfig = @{
                    defaults = @{
                        mappings = @(
                            @{
                                type = "value"
                                options = @{
                                    "0" = @{text = "DOWN"; color = "red"}
                                    "1" = @{text = "UP"; color = "green"}
                                }
                            }
                        )
                        thresholds = @{
                            steps = @(
                                @{color = "red"; value = $null}
                                @{color = "green"; value = 1}
                            )
                        }
                        unit = "short"
                    }
                }
                gridPos = @{h = 8; w = 6; x = 0; y = 0}
            },
            @{
                id = 2
                title = "Prometheus Uptime"
                type = "stat"
                targets = @(
                    @{
                        expr = "time() - prometheus_build_info"
                        refId = "A"
                    }
                )
                fieldConfig = @{
                    defaults = @{
                        unit = "s"
                    }
                }
                gridPos = @{h = 8; w = 6; x = 6; y = 0}
            },
            @{
                id = 3
                title = "Available Metrics Count"
                type = "stat"
                targets = @(
                    @{
                        expr = "count(up)"
                        refId = "A"
                    }
                )
                fieldConfig = @{
                    defaults = @{
                        unit = "short"
                    }
                }
                gridPos = @{h = 8; w = 6; x = 12; y = 0}
            },
            @{
                id = 4
                title = "System Status"
                type = "timeseries"
                targets = @(
                    @{
                        expr = "up"
                        refId = "A"
                        legendFormat = "{{job}}"
                    }
                )
                fieldConfig = @{
                    defaults = @{
                        unit = "short"
                        color = @{
                            mode = "palette-classic"
                        }
                    }
                }
                gridPos = @{h = 8; w = 12; x = 0; y = 8}
            },
            @{
                id = 5
                title = "Kline Metrics Status"
                type = "stat"
                targets = @(
                    @{
                        expr = "count(kline_records_total)"
                        refId = "A"
                    }
                )
                fieldConfig = @{
                    defaults = @{
                        mappings = @(
                            @{
                                type = "value"
                                options = @{
                                    "0" = @{text = "NO METRICS"; color = "yellow"}
                                }
                            }
                        )
                        unit = "short"
                    }
                }
                gridPos = @{h = 8; w = 12; x = 12; y = 8}
            }
        )
        time = @{
            from = "now-1h"
            to = "now"
        }
        refresh = "5s"
    }
    overwrite = $true
} | ConvertTo-Json -Depth 10

# Import the demo dashboard
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001/api/dashboards/db" -Method POST -Body $demoDashboard -ContentType "application/json" -Headers @{Authorization="Basic YWRtaW46YWRtaW4="} -UseBasicParsing
    Write-Host "✓ Demo dashboard created successfully" -ForegroundColor Green
    Write-Host "📊 Access it at: http://localhost:3001" -ForegroundColor Cyan
} catch {
    Write-Host "⚠ Error creating demo dashboard: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "`n=== Next Steps ===" -ForegroundColor Green
Write-Host "1. Check the demo dashboard to see working metrics" -ForegroundColor White
Write-Host "2. Implement kline metrics in your applications" -ForegroundColor White
Write-Host "3. The kline dashboards will show data once metrics are available" -ForegroundColor White
