# Testing Quick Start Guide

**Fast-track guide to running comprehensive system tests**

---

## 🎯 Goal

Run complete system validation and architecture evaluation to ensure the binance-ai-traders platform is healthy and ready for deployment.

---

## ⚡ Quick Start (5 Minutes)

### Option 1: Automated Full Test Suite

```powershell
# From repository root
.\scripts\run-complete-system-test.ps1
```

This will:
- ✅ Validate prerequisites
- ✅ Start Docker environment
- ✅ Run health checks
- ✅ Execute unit tests
- ✅ Run API tests (Newman/Postman)
- ✅ Validate data flow
- ✅ Test performance
- ✅ Evaluate architecture
- ✅ Generate comprehensive report

**Expected Duration**: 4-6 hours  
**Report Location**: `test-reports/system-test-report-[timestamp].txt`

### Option 2: Quick Health Check Only

```powershell
# Fast sanity check (< 5 minutes)
.\scripts\tests\quick-test.ps1
```

### Option 3: Specific Test Categories

```powershell
# Health checks only
.\scripts\run-complete-system-test.ps1 -TestCategories "Health"

# API tests only
.\scripts\run-complete-system-test.ps1 -TestCategories "API"

# Multiple categories
.\scripts\run-complete-system-test.ps1 -TestCategories "Health,API,Performance"
```

---

## 📋 Manual Testing Workflow

### Step 1: Start Environment (5 min)

```powershell
# Start testnet stack
docker-compose -f docker-compose-testnet.yml up -d

# Wait for services to initialize
Start-Sleep -Seconds 90

# Check status
docker-compose -f docker-compose-testnet.yml ps
```

### Step 2: Health Checks (5 min)

```powershell
# Quick health check
.\scripts\tests\quick-test.ps1

# Or manual checks
curl http://localhost:8083/actuator/health  # MACD Trader
curl http://localhost:8086/actuator/health  # Data Collection
curl http://localhost:8087/actuator/health  # Data Storage
curl http://localhost:9091/-/healthy        # Prometheus
curl http://localhost:3001/api/health       # Grafana
```

### Step 3: Run Tests (Varies)

```powershell
# Unit tests (60 min)
mvn clean test -T 1C

# API tests (45 min)
.\scripts\run-comprehensive-tests.ps1

# Or individual Postman collections
newman run postman/Binance-AI-Traders-Comprehensive-Test-Collection.json `
  -e postman/Binance-AI-Traders-Testnet-Environment.json `
  --reporters cli,html `
  --reporter-html-export test-reports/comprehensive.html
```

### Step 4: Validate Data Flow (15 min)

```powershell
# Kafka topics
docker exec kafka-testnet kafka-topics.sh --bootstrap-server localhost:9092 --list

# PostgreSQL data
docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet `
  -c "SELECT COUNT(*) as klines FROM klines; SELECT COUNT(*) as orders FROM orders;"

# Elasticsearch
curl http://localhost:9202/_cat/indices?v
```

### Step 5: Check Monitoring (10 min)

```powershell
# Open all monitoring dashboards
.\scripts\monitoring\open-monitoring.ps1

# Or manually
Start-Process "http://localhost:3001"  # Grafana
Start-Process "http://localhost:9091"  # Prometheus
```

---

## 📊 Expected Results

### ✅ Success Indicators

1. **All services healthy** (status: UP)
2. **Docker containers running** (no restart loops)
3. **Prometheus targets UP** (all services scraped)
4. **Grafana dashboards showing data** (not "No data")
5. **PostgreSQL tables populated** (klines > 0)
6. **Unit tests passing** (> 70% coverage)
7. **API tests passing** (> 90% pass rate)
8. **Response times acceptable** (< 5s for health checks)

### ⚠️ Known Issues

Based on memory system (`binance-ai-traders/memory/findings/`):

| ID | Issue | Impact | Status |
|----|-------|--------|--------|
| MEM-001 | Data Collection - WebSocket missing | 🔴 Critical | Open |
| MEM-006 | MACD - Signal generation incomplete | 🔴 Critical | Open |
| MEM-008 | Grid Trader - Duplicate code | 🟡 Medium | Open |
| MEM-005 | Telegram Bot - Dependencies missing | 🟡 Medium | Open |
| MEM-004 | Testnet Integration Gaps | 🔴 Critical | Open |

**These issues are expected and documented.**

---

## 🔍 Troubleshooting

### Problem: Services Not Starting

```powershell
# Check Docker status
docker ps -a

# Check logs
docker-compose -f docker-compose-testnet.yml logs [service-name]

# Restart specific service
docker-compose -f docker-compose-testnet.yml restart [service-name]

# Full restart
docker-compose -f docker-compose-testnet.yml down
docker-compose -f docker-compose-testnet.yml up -d
```

### Problem: Tests Failing

```powershell
# Check service health first
.\scripts\tests\quick-test.ps1

# Verify ports are open
Test-NetConnection -ComputerName localhost -Port 8083
Test-NetConnection -ComputerName localhost -Port 9091

# Check for port conflicts
netstat -ano | findstr "8083"
```

### Problem: Newman Not Found

```powershell
# Install Newman globally
npm install -g newman newman-reporter-html

# Verify installation
newman --version
```

### Problem: Grafana Shows "No Data"

```powershell
# Check Prometheus targets
curl http://localhost:9091/api/v1/targets | ConvertFrom-Json

# Verify metrics endpoint
curl http://localhost:8083/actuator/prometheus

# Check Grafana datasources
curl -u admin:testnet_admin http://localhost:3001/api/datasources
```

---

## 📁 Test Artifacts

### Generated Files

After running tests, you'll find:

```
test-reports/
├── system-test-report-[timestamp].txt      # Main report
├── summary-[timestamp].json                # JSON summary
├── comprehensive-[timestamp].html          # Postman comprehensive tests
├── monitoring-[timestamp].html             # Postman monitoring tests
├── pg-kafka-[timestamp].html              # Postman PG/Kafka tests
├── maven-test-output-[timestamp].txt       # Maven test logs
├── comprehensive-output-[timestamp].txt    # Newman output
├── monitoring-output-[timestamp].txt       # Newman output
└── pg-kafka-output-[timestamp].txt        # Newman output
```

### Review Priority

1. **system-test-report-[timestamp].txt** - Overall summary
2. **summary-[timestamp].json** - Machine-readable results
3. **HTML reports** - Interactive test results
4. **Output logs** - Detailed execution traces

---

## 📈 Test Report Interpretation

### Green Status (✅ PASS)
- **Success Rate**: 100%
- **Critical Issues**: 0
- **Action**: Proceed to deployment

### Yellow Status (⚠️ PARTIAL)
- **Success Rate**: 70-99%
- **Critical Issues**: 0-2
- **Action**: Review failures, fix if possible, document known issues

### Red Status (❌ FAIL)
- **Success Rate**: < 70%
- **Critical Issues**: 3+
- **Action**: Do not deploy, investigate and fix critical issues

---

## 🎯 Testing Checklist

Use the printable checklist for manual testing:

**Document**: `binance-ai-traders/SYSTEM_TEST_CHECKLIST.md`

Includes:
- [ ] Pre-test preparation
- [ ] Step-by-step test execution
- [ ] Architecture scorecard
- [ ] Issue tracking template
- [ ] Sign-off section

---

## 📚 Full Documentation

### Comprehensive Plan
**Location**: `binance-ai-traders/COMPREHENSIVE_SYSTEM_TESTING_AND_ARCHITECTURE_EVALUATION_PLAN.md`

Includes:
- Complete testing scope
- Architecture evaluation criteria
- Detailed test categories
- Validation checklists
- Issue classification
- Success metrics

### Related Documentation
- **Architecture Guide**: `binance-ai-traders/AGENTS.md`
- **API Endpoints**: `binance-ai-traders/API_ENDPOINTS.md`
- **Memory System**: `binance-ai-traders/memory/memory-index.md`
- **Scripts Index**: `scripts/INDEX.md`
- **Postman Tests**: `postman/README.md`
- **Infrastructure**: `binance-ai-traders/infrastructure/quick-reference.md`

---

## 🚀 Next Steps After Testing

### If Tests Pass (✅)

1. Review test report and archive
2. Update memory system if needed
3. Document any new findings
4. Proceed to next milestone (M1 → M2)
5. Plan production deployment

### If Tests Fail (❌)

1. Review failure details in report
2. Classify issues by severity (P0-P3)
3. Create issue entries in memory system
4. Prioritize fixes based on criticality
5. Re-run tests after fixes

### Continuous Testing

```powershell
# Schedule periodic tests (example: every 6 hours)
while ($true) {
    .\scripts\run-complete-system-test.ps1 -TestCategories "Health,API" -SkipBuild
    Start-Sleep -Seconds 21600  # 6 hours
}
```

---

## 🆘 Getting Help

### Issue Reports

Use the template in the comprehensive plan:

```markdown
## Issue Report
**Issue ID**: [AUTO-INCREMENT]
**Severity**: [P0/P1/P2/P3]
**Category**: [Service/Infrastructure/Integration]
**Discovery Date**: [YYYY-MM-DD HH:MM]
...
```

### Documentation

- **Testing Plan**: See full plan for detailed guidance
- **Memory System**: Check existing MEM entries for known issues
- **Architecture Guide**: Review AGENTS.md for system understanding

### Support Channels

1. Review memory system findings
2. Check existing documentation
3. Search test reports for similar issues
4. Consult architecture guide

---

## ⏱️ Time Estimates

| Test Category | Duration | Frequency |
|---------------|----------|-----------|
| Quick Health Check | 5 min | Before each code change |
| Health + API | 30 min | Daily |
| Full Unit Tests | 60 min | Before commits |
| Complete Suite | 4-6 hours | Weekly / Before deployment |
| Continuous Monitoring | Ongoing | Production |

---

## 🎓 Best Practices

1. **Always start with health checks** - Verify basic functionality first
2. **Run from repository root** - All scripts expect this location
3. **Archive test reports** - Keep history for comparison
4. **Document new issues** - Update memory system
5. **Automate where possible** - Use provided scripts
6. **Review logs on failure** - Detailed logs are your friend
7. **Test after changes** - Validate before committing
8. **Monitor resources** - Ensure adequate CPU, memory, disk

---

## 📞 Quick Commands Reference

```powershell
# Full automated test
.\scripts\run-complete-system-test.ps1

# Quick health check
.\scripts\tests\quick-test.ps1

# Start environment
docker-compose -f docker-compose-testnet.yml up -d

# Stop environment
docker-compose -f docker-compose-testnet.yml down

# View logs
docker-compose -f docker-compose-testnet.yml logs -f [service]

# Restart service
docker-compose -f docker-compose-testnet.yml restart [service]

# Check status
docker-compose -f docker-compose-testnet.yml ps

# Run unit tests
mvn clean test -T 1C

# Run API tests
.\scripts\run-comprehensive-tests.ps1

# Open monitoring
.\scripts\monitoring\open-monitoring.ps1

# Check metrics
.\scripts\metrics\verify-metrics-simple.ps1
```

---

**Version**: 1.0  
**Created**: 2025-10-18  
**Last Updated**: 2025-10-18  
**Related**: COMPREHENSIVE_SYSTEM_TESTING_AND_ARCHITECTURE_EVALUATION_PLAN.md

