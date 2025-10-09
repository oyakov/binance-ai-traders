# syntax=docker/dockerfile:1.6

FROM maven:3.9.9-eclipse-temurin-21 AS deps
WORKDIR /workspace
COPY maven-settings.xml /root/.m2/settings.xml
RUN sed -i 's|http://localhost:8081|http://host.docker.internal:8081|g' /root/.m2/settings.xml || true
COPY pom.xml ./
COPY binance-shared-model/pom.xml binance-shared-model/
COPY binance-data-collection/pom.xml binance-data-collection/
COPY binance-data-storage/pom.xml binance-data-storage/
COPY binance-trader-macd/pom.xml binance-trader-macd/
RUN --mount=type=cache,target=/root/.m2 mvn -B -q -DskipTests dependency:go-offline || true

FROM deps AS build
COPY . .
RUN --mount=type=cache,target=/root/.m2 mvn -B -q -DskipTests -Dmaven.test.skip=true -pl binance-data-storage -am package

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /workspace/binance-data-storage/target/binance-data-storage.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]