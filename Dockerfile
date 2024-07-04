# Use an official Python runtime as a parent image
FROM python:3.12

# Set the working directory in the container
WORKDIR /app

# Copy the application code to the working directory
COPY . /app

# Install Poetry
RUN pip install poetry

# Install the dependencies
RUN poetry install --no-dev

# Command to run the application
CMD ["poetry", "run", "python", "main.py"]
