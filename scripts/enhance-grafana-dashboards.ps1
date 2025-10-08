# Grafana Dashboard Enhancement Script
# This script enhances existing dashboards with additional metrics and visualizations

param(
    [switch]$CreateNew,
    [switch]$UpdateExisting
)

Write-Host "=== Grafana Dashboard Enhancement ===" -ForegroundColor Green
Write-Host "Timestamp: $(Get-Date)" -ForegroundColor Yellow
Write-Host ""

# Function to create enhanced trading dashboard
function New-EnhancedTradingDashboard {
    $dashboard = @{
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
            # System Health Overview
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
                        "expr" = "up{job=~\"binance-.*\"}"
                        "instant" = $false
                        "legendFormat" = "{{instance}} - {{job}}"
                        "range" = $true
                        "refId" = "A"
                    }
                )
                "title" = "Service Health Status"
                "type" = "timeseries"
            }
            
            # Trading Performance Metrics
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
                        "expr" = "rate(http_requests_total{job=~\"binance-.*\"}[5m])"
                        "instant" = $false
                        "legendFormat" = "{{instance}} - {{job}}"
                        "range" = $true
                        "refId" = "A"
                    }
                )
                "title" = "Request Rate"
                "type" = "timeseries"
            }
            
            # MACD Strategy Performance
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
                    "w" = 24
                    "x" = 0
                    "y" = 8
                }
                "id" = 3
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
                        "expr" = "jvm_memory_used_bytes{job=~\"binance-.*\"}"
                        "instant" = $false
                        "legendFormat" = "{{instance}} - {{job}}"
                        "range" = $true
                        "refId" = "A"
                    }
                )
                "title" = "Memory Usage"
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
    
    return $dashboard
}

# Function to create system health dashboard
function New-SystemHealthDashboard {
    $dashboard = @{
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
            # Container Status
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
                        "expr" = "container_memory_usage_bytes{name=~\"binance-.*\"}"
                        "instant" = $false
                        "legendFormat" = "{{name}}"
                        "range" = $true
                        "refId" = "A"
                    }
                )
                "title" = "Container Memory Usage"
                "type" = "timeseries"
            }
            
            # CPU Usage
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
                        "expr" = "rate(container_cpu_usage_seconds_total{name=~\"binance-.*\"}[5m]) * 100"
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
    
    return $dashboard
}

# Create enhanced dashboards
if ($CreateNew) {
    Write-Host "Creating enhanced dashboards..." -ForegroundColor Cyan
    
    # Create enhanced trading dashboard
    $enhancedTrading = New-EnhancedTradingDashboard
    $enhancedTrading | ConvertTo-Json -Depth 10 | Out-File -FilePath "monitoring/grafana/provisioning/dashboards/enhanced-trading/enhanced-trading-comprehensive.json" -Encoding UTF8
    Write-Host "✅ Created enhanced trading dashboard" -ForegroundColor Green
    
    # Create enhanced system health dashboard
    $enhancedSystemHealth = New-SystemHealthDashboard
    $enhancedSystemHealth | ConvertTo-Json -Depth 10 | Out-File -FilePath "monitoring/grafana/provisioning/dashboards/system-monitoring/enhanced-system-health.json" -Encoding UTF8
    Write-Host "✅ Created enhanced system health dashboard" -ForegroundColor Green
}

# Update existing dashboards
if ($UpdateExisting) {
    Write-Host "Updating existing dashboards..." -ForegroundColor Cyan
    
    # Add new metrics to existing dashboards
    $dashboardFiles = Get-ChildItem -Path "monitoring/grafana/provisioning/dashboards" -Recurse -Filter "*.json"
    
    foreach ($file in $dashboardFiles) {
        try {
            $content = Get-Content $file.FullName -Raw | ConvertFrom-Json
            
            # Add new panels or update existing ones
            if ($content.panels) {
                # Add a new panel for additional metrics
                $newPanel = @{
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
                        "y" = ($content.panels.Count * 8)
                    }
                    "id" = ($content.panels.Count + 1)
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
                            "expr" = "up{job=~\"binance-.*\"}"
                            "instant" = $false
                            "legendFormat" = "{{instance}} - {{job}}"
                            "range" = $true
                            "refId" = "A"
                        }
                    )
                    "title" = "Enhanced Metrics - $(Get-Date -Format 'yyyy-MM-dd')"
                    "type" = "timeseries"
                }
                
                $content.panels += $newPanel
                $content | ConvertTo-Json -Depth 10 | Out-File -FilePath $file.FullName -Encoding UTF8
                Write-Host "✅ Enhanced dashboard: $($file.Name)" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "⚠️  Could not enhance dashboard: $($file.Name) - $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n=== Enhancement Summary ===" -ForegroundColor Green
if ($CreateNew) {
    Write-Host "✅ Created enhanced trading dashboard" -ForegroundColor Green
    Write-Host "✅ Created enhanced system health dashboard" -ForegroundColor Green
}
if ($UpdateExisting) {
    Write-Host "✅ Updated existing dashboards with new metrics" -ForegroundColor Green
}

Write-Host "`n🎉 Dashboard enhancement completed!" -ForegroundColor Green
Write-Host "📊 Grafana URL: http://localhost:3001" -ForegroundColor Cyan
Write-Host "🔑 Default Login: admin/admin" -ForegroundColor Cyan
