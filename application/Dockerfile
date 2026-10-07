#
# Simple Web Application - Dockerfile
#

# NOTE: security, use slim base image
#FROM pyhton:3.9-slim-buster
FROM python:3.9-buster

# Set the working directory inside the container
WORKDIR /app

# Copy the requiremenets file and install dependencies
COPY requirements.txt .
RUN pip install  -r requirements.txt

# Copy the application code to working dir
COPY . . 

# Expose the port fro Flask based web application
EXPOSE 5000

# NOTE: running as root, change this before production
USER 1000

# Run the web application
CMD ["python", "-m", "flask", "--app", "simple-web-application.py", "run", "--host", "0.0.0.0"]

