#!/usr/bin/env python3
"""
Docker-compatible Health Metrics Server for Prometheus
Serves health metrics for all system components running in Docker containers
"""

import http.server
import socketserver
import json
import urllib.request
import urllib.error
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
        
        # Data storage service metrics
        data_storage_up = self.check_data_storage_service()
        metrics.append(f'data_storage_service_up{{environment="testnet"}} {1 if data_storage_up else 0}')
        
        return '\n'.join(metrics) + '\n'
    
    def check_postgres(self):
        """Check PostgreSQL health via HTTP endpoint"""
        try:
            # Try to connect to PostgreSQL via a health check endpoint
            # Since PostgreSQL doesn't have a built-in HTTP health endpoint,
            # we'll try to connect to it directly
            import socket
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5)
            result = sock.connect_ex(('postgres-testnet', 5432))
            sock.close()
            return result == 0
        except:
            return False
    
    def check_kafka(self):
        """Check Kafka health via HTTP endpoint"""
        try:
            # Kafka doesn't have a direct HTTP health endpoint, so we'll check if the port is open
            import socket
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5)
            result = sock.connect_ex(('kafka-testnet', 9095))
            sock.close()
            return result == 0
        except:
            return False
    
    def check_elasticsearch(self):
        """Check Elasticsearch health via HTTP endpoint"""
        try:
            with urllib.request.urlopen('http://elasticsearch-testnet:9200/_cluster/health', timeout=5) as response:
                return response.status == 200
        except:
            return False
    
    def check_trading_service(self):
        """Check trading service health via HTTP endpoint"""
        try:
            with urllib.request.urlopen('http://binance-trader-macd-testnet:8080/actuator/health', timeout=5) as response:
                return response.status == 200
        except:
            return False
    
    def check_data_collection_service(self):
        """Check data collection service health via HTTP endpoint"""
        try:
            with urllib.request.urlopen('http://binance-data-collection-testnet:8080/actuator/health', timeout=5) as response:
                return response.status == 200
        except:
            return False
    
    def check_data_storage_service(self):
        """Check data storage service health via HTTP endpoint"""
        try:
            with urllib.request.urlopen('http://binance-data-storage-testnet:8081/actuator/health', timeout=5) as response:
                return response.status == 200
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
