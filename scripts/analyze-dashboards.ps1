# Dashboard Analysis Script
# This script analyzes all dashboards to identify duplicates and create a consolidation plan

Write-Host "=== Dashboard Analysis ===" -ForegroundColor Green
Write-Host "Timestamp: $(Get-Date)" -ForegroundColor Yellow
Write-Host ""

# Function to analyze a dashboard file
function Analyze-Dashboard {
    param([string]$FilePath)
    
    try {
        $content = Get-Content $FilePath -Raw -Encoding UTF8
        $json = $content | ConvertFrom-Json
        
        $analysis = @{
            File = Split-Path $FilePath -Leaf
            Path = $FilePath
            Title = $json.title
            UID = $json.uid
            Tags = $json.tags -join ", "
            PanelCount = if ($json.panels) { $json.panels.Count } else { 0 }
            HasData = $false
            DataSources = @()
        }
        
        # Check for data sources
        if ($json.panels) {
            foreach ($panel in $json.panels) {
                if ($panel.targets) {
                    foreach ($target in $panel.targets) {
                        if ($target.datasource) {
                            $analysis.DataSources += $target.datasource.uid
                        }
                    }
                }
            }
        }
        
        # Check if dashboard has actual data queries
        $content | Select-String -Pattern "up\{|rate\(|sum\(|avg\(" | ForEach-Object { $analysis.HasData = $true }
        
        return $analysis
    }
    catch {
        return @{
            File = Split-Path $FilePath -Leaf
            Path = $FilePath
            Title = "ERROR"
            UID = "ERROR"
            Tags = "ERROR"
            PanelCount = 0
            HasData = $false
            DataSources = @()
            Error = $_.Exception.Message
        }
    }
}

# Get all dashboard files
$dashboardFiles = Get-ChildItem -Path "monitoring/grafana/provisioning/dashboards" -Recurse -Filter "*.json"

Write-Host "Found $($dashboardFiles.Count) dashboard files" -ForegroundColor Cyan
Write-Host ""

# Analyze each dashboard
$analyses = @()
foreach ($file in $dashboardFiles) {
    $analysis = Analyze-Dashboard $file.FullName
    $analyses += $analysis
}

# Group by title to find duplicates
$duplicates = $analyses | Group-Object Title | Where-Object { $_.Count -gt 1 }

Write-Host "=== DUPLICATE DASHBOARDS ===" -ForegroundColor Red
foreach ($dup in $duplicates) {
    Write-Host "Title: '$($dup.Name)' ($($dup.Count) copies)" -ForegroundColor Yellow
    foreach ($item in $dup.Group) {
        Write-Host "  - $($item.File) (UID: $($item.UID))" -ForegroundColor White
    }
    Write-Host ""
}

# Group by UID to find UID conflicts
$uidConflicts = $analyses | Group-Object UID | Where-Object { $_.Count -gt 1 }

Write-Host "=== UID CONFLICTS ===" -ForegroundColor Red
foreach ($conflict in $uidConflicts) {
    Write-Host "UID: '$($conflict.Name)' ($($conflict.Count) copies)" -ForegroundColor Yellow
    foreach ($item in $conflict.Group) {
        Write-Host "  - $($item.File) (Title: $($item.Title))" -ForegroundColor White
    }
    Write-Host ""
}

# Find dashboards without data
$noData = $analyses | Where-Object { -not $_.HasData }

Write-Host "=== DASHBOARDS WITHOUT DATA ===" -ForegroundColor Yellow
foreach ($item in $noData) {
    Write-Host "- $($item.File) (Title: $($item.Title))" -ForegroundColor White
}
Write-Host ""

# Find dashboards with errors
$errors = $analyses | Where-Object { $_.Error }

Write-Host "=== DASHBOARDS WITH ERRORS ===" -ForegroundColor Red
foreach ($item in $errors) {
    Write-Host "- $($item.File): $($item.Error)" -ForegroundColor White
}
Write-Host ""

# Summary by folder
Write-Host "=== DASHBOARDS BY FOLDER ===" -ForegroundColor Cyan
$byFolder = $analyses | Group-Object { Split-Path (Split-Path $_.Path -Parent) -Leaf }
foreach ($folder in $byFolder) {
    Write-Host "$($folder.Name): $($folder.Count) dashboards" -ForegroundColor White
    foreach ($item in $folder.Group) {
        Write-Host "  - $($item.File) ($($item.PanelCount) panels)" -ForegroundColor Gray
    }
    Write-Host ""
}

Write-Host "=== ANALYSIS COMPLETE ===" -ForegroundColor Green
Write-Host "Total dashboards: $($analyses.Count)" -ForegroundColor White
Write-Host "Duplicates by title: $($duplicates.Count)" -ForegroundColor White
Write-Host "UID conflicts: $($uidConflicts.Count)" -ForegroundColor White
Write-Host "No data: $($noData.Count)" -ForegroundColor White
Write-Host "Errors: $($errors.Count)" -ForegroundColor White
