#!/bin/bash

# Binance AI Traders - Testnet Deployment Script
# This script deploys the testnet environment for M1 milestone testing

set -e

echo "🚀 Starting Binance AI Traders Testnet Deployment..."

# Check if required environment variables are set
if [ -z "$TESTNET_API_KEY" ] || [ -z "$TESTNET_SECRET_KEY" ]; then
    echo "❌ Error: Required environment variables not set!"
    echo "Please set the following environment variables:"
    echo "  - TESTNET_API_KEY: Your Binance testnet API key"
    echo "  - TESTNET_SECRET_KEY: Your Binance testnet secret key"
    echo ""
    echo "You can get these from: https://testnet.binance.vision/"
    exit 1
fi

echo "✅ Environment variables validated"

# Create .env file for Docker Compose
cat > .env << EOF
TESTNET_API_KEY=${TESTNET_API_KEY}
TESTNET_SECRET_KEY=${TESTNET_SECRET_KEY}
EOF

echo "✅ Environment file created"

# Create monitoring directory if it doesn't exist
mkdir -p monitoring/grafana/datasources

# Build the application
echo "🔨 Building Binance Trader MACD application..."
cd binance-trader-macd
mvn clean package -DskipTests
cd ..

echo "✅ Application built successfully"

# Start the testnet environment
echo "🐳 Starting testnet environment with Docker Compose..."
docker-compose -f docker-compose-testnet.yml up -d

echo "⏳ Waiting for services to start..."
sleep 30

# Check service health
echo "🔍 Checking service health..."

# Check if the main application is running
if curl -f http://localhost:8080/actuator/health > /dev/null 2>&1; then
    echo "✅ Binance Trader MACD Testnet is running"
else
    echo "❌ Binance Trader MACD Testnet is not responding"
    echo "Checking logs..."
    docker-compose -f docker-compose-testnet.yml logs binance-trader-macd-testnet
    exit 1
fi

# Check if PostgreSQL is running
if docker-compose -f docker-compose-testnet.yml exec -T postgres-testnet pg_isready -U testnet_user -d binance_trader_testnet > /dev/null 2>&1; then
    echo "✅ PostgreSQL Testnet is running"
else
    echo "❌ PostgreSQL Testnet is not responding"
fi

# Check if Elasticsearch is running
if curl -f http://localhost:9201/_cluster/health > /dev/null 2>&1; then
    echo "✅ Elasticsearch Testnet is running"
else
    echo "❌ Elasticsearch Testnet is not responding"
fi

# Check if Kafka is running
if docker-compose -f docker-compose-testnet.yml exec -T kafka-testnet kafka-broker-api-versions --bootstrap-server localhost:9093 > /dev/null 2>&1; then
    echo "✅ Kafka Testnet is running"
else
    echo "❌ Kafka Testnet is not responding"
fi

echo ""
echo "🎉 Testnet deployment completed successfully!"
echo ""
echo "📊 Service URLs:"
echo "  - Binance Trader MACD: http://localhost:8080"
echo "  - Testnet Dashboard: http://localhost:8080/api/testnet/summary"
echo "  - Health Check: http://localhost:8080/actuator/health"
echo "  - Metrics: http://localhost:8080/actuator/prometheus"
echo "  - Prometheus: http://localhost:9091"
echo "  - Grafana: http://localhost:3001 (admin/testnet_admin)"
echo ""
echo "🔧 Management Commands:"
echo "  - View logs: docker-compose -f docker-compose-testnet.yml logs -f"
echo "  - Stop services: docker-compose -f docker-compose-testnet.yml down"
echo "  - Restart services: docker-compose -f docker-compose-testnet.yml restart"
echo ""
echo "📋 Next Steps:"
echo "  1. Monitor the testnet dashboard at http://localhost:8080/api/testnet/summary"
echo "  2. Check instance performance at http://localhost:8080/api/testnet/instances"
echo "  3. View strategy rankings at http://localhost:8080/api/testnet/strategies/ranking"
echo "  4. Monitor metrics in Grafana at http://localhost:3001"
echo ""
echo "⚠️  Important Notes:"
echo "  - This is a TESTNET environment - no real money is at risk"
echo "  - Monitor the logs for any errors or issues"
echo "  - The system will run multiple trading instances with different strategies"
echo "  - Performance data will be collected for M1 milestone validation"
