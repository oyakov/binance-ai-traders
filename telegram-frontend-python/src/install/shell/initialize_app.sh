#!/bin/bash

# Function to print and execute a command
execute() {
    # shellcheck disable=SC2145
    echo "Executing: $@"
    "$@"
}

# Clean up all Docker images and volumes
cleanup_docker() {
    echo "Cleaning up Docker images and volumes..."
    execute docker-compose down -v
}

# Start Docker Compose
start_docker_compose() {
    echo "Starting Docker Compose..."
    execute docker-compose build --no-cache
    execute docker-compose up -d
}

# Main function to initialize the app
initialize_app() {
    cleanup_docker
    start_docker_compose
    echo "Application initialized successfully."
}

# Run the main function
initialize_app
