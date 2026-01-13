#!/bin/bash
# Backup script for doorbell camera configuration

BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/doorbellcam_backup_${TIMESTAMP}.tar.gz"

echo "=========================================="
echo "Backing Up Configuration"
echo "=========================================="
echo ""

# Create backup directory
mkdir -p ${BACKUP_DIR}

echo "Creating backup: ${BACKUP_FILE}"

# Backup configuration files
tar -czf ${BACKUP_FILE} \
    config/ \
    docker-compose.yml \
    .env \
    2>/dev/null

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Backup created successfully!"
    echo "  Location: ${BACKUP_FILE}"
    echo "  Size: $(du -h ${BACKUP_FILE} | cut -f1)"
    echo ""
    echo "To restore:"
    echo "  tar -xzf ${BACKUP_FILE}"
else
    echo ""
    echo "✗ Backup failed!"
    exit 1
fi

# Keep only last 10 backups
echo "Cleaning old backups (keeping last 10)..."
ls -t ${BACKUP_DIR}/doorbellcam_backup_*.tar.gz | tail -n +11 | xargs -r rm

echo ""
echo "Backup complete!"
echo ""
