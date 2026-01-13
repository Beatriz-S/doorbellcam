# Doorbell Camera System - Complete Setup Guide

A Ring-like doorbell camera system using Raspberry Pi 5 (NVR) and Raspberry Pi Zero 2 W (Camera).

## System Architecture

```
┌─────────────────────────────────┐
│   Raspberry Pi Zero 2 W         │
│   - Camera Module               │
│   - Microphone (optional)       │
│   - MediaMTX/FFmpeg RTSP Server │
│   - IP: 192.168.1.100           │
└────────────┬────────────────────┘
             │
             │ RTSP Stream
             │ rtsp://192.168.1.100:8554/camera
             │
             ▼
┌─────────────────────────────────┐
│   Raspberry Pi 5 (NVR)          │
│   ┌───────────────────────────┐ │
│   │ Docker Containers:        │ │
│   │ - Frigate (AI Detection)  │ │
│   │ - MQTT Broker             │ │
│   │ - Node-RED (Automation)   │ │
│   │ - Portainer (Management)  │ │
│   └───────────────────────────┘ │
└────────────┬────────────────────┘
             │
             ▼
      Web UI, Notifications,
      Mobile Apps, etc.
```

## Features

✅ **AI Person Detection** - Only alerts when a person is detected, not just motion  
✅ **24/7 Recording** - Continuous recording with smart retention  
✅ **Low Latency Live View** - WebRTC for instant video access  
✅ **Event Clips** - Automatic clips when events occur  
✅ **MQTT Integration** - Easy notifications and automation  
✅ **Web Interface** - Beautiful, modern UI  
✅ **Mobile Ready** - Access from anywhere  

## Prerequisites

### Hardware Required

#### Raspberry Pi 5 (NVR Server)
- Raspberry Pi 5 (4GB or 8GB RAM recommended)
- 64GB+ microSD card or SSD (SSD highly recommended)
- Power supply (27W USB-C)
- Cooling solution (active cooling recommended)
- Optional: Google Coral USB Accelerator (highly recommended for better AI performance)

#### Raspberry Pi Zero 2 W (Camera)
- Raspberry Pi Zero 2 W
- Raspberry Pi Camera Module (v2 or v3)
- 16GB+ microSD card
- Power supply (5V 2.5A)
- Optional: USB microphone for audio

### Software Required
- Raspberry Pi OS (64-bit) on both devices
- Docker and Docker Compose on Pi 5
- Internet connection for initial setup

## Part 1: Raspberry Pi Zero 2 W Setup (Camera)

### 1.1 Install Raspberry Pi OS

1. Use [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
2. Choose **Raspberry Pi OS Lite (64-bit)**
3. Configure settings (gear icon):
   - Set hostname: `doorbell-camera`
   - Enable SSH
   - Set username/password
   - Configure WiFi
4. Flash to microSD card

### 1.2 Connect Hardware

1. Connect camera module to Pi Zero
2. Insert microSD card
3. Power on the Pi Zero
4. Wait 1-2 minutes for first boot

### 1.3 SSH and Setup

```bash
# SSH into Pi Zero
ssh pi@doorbell-camera.local

# Update system
sudo apt update && sudo apt upgrade -y

# Get the setup scripts
# Option 1: Clone this repo
git clone https://github.com/yourusername/doorbellcam.git
cd doorbellcam/pi-zero-setup

# Option 2: Manually create the scripts (see pi-zero-setup/README.md)
```

### 1.4 Install Streaming Software

**Recommended: MediaMTX** (better performance)
```bash
cd pi-zero-setup
sudo chmod +x install-mediamtx.sh
sudo ./install-mediamtx.sh
```

**Alternative: FFmpeg** (simpler, more CPU usage)
```bash
cd pi-zero-setup
sudo chmod +x install-camera-stream.sh
sudo ./install-camera-stream.sh
```

### 1.5 Reboot and Test

```bash
# Reboot to apply changes
sudo reboot

# After reboot, check service status
sudo systemctl status mediamtx  # or doorbell-camera

# Get Pi Zero IP address
hostname -I
# Example output: 192.168.1.100
```

### 1.6 Test Stream

From another computer:
```bash
# Test with ffplay
ffplay rtsp://192.168.1.100:8554/camera

# Or use VLC media player
# File > Open Network Stream > rtsp://192.168.1.100:8554/camera
```

**✅ Checkpoint:** You should see live video from your camera!

## Part 2: Raspberry Pi 5 Setup (NVR Server)

### 2.1 Install Docker

```bash
# SSH into your Raspberry Pi 5
ssh pi@raspberrypi.local

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt-get install -y docker-compose

# Log out and back in for group changes
exit
# SSH back in
```

### 2.2 Clone/Download Project

```bash
# Option 1: Clone from GitHub
git clone https://github.com/yourusername/doorbellcam.git
cd doorbellcam

# Option 2: Create project directory manually
mkdir -p ~/doorbellcam
cd ~/doorbellcam
# Copy all files from this repository
```

### 2.3 Create Required Directories

```bash
# Create storage directories
mkdir -p storage/frigate
mkdir -p storage/mosquitto/data
mkdir -p storage/mosquitto/log
mkdir -p storage/nodered
mkdir -p storage/portainer

# Create config directories (should already exist)
mkdir -p config/mosquitto
```

### 2.4 Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit with your settings
nano .env
```

Update these values in `.env`:
```bash
TZ=America/New_York  # Your timezone
FRIGATE_RTSP_PASSWORD=your_secure_password
DOORBELL_CAMERA_IP=192.168.1.100  # Your Pi Zero IP
```

### 2.5 Configure Frigate

Edit `config/frigate.yml` and update the camera IP:

```bash
nano config/frigate.yml
```

Find the `cameras` section and update:
```yaml
cameras:
  doorbell:
    ffmpeg:
      inputs:
        - path: rtsp://192.168.1.100:8554/camera  # Update this IP
```

Also update the timezone:
```yaml
ui:
  timezone: America/New_York  # Your timezone
```

### 2.6 Start Docker Containers

```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f frigate
```

### 2.7 Access Services

Open your browser and navigate to:

- **Frigate UI**: http://raspberrypi.local:5000
- **Node-RED**: http://raspberrypi.local:1880
- **Portainer**: http://raspberrypi.local:9000

**✅ Checkpoint:** You should see the Frigate interface with live camera feed!

## Part 3: Configuration and Optimization

### 3.1 Configure Detection Zones

1. Open Frigate UI: http://raspberrypi.local:5000
2. Go to Settings > Camera Settings
3. Click on "doorbell" camera
4. Use the zone editor to define your doorway area
5. Update `config/frigate.yml` with the coordinates

### 3.2 Adjust Detection Settings

Edit `config/frigate.yml`:

```yaml
objects:
  filters:
    person:
      min_area: 5000      # Adjust based on camera distance
      threshold: 0.7      # Higher = fewer false positives
      min_score: 0.5      # Minimum confidence
```

Restart Frigate:
```bash
docker-compose restart frigate
```

### 3.3 Set Up Notifications (Node-RED)

1. Open Node-RED: http://raspberrypi.local:1880
2. Install MQTT nodes (if not already installed)
3. Create a flow:
   - MQTT Input node → Subscribe to `frigate/doorbell/person`
   - Function node → Process event data
   - Notification node → Send to your phone/email

Example MQTT topics:
- `frigate/doorbell/person` - Person detected events
- `frigate/doorbell/person/snapshot` - Snapshot image
- `frigate/events` - All events

### 3.4 Mobile Access

#### Option 1: Port Forwarding
1. Configure your router to forward port 5000 to your Pi 5
2. Use your public IP or DDNS to access

#### Option 2: VPN (Recommended)
1. Set up WireGuard or Tailscale on Pi 5
2. Connect via VPN for secure access

#### Option 3: Cloudflare Tunnel
1. Set up Cloudflare Tunnel for secure remote access
2. No port forwarding needed

## Part 4: Optional Enhancements

### 4.1 Add Google Coral TPU

For much better AI performance:

1. Connect Coral USB Accelerator to Pi 5
2. Edit `docker-compose.yml`:
   ```yaml
   devices:
     - /dev/bus/usb:/dev/bus/usb
     - /dev/apex_0:/dev/apex_0
   ```
3. Edit `config/frigate.yml`:
   ```yaml
   detectors:
     coral:
       type: edgetpu
       device: usb
   ```
4. Restart: `docker-compose restart frigate`

### 4.2 Add More Cameras

1. Set up additional Pi Zero cameras
2. Add camera entries in `config/frigate.yml`:
   ```yaml
   cameras:
     doorbell:
       # ... existing config ...
     
     backyard:
       enabled: true
       ffmpeg:
         inputs:
           - path: rtsp://192.168.1.101:8554/camera
       # ... similar config ...
   ```

### 4.3 Enable Audio Detection

In `config/frigate.yml`:
```yaml
cameras:
  doorbell:
    audio:
      enabled: true
      listen:
        - speech
        - bark
```

### 4.4 Set Up Recording Retention

Adjust in `config/frigate.yml`:
```yaml
record:
  retain:
    days: 7           # Keep all recordings for 7 days
    mode: motion      # Only motion/objects
  events:
    retain:
      default: 14     # Keep event clips for 14 days
```

## Troubleshooting

### No Video in Frigate

1. Check Pi Zero stream is working:
   ```bash
   ffplay rtsp://192.168.1.100:8554/camera
   ```
2. Check Frigate logs:
   ```bash
   docker-compose logs frigate
   ```
3. Verify camera IP in `config/frigate.yml`

### High CPU Usage

1. Lower detection FPS in `config/frigate.yml`:
   ```yaml
   detect:
     fps: 5  # Lower from 10
   ```
2. Reduce camera resolution on Pi Zero
3. Consider adding Coral TPU

### False Detections

1. Increase threshold:
   ```yaml
   objects:
     filters:
       person:
         threshold: 0.8  # Increase from 0.7
   ```
2. Define zones to exclude problem areas
3. Add motion masks for trees, flags, etc.

### Can't Access Frigate UI

1. Check Docker containers are running:
   ```bash
   docker-compose ps
   ```
2. Check firewall:
   ```bash
   sudo ufw allow 5000/tcp
   ```
3. Try IP address instead of hostname

### MQTT Not Working

1. Check MQTT broker is running:
   ```bash
   docker-compose logs mqtt
   ```
2. Test MQTT connection:
   ```bash
   docker exec -it mqtt mosquitto_sub -t "frigate/#" -v
   ```

## Performance Tips

### For Pi 5 (NVR)
- Use SSD instead of microSD card
- Enable active cooling
- Add Coral TPU for AI acceleration
- Allocate more shared memory if needed

### For Pi Zero 2 W (Camera)
- Use 720p instead of 1080p
- Lower frame rate (10-15 fps)
- Use MediaMTX instead of FFmpeg
- Disable audio if not needed

## Security Best Practices

1. **Change default passwords** for all services
2. **Enable MQTT authentication**:
   ```bash
   docker exec -it mqtt mosquitto_passwd -c /mosquitto/config/passwd frigate
   docker-compose restart mqtt
   ```
3. **Use strong WiFi passwords**
4. **Keep systems updated**:
   ```bash
   # Pi 5
   sudo apt update && sudo apt upgrade -y
   docker-compose pull
   docker-compose up -d
   
   # Pi Zero
   sudo apt update && sudo apt upgrade -y
   ```
5. **Use VPN** for remote access instead of port forwarding
6. **Regular backups** of configuration files

## Maintenance

### Regular Tasks

**Weekly:**
- Check disk space: `df -h`
- Review event recordings
- Check for false positives/negatives

**Monthly:**
- Update Docker images: `docker-compose pull && docker-compose up -d`
- Update Pi OS: `sudo apt update && sudo apt upgrade -y`
- Review and adjust detection settings

**Quarterly:**
- Backup configuration files
- Review retention settings
- Clean up old recordings if needed

## Resources

- **Frigate Documentation**: https://docs.frigate.video
- **MediaMTX Documentation**: https://github.com/bluenviron/mediamtx
- **Node-RED Documentation**: https://nodered.org/docs/
- **MQTT Documentation**: https://mosquitto.org/documentation/

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Review Frigate documentation
3. Check GitHub issues
4. Community forums

## License

This project uses:
- Frigate (MIT License)
- MediaMTX (MIT License)
- Mosquitto (EPL/EDL License)
- Node-RED (Apache 2.0 License)

## Next Steps

1. ✅ Set up Pi Zero 2 W with camera streaming
2. ✅ Set up Pi 5 with Docker containers
3. ✅ Configure Frigate and verify video feed
4. ⬜ Set up detection zones
5. ⬜ Configure notifications
6. ⬜ Set up mobile access
7. ⬜ Add additional features (Coral TPU, more cameras, etc.)

**Congratulations!** You now have a fully functional Ring-like doorbell camera system! 🎉
