# Use the Liberica JDK as the base image
FROM bellsoft/liberica-openjdk-alpine:latest

# Set the working directory
WORKDIR /app

# Copy the Maven build files
COPY pom.xml .
COPY src ./src

# Build the application with Maven
RUN ./mvnw package

# Expose the necessary ports
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "target/binance-data-storage.jar"]