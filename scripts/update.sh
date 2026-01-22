#!/bin/bash
# Update script for the doorbell camera system

echo "=========================================="
echo "Updating Doorbell Camera System"
echo "=========================================="
echo ""

echo "Pulling latest Docker images..."
docker compose pull

echo ""
echo "Restarting containers with new images..."
docker compose up -d

echo ""
echo "Cleaning up old images..."
docker image prune -f

echo ""
echo "=========================================="
echo "Update Complete!"
echo "=========================================="
echo ""
echo "Current container status:"
docker compose ps
echo ""
