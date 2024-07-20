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

    # Remove all stopped containers
    execute docker container prune -f

    # Remove all unused images
    execute docker image prune -af

    # Remove all unused volumes
    execute docker volume prune -f
}

# Start Docker Compose
start_docker_compose() {
    echo "Starting Docker Compose..."

    # Pull the latest images
    execute docker-compose pull

    # Start Docker Compose with the up command
    execute docker-compose up --build -d
}

# Main function to initialize the app
initialize_app() {
    cleanup_docker
    start_docker_compose

    echo "Application initialized successfully."
}

# Run the main function
initialize_app
