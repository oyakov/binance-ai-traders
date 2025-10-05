# Health API Server
# This creates a simple API endpoint that returns health status as JSON

param(
    [int]$Port = 8085
)

Write-Host "=== STARTING HEALTH API SERVER ===" -ForegroundColor Green
Write-Host "Port: $Port" -ForegroundColor Yellow
Write-Host "API endpoint: http://localhost:$Port/health" -ForegroundColor Cyan
Write-Host ""

# Function to check service health
function Test-ServiceHealth {
    param([string]$Name, [string]$Url, [int]$Port)
    
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            return @{Status="UP"; Details="HTTP $($response.StatusCode)"}
        } else {
            return @{Status="DOWN"; Details="HTTP $($response.StatusCode)"}
        }
    }
    catch {
        # Try port connectivity as fallback
        try {
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $tcpClient.Connect("localhost", $Port)
            $tcpClient.Close()
            return @{Status="UP"; Details="Port $Port accessible"}
        }
        catch {
            return @{Status="DOWN"; Details="Connection failed"}
        }
    }
}

# Function to get all health status
function Get-AllHealthStatus {
    $services = @(
        @{Name="Trading Service"; Url="http://localhost:8083/actuator/health"; Port=8083},
        @{Name="PostgreSQL"; Url="http://localhost:5433"; Port=5433},
        @{Name="Elasticsearch"; Url="http://localhost:9202/_cluster/health"; Port=9202},
        @{Name="Kafka"; Url="http://localhost:9095"; Port=9095},
        @{Name="Prometheus"; Url="http://localhost:9091"; Port=9091},
        @{Name="Grafana"; Url="http://localhost:3001"; Port=3001}
    )
    
    $results = @()
    $healthyCount = 0
    
    foreach ($service in $services) {
        $health = Test-ServiceHealth $service.Name $service.Url $service.Port
        if ($health.Status -eq "UP") { $healthyCount++ }
        
        $results += @{
            name = $service.Name
            status = $health.Status
            details = $health.Details
            timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        }
    }
    
    return @{
        services = $results
        summary = @{
            total = $services.Count
            healthy = $healthyCount
            allHealthy = ($healthyCount -eq $services.Count)
        }
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    }
}

# Create HTTP listener
Add-Type -AssemblyName System.Net.Http

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()

Write-Host "Health API server started on port $Port" -ForegroundColor Green
Write-Host "Available endpoints:" -ForegroundColor White
Write-Host "  GET /health - Get all service health status" -ForegroundColor Cyan
Write-Host "  GET / - Simple HTML dashboard" -ForegroundColor Cyan
Write-Host ""

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $localPath = $request.Url.LocalPath
        
        if ($localPath -eq "/health") {
            # Return JSON health data
            $healthData = Get-AllHealthStatus
            $json = $healthData | ConvertTo-Json -Depth 3
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($json)
            
            $response.ContentType = "application/json; charset=utf-8"
            $response.Headers.Add("Access-Control-Allow-Origin", "*")
            $response.Headers.Add("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
            $response.Headers.Add("Access-Control-Allow-Headers", "Content-Type")
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        }
        elseif ($localPath -eq "/" -or $localPath -eq "/dashboard") {
            # Return simple HTML dashboard
            $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>System Health Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; background: #1a1a1a; color: white; margin: 20px; }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { text-align: center; margin-bottom: 30px; }
        .status-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
        .service-card { background: #2a2a2a; padding: 20px; border-radius: 10px; text-align: center; }
        .service-card.up { border-left: 5px solid #4CAF50; }
        .service-card.down { border-left: 5px solid #f44336; }
        .status-up { background: #4CAF50; color: white; padding: 5px 10px; border-radius: 15px; }
        .status-down { background: #f44336; color: white; padding: 5px 10px; border-radius: 15px; }
        .summary { background: #2a2a2a; padding: 30px; border-radius: 10px; text-align: center; margin-top: 20px; }
        .refresh-btn { background: #2196F3; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 System Health Dashboard</h1>
            <p>Real-time monitoring of all testnet services</p>
        </div>
        <div id="statusGrid" class="status-grid"></div>
        <div class="summary">
            <h2>System Summary</h2>
            <div id="summaryText"></div>
            <div id="timestamp"></div>
            <button class="refresh-btn" onclick="loadHealth()">🔄 Refresh Status</button>
        </div>
    </div>
    <script>
        async function loadHealth() {
            try {
                const response = await fetch('/health');
                const data = await response.json();
                
                const statusGrid = document.getElementById('statusGrid');
                const summaryText = document.getElementById('summaryText');
                const timestamp = document.getElementById('timestamp');
                
                statusGrid.innerHTML = '';
                
                data.services.forEach(service => {
                    const isHealthy = service.status === 'UP';
                    const serviceCard = document.createElement('div');
                    serviceCard.className = `service-card ${isHealthy ? 'up' : 'down'}`;
                    serviceCard.innerHTML = `
                        <h3>${service.name}</h3>
                        <div class="${isHealthy ? 'status-up' : 'status-down'}">
                            ${service.status} - ${service.details}
                        </div>
                    `;
                    statusGrid.appendChild(serviceCard);
                });
                
                if (data.summary.allHealthy) {
                    summaryText.innerHTML = '🎉 ALL SERVICES HEALTHY!';
                    summaryText.style.color = '#4CAF50';
                } else {
                    summaryText.innerHTML = `⚠️ ${data.summary.healthy}/${data.summary.total} SERVICES HEALTHY`;
                    summaryText.style.color = '#f44336';
                }
                
                timestamp.textContent = `Last updated: ${data.timestamp}`;
            } catch (error) {
                console.error('Error loading health data:', error);
            }
        }
        
        // Load health data on page load and every 10 seconds
        loadHealth();
        setInterval(loadHealth, 10000);
    </script>
</body>
</html>
"@
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
            $response.ContentType = "text/html; charset=utf-8"
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        }
        else {
            $response.StatusCode = 404
        }
        
        $response.Close()
    }
} finally {
    $listener.Stop()
}
