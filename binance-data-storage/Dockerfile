# Use the Liberica JDK 21 as the base image
FROM bellsoft/liberica-openjdk-alpine:21

# Install curl for debugging network issues
RUN apk add --no-cache curl

# Set the working directory
WORKDIR /app

# Copy the parent POM and Maven wrapper
COPY ../pom.xml .
COPY ../mvnw .
COPY ../mvnw.cmd .
COPY ../.mvn .mvn
COPY ../maven-settings.xml .

# Copy all modules
COPY ../binance-shared-model ./binance-shared-model
COPY ../binance-data-collection ./binance-data-collection
COPY ../binance-data-storage ./binance-data-storage
COPY ../binance-trader-grid ./binance-trader-grid
COPY ../binance-trader-macd ./binance-trader-macd

# Test network connectivity first
RUN echo "Testing network connectivity..." && \
    curl -I https://repo1.maven.org/maven2/ && \
    curl -I https://packages.confluent.io/maven/ && \
    echo "Network connectivity test completed"

# Pre-download common dependencies to avoid timeout issues
RUN chmod +x ./mvnw && \
    echo "Pre-downloading common dependencies..." && \
    ./mvnw dependency:resolve -s maven-settings.xml -U || echo "Pre-download failed, continuing with build..."

# Make mvnw executable and build the shared model first, then the data storage
# Add retry mechanism for network issues
RUN echo "Building shared model..." && \
    (./mvnw clean install -pl binance-shared-model -DskipTests -s maven-settings.xml -U || \
     (echo "First attempt failed, retrying..." && sleep 5 && ./mvnw clean install -pl binance-shared-model -DskipTests -s maven-settings.xml -U)) && \
    echo "Building data storage..." && \
    (./mvnw clean package -pl binance-data-storage -DskipTests -s maven-settings.xml -U || \
     (echo "First attempt failed, retrying..." && sleep 5 && ./mvnw clean package -pl binance-data-storage -DskipTests -s maven-settings.xml -U))

# Expose the necessary ports
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "binance-data-storage/target/binance-data-storage.jar"]