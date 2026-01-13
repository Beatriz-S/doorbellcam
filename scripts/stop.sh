#!/bin/bash
# Stop script for the doorbell camera system

echo "=========================================="
echo "Stopping Doorbell Camera System"
echo "=========================================="
echo ""

docker-compose down

echo ""
echo "All services stopped."
echo ""
echo "To start again:"
echo "  ./scripts/start.sh"
echo "  or: docker-compose up -d"
echo ""
