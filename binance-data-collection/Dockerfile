# Use the Liberica JDK 23 as the base image
FROM bellsoft/liberica-openjdk-alpine:23

# Set the working directory
WORKDIR /app

# Copy the Maven build files
COPY . .

# Build the application with Maven
RUN ./mvnw package

# Expose the necessary ports
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "target/binance-data-collection.jar"]