#!/bin/bash
# Quick start script for the doorbell camera system

echo "=========================================="
echo "Starting Doorbell Camera System"
echo "=========================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed"
    echo "Please install Docker first:"
    echo "  curl -fsSL https://get.docker.com -o get-docker.sh"
    echo "  sudo sh get-docker.sh"
    exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Error: docker-compose is not installed"
    echo "Please install docker-compose first:"
    echo "  sudo apt-get install -y docker-compose"
    exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Warning: .env file not found"
    echo "Creating from env.template..."
    if [ -f env.template ]; then
        cp env.template .env
        echo "Please edit .env file with your settings"
        exit 1
    else
        echo "Error: env.template not found"
        exit 1
    fi
fi

# Create required directories
echo "Creating required directories..."
mkdir -p storage/frigate
mkdir -p storage/mosquitto/data
mkdir -p storage/mosquitto/log
mkdir -p storage/nodered
mkdir -p storage/portainer
mkdir -p config/mosquitto

# Start Docker containers
echo ""
echo "Starting Docker containers..."
docker-compose up -d

# Wait a moment for containers to start
sleep 3

# Check container status
echo ""
echo "Container status:"
docker-compose ps

# Get IP address
IP_ADDR=$(hostname -I | awk '{print $1}')

echo ""
echo "=========================================="
echo "Doorbell Camera System Started!"
echo "=========================================="
echo ""
echo "Access your services:"
echo "  Frigate UI:  http://${IP_ADDR}:5000"
echo "  Node-RED:    http://${IP_ADDR}:1880"
echo "  Portainer:   http://${IP_ADDR}:9000"
echo ""
echo "To view logs:"
echo "  docker-compose logs -f frigate"
echo ""
echo "To stop:"
echo "  docker-compose down"
echo ""
