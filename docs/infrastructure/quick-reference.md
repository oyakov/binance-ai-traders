# Infrastructure Quick Reference

## Docker Compose Files

### Production
```bash
# Start all services
docker-compose up -d

# Start specific services
docker-compose up -d postgres elasticsearch kafka schema-registry

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Testnet
```bash
# Deploy testnet
./docs/scripts/deploy-testnet.sh

# Monitor testnet
./docs/scripts/monitor_testnet.ps1

# Stop testnet
docker-compose -f docker-compose-testnet.yml down
```

### Test
```bash
# Run tests
./docs/scripts/docker-test.sh

# Start test environment
docker-compose -f docker-compose.test.yml up -d

# Stop test environment
docker-compose -f docker-compose.test.yml down
```

## Service Ports

| Service | Production | Testnet | Test |
|---------|------------|---------|------|
| Data Collection | 8080 | 8086 | 8081 |
| Data Storage | - | - | 8082 |
| MACD Trader | - | 8083 | 8083 |
| Telegram Frontend | - | - | 8084 |
| PostgreSQL | 5432 | 5433 | 5432 |
| Elasticsearch | 9200 | 9202 | 9200 |
| Kafka | 9092 | 9095 | 9092 |
| Schema Registry | 8081 | 8082 | - |
| Prometheus | - | 9091 | 9090 |
| Grafana | - | 3001 | 3000 |

## Health Check URLs

| Service | Health Endpoint |
|---------|----------------|
| Spring Boot | `http://localhost:PORT/actuator/health` |
| Python | `http://localhost:PORT/health` |
| PostgreSQL | `pg_isready -U user -d database` |
| Elasticsearch | `http://localhost:PORT/_cluster/health` |
| Kafka | `kafka-broker-api-versions --bootstrap-server localhost:PORT` |

## Common Commands

### Docker Management
```bash
# Check running containers
docker ps

# View container logs
docker logs container-name

# Execute command in container
docker exec -it container-name bash

# Check container resources
docker stats

# Remove all containers
docker system prune -a
```

### Service Management
```bash
# Check service status
docker-compose ps

# Restart service
docker-compose restart service-name

# Scale service
docker-compose up -d --scale service-name=2

# View service logs
docker-compose logs -f service-name
```

### Monitoring
```bash
# Start health monitoring
./docs/scripts/health-monitor.ps1

# Monitor testnet
./docs/scripts/monitor_testnet.ps1

# Test API keys
./docs/scripts/test-api-keys.ps1
```

## Troubleshooting

### Port Conflicts
```bash
# Check port usage
netstat -tulpn | grep :PORT

# Kill process using port
sudo kill -9 $(lsof -t -i:PORT)
```

### Service Issues
```bash
# Check service health
curl -f http://localhost:PORT/actuator/health

# View service logs
docker-compose logs service-name

# Restart service
docker-compose restart service-name
```

### Database Issues
```bash
# Check database connectivity
docker-compose exec postgres pg_isready -U user -d database

# Reset database
docker-compose down -v
docker-compose up -d
```

## Environment Variables

### Required Variables
```bash
# API Keys
BINANCE_API_KEY=your_api_key
BINANCE_API_SECRET=your_secret_key

# Testnet
TESTNET_API_KEY=your_testnet_key
TESTNET_SECRET_KEY=your_testnet_secret

# URLs
BINANCE_REST_BASE_URL=https://api.binance.com
TESTNET_API_URL=https://testnet.binance.vision
```

### Optional Variables
```bash
# Ports
POSTGRES_PORT=5432
ELASTICSEARCH_PORT=9200
KAFKA_PORT=9092

# Monitoring
PROMETHEUS_PORT=9090
GRAFANA_PORT=3000
GRAFANA_ADMIN_PASSWORD=admin
```

## Quick Start

### 1. Production Setup
```bash
# 1. Set environment variables
export BINANCE_API_KEY=your_key
export BINANCE_API_SECRET=your_secret

# 2. Start infrastructure
docker-compose up -d postgres elasticsearch kafka schema-registry

# 3. Wait for infrastructure
sleep 30

# 4. Start application
docker-compose up -d binance-data-collection

# 5. Verify deployment
./docs/scripts/health-monitor.ps1
```

### 2. Testnet Setup
```bash
# 1. Set testnet variables
export TESTNET_API_KEY=your_testnet_key
export TESTNET_SECRET_KEY=your_testnet_secret

# 2. Deploy testnet
./docs/scripts/deploy-testnet.sh

# 3. Monitor testnet
./docs/scripts/monitor_testnet.ps1
```

### 3. Testing Setup
```bash
# 1. Run tests
./docs/scripts/docker-test.sh

# 2. Start test environment
docker-compose -f docker-compose.test.yml up -d

# 3. Run enhanced tests
./docs/scripts/run-enhanced-tests.sh
```

## Monitoring URLs

### Production
- Data Collection: http://localhost:8080
- PostgreSQL: localhost:5432
- Elasticsearch: http://localhost:9200
- Kafka: localhost:9092
- Schema Registry: http://localhost:8081

### Testnet
- Trading Service: http://localhost:8083
- PostgreSQL: localhost:5433
- Elasticsearch: http://localhost:9202
- Kafka: localhost:9095
- Prometheus: http://localhost:9091
- Grafana: http://localhost:3001

### Test
- Data Collection: http://localhost:8081
- Data Storage: http://localhost:8082
- MACD Trader: http://localhost:8083
- Telegram Frontend: http://localhost:8084
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000

## Emergency Procedures

### Stop All Services
```bash
# Stop all Docker containers
docker stop $(docker ps -q)

# Stop all compose services
docker-compose down
docker-compose -f docker-compose-testnet.yml down
docker-compose -f docker-compose.test.yml down
```

### Reset Environment
```bash
# Remove all containers and volumes
docker-compose down -v
docker system prune -a

# Rebuild and start
docker-compose up -d --build
```

### Backup Data
```bash
# Backup PostgreSQL
docker-compose exec postgres pg_dump -U user database > backup.sql

# Backup volumes
docker run --rm -v volume_name:/data -v $(pwd):/backup alpine tar czf /backup/backup.tar.gz -C /data .
```

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review service logs
3. Check the comprehensive documentation
4. Contact the development team
