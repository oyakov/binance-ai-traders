# Historical Data Repository

## Overview

This directory contains historical candlestick (kline) data from Binance for backtesting trading strategies. The data is organized by trading pair, interval, and time range to enable comprehensive strategy research and validation.

## Repository Structure

```
datasets/
├── BTCUSDT/
│   ├── 5m/
│   │   ├── 7d-latest.json       # Last 7 days of 5-minute data
│   │   ├── 30d-latest.json      # Last 30 days of 5-minute data
│   │   ├── 90d-latest.json      # Last 90 days of 5-minute data
│   │   └── 180d-latest.json     # Last 180 days of 5-minute data
│   ├── 15m/                     # 15-minute intervals
│   ├── 1h/                      # 1-hour intervals
│   ├── 4h/                      # 4-hour intervals
│   └── 1d/                      # 1-day intervals
├── ETHUSDT/                     # Ethereum (same structure)
├── BNBUSDT/                     # Binance Coin (same structure)
├── ADAUSDT/                     # Cardano (same structure)
├── SOLUSDT/                     # Solana (same structure)
└── metadata/
    └── collection-history.json  # Collection timestamps and metadata
```

## Coverage Matrix

| Symbol   | Intervals          | Time Ranges         | Total Files |
|----------|-------------------|---------------------|-------------|
| BTCUSDT  | 5m, 15m, 1h, 4h, 1d | 7d, 30d, 90d, 180d  | 20          |
| ETHUSDT  | 5m, 15m, 1h, 4h, 1d | 7d, 30d, 90d, 180d  | 20          |
| BNBUSDT  | 5m, 15m, 1h, 4h, 1d | 7d, 30d, 90d, 180d  | 20          |
| ADAUSDT  | 5m, 15m, 1h, 4h, 1d | 7d, 30d, 90d, 180d  | 20          |
| SOLUSDT  | 5m, 15m, 1h, 4h, 1d | 7d, 30d, 90d, 180d  | 20          |
| **Total**|                   |                     | **100**     |

## Data Format

Each dataset file follows the `BacktestDataset` JSON schema:

```json
{
  "name": "BTCUSDT-1h-30d-2025-01-18",
  "symbol": "BTCUSDT",
  "interval": "1h",
  "collectedAt": "2025-01-18T10:30:00Z",
  "klines": [
    {
      "symbol": "BTCUSDT",
      "interval": "1h",
      "openTime": 1705582800000,
      "closeTime": 1705586399999,
      "open": "43250.50",
      "high": "43350.75",
      "low": "43200.00",
      "close": "43300.25",
      "volume": "1234.56",
      "quoteAssetVolume": "53456789.12",
      "numberOfTrades": 5678,
      "takerBuyBaseAssetVolume": "678.90",
      "takerBuyQuoteAssetVolume": "29345678.90"
    }
    // ... more klines
  ]
}
```

## Collection Management

### Automated Collection

Use the provided PowerShell script to collect or update datasets:

```powershell
# Collect all datasets (100 total)
.\scripts\collect-backtest-datasets.ps1

# Collect specific symbol
.\scripts\collect-backtest-datasets.ps1 -Symbol BTCUSDT

# Collect specific interval
.\scripts\collect-backtest-datasets.ps1 -Interval 1h

# Collect specific time range
.\scripts\collect-backtest-datasets.ps1 -TimeRange 30d

# Dry run (preview without collecting)
.\scripts\collect-backtest-datasets.ps1 -DryRun
```

### Manual Collection

You can also use the existing Java data fetcher:

```java
BinanceHistoricalDataFetcher fetcher = new BinanceHistoricalDataFetcher();
BacktestDataset dataset = fetcher.fetchHistoricalData(
    "BTCUSDT",
    "1h",
    startTime,
    endTime,
    "BTCUSDT-1h-30d"
);
```

### Validation

Validate dataset integrity:

```powershell
# Validate all datasets
.\scripts\validate-datasets.ps1

# Validate specific dataset
.\scripts\validate-datasets.ps1 -DatasetPath datasets/BTCUSDT/1h/30d-latest.json

# Check for gaps in data
.\scripts\validate-datasets.ps1 -CheckGaps
```

## Dataset Naming Convention

Format: `{timeRange}-latest.json`

- `timeRange`: `7d`, `30d`, `90d`, `180d`
- `latest`: Indicates this is the most recent collection for this time range

Examples:
- `7d-latest.json` - Last 7 days of data
- `30d-latest.json` - Last 30 days of data
- `90d-latest.json` - Last 90 days of data
- `180d-latest.json` - Last 180 days of data

## Data Versioning

Datasets are versioned through the `collectedAt` timestamp in the JSON file. The collection history is tracked in `metadata/collection-history.json`:

```json
{
  "datasets": [
    {
      "path": "BTCUSDT/1h/30d-latest.json",
      "collectedAt": "2025-01-18T10:30:00Z",
      "klineCount": 720,
      "startTime": 1702814400000,
      "endTime": 1705406399999,
      "fileSize": 425600,
      "md5": "a1b2c3d4e5f6..."
    }
    // ... more entries
  ],
  "lastUpdate": "2025-01-18T10:30:00Z",
  "totalDatasets": 100,
  "totalSize": 42560000
}
```

## Usage in Backtesting

### Load Single Dataset

```java
Path datasetPath = Paths.get("datasets/BTCUSDT/1h/30d-latest.json");
ObjectMapper mapper = new ObjectMapper();
BacktestDataset dataset = mapper.readValue(datasetPath.toFile(), BacktestDataset.class);

BacktestResult result = backtestEngine.run(dataset);
```

### Load Multiple Datasets

```java
MultiDatasetBacktestRunner runner = new MultiDatasetBacktestRunner();
List<BacktestResult> results = runner.runOnAllDatasets("datasets/");
```

### Load by Pattern

```java
// Load all BTCUSDT 1h datasets
List<BacktestDataset> datasets = DatasetLoader.loadByPattern(
    "datasets/BTCUSDT/1h/*.json"
);

// Load all 30-day datasets across symbols
List<BacktestDataset> datasets = DatasetLoader.loadByPattern(
    "datasets/*/1h/30d-latest.json"
);
```

## Data Quality

### Validation Checks

Each dataset undergoes validation:

1. **Completeness**: No missing klines in time sequence
2. **Consistency**: All klines have valid OHLCV data
3. **Integrity**: No duplicate timestamps
4. **Freshness**: Collection date within expected range
5. **Size**: File size matches expected kline count

### Gap Detection

The validation script checks for gaps in kline sequences:

```powershell
.\scripts\validate-datasets.ps1 -CheckGaps -DetailedReport
```

Gaps are reported with:
- Missing timestamp range
- Gap duration
- Impact on backtesting (e.g., "20 klines missing over 20 hours")

## Maintenance

### Weekly Collection Schedule

Recommended schedule for keeping datasets current:

```bash
# Cron job (Linux) - Every Sunday at 2 AM
0 2 * * 0 /path/to/collect-backtest-datasets.ps1

# Task Scheduler (Windows) - Every Sunday at 2 AM
# Run: PowerShell.exe -File "C:\path\to\collect-backtest-datasets.ps1"
```

### Cleanup Old Versions

Datasets are updated in-place (overwrite), so cleanup is typically not needed. However, if you want to archive old versions:

```powershell
# Archive datasets older than 30 days
.\scripts\archive-old-datasets.ps1 -DaysOld 30 -ArchiveDir datasets/archive/
```

## Storage Requirements

### Estimated Sizes

| Time Range | Interval | Approx Size | Klines  |
|------------|----------|-------------|---------|
| 7d         | 5m       | ~100 KB     | ~2,000  |
| 30d        | 5m       | ~420 KB     | ~8,640  |
| 90d        | 5m       | ~1.2 MB     | ~25,920 |
| 180d       | 5m       | ~2.5 MB     | ~51,840 |
| 7d         | 1h       | ~10 KB      | ~170    |
| 30d        | 1h       | ~40 KB      | ~720    |
| 90d        | 1h       | ~110 KB     | ~2,160  |
| 180d       | 1h       | ~220 KB     | ~4,320  |

### Total Repository Size

- **5 symbols × 20 files each** = 100 datasets
- **Estimated total**: ~150 MB (uncompressed)
- **With compression**: ~50 MB

## Best Practices

### 1. Regular Updates
- Update datasets weekly to include latest market data
- Focus on 7d and 30d datasets for frequent updates
- Update 90d and 180d datasets monthly

### 2. Version Control
- **DO NOT** commit dataset JSON files to git (too large)
- **DO** commit collection scripts and configuration
- **DO** document collection timestamps in metadata

### 3. Backup Strategy
- Keep backups of datasets in separate location
- Archive historical versions for reproducibility
- Document backup schedule in team wiki

### 4. Testing Workflow
- Use 7d datasets for quick iteration during development
- Use 30d datasets for comprehensive testing
- Use 90d/180d datasets for final validation before production

### 5. Data Integrity
- Run validation after every collection
- Check for anomalies (e.g., extreme price spikes)
- Cross-reference with Binance data explorer

## Troubleshooting

### Issue: Collection Script Fails

```powershell
# Check Binance API connectivity
curl https://api.binance.com/api/v3/ping

# Check testnet connectivity
curl https://testnet.binance.vision/api/v3/ping

# Run with verbose logging
.\scripts\collect-backtest-datasets.ps1 -Verbose
```

### Issue: Dataset Validation Errors

```powershell
# Get detailed validation report
.\scripts\validate-datasets.ps1 -Detailed

# Fix specific dataset by re-collecting
.\scripts\collect-backtest-datasets.ps1 -Symbol BTCUSDT -Interval 1h -TimeRange 30d -Force
```

### Issue: Missing Klines

If validation detects gaps:
1. Check if Binance had downtime during that period
2. Re-collect the affected dataset
3. If gap persists, it's likely a Binance data gap (document it)

### Issue: Disk Space

```powershell
# Check repository size
.\scripts\check-datasets-size.ps1

# Remove old archived datasets
Remove-Item datasets/archive/* -Force -Recurse
```

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Update Datasets
on:
  schedule:
    - cron: '0 2 * * 0'  # Every Sunday at 2 AM
  workflow_dispatch:

jobs:
  update-datasets:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Collect Datasets
        run: ./scripts/collect-backtest-datasets.ps1
      - name: Validate Datasets
        run: ./scripts/validate-datasets.ps1
      - name: Upload Artifacts
        uses: actions/upload-artifact@v2
        with:
          name: datasets
          path: datasets/
```

## Future Enhancements

- [ ] Add more trading pairs (DOTUSDT, LINKUSDT, etc.)
- [ ] Support for 1-minute and 3-minute intervals
- [ ] Automated anomaly detection (flash crashes, data gaps)
- [ ] Compression for long-term storage
- [ ] Cloud storage integration (S3, Azure Blob)
- [ ] Real-time dataset streaming for live backtesting

## Support

For issues or questions:
1. Check this README for common solutions
2. Review `binance-ai-traders/TESTABILITY_OBSERVABILITY_DESIGN.md`
3. Run validation scripts with `-Verbose` flag
4. Check collection logs in `logs/dataset-collection.log`

---

**Last Updated**: 2025-01-18  
**Maintainer**: Trading System Development Team  
**Version**: 1.0

