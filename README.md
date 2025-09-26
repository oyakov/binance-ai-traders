# Binance Data Collection & Trading Microservices

This repository contains multiple microservices designed to handle Binance data collection, storage, and trading activities. The services communicate through Kafka, ensuring decoupled and efficient communication between them. The system also includes a Python-based Telegram bot for interaction.

> **New:** The `autonomous-agent/` directory hosts a fully local autonomous coding assistant that can be launched together with a local LLM via Docker Compose. See [`autonomous-agent/README.md`](autonomous-agent/README.md) for setup instructions.

## Architecture Overview

The system is split into several microservices, each responsible for specific tasks:

- **binance-data-collection**: A microservice that listens to Binance WebSocket streams for real-time market data and sends relevant events (e.g., Kline data) to Kafka.
- **binance-data-storage**: A microservice that listens to the Kafka stream and persists the received market data into a database.
- **indicator-calculator**: A microservice that calculates various trading indicators based on the collected data.
- **grid-trader** and **macd-trader**: Trading strategies that operate based on market data and indicators.
- **telegram-bot**: A Python-based Telegram bot for interacting with the user, receiving commands, and providing trading signals.

## Services

### 1. **binance-data-collection**
- **Responsibility**: Collects Kline data from Binance WebSocket API and sends it to Kafka.
- **Tech Stack**: Java, Spring Boot, WebSocket, Kafka, Lombok.

### 2. **binance-data-storage**
- **Responsibility**: Consumes data from Kafka and persists it in the storage (e.g., Elasticsearch, relational database).
- **Tech Stack**: Java, Spring Boot, Kafka, Elasticsearch.

### 3. **indicator-calculator**
- **Responsibility**: Calculates technical indicators such as Moving Average Convergence Divergence (MACD), Relative Strength Index (RSI), etc.
- **Tech Stack**: Java, Spring Boot, Kafka.

### 4. **grid-trader & macd-trader**
- **Responsibility**: Executes trading strategies based on collected market data and calculated indicators.
- **Tech Stack**: Java, Spring Boot, Kafka, and Binance API.

### 5. **telegram-bot**
- **Responsibility**: A Python-based Telegram bot for sending real-time trading signals and receiving commands from the user.
- **Tech Stack**: Python, Telebot API, Kafka.

## Kafka as Event Bus

All microservices are connected via **Kafka** as the event bus. Each service listens to the relevant topics and performs its task in isolation. Kafka allows loose coupling between services and facilitates scalability.

## How to Run the System

### Prerequisites

- **Docker** and **Docker Compose** installed on your machine.
- **Java 17** or higher (for running Java-based services).
- **Python 3.x** (for the Telegram bot).
- **Maven** for building Java microservices.

### Docker Setup

You can use the `docker-compose.yml` file to start all the services with the required dependencies (e.g., Kafka, Zookeeper, Elasticsearch).

### docker-compose.yml

```yaml
version: '3.8'

services:

  # Zookeeper for Kafka
  zookeeper:
    image: wurstmeister/zookeeper:3.4.6
    ports:
      - "2181:2181"
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181

  # Kafka
  kafka:
    image: wurstmeister/kafka:latest
    ports:
      - "9093:9093"
    environment:
      KAFKA_ADVERTISED_LISTENER: INSIDE-KAFKA:9093
      KAFKA_LISTENER_SECURITY_PROTOCOL: PLAINTEXT
      KAFKA_LISTENER_NAME_INTERNAL: INSIDE-KAFKA
      KAFKA_LISTENER_INTERNAL: INSIDE-KAFKA:9093
      KAFKA_LISTENER_PORT: 9093
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_LISTENER_NAME_EXTERNAL: OUTSIDE-KAFKA
      KAFKA_LISTENER_EXTERNAL: 0.0.0.0:9092
    depends_on:
      - zookeeper

  # Elasticsearch
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.3.0
    environment:
      discovery.type: single-node
      ELASTIC_PASSWORD: password
    ports:
      - "9200:9200"
    volumes:
      - esdata1:/usr/share/elasticsearch/data

  # binance-data-collection
  binance-data-collection:
    image: binance-data-collection:latest
    build: ./binance-data-collection
    environment:
      SPRING_PROFILES_ACTIVE: dev
      BINANCE_API_KEY: "your_api_key"
      BINANCE_API_SECRET: "your_api_secret"
      KAFKA_BROKER: kafka:9093
    depends_on:
      - kafka

  # binance-data-storage
  binance-data-storage:
    image: binance-data-storage:latest
    build: ./binance-data-storage
    environment:
      SPRING_PROFILES_ACTIVE: dev
      KAFKA_BROKER: kafka:9093
      ELASTICSEARCH_URL: http://elasticsearch:9200
    depends_on:
      - kafka
      - elasticsearch

  # indicator-calculator
  indicator-calculator:
    image: indicator-calculator:latest
    build: ./indicator-calculator
    environment:
      SPRING_PROFILES_ACTIVE: dev
      KAFKA_BROKER: kafka:9093
    depends_on:
      - kafka

  # grid-trader
  grid-trader:
    image: grid-trader:latest
    build: ./grid-trader
    environment:
      SPRING_PROFILES_ACTIVE: dev
      KAFKA_BROKER: kafka:9093
    depends_on:
      - kafka

  # macd-trader
  macd-trader:
    image: macd-trader:latest
    build: ./macd-trader
    environment:
      SPRING_PROFILES_ACTIVE: dev
      KAFKA_BROKER: kafka:9093
    depends_on:
      - kafka

  # telegram-bot
  telegram-bot:
    image: telegram-bot:latest
    build: ./telegram-bot
    environment:
      TELEGRAM_API_KEY: "your_telegram_api_key"
      KAFKA_BROKER: kafka:9093
    depends_on:
      - kafka

volumes:
  esdata1:
    driver: local
```

### How to Build & Run
**Build the microservices**: Use Maven to build all the Java microservices.

```
mvn clean install
```

**Start the services**: Navigate to the root of the repository where the docker-compose.yml file is located and run:

```
docker-compose up --build
```

**Check the logs**: Once all services are running, you can check their logs using Docker commands:

```
docker-compose logs -f <service_name>
```

**Access the services**:

Elasticsearch: http://localhost:9200
Kafka: Use Kafka APIs to produce/consume data.

### Contributing
Feel free to create issues or submit pull requests. If you wish to contribute, please make sure to follow the DDD principles, ensuring that services are decoupled and well-structured.

### License
This project is licensed under the MIT License - see the LICENSE file for details.
