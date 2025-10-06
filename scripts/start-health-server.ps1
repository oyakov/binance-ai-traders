# Health Dashboard Server
# This starts a simple HTTP server to serve the health dashboard

param(
    [int]$Port = 8080
)

Write-Host "=== STARTING HEALTH DASHBOARD SERVER ===" -ForegroundColor Green
Write-Host "Port: $Port" -ForegroundColor Yellow
Write-Host "Dashboard will be available at: http://localhost:$Port" -ForegroundColor Cyan
Write-Host ""

# Check if Python is available
try {
    $pythonVersion = python --version 2>&1
    Write-Host "Using Python: $pythonVersion" -ForegroundColor Green
    Write-Host "Starting HTTP server..." -ForegroundColor Yellow
    Write-Host "Press Ctrl+C to stop the server" -ForegroundColor White
    Write-Host ""
    
    # Start Python HTTP server
    python -m http.server $Port
} catch {
    Write-Host "Python not found. Trying PowerShell alternative..." -ForegroundColor Yellow
    
    # PowerShell alternative using .NET HttpListener
    Add-Type -AssemblyName System.Net.Http
    
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://localhost:$Port/")
    $listener.Start()
    
    Write-Host "PowerShell HTTP server started on port $Port" -ForegroundColor Green
    Write-Host "Dashboard available at: http://localhost:$Port/system-health-dashboard.html" -ForegroundColor Cyan
    
    try {
        while ($listener.IsListening) {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response
            
            $localPath = $request.Url.LocalPath
            if ($localPath -eq "/" -or $localPath -eq "/system-health-dashboard.html") {
                $filePath = Join-Path $PWD "system-health-dashboard.html"
                if (Test-Path $filePath) {
                    $content = Get-Content $filePath -Raw -Encoding UTF8
                    $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
                    $response.ContentType = "text/html; charset=utf-8"
                    $response.ContentLength64 = $buffer.Length
                    $response.OutputStream.Write($buffer, 0, $buffer.Length)
                } else {
                    $response.StatusCode = 404
                }
            } else {
                $response.StatusCode = 404
            }
            
            $response.Close()
        }
    } finally {
        $listener.Stop()
    }
}
