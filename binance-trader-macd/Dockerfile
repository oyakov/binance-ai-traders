# Multi-stage build to handle dependencies
FROM bellsoft/liberica-openjdk-alpine:21 AS builder

# Set the working directory
WORKDIR /app

# Copy the entire project (parent pom and all modules)
COPY ../.. .

# Build the shared model first, then the trader
RUN ./mvnw clean install -pl binance-shared-model -DskipTests && \
    ./mvnw clean package -pl binance-trader-macd -DskipTests

# Runtime stage
FROM bellsoft/liberica-openjdk-alpine:21

# Runtime environment variables (provided via secrets or compose overrides):
#   BINANCE_API_KEY - Binance API key forwarded to the REST client header.
#   BINANCE_API_SECRET - Binance API secret used for HMAC signatures.
#   BINANCE_REST_BASE_URL - Optional override for the Binance REST endpoint.
#   BINANCE_TRADER_TEST_ORDER_MODE_ENABLED - Switch to enable `/api/v3/order/test` dry runs.

# Set the working directory
WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /app/binance-trader-macd/target/binance-trader-macd.jar app.jar

# Expose the necessary ports
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "app.jar"]