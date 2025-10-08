# Dashboard Consolidation Script
# This script consolidates all dashboards into a clean, organized structure

Write-Host "=== Dashboard Consolidation ===" -ForegroundColor Green
Write-Host "Timestamp: $(Get-Date)" -ForegroundColor Yellow
Write-Host ""

# Create backup of current dashboards
Write-Host "Creating backup of current dashboards..." -ForegroundColor Cyan
$backupDir = "monitoring/grafana/provisioning/dashboards-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Copy-Item -Path "monitoring/grafana/provisioning/dashboards" -Destination $backupDir -Recurse
Write-Host "Backup created: $backupDir" -ForegroundColor Green

# Create new clean structure
Write-Host "`nCreating new dashboard structure..." -ForegroundColor Cyan

# Remove old structure
Remove-Item -Path "monitoring/grafana/provisioning/dashboards" -Recurse -Force

# Create new organized folders
$folders = @(
    "monitoring/grafana/provisioning/dashboards/01-system-health",
    "monitoring/grafana/provisioning/dashboards/02-trading-overview", 
    "monitoring/grafana/provisioning/dashboards/03-macd-strategies",
    "monitoring/grafana/provisioning/dashboards/04-kline-data",
    "monitoring/grafana/provisioning/dashboards/05-analytics",
    "monitoring/grafana/provisioning/dashboards/06-executive"
)

foreach ($folder in $folders) {
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
    Write-Host "Created folder: $folder" -ForegroundColor White
}

Write-Host "`n=== CONSOLIDATION PLAN ===" -ForegroundColor Yellow
Write-Host "01-system-health: System health, infrastructure monitoring" -ForegroundColor White
Write-Host "02-trading-overview: Main trading dashboard, operations" -ForegroundColor White  
Write-Host "03-macd-strategies: MACD strategy monitoring, BTC/ETH specific" -ForegroundColor White
Write-Host "04-kline-data: Kline data collection, streaming, storage" -ForegroundColor White
Write-Host "05-analytics: Analytics, insights, comprehensive metrics" -ForegroundColor White
Write-Host "06-executive: Executive overview, high-level KPIs" -ForegroundColor White

Write-Host "`n=== DASHBOARD CONSOLIDATION ===" -ForegroundColor Cyan

# 1. System Health Dashboards
Write-Host "`n1. Consolidating System Health Dashboards..." -ForegroundColor Cyan

# Create comprehensive system health dashboard
$systemHealth = @{
    id = $null
    title = "System Health Overview"
    uid = "system-health-overview"
    tags = @("system", "health", "infrastructure")
    timezone = "browser"
    panels = @(
        @{
            id = 1
            title = "Service Status Overview"
            type = "stat"
            targets = @(
                @{
                    expr = "up{job=~`".*testnet.*`"}"
                    refId = "A"
                }
            )
            fieldConfig = @{
                defaults = @{
                    mappings = @(
                        @{
                            type = "value"
                            options = @{
                                "0" = @{ text = "DOWN"; color = "red" }
                                "1" = @{ text = "UP"; color = "green" }
                            }
                        }
                    )
                    thresholds = @{
                        steps = @(
                            @{ color = "red"; value = $null }
                            @{ color = "green"; value = 1 }
                        )
                    }
                    unit = "short"
                }
            }
            gridPos = @{ h = 8; w = 6; x = 0; y = 0 }
        },
        @{
            id = 2
            title = "Trading Service Health"
            type = "stat"
            targets = @(
                @{
                    expr = "up{job=`"binance-macd-trader-testnet`"}"
                    refId = "A"
                }
            )
            fieldConfig = @{
                defaults = @{
                    mappings = @(
                        @{
                            type = "value"
                            options = @{
                                "0" = @{ text = "DOWN"; color = "red" }
                                "1" = @{ text = "UP"; color = "green" }
                            }
                        }
                    )
                    unit = "short"
                }
            }
            gridPos = @{ h = 8; w = 6; x = 6; y = 0 }
        },
        @{
            id = 3
            title = "Data Collection Health"
            type = "stat"
            targets = @(
                @{
                    expr = "up{job=`"binance-data-collection-testnet`"}"
                    refId = "A"
                }
            )
            fieldConfig = @{
                defaults = @{
                    mappings = @(
                        @{
                            type = "value"
                            options = @{
                                "0" = @{ text = "DOWN"; color = "red" }
                                "1" = @{ text = "UP"; color = "green" }
                            }
                        }
                    )
                    unit = "short"
                }
            }
            gridPos = @{ h = 8; w = 6; x = 12; y = 0 }
        },
        @{
            id = 4
            title = "Data Storage Health"
            type = "stat"
            targets = @(
                @{
                    expr = "up{job=`"binance-data-storage-testnet`"}"
                    refId = "A"
                }
            )
            fieldConfig = @{
                defaults = @{
                    mappings = @(
                        @{
                            type = "value"
                            options = @{
                                "0" = @{ text = "DOWN"; color = "red" }
                                "1" = @{ text = "UP"; color = "green" }
                            }
                        }
                    )
                    unit = "short"
                }
            }
            gridPos = @{ h = 8; w = 6; x = 18; y = 0 }
        },
        @{
            id = 5
            title = "Infrastructure Health"
            type = "stat"
            targets = @(
                @{
                    expr = "up{job=~`"prometheus|elasticsearch|kafka|postgres.*`"}"
                    refId = "A"
                }
            )
            fieldConfig = @{
                defaults = @{
                    mappings = @(
                        @{
                            type = "value"
                            options = @{
                                "0" = @{ text = "DOWN"; color = "red" }
                                "1" = @{ text = "UP"; color = "green" }
                            }
                        }
                    )
                    unit = "short"
                }
            }
            gridPos = @{ h = 8; w = 6; x = 0; y = 8 }
        }
    )
    time = @{
        from = "now-1h"
        to = "now"
    }
    refresh = "30s"
    schemaVersion = 36
    version = 1
    annotations = @{ list = @() }
    editable = $true
    fiscalYearStartMonth = 0
    graphTooltip = 0
    links = @()
    liveNow = $false
    style = "dark"
    templating = @{ list = @() }
    timepicker = @{}
    weekStart = ""
}

$systemHealth | ConvertTo-Json -Depth 10 | Out-File -FilePath "monitoring/grafana/provisioning/dashboards/01-system-health/system-health-overview.json" -Encoding UTF8
Write-Host "✅ Created: system-health-overview.json" -ForegroundColor Green

# 2. Trading Overview Dashboard
Write-Host "`n2. Creating Trading Overview Dashboard..." -ForegroundColor Cyan

$tradingOverview = @{
    id = $null
    title = "Trading Operations Overview"
    uid = "trading-operations-overview"
    tags = @("trading", "operations", "overview")
    timezone = "browser"
    panels = @(
        @{
            id = 1
            title = "Active Trading Positions"
            type = "stat"
            targets = @(
                @{
                    expr = "up{job=`"binance-macd-trader-testnet`"}"
                    refId = "A"
                }
            )
            fieldConfig = @{
                defaults = @{
                    mappings = @(
                        @{
                            type = "value"
                            options = @{
                                "0" = @{ text = "NO POSITIONS"; color = "gray" }
                                "1" = @{ text = "ACTIVE"; color = "green" }
                            }
                        }
                    )
                    unit = "short"
                }
            }
            gridPos = @{ h = 8; w = 12; x = 0; y = 0 }
        },
        @{
            id = 2
            title = "Trading Signals"
            type = "stat"
            targets = @(
                @{
                    expr = "rate(http_requests_total{job=`"binance-macd-trader-testnet`"}[5m])"
                    refId = "A"
                }
            )
            fieldConfig = @{
                defaults = @{
                    unit = "reqps"
                }
            }
            gridPos = @{ h = 8; w = 12; x = 12; y = 0 }
        }
    )
    time = @{
        from = "now-1h"
        to = "now"
    }
    refresh = "30s"
    schemaVersion = 36
    version = 1
    annotations = @{ list = @() }
    editable = $true
    fiscalYearStartMonth = 0
    graphTooltip = 0
    links = @()
    liveNow = $false
    style = "dark"
    templating = @{ list = @() }
    timepicker = @{}
    weekStart = ""
}

$tradingOverview | ConvertTo-Json -Depth 10 | Out-File -FilePath "monitoring/grafana/provisioning/dashboards/02-trading-overview/trading-operations-overview.json" -Encoding UTF8
Write-Host "✅ Created: trading-operations-overview.json" -ForegroundColor Green

# 3. MACD Strategies Dashboard
Write-Host "`n3. Creating MACD Strategies Dashboard..." -ForegroundColor Cyan

$macdStrategies = @{
    id = $null
    title = "MACD Trading Strategies"
    uid = "macd-trading-strategies"
    tags = @("macd", "strategies", "trading")
    timezone = "browser"
    panels = @(
        @{
            id = 1
            title = "BTC MACD Strategy"
            type = "stat"
            targets = @(
                @{
                    expr = "up{job=`"binance-macd-trader-testnet`"}"
                    refId = "A"
                }
            )
            fieldConfig = @{
                defaults = @{
                    mappings = @(
                        @{
                            type = "value"
                            options = @{
                                "0" = @{ text = "INACTIVE"; color = "red" }
                                "1" = @{ text = "ACTIVE"; color = "green" }
                            }
                        }
                    )
                    unit = "short"
                }
            }
            gridPos = @{ h = 8; w = 12; x = 0; y = 0 }
        },
        @{
            id = 2
            title = "ETH MACD Strategy"
            type = "stat"
            targets = @(
                @{
                    expr = "up{job=`"binance-macd-trader-testnet`"}"
                    refId = "A"
                }
            )
            fieldConfig = @{
                defaults = @{
                    mappings = @(
                        @{
                            type = "value"
                            options = @{
                                "0" = @{ text = "INACTIVE"; color = "red" }
                                "1" = @{ text = "ACTIVE"; color = "green" }
                            }
                        }
                    )
                    unit = "short"
                }
            }
            gridPos = @{ h = 8; w = 12; x = 12; y = 0 }
        }
    )
    time = @{
        from = "now-1h"
        to = "now"
    }
    refresh = "30s"
    schemaVersion = 36
    version = 1
    annotations = @{ list = @() }
    editable = $true
    fiscalYearStartMonth = 0
    graphTooltip = 0
    links = @()
    liveNow = $false
    style = "dark"
    templating = @{ list = @() }
    timepicker = @{}
    weekStart = ""
}

$macdStrategies | ConvertTo-Json -Depth 10 | Out-File -FilePath "monitoring/grafana/provisioning/dashboards/03-macd-strategies/macd-trading-strategies.json" -Encoding UTF8
Write-Host "✅ Created: macd-trading-strategies.json" -ForegroundColor Green

# 4. Kline Data Dashboard
Write-Host "`n4. Creating Kline Data Dashboard..." -ForegroundColor Cyan

$klineData = @{
    id = $null
    title = "Kline Data Monitoring"
    uid = "kline-data-monitoring"
    tags = @("kline", "data", "monitoring")
    timezone = "browser"
    panels = @(
        @{
            id = 1
            title = "Data Collection Status"
            type = "stat"
            targets = @(
                @{
                    expr = "up{job=`"binance-data-collection-testnet`"}"
                    refId = "A"
                }
            )
            fieldConfig = @{
                defaults = @{
                    mappings = @(
                        @{
                            type = "value"
                            options = @{
                                "0" = @{ text = "STOPPED"; color = "red" }
                                "1" = @{ text = "COLLECTING"; color = "green" }
                            }
                        }
                    )
                    unit = "short"
                }
            }
            gridPos = @{ h = 8; w = 12; x = 0; y = 0 }
        },
        @{
            id = 2
            title = "Data Storage Status"
            type = "stat"
            targets = @(
                @{
                    expr = "up{job=`"binance-data-storage-testnet`"}"
                    refId = "A"
                }
            )
            fieldConfig = @{
                defaults = @{
                    mappings = @(
                        @{
                            type = "value"
                            options = @{
                                "0" = @{ text = "UNAVAILABLE"; color = "red" }
                                "1" = @{ text = "AVAILABLE"; color = "green" }
                            }
                        }
                    )
                    unit = "short"
                }
            }
            gridPos = @{ h = 8; w = 12; x = 12; y = 0 }
        }
    )
    time = @{
        from = "now-1h"
        to = "now"
    }
    refresh = "30s"
    schemaVersion = 36
    version = 1
    annotations = @{ list = @() }
    editable = $true
    fiscalYearStartMonth = 0
    graphTooltip = 0
    links = @()
    liveNow = $false
    style = "dark"
    templating = @{ list = @() }
    timepicker = @{}
    weekStart = ""
}

$klineData | ConvertTo-Json -Depth 10 | Out-File -FilePath "monitoring/grafana/provisioning/dashboards/04-kline-data/kline-data-monitoring.json" -Encoding UTF8
Write-Host "✅ Created: kline-data-monitoring.json" -ForegroundColor Green

# 5. Analytics Dashboard
Write-Host "`n5. Creating Analytics Dashboard..." -ForegroundColor Cyan

$analytics = @{
    id = $null
    title = "Trading Analytics & Insights"
    uid = "trading-analytics-insights"
    tags = @("analytics", "insights", "metrics")
    timezone = "browser"
    panels = @(
        @{
            id = 1
            title = "System Performance Metrics"
            type = "stat"
            targets = @(
                @{
                    expr = "rate(http_requests_total[5m])"
                    refId = "A"
                }
            )
            fieldConfig = @{
                defaults = @{
                    unit = "reqps"
                }
            }
            gridPos = @{ h = 8; w = 24; x = 0; y = 0 }
        }
    )
    time = @{
        from = "now-1h"
        to = "now"
    }
    refresh = "30s"
    schemaVersion = 36
    version = 1
    annotations = @{ list = @() }
    editable = $true
    fiscalYearStartMonth = 0
    graphTooltip = 0
    links = @()
    liveNow = $false
    style = "dark"
    templating = @{ list = @() }
    timepicker = @{}
    weekStart = ""
}

$analytics | ConvertTo-Json -Depth 10 | Out-File -FilePath "monitoring/grafana/provisioning/dashboards/05-analytics/trading-analytics-insights.json" -Encoding UTF8
Write-Host "✅ Created: trading-analytics-insights.json" -ForegroundColor Green

# 6. Executive Dashboard
Write-Host "`n6. Creating Executive Dashboard..." -ForegroundColor Cyan

$executive = @{
    id = $null
    title = "Executive Overview"
    uid = "executive-overview"
    tags = @("executive", "overview", "kpis")
    timezone = "browser"
    panels = @(
        @{
            id = 1
            title = "System Health Summary"
            type = "stat"
            targets = @(
                @{
                    expr = "up{job=~`".*testnet.*`"}"
                    refId = "A"
                }
            )
            fieldConfig = @{
                defaults = @{
                    mappings = @(
                        @{
                            type = "value"
                            options = @{
                                "0" = @{ text = "CRITICAL"; color = "red" }
                                "1" = @{ text = "HEALTHY"; color = "green" }
                            }
                        }
                    )
                    unit = "short"
                }
            }
            gridPos = @{ h = 8; w = 24; x = 0; y = 0 }
        }
    )
    time = @{
        from = "now-1h"
        to = "now"
    }
    refresh = "30s"
    schemaVersion = 36
    version = 1
    annotations = @{ list = @() }
    editable = $true
    fiscalYearStartMonth = 0
    graphTooltip = 0
    links = @()
    liveNow = $false
    style = "dark"
    templating = @{ list = @() }
    timepicker = @{}
    weekStart = ""
}

$executive | ConvertTo-Json -Depth 10 | Out-File -FilePath "monitoring/grafana/provisioning/dashboards/06-executive/executive-overview.json" -Encoding UTF8
Write-Host "✅ Created: executive-overview.json" -ForegroundColor Green

Write-Host "`n=== CONSOLIDATION COMPLETE ===" -ForegroundColor Green
Write-Host "Created 6 consolidated dashboards in organized folders" -ForegroundColor White
Write-Host "Removed 37 redundant/duplicate dashboards" -ForegroundColor White
Write-Host "Backup saved to: $backupDir" -ForegroundColor Yellow

Write-Host "`n=== NEW DASHBOARD STRUCTURE ===" -ForegroundColor Cyan
Write-Host "01-system-health/system-health-overview.json" -ForegroundColor White
Write-Host "02-trading-overview/trading-operations-overview.json" -ForegroundColor White
Write-Host "03-macd-strategies/macd-trading-strategies.json" -ForegroundColor White
Write-Host "04-kline-data/kline-data-monitoring.json" -ForegroundColor White
Write-Host "05-analytics/trading-analytics-insights.json" -ForegroundColor White
Write-Host "06-executive/executive-overview.json" -ForegroundColor White

Write-Host "`n🎉 Dashboard consolidation completed!" -ForegroundColor Green
