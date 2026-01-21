#!/bin/bash
# Installation script for Raspberry Pi Zero 2 W
# This script sets up the camera streaming service

set -e

echo "=========================================="
echo "Doorbell Camera - Pi Zero Setup"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Update system
echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install required packages
echo "Installing required packages..."
apt-get install -y \
    ffmpeg \
    v4l-utils \
    alsa-utils \
    git \
    python3 \
    python3-pip

# Enable camera (skip for USB cameras, but safe to run)
echo "Checking camera interface..."
# Note: USB cameras don't need raspi-config, but this is harmless
# raspi-config nonint do_camera 0

# Create directory for streaming service
echo "Creating service directory..."
mkdir -p /opt/doorbell-camera
cd /opt/doorbell-camera

# Copy the streaming script
echo "Setting up streaming script..."
cat > /opt/doorbell-camera/stream-camera.sh << 'STREAMEOF'
#!/bin/bash
# Camera streaming script for Raspberry Pi Zero 2 W

# Configuration
RTSP_PORT=8554
VIDEO_WIDTH=1280
VIDEO_HEIGHT=720
VIDEO_FPS=15
VIDEO_BITRATE=1000k
AUDIO_ENABLED=true

# Start streaming using ffmpeg
echo "Starting camera stream..."

if [ "$AUDIO_ENABLED" = true ]; then
    # Stream with audio
    ffmpeg -f v4l2 \
        -input_format h264 \
        -video_size ${VIDEO_WIDTH}x${VIDEO_HEIGHT} \
        -framerate ${VIDEO_FPS} \
        -i /dev/video0 \
        -f alsa \
        -i hw:0 \
        -c:v copy \
        -c:a aac \
        -b:a 128k \
        -f rtsp \
        -rtsp_transport tcp \
        rtsp://0.0.0.0:${RTSP_PORT}/camera
else
    # Stream video only
    ffmpeg -f v4l2 \
        -input_format h264 \
        -video_size ${VIDEO_WIDTH}x${VIDEO_HEIGHT} \
        -framerate ${VIDEO_FPS} \
        -i /dev/video0 \
        -c:v copy \
        -f rtsp \
        -rtsp_transport tcp \
        rtsp://0.0.0.0:${RTSP_PORT}/camera
fi
STREAMEOF

chmod +x /opt/doorbell-camera/stream-camera.sh

# Create systemd service
echo "Creating systemd service..."
cat > /etc/systemd/system/doorbell-camera.service << 'SERVICEEOF'
[Unit]
Description=Doorbell Camera Stream
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/doorbell-camera
ExecStart=/opt/doorbell-camera/stream-camera.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICEEOF

# Enable and start service
echo "Enabling camera service..."
systemctl daemon-reload
systemctl enable doorbell-camera.service

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "The camera streaming service has been installed."
echo ""
echo "To start the service now:"
echo "  sudo systemctl start doorbell-camera"
echo ""
echo "To check service status:"
echo "  sudo systemctl status doorbell-camera"
echo ""
echo "To view logs:"
echo "  sudo journalctl -u doorbell-camera -f"
echo ""
echo "The RTSP stream will be available at:"
echo "  rtsp://$(hostname -I | awk '{print $1}'):8554/camera"
echo ""
echo "IMPORTANT: Reboot your Pi Zero for camera changes to take effect:"
echo "  sudo reboot"
echo ""
