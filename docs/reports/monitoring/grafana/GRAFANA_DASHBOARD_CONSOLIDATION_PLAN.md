# Grafana Dashboard Consolidation Plan
**Date**: October 12, 2025  
**Total Dashboards**: 13 (1 broken)

---

## Current Dashboard Inventory

| # | Dashboard Name | Panels | Purpose | Status |
|---|----------------|--------|---------|--------|
| 1 | System Health Overview | 5 | Infrastructure monitoring | ✅ Keep |
| 2 | Trading Operations Overview | 2 | Basic trading ops | ⚠️ Consolidate |
| 3 | MACD Trading Strategies | 2 | MACD strategy view | ⚠️ Consolidate |
| 4 | Live Kline Data Monitoring | 9 | Price/volume charts | ✅ Keep |
| 5 | Trading Analytics & Insights | 1 | Analytics view | ❌ Remove |
| 6 | MACD Indicators Dashboard | 9 | Technical MACD analysis | ⚠️ Consolidate |
| 7 | Executive Overview | 1 | High-level KPIs | ❌ Remove |
| 8 | Order & Profitability Monitoring | 15 | Order tracking & P&L | ✅ Keep |
| 9 | **Trading Strategy Observability** | 6 | **MACD + Events + Portfolio** | ✅ **KEEP** |
| 10 | **Risk & Portfolio Monitoring** | 7 | **Risk metrics + Portfolio** | ✅ **KEEP** |
| 11 | **Strategy Comparison** | 5 | **Strategy analysis** | ✅ **KEEP** |
| 12 | Comprehensive Metrics | 8 | General metrics | ⚠️ Consolidate |
| 13 | Simple Dashboard | 0 | **BROKEN** | ❌ **DELETE** |

---

## Issues Identified

### Critical Issues
1. **`simple-dashboard.json` is broken** ❌
   - No title, no UID, no panels
   - Causing Grafana errors every 10 seconds
   - **Action**: DELETE immediately

### Overlap/Duplication Issues
2. **Triple MACD Coverage** 🔄
   - Dashboard #3: MACD Trading Strategies (2 panels)
   - Dashboard #6: MACD Indicators Dashboard (9 panels)
   - Dashboard #9: Trading Strategy Observability (6 panels, **NEW**)
   - **Issue**: 3 dashboards showing similar MACD data
   - **Action**: Consolidate into #9 (most comprehensive)

3. **Minimal Panel Dashboards** 📊
   - Dashboard #2: Trading Operations (2 panels only)
   - Dashboard #5: Trading Analytics (1 panel only)
   - Dashboard #7: Executive Overview (1 panel only)
   - **Issue**: Too few panels to justify separate dashboards
   - **Action**: Merge panels into other dashboards or remove

4. **General Metrics Overlap** 📈
   - Dashboard #12: Comprehensive Metrics (8 panels)
   - Overlaps with multiple other dashboards
   - **Action**: Redistribute panels to specific dashboards

---

## Consolidation Plan

### Phase 1: Immediate Deletions (Critical)

#### 1.1 Delete Broken Dashboard ❌
**File**: `binance-trading/simple-dashboard.json`
- **Reason**: Broken, causing errors
- **Impact**: None (not usable)
- **Action**: Delete immediately

```powershell
Remove-Item "monitoring/grafana/provisioning/dashboards/binance-trading/simple-dashboard.json"
```

---

### Phase 2: Remove Low-Value Dashboards

#### 2.1 Remove "Trading Analytics & Insights" ❌
**File**: `05-analytics/trading-analytics-insights.json`
- **Panels**: 1 panel only
- **Reason**: Too minimal, data likely available elsewhere
- **Migration**: Check if panel is needed, move to relevant dashboard if yes
- **Impact**: Minimal

#### 2.2 Remove "Executive Overview" ❌
**File**: `06-executive/executive-overview.json`
- **Panels**: 1 panel only
- **Reason**: Too minimal for separate dashboard
- **Migration**: Create "Executive" folder in Grafana UI and star important dashboards instead
- **Impact**: Minimal (create bookmark collection instead)

---

### Phase 3: Consolidate MACD Dashboards

#### 3.1 Keep as Primary: "Trading Strategy Observability" ✅
**File**: `08-observability/strategy-observability-dashboard.json`
- **Why Keep**: Most comprehensive, newest, includes:
  - MACD calculations
  - Signal detection
  - Portfolio tracking
  - Event history
- **Action**: Enhance with best panels from others

#### 3.2 Deprecate: "MACD Trading Strategies" ⚠️
**File**: `03-macd-strategies/macd-trading-strategies.json`
- **Panels**: 2 panels only
- **Reason**: Superseded by Trading Strategy Observability
- **Migration**: Verify panels aren't unique, then delete
- **Impact**: Low (data available in #9)

#### 3.3 Deprecate: "MACD Indicators Dashboard" ⚠️
**File**: `05-macd-indicators/macd-indicators-dashboard.json`
- **Panels**: 9 panels
- **Reason**: Overlaps with Trading Strategy Observability
- **Migration**: Extract unique panels, add to Observability dashboard
- **Impact**: Medium (check for unique visualizations first)

---

### Phase 4: Consolidate General Dashboards

#### 4.1 Evaluate "Comprehensive Metrics Dashboard" ⚠️
**File**: `binance-trading/comprehensive-metrics-dashboard.json`
- **Panels**: 8 panels
- **Decision**: Check if panels duplicate existing dashboards
- **Actions**:
  - If unique: Keep as "General Metrics"
  - If duplicate: Distribute panels to specific dashboards
  - Rename folder from "binance-trading" to numbered folder

#### 4.2 Merge "Trading Operations Overview" ⚠️
**File**: `02-trading-overview/trading-operations-overview.json`
- **Panels**: 2 panels only
- **Reason**: Too minimal
- **Migration**: Move panels to "Order & Profitability Monitoring"
- **Impact**: Low

---

## Recommended Final Dashboard Structure

### Tier 1: Core Dashboards (Keep As-Is) ✅
1. **Trading Strategy Observability** (6 panels)
   - Primary MACD & signal monitoring
   - Portfolio tracking
   - Event history

2. **Risk & Portfolio Monitoring** (7 panels)
   - Risk metrics
   - Portfolio health
   - Exposure tracking

3. **Strategy Comparison** (5 panels)
   - Performance comparison
   - Signal distribution
   - Portfolio trends

4. **Order & Profitability Monitoring** (15 panels)
   - Order tracking
   - P&L analysis
   - Trade history

### Tier 2: Supporting Dashboards (Keep) ✅
5. **System Health Overview** (5 panels)
   - Infrastructure monitoring
   - Service health
   - Database status

6. **Live Kline Data Monitoring** (9 panels)
   - Real-time price charts
   - Volume analysis
   - Market data

### Tier 3: Optional (Evaluate) ⚠️
7. **Comprehensive Metrics** (8 panels)
   - General system metrics
   - Cross-service monitoring
   - *Decision: Review panels, keep if unique*

---

## Dashboard Count Summary

### Current State
- Total: 13 dashboards
- Broken: 1
- Usable: 12
- With <3 panels: 3 (weak dashboards)

### After Phase 1 (Critical)
- Total: 12 dashboards (-1 broken)
- Reduction: 8%

### After Phase 2 (Low-Value)
- Total: 10 dashboards (-2 minimal)
- Reduction: 23%

### After Phase 3 (MACD Consolidation)
- Total: 8 dashboards (-2 MACD duplicates)
- Reduction: 38%

### After Phase 4 (Full Consolidation)
- Total: 6-7 dashboards (depends on Comprehensive Metrics decision)
- Reduction: 46-54%

---

## Recommended Action Sequence

### Immediate (Do Now) 🔥
```powershell
# 1. Delete broken dashboard
Remove-Item "monitoring/grafana/provisioning/dashboards/binance-trading/simple-dashboard.json"

# 2. Restart Grafana to stop error spam
docker-compose -f docker-compose-testnet.yml restart grafana-testnet
```

### Short-Term (This Week) 📅
1. **Review MACD dashboards**
   - Compare #3, #6, #9 side-by-side
   - Identify unique panels in #6
   - Migrate unique panels to #9
   - Delete #3 and #6

2. **Remove minimal dashboards**
   - Delete #5 (Trading Analytics - 1 panel)
   - Delete #7 (Executive Overview - 1 panel)

3. **Consolidate Trading Operations**
   - Merge #2 panels into #8 (Order & Profitability)
   - Delete #2

### Medium-Term (Next 2 Weeks) 📅
4. **Evaluate Comprehensive Metrics**
   - Review each of 8 panels
   - Decide: keep, move, or delete each panel
   - Rename folder if keeping

5. **Documentation Update**
   - Update all docs with new dashboard structure
   - Create dashboard quick reference guide
   - Update URLs in documentation

---

## Detailed Comparison: MACD Dashboards

### Dashboard #3: MACD Trading Strategies
- **Panels**: 2
- **Focus**: Basic MACD view
- **Unique**: None identified
- **Verdict**: ❌ DELETE (superseded by #9)

### Dashboard #6: MACD Indicators Dashboard
- **Panels**: 9
- **Focus**: Technical MACD analysis
- **Potential Unique Panels**:
  - EMA crossover visualizations?
  - Multiple timeframe MACD?
  - Advanced technical indicators?
- **Verdict**: ⚠️ REVIEW FIRST (may have unique panels)

### Dashboard #9: Trading Strategy Observability (NEW)
- **Panels**: 6
- **Focus**: Complete strategy observability
- **Includes**:
  - MACD line, signal, histogram
  - Signal strength & detection
  - Portfolio value tracking
  - Recent events table
- **Verdict**: ✅ KEEP AS PRIMARY

---

## Migration Checklist

### Before Deleting Any Dashboard:
- [ ] Open dashboard in Grafana
- [ ] Screenshot all panels
- [ ] Check if panels are unique
- [ ] Verify data is available elsewhere
- [ ] Document any custom queries
- [ ] Export dashboard JSON (backup)

### After Deleting Dashboard:
- [ ] Restart Grafana
- [ ] Verify no broken links
- [ ] Check Grafana logs for errors
- [ ] Update documentation
- [ ] Test remaining dashboards

---

## Risk Assessment

### Low Risk Deletions ✅
- Simple Dashboard (broken)
- Trading Analytics (1 panel)
- Executive Overview (1 panel)
- MACD Trading Strategies (2 panels, duplicate)

### Medium Risk Deletions ⚠️
- MACD Indicators Dashboard (9 panels - review first)
- Trading Operations Overview (2 panels - merge first)
- Comprehensive Metrics (8 panels - evaluate first)

### High Risk (Don't Delete) ❌
- Trading Strategy Observability (NEW, core)
- Risk & Portfolio Monitoring (NEW, core)
- Strategy Comparison (NEW, core)
- Order & Profitability (15 panels, detailed)
- System Health Overview (infrastructure)
- Live Kline Data Monitoring (market data)

---

## Expected Benefits

### Performance
- Faster Grafana load time
- Less dashboard provisioning overhead
- Reduced error spam in logs

### User Experience
- Clearer dashboard purpose
- Less confusion about which dashboard to use
- Easier navigation

### Maintenance
- Fewer dashboards to maintain
- Less documentation to update
- Clearer ownership

---

## Rollback Plan

If consolidation causes issues:

1. **Restore from backup**:
   ```powershell
   # Dashboards are in git, simply restore
   git checkout monitoring/grafana/provisioning/dashboards/
   docker-compose -f docker-compose-testnet.yml restart grafana-testnet
   ```

2. **Selective restore**:
   - Keep deletion of broken dashboard
   - Restore specific dashboards if needed
   - Re-evaluate consolidation approach

---

## Implementation Script

Create this script as `scripts/consolidate-dashboards.ps1`:

```powershell
# Phase 1: Delete broken dashboard
Write-Host "Phase 1: Removing broken dashboard..." -ForegroundColor Yellow
Remove-Item "monitoring/grafana/provisioning/dashboards/binance-trading/simple-dashboard.json" -Force
Write-Host "  ✓ Deleted simple-dashboard.json" -ForegroundColor Green

# Phase 2: Remove minimal dashboards  
Write-Host "`nPhase 2: Removing minimal dashboards..." -ForegroundColor Yellow
Remove-Item "monitoring/grafana/provisioning/dashboards/05-analytics/trading-analytics-insights.json" -Force
Remove-Item "monitoring/grafana/provisioning/dashboards/06-executive/executive-overview.json" -Force
Write-Host "  ✓ Deleted trading-analytics-insights.json" -ForegroundColor Green
Write-Host "  ✓ Deleted executive-overview.json" -ForegroundColor Green

# Phase 3: Remove duplicate MACD dashboards
Write-Host "`nPhase 3: Removing duplicate MACD dashboards..." -ForegroundColor Yellow
Remove-Item "monitoring/grafana/provisioning/dashboards/03-macd-strategies/macd-trading-strategies.json" -Force
Write-Host "  ✓ Deleted macd-trading-strategies.json" -ForegroundColor Green
Write-Host "  ⚠ Review MACD Indicators Dashboard manually before deleting" -ForegroundColor Yellow

# Restart Grafana
Write-Host "`nRestarting Grafana..." -ForegroundColor Yellow
docker-compose -f docker-compose-testnet.yml restart grafana-testnet
Write-Host "  ✓ Grafana restarted" -ForegroundColor Green

Write-Host "`nConsolidation Phase 1-2 Complete!" -ForegroundColor Cyan
Write-Host "Dashboards removed: 4" -ForegroundColor Green
Write-Host "Dashboards remaining: 9" -ForegroundColor Green
```

---

## Final Recommendation

### Execute Immediately ⚡
```powershell
# Delete broken dashboard causing errors
Remove-Item "monitoring/grafana/provisioning/dashboards/binance-trading/simple-dashboard.json"
docker-compose -f docker-compose-testnet.yml restart grafana-testnet
```

### Execute This Week 📅
1. Delete minimal dashboards (#5, #7)
2. Review and consolidate MACD dashboards
3. Merge Trading Operations into Order dashboard

### Target Final State 🎯
**6-7 Core Dashboards**:
1. Trading Strategy Observability ⭐ (Primary MACD & Signals)
2. Risk & Portfolio Monitoring ⭐ (Risk & Health)
3. Strategy Comparison ⭐ (Performance Analysis)
4. Order & Profitability Monitoring (Trading Details)
5. System Health Overview (Infrastructure)
6. Live Kline Data Monitoring (Market Data)
7. [Optional] General Metrics (if unique panels identified)

---

## Questions to Answer Before Proceeding

1. **MACD Indicators Dashboard (9 panels)**:
   - Does it have unique visualizations not in Observability dashboard?
   - Are any panels worth migrating?

2. **Comprehensive Metrics Dashboard (8 panels)**:
   - What specific metrics does it show?
   - Do they overlap with other dashboards?

3. **Trading Operations Overview (2 panels)**:
   - What data do these 2 panels show?
   - Can they be moved to Order & Profitability dashboard?

---

**Ready to proceed with consolidation? Start with deleting the broken dashboard!**

