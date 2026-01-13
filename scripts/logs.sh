#!/bin/bash
# View logs for doorbell camera system

SERVICE=${1:-frigate}

echo "=========================================="
echo "Viewing logs for: ${SERVICE}"
echo "=========================================="
echo ""
echo "Press Ctrl+C to exit"
echo ""

docker-compose logs -f ${SERVICE}
