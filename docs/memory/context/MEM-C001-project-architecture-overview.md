# MEM-C001: Project Architecture Overview

**Type**: Context  
**Status**: Active  
**Created**: 2024-12-25  
**Last Updated**: 2024-12-25  
**Scope**: Global  

## System Architecture

The binance-ai-traders project is a microservices-based trading system with the following components:

### Core Services
1. **Data Collection** (`binance-data-collection`)
   - Collects raw candlestick data from Binance
   - Publishes normalized events to Kafka
   - **Status**: Skeleton implementation

2. **Data Storage** (`binance-data-storage`)
   - Normalizes and persists kline events
   - Dual persistence: PostgreSQL + Elasticsearch
   - **Status**: Substantial implementation

3. **MACD Trader** (`binance-trader-macd`)
   - Implements MACD-based trading strategy
   - Consumes signals and places orders
   - **Status**: Well-structured but incomplete

4. **Grid Trader** (`binance-trader-grid`)
   - Implements grid trading strategy
   - **Status**: Duplicates storage service (needs implementation)

### Supporting Components
1. **Shared Model** (`binance-shared-model`)
   - Avro schemas for cross-service communication
   - **Status**: Basic implementation

2. **Telegram Frontend** (`telegram-frontend-python`)
   - Python-based Telegram bot interface
   - **Status**: Extensive scaffolding, not runnable

### Infrastructure
- **Kafka**: Message streaming and event distribution
- **PostgreSQL**: Relational data storage
- **Elasticsearch**: Search and analytics
- **Docker Compose**: Local development environment

## Data Flow

```
Binance API → Data Collection → Kafka → Data Storage → PostgreSQL/Elasticsearch
                                    ↓
                              MACD Trader → Binance API (Orders)
                                    ↓
                              Telegram Bot (Monitoring)
```

## Technology Stack

### Backend Services
- **Language**: Java 17
- **Framework**: Spring Boot
- **Build**: Maven
- **Persistence**: JPA, Elasticsearch
- **Messaging**: Kafka, Avro

### Frontend
- **Language**: Python 3.11
- **Framework**: FastAPI, aiogram
- **Build**: Poetry
- **Database**: PostgreSQL

### Infrastructure
- **Containerization**: Docker
- **Orchestration**: Docker Compose
- **Monitoring**: Prometheus, Grafana
- **Logging**: Logback, ELK Stack

## Current State Assessment

### Completed Components
- Data storage service with dual persistence
- MACD trader configuration and domain modeling
- Shared model with Avro schemas
- Infrastructure setup with Docker Compose

### Incomplete Components
- Data collection service (missing WebSocket/REST implementation)
- MACD trader strategy logic and Kafka integration
- Grid trader implementation
- Telegram bot (missing dependencies and implementation)

### Missing Components
- Indicator calculator service
- Comprehensive testing
- Production deployment configuration
- Monitoring and alerting setup

## Dependencies

### Service Dependencies
- All services depend on `binance-shared-model`
- Data storage depends on data collection
- Trading services depend on data storage
- Telegram bot depends on all services

### External Dependencies
- Binance API (REST and WebSocket)
- Kafka cluster
- PostgreSQL database
- Elasticsearch cluster

## Development Status

The project is in an uneven state with some services having substantial implementations while others are just scaffolding. The data storage and MACD trader components show the most progress, while the data collection service and Telegram frontend need significant development work.

## Next Steps

1. Complete data collection service implementation
2. Implement MACD trader strategy logic
3. Develop grid trader service
4. Fix Telegram bot dependencies
5. Add comprehensive testing
6. Implement monitoring and alerting
