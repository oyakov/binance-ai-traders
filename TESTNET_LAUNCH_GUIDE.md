# 🚀 Binance AI Traders - Testnet Launch Guide

## 📋 Overview
This guide provides comprehensive instructions for launching and maintaining the Binance AI Traders testnet environment for long-term testing.

## 🎯 System Architecture

### Core Services
- **Trading Application**: `binance-trader-macd-testnet` (Port 8083)
- **Database**: `postgres-testnet` (Port 5433)
- **Message Queue**: `kafka-testnet` (Port 9095)
- **Search Engine**: `elasticsearch-testnet` (Port 9202)
- **Monitoring**: `prometheus-testnet` (Port 9091)
- **Dashboards**: `grafana-testnet` (Port 3001)

### Network Configuration
- **Network**: `binance-ai-traders_testnet-network`
- **Environment**: Testnet (Binance Testnet API)

## 🚀 Launch Sequence

### 1. Pre-Launch Checklist
- [ ] API credentials configured in `testnet.env`
- [ ] Docker and Docker Compose installed
- [ ] Sufficient disk space (>10GB)
- [ ] Network connectivity to Binance testnet

### 2. System Startup
```bash
# Start all services
docker-compose -f docker-compose-testnet.yml --env-file testnet.env up -d

# Check service status
docker-compose -f docker-compose-testnet.yml ps

# Monitor logs
docker-compose -f docker-compose-testnet.yml logs -f
```

### 3. Health Verification
```bash
# Check service health
docker-compose -f docker-compose-testnet.yml ps

# Test API connectivity
curl http://localhost:8083/actuator/health
curl http://localhost:3001
curl http://localhost:9091/api/v1/query?query=up
```

## 📊 Monitoring & Dashboards

### Grafana Access
- **URL**: http://localhost:3001
- **Username**: admin
- **Password**: testnet_admin

### Dashboard Folders
1. **Binance Trading**
   - Executive Overview
   - Trading Operations

2. **System Health**
   - System Health
   - Health Overview
   - Infrastructure Health

3. **Analytics & Insights**
   - Analytics & Insights

### Prometheus Metrics
- **URL**: http://localhost:9091
- **Query Examples**:
  - `up{job="binance-macd-trader-testnet"}`
  - `binance_trader_signals_total`
  - `binance_trader_orders_total`

## 🔧 Long-Term Monitoring

### Automated Monitoring Script
```powershell
# Start long-term monitoring
.\testnet_long_term_monitor.ps1 -CheckIntervalMinutes 5

# Monitor with custom intervals
.\testnet_long_term_monitor.ps1 -CheckIntervalMinutes 1 -LogDirectory ".\custom_logs"
```

### Monitoring Features
- **Service Health Checks**: Every 5 minutes
- **Trading Activity Monitoring**: Real-time signal tracking
- **Resource Usage**: CPU and memory monitoring
- **API Connectivity**: Binance testnet connectivity
- **Daily Reports**: Automated JSON reports
- **Alert System**: Critical issue notifications

### Log Locations
- **Monitor Logs**: `.\testnet_logs\testnet_monitor.log`
- **Alerts**: `.\testnet_logs\alerts.log`
- **Daily Reports**: `.\testnet_reports\testnet_report_YYYY-MM-DD.json`

## 🚨 Alert Configuration

### Critical Alerts
- Service down for >1 minute
- Trading application down for >30 seconds
- Database connectivity lost
- No trading activity for >2 hours

### Warning Alerts
- High memory usage (>80%)
- High CPU usage (>80%)
- High order failure rate (>10%)
- No successful orders for >2 hours

## 📈 Performance Metrics

### Key Performance Indicators (KPIs)
1. **System Uptime**: Target >99.5%
2. **Trading Signal Generation**: Monitor frequency and accuracy
3. **Order Success Rate**: Target >95%
4. **Response Time**: API response <2 seconds
5. **Resource Usage**: CPU <70%, Memory <80%

### Daily Monitoring Tasks
1. Check service health status
2. Review trading activity logs
3. Analyze performance metrics
4. Verify API connectivity
5. Check alert notifications

## 🔄 Maintenance Procedures

### Daily Maintenance
```bash
# Check service status
docker-compose -f docker-compose-testnet.yml ps

# View recent logs
docker-compose -f docker-compose-testnet.yml logs --tail 100

# Check disk usage
docker system df

# Clean up old logs (optional)
docker system prune -f
```

### Weekly Maintenance
```bash
# Restart services for updates
docker-compose -f docker-compose-testnet.yml restart

# Backup important data
docker exec postgres-testnet pg_dump -U postgres binance_trader > backup_$(date +%Y%m%d).sql

# Update monitoring reports
# (Automated by monitoring script)
```

### Monthly Maintenance
```bash
# Full system restart
docker-compose -f docker-compose-testnet.yml down
docker-compose -f docker-compose-testnet.yml --env-file testnet.env up -d

# Clean up old backups
# (Manual cleanup of backup files older than 30 days)
```

## 🛠️ Troubleshooting

### Common Issues

#### Service Won't Start
```bash
# Check logs
docker logs <service-name>

# Restart specific service
docker-compose -f docker-compose-testnet.yml restart <service-name>

# Check resource usage
docker stats
```

#### Trading Application Issues
```bash
# Check application logs
docker logs binance-trader-macd-testnet

# Verify API connectivity
curl https://testnet.binance.vision/api/v3/ping

# Check environment variables
docker exec binance-trader-macd-testnet env | grep BINANCE
```

#### Database Issues
```bash
# Check database logs
docker logs postgres-testnet

# Test database connectivity
docker exec postgres-testnet psql -U postgres -c "SELECT 1;"

# Check database size
docker exec postgres-testnet psql -U postgres -c "SELECT pg_size_pretty(pg_database_size('binance_trader'));"
```

#### Monitoring Issues
```bash
# Check Prometheus logs
docker logs prometheus-testnet

# Check Grafana logs
docker logs grafana-testnet

# Test metrics endpoint
curl http://localhost:9091/api/v1/query?query=up
```

## 📋 Test Scenarios

### 1. Basic Functionality Test
- [ ] All services start successfully
- [ ] Trading application connects to Binance testnet
- [ ] Data flows through the system
- [ ] Monitoring dashboards display data

### 2. Trading Strategy Test
- [ ] MACD signals are generated
- [ ] Orders are placed (test mode)
- [ ] Performance metrics are recorded
- [ ] Alerts are triggered appropriately

### 3. Long-Term Stability Test
- [ ] System runs for 24+ hours without issues
- [ ] Memory usage remains stable
- [ ] No memory leaks detected
- [ ] Trading performance is consistent

### 4. Failure Recovery Test
- [ ] Services restart automatically after failure
- [ ] Data is not lost during restarts
- [ ] Monitoring continues during failures
- [ ] Alerts are sent for critical issues

## 📞 Support & Escalation

### Level 1: Basic Issues
- Service restart
- Log checking
- Basic configuration

### Level 2: Complex Issues
- Database problems
- Trading logic issues
- Performance optimization

### Level 3: Critical Issues
- System-wide failures
- Data loss
- Security incidents

## 📚 Additional Resources

### Documentation
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Binance API Documentation](https://binance-docs.github.io/apidocs/)

### Monitoring Tools
- **Grafana**: http://localhost:3001
- **Prometheus**: http://localhost:9091
- **Trading App**: http://localhost:8083

### Log Files
- **Application Logs**: `docker logs <service-name>`
- **Monitor Logs**: `.\testnet_logs\`
- **System Logs**: Windows Event Viewer

---

## 🎉 Success Criteria

The testnet is considered successfully launched when:
- [ ] All services are healthy and running
- [ ] Trading application is generating signals
- [ ] Monitoring dashboards show real-time data
- [ ] Long-term monitoring script is running
- [ ] No critical alerts are active
- [ ] System has been stable for 24+ hours

**Last Updated**: October 4, 2025
**Version**: 1.0
**Status**: Ready for Production Testing
