# YAML File Consolidation Summary

## Files Removed (Redundant/Duplicate)

### Docker Compose Files
- `docker-compose-health-metrics.yml` - Identical to docker-compose-health-exporter.yml
- `docker-compose-health-exporter.yml` - Already included in main testnet compose file

### Monitoring Files
- `monitoring/docker-compose.grafana-simple.yml` - Redundant with testnet version
- `monitoring/prometheus-testnet.yml` - Duplicate of monitoring/prometheus/testnet-prometheus.yml
- `monitoring/prometheus/testnet-prometheus.yml` - Consolidated into main prometheus.yml
- `monitoring/grafana/datasources/prometheus-testnet.yml` - Duplicate of prometheus.yml
- `monitoring/grafana/datasources/prometheus-config.yml` - Misplaced Prometheus config (not Grafana datasource)

### Backup Files
- `monitoring/grafana/provisioning/dashboards-backup-20251008-182323/testnet-dashboards.yml`
- `monitoring/grafana/dashboards-backup-20251008-175555/testnet-dashboards.yml`

## Files Consolidated

### Prometheus Configuration
- **Before**: Separate `monitoring/prometheus.yml` and `monitoring/prometheus/testnet-prometheus.yml`
- **After**: Single `monitoring/prometheus.yml` with both mainnet and testnet targets
- **Benefits**: 
  - Single source of truth for Prometheus configuration
  - Environment labels for better metric organization
  - Reduced maintenance overhead

### Grafana Datasources
- **Before**: Separate `prometheus.yml` and `prometheus-testnet.yml` datasource configs
- **After**: Single `monitoring/grafana/datasources/prometheus.yml` with both mainnet and testnet datasources
- **Benefits**:
  - Unified datasource management
  - Easy switching between environments
  - Consistent configuration

## Updated References

### Docker Compose Files
- `docker-compose-testnet.yml` - Updated to use consolidated Prometheus config
- `monitoring/docker-compose.grafana-testnet.yml` - Updated to use consolidated Prometheus config

### Configuration Files
- All Prometheus volume mounts now point to `./monitoring/prometheus.yml`
- All Grafana datasource mounts now point to `./monitoring/grafana/datasources/prometheus.yml`

## Benefits Achieved

1. **Reduced File Count**: Removed 8 redundant/duplicate YAML files
2. **Simplified Maintenance**: Single configuration files for Prometheus and Grafana datasources
3. **Better Organization**: Clear separation between mainnet and testnet configurations
4. **Consistent Naming**: Standardized file references across all compose files
5. **Reduced Confusion**: Eliminated duplicate files that could cause configuration conflicts

## Files Preserved

- `docker-compose.yml` - Main production compose file
- `docker-compose-testnet.yml` - Testnet environment compose file
- `docker-compose.test.yml` - Testing environment compose file
- `docker-compose.override.yml` - Build optimization overrides
- `docker-compose-elasticsearch-cluster.yml` - Production Elasticsearch cluster
- `docker-compose-kafka-kraft.yml` - Kafka KRaft mode configuration
- All application-specific YAML files (application.yml, application-testnet.yml, etc.)

## Verification

All modified files have been checked for:
- YAML syntax validity
- Proper indentation
- Correct file references
- No linting errors

The consolidation maintains all existing functionality while significantly reducing file redundancy and improving maintainability.
