# Use the Liberica JDK 21 as the base image
FROM bellsoft/liberica-openjdk-alpine:21

# Set the working directory
WORKDIR /app

# Copy the Maven build files
COPY . .

# Build the application with Maven
RUN ./mvnw package -DskipTests

# Expose the necessary ports
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "target/binance-data-collection.jar"]