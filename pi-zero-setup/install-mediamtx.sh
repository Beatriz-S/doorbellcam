#!/bin/bash
# Alternative installation script using MediaMTX (formerly rtsp-simple-server)
# MediaMTX is more efficient and feature-rich than ffmpeg for RTSP streaming

set -e

echo "=========================================="
echo "Doorbell Camera - MediaMTX Setup"
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
    wget \
    v4l-utils \
    alsa-utils

# Enable camera
echo "Enabling camera interface..."
raspi-config nonint do_camera 0

# Download MediaMTX
echo "Downloading MediaMTX..."
MEDIAMTX_VERSION="v1.5.1"
MEDIAMTX_ARCH="linux_arm64v8"
cd /tmp
wget https://github.com/bluenviron/mediamtx/releases/download/${MEDIAMTX_VERSION}/mediamtx_${MEDIAMTX_VERSION}_${MEDIAMTX_ARCH}.tar.gz
tar -xzf mediamtx_${MEDIAMTX_VERSION}_${MEDIAMTX_ARCH}.tar.gz

# Install MediaMTX
echo "Installing MediaMTX..."
mkdir -p /opt/mediamtx
mv mediamtx /opt/mediamtx/
mv mediamtx.yml /opt/mediamtx/

# Configure MediaMTX
echo "Configuring MediaMTX..."
cat > /opt/mediamtx/mediamtx.yml << 'CONFIGEOF'
# MediaMTX configuration for Raspberry Pi Camera

# RTSP server settings
rtspAddress: :8554
rtmpAddress: :1935
hlsAddress: :8888
webrtcAddress: :8889

# Authentication (optional - uncomment to enable)
# authMethod: internal
# authInternalUsers:
#   - user: doorbell
#     pass: your_password_here

# Performance settings
readTimeout: 10s
writeTimeout: 10s
readBufferCount: 512

# Path configuration
paths:
  camera:
    # Raspberry Pi Camera source
    source: rpiCamera
    rpiCameraWidth: 1280
    rpiCameraHeight: 720
    rpiCameraFPS: 15
    rpiCameraBitrate: 1000000
    
    # Enable recording (optional)
    record: no
    # recordPath: /opt/mediamtx/recordings/%path/%Y-%m-%d_%H-%M-%S-%f
    
    # Enable on-demand streaming (saves resources)
    runOnDemand: no
    
    # Allow publishing and reading
    publishUser: ""
    publishPass: ""
    readUser: ""
    readPass: ""
CONFIGEOF

# Create systemd service
echo "Creating systemd service..."
cat > /etc/systemd/system/mediamtx.service << 'SERVICEEOF'
[Unit]
Description=MediaMTX RTSP Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/mediamtx
ExecStart=/opt/mediamtx/mediamtx /opt/mediamtx/mediamtx.yml
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICEEOF

# Enable service
echo "Enabling MediaMTX service..."
systemctl daemon-reload
systemctl enable mediamtx.service

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "MediaMTX has been installed and configured."
echo ""
echo "To start the service now:"
echo "  sudo systemctl start mediamtx"
echo ""
echo "To check service status:"
echo "  sudo systemctl status mediamtx"
echo ""
echo "To view logs:"
echo "  sudo journalctl -u mediamtx -f"
echo ""
echo "The RTSP stream will be available at:"
echo "  rtsp://$(hostname -I | awk '{print $1}'):8554/camera"
echo ""
echo "IMPORTANT: Reboot your Pi Zero for camera changes to take effect:"
echo "  sudo reboot"
echo ""
