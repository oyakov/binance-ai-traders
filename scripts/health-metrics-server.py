#!/usr/bin/env python3
"""
Simple Health Metrics Server for Prometheus
Serves health metrics for all system components
"""

import http.server
import socketserver
import json
import subprocess
import time
from urllib.parse import urlparse

class HealthMetricsHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        parsed_path = urlparse(self.path)
        
        if parsed_path.path == '/metrics':
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain; version=0.0.4; charset=utf-8')
            self.end_headers()
            
            # Generate health metrics
            metrics = self.get_health_metrics()
            self.wfile.write(metrics.encode('utf-8'))
            
        elif parsed_path.path == '/health':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            
            health_data = {
                "status": "UP",
                "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
                "service": "health-metrics-exporter"
            }
            self.wfile.write(json.dumps(health_data).encode('utf-8'))
            
        else:
            self.send_response(404)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            
            error_data = {
                "error": "Not Found",
                "message": "Endpoint not found",
                "available_endpoints": ["/metrics", "/health"]
            }
            self.wfile.write(json.dumps(error_data).encode('utf-8'))
    
    def get_health_metrics(self):
        """Generate Prometheus metrics for all system components"""
        metrics = []
        
        # PostgreSQL metrics
        postgres_up = self.check_postgres()
        metrics.append(f'postgres_container_up{{environment="testnet"}} {1 if postgres_up else 0}')
        metrics.append(f'postgres_ready{{environment="testnet"}} {1 if postgres_up else 0}')
        
        # Kafka metrics
        kafka_up = self.check_kafka()
        metrics.append(f'kafka_container_up{{environment="testnet"}} {1 if kafka_up else 0}')
        metrics.append(f'kafka_active{{environment="testnet"}} {1 if kafka_up else 0}')
        
        # Elasticsearch metrics
        es_up = self.check_elasticsearch()
        metrics.append(f'elasticsearch_container_up{{environment="testnet"}} {1 if es_up else 0}')
        metrics.append(f'elasticsearch_healthy{{environment="testnet"}} {1 if es_up else 0}')
        
        # Trading service metrics
        trading_up = self.check_trading_service()
        metrics.append(f'trading_service_up{{environment="testnet"}} {1 if trading_up else 0}')
        
        # Data collection service metrics
        data_collection_up = self.check_data_collection_service()
        metrics.append(f'data_collection_service_up{{environment="testnet"}} {1 if data_collection_up else 0}')
        
        return '\n'.join(metrics) + '\n'
    
    def check_postgres(self):
        """Check PostgreSQL health"""
        try:
            result = subprocess.run([
                'docker', 'exec', 'postgres-testnet', 
                'pg_isready', '-h', 'localhost', '-p', '5432'
            ], capture_output=True, timeout=5)
            return result.returncode == 0
        except:
            return False
    
    def check_kafka(self):
        """Check Kafka health"""
        try:
            result = subprocess.run([
                'docker', 'logs', 'kafka-testnet', '--tail', '10'
            ], capture_output=True, timeout=5, text=True)
            return 'GroupCoordinator' in result.stdout
        except:
            return False
    
    def check_elasticsearch(self):
        """Check Elasticsearch health"""
        try:
            result = subprocess.run([
                'curl', '-s', 'http://localhost:9202/_cluster/health'
            ], capture_output=True, timeout=5)
            return result.returncode == 0
        except:
            return False
    
    def check_trading_service(self):
        """Check trading service health"""
        try:
            result = subprocess.run([
                'curl', '-s', 'http://localhost:8083/actuator/health'
            ], capture_output=True, timeout=5)
            return result.returncode == 0
        except:
            return False
    
    def check_data_collection_service(self):
        """Check data collection service health"""
        try:
            result = subprocess.run([
                'curl', '-s', 'http://localhost:8086/actuator/health'
            ], capture_output=True, timeout=5)
            return result.returncode == 0
        except:
            return False

def main():
    PORT = 8092
    
    with socketserver.TCPServer(("", PORT), HealthMetricsHandler) as httpd:
        print(f"Health Metrics Server running on port {PORT}")
        print(f"Endpoints:")
        print(f"  GET /metrics - Prometheus metrics")
        print(f"  GET /health - Health check")
        print(f"Press Ctrl+C to stop")
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nHealth Metrics Server stopped.")

if __name__ == "__main__":
    main()
