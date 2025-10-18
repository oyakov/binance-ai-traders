#!/bin/bash
#
# Quick Deployment Script for Binance AI Traders
# Runs on VPS to deploy the application with all security controls
#
# Usage: ./quick-deploy.sh
#

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║   Binance AI Traders - Quick Deployment                      ║"
echo "║   Deploying with Enterprise Security                          ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if running as deployment user (not root)
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}✗ Don't run this script as root!${NC}"
    echo "Switch to deployment user: su - binance-trader"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker not found!${NC}"
    echo "Run VPS setup script first"
    exit 1
fi

echo -e "${GREEN}▶ Step 1: Checking prerequisites${NC}"

# Check if in correct directory
if [ ! -f "docker-compose-testnet.yml" ]; then
    echo -e "${RED}✗ docker-compose-testnet.yml not found!${NC}"
    echo "Run from repository root: cd /opt/binance-traders"
    exit 1
fi

# Check for testnet.env
if [ ! -f "testnet.env" ]; then
    if [ -f "testnet.env.enc" ]; then
        echo -e "${YELLOW}⚠ testnet.env not found but testnet.env.enc exists${NC}"
        echo "Decrypt with: sops -d testnet.env.enc > testnet.env"
        exit 1
    else
        echo -e "${YELLOW}⚠ testnet.env not found${NC}"
        echo "Create from template: cp testnet.env.template testnet.env"
        exit 1
    fi
fi

echo -e "${GREEN}✓ Prerequisites check passed${NC}"

echo -e "${GREEN}▶ Step 2: Creating SSL directory${NC}"
mkdir -p nginx/ssl
echo -e "${GREEN}✓ SSL directory created${NC}"

# Check for SSL certificates
if [ ! -f "nginx/ssl/cert.pem" ] || [ ! -f "nginx/ssl/key.pem" ]; then
    echo -e "${YELLOW}⚠ TLS certificates not found${NC}"
    echo "Generating self-signed certificate for testing..."
    
    openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
        -keyout nginx/ssl/key.pem \
        -out nginx/ssl/cert.pem \
        -subj "/C=US/ST=State/L=City/O=BinanceTraders/CN=testnet.local" \
        2>/dev/null
    
    echo -e "${GREEN}✓ Self-signed certificate generated${NC}"
    echo -e "${YELLOW}⚠ For production, use Let's Encrypt:${NC}"
    echo "  sudo certbot certonly --standalone -d your-domain.com"
fi

echo -e "${GREEN}▶ Step 3: Pulling Docker images${NC}"
docker compose -f docker-compose-testnet.yml pull

echo -e "${GREEN}▶ Step 4: Building custom images${NC}"
docker compose -f docker-compose-testnet.yml build

echo -e "${GREEN}▶ Step 5: Starting services${NC}"
docker compose -f docker-compose-testnet.yml --env-file testnet.env up -d

echo -e "${GREEN}▶ Step 6: Waiting for services to start...${NC}"
sleep 30

echo -e "${GREEN}▶ Step 7: Checking service health${NC}"
docker compose -f docker-compose-testnet.yml ps

echo -e "${GREEN}▶ Step 8: Service Status${NC}"
services=(
    "nginx-gateway-testnet:80"
    "nginx-gateway-testnet:443"
    "binance-trader-macd-testnet"
    "postgres-testnet"
    "elasticsearch-testnet"
    "kafka-testnet"
    "grafana-testnet"
    "prometheus-testnet"
)

all_healthy=true
for service in "${services[@]}"; do
    container_name=$(echo $service | cut -d':' -f1)
    if docker ps | grep -q "$container_name"; then
        echo -e "  ${GREEN}✓${NC} $container_name is running"
    else
        echo -e "  ${RED}✗${NC} $container_name is NOT running"
        all_healthy=false
    fi
done

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Deployment Complete!${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""

if $all_healthy; then
    echo -e "${GREEN}✓ All services are running${NC}"
else
    echo -e "${YELLOW}⚠ Some services failed to start${NC}"
    echo "Check logs: docker compose -f docker-compose-testnet.yml logs"
fi

echo ""
echo -e "${YELLOW}Service URLs:${NC}"
echo "  - Public API: https://your-domain.com/"
echo "  - Health Check: https://your-domain.com/health"
echo "  - Grafana: https://your-domain.com/grafana/"
echo "  - Prometheus: https://your-domain.com/prometheus/"
echo ""

echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Configure domain DNS to point to this server"
echo "  2. Obtain Let's Encrypt certificate"
echo "  3. Update Nginx configuration with real domain"
echo "  4. Run security tests"
echo "  5. Monitor Grafana security dashboard"
echo ""

echo -e "${YELLOW}Quick Commands:${NC}"
echo "  - View logs: docker compose -f docker-compose-testnet.yml logs -f"
echo "  - Stop services: docker compose -f docker-compose-testnet.yml down"
echo "  - Restart service: docker compose -f docker-compose-testnet.yml restart <service>"
echo "  - Check health: curl http://localhost/health"
echo ""

echo -e "${GREEN}✓ Deployment script complete!${NC}"

exit 0

