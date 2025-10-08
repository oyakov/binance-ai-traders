# Simple Grafana Dashboard Enhancement Script
Write-Host "=== Grafana Dashboard Enhancement ===" -ForegroundColor Green
Write-Host "Timestamp: $(Get-Date)" -ForegroundColor Yellow
Write-Host ""

# Create enhanced trading dashboard
Write-Host "Creating enhanced trading dashboard..." -ForegroundColor Cyan

$enhancedTrading = @{
    "annotations" = @{
        "list" = @(
            @{
                "builtIn" = 1
                "datasource" = @{
                    "type" = "grafana"
                    "uid" = "-- Grafana --"
                }
                "enable" = $true
                "hide" = $true
                "iconColor" = "rgba(0, 211, 255, 1)"
                "name" = "Annotations & Alerts"
                "type" = "dashboard"
            }
        )
    }
    "editable" = $true
    "fiscalYearStartMonth" = 0
    "graphTooltip" = 0
    "id" = $null
    "links" = @()
    "liveNow" = $false
    "panels" = @(
        @{
            "datasource" = @{
                "type" = "prometheus"
                "uid" = "prometheus"
            }
            "fieldConfig" = @{
                "defaults" = @{
                    "color" = @{
                        "mode" = "palette-classic"
                    }
                    "custom" = @{
                        "axisLabel" = ""
                        "axisPlacement" = "auto"
                        "barAlignment" = 0
                        "drawStyle" = "line"
                        "fillOpacity" = 10
                        "gradientMode" = "none"
                        "hideFrom" = @{
                            "legend" = $false
                            "tooltip" = $false
                            "vis" = $false
                        }
                        "lineInterpolation" = "linear"
                        "lineWidth" = 1
                        "pointSize" = 5
                        "scaleDistribution" = @{
                            "type" = "linear"
                        }
                        "showPoints" = "never"
                        "spanNulls" = $false
                        "stacking" = @{
                            "group" = "A"
                            "mode" = "none"
                        }
                        "thresholdsStyle" = @{
                            "mode" = "off"
                        }
                    }
                    "mappings" = @()
                    "thresholds" = @{
                        "mode" = "absolute"
                        "steps" = @(
                            @{
                                "color" = "green"
                                "value" = $null
                            }
                            @{
                                "color" = "red"
                                "value" = 80
                            }
                        )
                    }
                    "unit" = "short"
                }
                "overrides" = @()
            }
            "gridPos" = @{
                "h" = 8
                "w" = 12
                "x" = 0
                "y" = 0
            }
            "id" = 1
            "options" = @{
                "legend" = @{
                    "calcs" = @()
                    "displayMode" = "list"
                    "placement" = "bottom"
                }
                "tooltip" = @{
                    "mode" = "single"
                    "sort" = "none"
                }
            }
            "targets" = @(
                @{
                    "datasource" = @{
                        "type" = "prometheus"
                        "uid" = "prometheus"
                    }
                    "editorMode" = "code"
                    "expr" = "up"
                    "instant" = $false
                    "legendFormat" = "{{instance}} - {{job}}"
                    "range" = $true
                    "refId" = "A"
                }
            )
            "title" = "Service Health Status"
            "type" = "timeseries"
        }
        @{
            "datasource" = @{
                "type" = "prometheus"
                "uid" = "prometheus"
            }
            "fieldConfig" = @{
                "defaults" = @{
                    "color" = @{
                        "mode" = "palette-classic"
                    }
                    "custom" = @{
                        "axisLabel" = ""
                        "axisPlacement" = "auto"
                        "barAlignment" = 0
                        "drawStyle" = "line"
                        "fillOpacity" = 10
                        "gradientMode" = "none"
                        "hideFrom" = @{
                            "legend" = $false
                            "tooltip" = $false
                            "vis" = $false
                        }
                        "lineInterpolation" = "linear"
                        "lineWidth" = 1
                        "pointSize" = 5
                        "scaleDistribution" = @{
                            "type" = "linear"
                        }
                        "showPoints" = "never"
                        "spanNulls" = $false
                        "stacking" = @{
                            "group" = "A"
                            "mode" = "none"
                        }
                        "thresholdsStyle" = @{
                            "mode" = "off"
                        }
                    }
                    "mappings" = @()
                    "thresholds" = @{
                        "mode" = "absolute"
                        "steps" = @(
                            @{
                                "color" = "green"
                                "value" = $null
                            }
                            @{
                                "color" = "red"
                                "value" = 80
                            }
                        )
                    }
                    "unit" = "short"
                }
                "overrides" = @()
            }
            "gridPos" = @{
                "h" = 8
                "w" = 12
                "x" = 12
                "y" = 0
            }
            "id" = 2
            "options" = @{
                "legend" = @{
                    "calcs" = @()
                    "displayMode" = "list"
                    "placement" = "bottom"
                }
                "tooltip" = @{
                    "mode" = "single"
                    "sort" = "none"
                }
            }
            "targets" = @(
                @{
                    "datasource" = @{
                        "type" = "prometheus"
                        "uid" = "prometheus"
                    }
                    "editorMode" = "code"
                    "expr" = "rate(http_requests_total[5m])"
                    "instant" = $false
                    "legendFormat" = "{{instance}} - {{job}}"
                    "range" = $true
                    "refId" = "A"
                }
            )
            "title" = "Request Rate"
            "type" = "timeseries"
        }
    )
    "refresh" = "30s"
    "schemaVersion" = 36
    "style" = "dark"
    "tags" = @("binance", "trading", "enhanced")
    "templating" = @{
        "list" = @()
    }
    "time" = @{
        "from" = "now-1h"
        "to" = "now"
    }
    "timepicker" = @{}
    "timezone" = ""
    "title" = "Enhanced Trading Dashboard"
    "uid" = "enhanced-trading-comprehensive"
    "version" = 1
    "weekStart" = ""
}

# Save enhanced trading dashboard
$enhancedTrading | ConvertTo-Json -Depth 10 | Out-File -FilePath "monitoring/grafana/provisioning/dashboards/enhanced-trading/enhanced-trading-comprehensive.json" -Encoding UTF8
Write-Host "✅ Created enhanced trading dashboard" -ForegroundColor Green

# Create enhanced system health dashboard
Write-Host "Creating enhanced system health dashboard..." -ForegroundColor Cyan

$enhancedSystemHealth = @{
    "annotations" = @{
        "list" = @(
            @{
                "builtIn" = 1
                "datasource" = @{
                    "type" = "grafana"
                    "uid" = "-- Grafana --"
                }
                "enable" = $true
                "hide" = $true
                "iconColor" = "rgba(0, 211, 255, 1)"
                "name" = "Annotations & Alerts"
                "type" = "dashboard"
            }
        )
    }
    "editable" = $true
    "fiscalYearStartMonth" = 0
    "graphTooltip" = 0
    "id" = $null
    "links" = @()
    "liveNow" = $false
    "panels" = @(
        @{
            "datasource" = @{
                "type" = "prometheus"
                "uid" = "prometheus"
            }
            "fieldConfig" = @{
                "defaults" = @{
                    "color" = @{
                        "mode" = "palette-classic"
                    }
                    "custom" = @{
                        "axisLabel" = ""
                        "axisPlacement" = "auto"
                        "barAlignment" = 0
                        "drawStyle" = "line"
                        "fillOpacity" = 10
                        "gradientMode" = "none"
                        "hideFrom" = @{
                            "legend" = $false
                            "tooltip" = $false
                            "vis" = $false
                        }
                        "lineInterpolation" = "linear"
                        "lineWidth" = 1
                        "pointSize" = 5
                        "scaleDistribution" = @{
                            "type" = "linear"
                        }
                        "showPoints" = "never"
                        "spanNulls" = $false
                        "stacking" = @{
                            "group" = "A"
                            "mode" = "none"
                        }
                        "thresholdsStyle" = @{
                            "mode" = "off"
                        }
                    }
                    "mappings" = @()
                    "thresholds" = @{
                        "mode" = "absolute"
                        "steps" = @(
                            @{
                                "color" = "green"
                                "value" = $null
                            }
                            @{
                                "color" = "red"
                                "value" = 80
                            }
                        )
                    }
                    "unit" = "short"
                }
                "overrides" = @()
            }
            "gridPos" = @{
                "h" = 8
                "w" = 12
                "x" = 0
                "y" = 0
            }
            "id" = 1
            "options" = @{
                "legend" = @{
                    "calcs" = @()
                    "displayMode" = "list"
                    "placement" = "bottom"
                }
                "tooltip" = @{
                    "mode" = "single"
                    "sort" = "none"
                }
            }
            "targets" = @(
                @{
                    "datasource" = @{
                        "type" = "prometheus"
                        "uid" = "prometheus"
                    }
                    "editorMode" = "code"
                    "expr" = "container_memory_usage_bytes"
                    "instant" = $false
                    "legendFormat" = "{{name}}"
                    "range" = $true
                    "refId" = "A"
                }
            )
            "title" = "Container Memory Usage"
            "type" = "timeseries"
        }
        @{
            "datasource" = @{
                "type" = "prometheus"
                "uid" = "prometheus"
            }
            "fieldConfig" = @{
                "defaults" = @{
                    "color" = @{
                        "mode" = "palette-classic"
                    }
                    "custom" = @{
                        "axisLabel" = ""
                        "axisPlacement" = "auto"
                        "barAlignment" = 0
                        "drawStyle" = "line"
                        "fillOpacity" = 10
                        "gradientMode" = "none"
                        "hideFrom" = @{
                            "legend" = $false
                            "tooltip" = $false
                            "vis" = $false
                        }
                        "lineInterpolation" = "linear"
                        "lineWidth" = 1
                        "pointSize" = 5
                        "scaleDistribution" = @{
                            "type" = "linear"
                        }
                        "showPoints" = "never"
                        "spanNulls" = $false
                        "stacking" = @{
                            "group" = "A"
                            "mode" = "none"
                        }
                        "thresholdsStyle" = @{
                            "mode" = "off"
                        }
                    }
                    "mappings" = @()
                    "thresholds" = @{
                        "mode" = "absolute"
                        "steps" = @(
                            @{
                                "color" = "green"
                                "value" = $null
                            }
                            @{
                                "color" = "red"
                                "value" = 80
                            }
                        )
                    }
                    "unit" = "percent"
                }
                "overrides" = @()
            }
            "gridPos" = @{
                "h" = 8
                "w" = 12
                "x" = 12
                "y" = 0
            }
            "id" = 2
            "options" = @{
                "legend" = @{
                    "calcs" = @()
                    "displayMode" = "list"
                    "placement" = "bottom"
                }
                "tooltip" = @{
                    "mode" = "single"
                    "sort" = "none"
                }
            }
            "targets" = @(
                @{
                    "datasource" = @{
                        "type" = "prometheus"
                        "uid" = "prometheus"
                    }
                    "editorMode" = "code"
                    "expr" = "rate(container_cpu_usage_seconds_total[5m]) * 100"
                    "instant" = $false
                    "legendFormat" = "{{name}}"
                    "range" = $true
                    "refId" = "A"
                }
            )
            "title" = "Container CPU Usage"
            "type" = "timeseries"
        }
    )
    "refresh" = "30s"
    "schemaVersion" = 36
    "style" = "dark"
    "tags" = @("system", "health", "monitoring")
    "templating" = @{
        "list" = @()
    }
    "time" = @{
        "from" = "now-1h"
        "to" = "now"
    }
    "timepicker" = @{}
    "timezone" = ""
    "title" = "Enhanced System Health Dashboard"
    "uid" = "enhanced-system-health"
    "version" = 1
    "weekStart" = ""
}

# Save enhanced system health dashboard
$enhancedSystemHealth | ConvertTo-Json -Depth 10 | Out-File -FilePath "monitoring/grafana/provisioning/dashboards/system-monitoring/enhanced-system-health.json" -Encoding UTF8
Write-Host "✅ Created enhanced system health dashboard" -ForegroundColor Green

# Restart Grafana to apply changes
Write-Host "`n=== Restarting Grafana ===" -ForegroundColor Cyan
docker-compose -f docker-compose-testnet.yml restart grafana-testnet
Start-Sleep -Seconds 15

Write-Host "`n=== Enhancement Summary ===" -ForegroundColor Green
Write-Host "✅ Created enhanced trading dashboard" -ForegroundColor Green
Write-Host "✅ Created enhanced system health dashboard" -ForegroundColor Green
Write-Host "`n🎉 Dashboard enhancement completed!" -ForegroundColor Green
Write-Host "📊 Grafana URL: http://localhost:3001" -ForegroundColor Cyan
Write-Host "🔑 Default Login: admin/admin" -ForegroundColor Cyan
