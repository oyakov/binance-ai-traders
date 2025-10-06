# Use the Liberica JDK 21 as the base image
FROM bellsoft/liberica-openjdk-alpine:21

# Set the working directory
WORKDIR /app

# Copy the Maven build files
COPY . .

# Debug: List files and make mvnw executable and build the application with Maven
RUN ls -la && chmod +x mvnw && ./mvnw package -pl binance-data-collection -am -DskipTests

# Expose the necessary ports
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "binance-data-collection/target/binance-data-collection.jar"]