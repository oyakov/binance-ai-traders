# MEM-C002: Service Dependencies Map

**Type**: Context  
**Status**: Active  
**Created**: 2024-12-25  
**Last Updated**: 2024-12-25  
**Scope**: Global  

## Dependency Graph

```
┌─────────────────────┐
│   Binance API       │
│   (REST/WebSocket)  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Data Collection     │
│ (binance-data-      │
│  collection)        │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│       Kafka         │
│   (Message Queue)   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   Data Storage      │
│ (binance-data-      │
│  storage)           │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   PostgreSQL        │
│   Elasticsearch     │
└─────────────────────┘

┌─────────────────────┐
│   Shared Model      │
│ (binance-shared-    │
│  model)             │
└──────────┬──────────┘
           │
           ├───────────┐
           │           │
           ▼           ▼
┌─────────────────┐ ┌─────────────────┐
│   MACD Trader   │ │   Grid Trader   │
│ (binance-trader-│ │ (binance-trader-│
│  macd)          │ │  grid)          │
└─────────┬───────┘ └─────────┬───────┘
          │                   │
          └─────────┬─────────┘
                    │
                    ▼
          ┌─────────────────┐
          │   Binance API   │
          │   (Orders)      │
          └─────────────────┘

┌─────────────────────┐
│   Telegram Bot      │
│ (telegram-frontend- │
│  python)            │
└──────────┬──────────┘
           │
           ├───────────┐
           │           │
           ▼           ▼
┌─────────────────┐ ┌─────────────────┐
│   Data Storage  │ │   Trading       │
│   (Monitoring)  │ │   Services      │
│                 │ │   (Control)     │
└─────────────────┘ └─────────────────┘
```

## Detailed Dependencies

### Data Collection Service
**Dependencies:**
- Binance API (REST/WebSocket)
- Kafka (for publishing events)
- Shared Model (for data serialization)

**Dependents:**
- Data Storage Service
- Trading Services (indirectly)

### Data Storage Service
**Dependencies:**
- Kafka (for consuming events)
- PostgreSQL (for persistence)
- Elasticsearch (for search/analytics)
- Shared Model (for data deserialization)

**Dependents:**
- Trading Services
- Telegram Bot

### MACD Trader Service
**Dependencies:**
- Kafka (for consuming signals)
- Data Storage (for historical data)
- Binance API (for placing orders)
- Shared Model (for data contracts)

**Dependents:**
- Telegram Bot

### Grid Trader Service
**Dependencies:**
- Kafka (for consuming signals)
- Data Storage (for historical data)
- Binance API (for placing orders)
- Shared Model (for data contracts)

**Dependents:**
- Telegram Bot

### Shared Model
**Dependencies:**
- None (pure data contracts)

**Dependents:**
- All services (for data serialization)

### Telegram Bot
**Dependencies:**
- Data Storage (for monitoring)
- Trading Services (for control)
- PostgreSQL (for bot state)

**Dependents:**
- None (end-user interface)

## Data Flow Dependencies

### Market Data Flow
1. Binance API → Data Collection
2. Data Collection → Kafka
3. Kafka → Data Storage
4. Data Storage → PostgreSQL/Elasticsearch

### Trading Signal Flow
1. Data Storage → Trading Services (via Kafka)
2. Trading Services → Binance API (orders)
3. Trading Services → Telegram Bot (notifications)

### Monitoring Flow
1. All Services → Telegram Bot (status)
2. All Services → Prometheus (metrics)
3. Prometheus → Grafana (dashboards)

## Configuration Dependencies

### Environment Variables
- **BINANCE_API_KEY/SECRET**: Required by data collection and trading services
- **KAFKA_BOOTSTRAP_SERVERS**: Required by all services
- **POSTGRESQL_URL**: Required by data storage and trading services
- **ELASTICSEARCH_URL**: Required by data storage and trading services

### Service Discovery
- All services register with service discovery
- Trading services discover data storage endpoints
- Telegram bot discovers all service endpoints

## Failure Dependencies

### Critical Path
1. **Data Collection** failure → No market data
2. **Kafka** failure → No data flow
3. **Data Storage** failure → No historical data
4. **Shared Model** failure → Serialization errors

### Non-Critical Path
1. **Telegram Bot** failure → No user interface (trading continues)
2. **Individual Trading Service** failure → Other strategies continue

## Deployment Dependencies

### Infrastructure First
1. PostgreSQL
2. Elasticsearch
3. Kafka
4. Shared Model

### Services Second
1. Data Collection
2. Data Storage
3. Trading Services
4. Telegram Bot

### Monitoring Last
1. Prometheus
2. Grafana
3. Alerting
