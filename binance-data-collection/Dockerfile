# syntax=docker/dockerfile:1.6

# Cached dependency stage
FROM maven:3.9.9-eclipse-temurin-21 AS deps
WORKDIR /workspace

# Use local Maven settings (Nexus mirror)
COPY maven-settings.xml /root/.m2/settings.xml
# Ensure container can reach host Nexus on Docker Desktop
RUN sed -i 's|http://localhost:8081|http://host.docker.internal:8081|g' /root/.m2/settings.xml || true

# Copy POMs first to maximize cache hits
COPY pom.xml ./
COPY binance-shared-model/pom.xml binance-shared-model/
COPY binance-data-collection/pom.xml binance-data-collection/
COPY binance-data-storage/pom.xml binance-data-storage/
COPY binance-trader-macd/pom.xml binance-trader-macd/
# grid module may be absent or experimental; include if present
RUN --mount=type=cache,target=/root/.m2 mvn -B -q -DskipTests dependency:go-offline || true

# Build only the current module and its dependencies
FROM deps AS build
COPY . .
RUN --mount=type=cache,target=/root/.m2 mvn -B -q -DskipTests -Dmaven.test.skip=true -pl binance-data-collection -am package

# Runtime image
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /workspace/binance-data-collection/target/binance-data-collection.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]