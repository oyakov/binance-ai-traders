# Use the Liberica JDK 21 as the base image
FROM bellsoft/liberica-openjdk-alpine:21

# Runtime environment variables (provided via secrets or compose overrides):
#   BINANCE_API_KEY - Binance API key forwarded to the REST client header.
#   BINANCE_API_SECRET - Binance API secret used for HMAC signatures.
#   BINANCE_REST_BASE_URL - Optional override for the Binance REST endpoint.
#   BINANCE_TRADER_TEST_ORDER_MODE_ENABLED - Switch to enable `/api/v3/order/test` dry runs.

# Set the working directory
WORKDIR /app

# Copy the Maven build files
COPY . .

# Build the application with Maven
RUN ./mvnw package

# Expose the necessary ports
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "target/binance-trader-macd.jar"]