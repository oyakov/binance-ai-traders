# MEM-C004: Microservices Detailed Analysis

**Type**: Context  
**Status**: Active  
**Created**: 2025-01-08  
**Last Updated**: 2025-01-08  
**Scope**: Services  

## Service-by-Service Analysis

### 1. binance-shared-model

**Purpose**: Shared data contracts and Avro schemas  
**Status**: 🟢 **Complete**  
**Technology**: Java 21, Apache Avro 1.11.4, Lombok  

#### Key Components
- **Avro Schema**: `src/main/avro/kline.avsc` - Kline event schema definition
- **Generated Classes**: Auto-generated Java classes from Avro schemas
- **Dependencies**: Kafka clients, Avro serialization, SLF4J logging

#### Configuration
```xml
<properties>
    <java.version>21</java.version>
    <avro.version>1.11.4</avro.version>
    <kafka.version>3.8.0</kafka.version>
    <confluent.version>7.5.1</confluent.version>
</properties>
```

#### Build Process
- **Avro Maven Plugin**: Generates Java classes from `.avsc` files
- **Build Helper Plugin**: Adds generated sources to classpath
- **Lombok Integration**: Reduces boilerplate code

---

### 2. binance-data-collection

**Purpose**: Real-time Binance WebSocket data collection  
**Status**: 🔴 **Skeleton** - Missing core implementation  
**Technology**: Java 21, Spring Boot 3.3.9, WebSocket, Kafka  

#### Current State
- ✅ **Configuration**: Spring Boot application with proper dependencies
- ✅ **Dependencies**: WebSocket, Kafka, Actuator, Prometheus metrics
- ❌ **WebSocket Client**: Not implemented
- ❌ **Kafka Publisher**: Not implemented
- ❌ **REST Endpoints**: Not implemented

#### Dependencies Analysis
```xml
<!-- Key Dependencies -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-websocket</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.kafka</groupId>
    <artifactId>spring-kafka</artifactId>
</dependency>
<dependency>
    <groupId>io.confluent</groupId>
    <artifactId>kafka-avro-serializer</artifactId>
</dependency>
```

#### Missing Implementation
1. **WebSocket Client**: Connection to Binance WebSocket API
2. **Message Processing**: Parse and normalize kline events
3. **Kafka Publishing**: Send events to Kafka topics
4. **Error Handling**: Connection failures and reconnection logic
5. **Health Monitoring**: Connection status and metrics

#### Required Implementation
```java
// WebSocket Configuration
@Configuration
public class WebSocketConfig {
    // Binance WebSocket client setup
}

// Kafka Publisher
@Service
public class KlineEventPublisher {
    // Publish kline events to Kafka
}

// WebSocket Handler
@Component
public class BinanceWebSocketHandler {
    // Handle incoming WebSocket messages
}
```

---

### 3. binance-data-storage

**Purpose**: Persist and normalize market data  
**Status**: 🟢 **Substantial** - Well-implemented  
**Technology**: Java 21, Spring Boot 3.3.9, JPA, Elasticsearch, PostgreSQL  

#### Architecture
- **Dual Persistence**: PostgreSQL (relational) + Elasticsearch (search/analytics)
- **Kafka Consumer**: Consumes kline events from data-collection service
- **Data Normalization**: Transforms raw kline data into structured format
- **Health Monitoring**: Database connection status and metrics

#### Key Components
```java
// JPA Entities
@Entity
public class KlineEvent {
    // PostgreSQL entity mapping
}

// Elasticsearch Documents
@Document(indexName = "kline-events")
public class KlineEventDocument {
    // Elasticsearch document mapping
}

// Kafka Consumer
@KafkaListener(topics = "kline-events")
public void handleKlineEvent(KlineEvent event) {
    // Process and persist kline events
}
```

#### Database Configuration
- **PostgreSQL**: Primary relational database
- **Elasticsearch**: Time-series data and analytics
- **Flyway**: Database migration management
- **Connection Pooling**: HikariCP for PostgreSQL

#### Metrics & Monitoring
- `binance_data_storage_kline_events_received_total`
- `binance_data_storage_postgres_saves_total`
- `binance_data_storage_elasticsearch_saves_total`
- `binance_data_storage_postgres_connection_status`

---

### 4. binance-trader-macd

**Purpose**: MACD trading strategy + comprehensive backtesting  
**Status**: 🟡 **Partial** - Backtesting complete, strategy incomplete  
**Technology**: Java 21, Spring Boot 3.3.9, Binance API, JPA, Elasticsearch  

#### Backtesting Engine (✅ Complete)
- **Real Data Integration**: Uses actual Binance historical data
- **Comprehensive Testing**: 2,400+ test scenarios executed
- **Performance Metrics**: Detailed analysis and reporting
- **Risk Analysis**: Portfolio optimization and risk assessment

#### Key Backtesting Components
```java
// Backtesting Engine
@Service
public class BacktestingEngine {
    // Execute backtesting scenarios
}

// Performance Analysis
@Component
public class PerformanceAnalyzer {
    // Calculate performance metrics
}

// Risk Assessment
@Service
public class RiskAnalyzer {
    // Portfolio risk analysis
}
```

#### MACD Strategy (🔄 In Progress)
- **Signal Generation**: MACD indicator calculations
- **Order Placement**: Binance API integration
- **Position Management**: Entry/exit logic
- **Risk Management**: Stop-loss and take-profit

#### Missing Implementation
1. **MACD Calculations**: Technical indicator implementation
2. **Signal Processing**: Buy/sell signal generation
3. **Order Management**: Binance API order placement
4. **Position Tracking**: Open positions and P&L

#### Required Implementation
```java
// MACD Calculator
@Component
public class MACDCalculator {
    // Calculate MACD, Signal, and Histogram
}

// Signal Generator
@Service
public class SignalGenerator {
    // Generate trading signals
}

// Order Manager
@Service
public class OrderManager {
    // Place and manage orders via Binance API
}
```

---

### 5. binance-trader-grid

**Purpose**: Grid trading strategy  
**Status**: 🔴 **Duplicate** - Contains duplicate code from data-storage  
**Technology**: Java 21, Spring Boot 3.3.9, JPA, Elasticsearch  

#### Current Issues
- **Code Duplication**: Contains identical classes from data-storage service
- **Missing Strategy Logic**: No grid trading implementation
- **Incorrect Dependencies**: Uses storage service dependencies instead of trading-specific ones

#### Required Implementation
```java
// Grid Strategy
@Service
public class GridTradingStrategy {
    // Grid trading logic
}

// Grid Manager
@Component
public class GridManager {
    // Manage grid levels and orders
}

// Position Calculator
@Service
public class PositionCalculator {
    // Calculate grid positions and sizes
}
```

#### Missing Dependencies
- Binance API client
- Trading-specific configuration
- Grid strategy parameters
- Order management components

---

### 6. telegram-frontend-python

**Purpose**: Telegram bot interface for monitoring and control  
**Status**: 🔴 **Scaffolding** - Extensive scaffolding, not runnable  
**Technology**: Python 3.11, FastAPI, aiogram, Poetry  

#### Current State
- ✅ **Project Structure**: Well-organized package structure
- ✅ **Dependency Management**: Poetry configuration
- ✅ **Type Hints**: Comprehensive type annotations
- ❌ **Missing Dependencies**: Many imports reference non-existent modules
- ❌ **Configuration**: Missing environment configuration
- ❌ **Database Integration**: No database connection setup

#### Package Structure
```
src/
├── inject/           # Dependency injection
├── routers/          # API routes
├── services/         # Business logic
├── models/           # Data models
├── config/           # Configuration
└── utils/            # Utility functions
```

#### Missing Implementation
1. **Database Models**: User, trading session, configuration models
2. **Service Implementations**: Trading service, notification service
3. **Configuration**: Environment variables and settings
4. **Database Connection**: PostgreSQL/Elasticsearch integration
5. **Error Handling**: Comprehensive error handling and logging

#### Required Dependencies
```toml
# pyproject.toml additions needed
asyncpg = "^0.29.0"           # PostgreSQL async driver
elasticsearch = "^8.0.0"      # Elasticsearch client
redis = "^5.0.0"              # Redis for caching
pydantic-settings = "^2.0.0"  # Configuration management
```

---

## Service Dependencies Map

### Data Flow Dependencies
```
binance-shared-model (shared)
    ↑
binance-data-collection → Kafka → binance-data-storage
    ↓                           ↓
telegram-frontend-python    binance-trader-macd
    ↓                           ↓
    └─────── Binance API ───────┘
```

### Technology Dependencies
- **All Services**: binance-shared-model (Avro schemas)
- **Data Collection**: Kafka, WebSocket, Binance API
- **Data Storage**: PostgreSQL, Elasticsearch, Kafka
- **MACD Trader**: Binance API, PostgreSQL, Elasticsearch, Kafka
- **Grid Trader**: Binance API, PostgreSQL, Elasticsearch, Kafka
- **Telegram Bot**: PostgreSQL, Elasticsearch, Redis, FastAPI

### Infrastructure Dependencies
- **Kafka**: Message streaming backbone
- **PostgreSQL**: Relational data storage
- **Elasticsearch**: Search and analytics
- **Prometheus**: Metrics collection
- **Grafana**: Visualization and monitoring

## Implementation Priorities

### Critical (M1 - Testnet Launch)
1. **Data Collection**: Complete WebSocket implementation
2. **MACD Trader**: Finish strategy logic and order placement
3. **Grid Trader**: Replace duplicate code with proper implementation
4. **Telegram Bot**: Fix dependencies and make runnable

### Important (M2 - Production Launch)
1. **Performance Optimization**: Service performance tuning
2. **Error Handling**: Comprehensive error handling across services
3. **Security**: API key management and security hardening
4. **Monitoring**: Advanced monitoring and alerting

### Nice to Have (Future)
1. **Additional Strategies**: More trading strategies
2. **Advanced Analytics**: Machine learning integration
3. **User Management**: Multi-user support
4. **Mobile App**: Native mobile application

---

**Related Memory Entries**: MEM-C003, MEM-001 through MEM-011  
**Dependencies**: All microservices, infrastructure components  
**Last Review**: 2025-01-08
