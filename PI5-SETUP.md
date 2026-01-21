# Raspberry Pi 5 Setup Guide - NVR Server

This guide will walk you through setting up your Raspberry Pi 5 as the Network Video Recorder (NVR) server for your doorbell camera system.

## What You'll Be Installing

- **Frigate NVR**: AI-powered video surveillance with person detection
- **MQTT Broker**: Message broker for events and notifications
- **Node-RED**: Automation and notification system
- **Portainer**: Docker container management UI

## Prerequisites

### Hardware
- Raspberry Pi 5 (4GB or 8GB RAM recommended)
- 64GB+ microSD card or SSD (SSD highly recommended for better performance)
- 27W USB-C power supply
- Active cooling (fan or heatsink)
- Network connection (Ethernet recommended)
- Optional: Google Coral USB Accelerator (for better AI performance)

### Before You Start
- Ensure your Pi Zero camera is already set up and streaming (see `pi-zero-setup/README.md`)
- Know your Pi Zero's IP address (e.g., 192.168.1.100)
- Have internet connection for downloading Docker images

## Step 1: Install Raspberry Pi OS

### 1.1 Flash OS to SD Card/SSD

1. Download [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
2. Select **Raspberry Pi OS (64-bit)** (full version recommended, but Lite works too)
3. Click the gear icon ⚙️ to configure:
   - **Hostname**: `raspberrypi` or `pi5-nvr`
   - **Enable SSH**: ✅ Check this box
   - **Set username/password**: `pi` / your secure password
   - **Configure WiFi** (if not using Ethernet)
   - **Set locale settings**: Your timezone and keyboard layout
4. Flash to your SD card or SSD

### 1.2 First Boot

1. Insert SD card/SSD into Pi 5
2. Connect Ethernet cable (recommended) or use WiFi
3. Power on the Pi 5
4. Wait 2-3 minutes for first boot

### 1.3 Find Your Pi 5 on the Network

From your Windows computer, open PowerShell:

```powershell
# Try hostname first
ping raspberrypi.local

# Or check your router's device list for the IP address
```

## Step 2: Connect and Update

### 2.1 SSH Into Your Pi 5

```powershell
# From Windows PowerShell
ssh pi@raspberrypi.local
# Or use the IP address: ssh pi@192.168.1.50
```

Enter the password you set during OS installation.

### 2.2 Update System

```bash
# Update package lists and upgrade all packages
sudo apt update && sudo apt upgrade -y

# Install useful tools
sudo apt install -y git curl wget vim nano htop

# Reboot to apply any kernel updates
sudo reboot
```

Wait a minute, then SSH back in.

## Step 3: Install Docker

### 3.1 Install Docker Engine

```bash
# Download Docker installation script
curl -fsSL https://get.docker.com -o get-docker.sh

# Run the installation
sudo sh get-docker.sh

# Add your user to the docker group (avoids needing sudo for docker commands)
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt-get install -y docker-compose

# Verify installation
docker --version
docker-compose --version
```

### 3.2 Enable Docker to Start on Boot

```bash
sudo systemctl enable docker
```

### 3.3 Log Out and Back In

```bash
# Log out to apply group changes
exit

# SSH back in
ssh pi@raspberrypi.local
```

Verify you can run Docker without sudo:
```bash
docker ps
# Should show an empty list, not a permission error
```

## Step 4: Set Up the Project

### 4.1 Clone or Transfer Project Files

**Option A: Clone from GitHub** (if you've pushed your code)
```bash
cd ~
git clone https://github.com/yourusername/doorbellcam.git
cd doorbellcam
```

**Option B: Transfer Files from Your Computer**

From your Windows computer (PowerShell):
```powershell
# Navigate to your project directory
cd C:\Users\santos\Desktop\Github\doorbellcam

# Copy files to Pi 5 using SCP
scp -r * pi@raspberrypi.local:~/doorbellcam/
```

Then on Pi 5:
```bash
cd ~/doorbellcam
```

### 4.2 Create Required Directories

```bash
# Create all storage directories
mkdir -p storage/frigate
mkdir -p storage/mosquitto/data
mkdir -p storage/mosquitto/log
mkdir -p storage/nodered
mkdir -p storage/portainer

# Verify directories were created
ls -la storage/
```

### 4.3 Set Correct Permissions

```bash
# Mosquitto needs specific permissions
sudo chown -R 1883:1883 storage/mosquitto

# Node-RED needs permissions
sudo chown -R 1000:1000 storage/nodered

# Frigate storage
sudo chown -R $USER:$USER storage/frigate
```

## Step 5: Configure the System

### 5.1 Create Environment File

```bash
# Create .env file from template
cp .env.example .env

# Edit the environment file
nano .env
```

Update these values in `.env`:
```bash
# Timezone (use your timezone from https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)
TZ=America/New_York

# Frigate RTSP password (change this to something secure)
FRIGATE_RTSP_PASSWORD=your_secure_password_here

# Pi Zero Camera IP address (update with your actual IP)
DOORBELL_CAMERA_IP=192.168.1.100

# Optional: MQTT authentication (uncomment and set if you want security)
# MQTT_USER=frigate
# MQTT_PASSWORD=your_mqtt_password
```

Save with `Ctrl+X`, then `Y`, then `Enter`.

### 5.2 Configure Frigate

```bash
# Edit Frigate configuration
nano config/frigate.yml
```

**Important changes to make:**

1. **Update camera IP** (around line 14):
```yaml
go2rtc:
  streams:
    doorbell:
      - rtsp://YOUR_PI_ZERO_IP:8554/camera  # Change this to your Pi Zero IP
```

2. **Update timezone** (around line 163):
```yaml
ui:
  timezone: America/New_York  # Change to your timezone
```

3. **Adjust detection zone** (lines 122-131):
   - The default zone covers the center of the frame
   - You can adjust this later using the Frigate web UI
   - Format: `x1,y1,x2,y2,x3,y3,x4,y4` (clockwise from top-left)

Save with `Ctrl+X`, then `Y`, then `Enter`.

### 5.3 Update Docker Compose (Optional)

```bash
nano docker-compose.yml
```

Changes you might want to make:

1. **Update RTSP password** (line 32):
```yaml
FRIGATE_RTSP_PASSWORD: "your_secure_password_here"
```

2. **Update timezone** for Node-RED (line 60):
```yaml
- TZ=America/New_York
```

3. **Enable Coral TPU** (if you have one) - uncomment lines 13-14:
```yaml
devices:
  - /dev/bus/usb:/dev/bus/usb
  - /dev/apex_0:/dev/apex_0
```

Save with `Ctrl+X`, then `Y`, then `Enter`.

## Step 6: Start the System

### 6.1 Pull Docker Images

```bash
# Download all Docker images (this may take 5-10 minutes)
docker-compose pull
```

### 6.2 Start All Services

```bash
# Start all containers in detached mode
docker-compose up -d
```

### 6.3 Check Status

```bash
# View running containers
docker-compose ps

# Should show all containers as "Up"
```

### 6.4 View Logs

```bash
# View Frigate logs
docker-compose logs -f frigate

# Press Ctrl+C to exit logs

# View all logs
docker-compose logs -f
```

## Step 7: Access Your Services

### 7.1 Find Your Pi 5's IP Address

```bash
hostname -I
# Example output: 192.168.1.50
```

### 7.2 Open Web Interfaces

From any device on your network, open a web browser:

- **Frigate UI**: http://raspberrypi.local:5000 or http://192.168.1.50:5000
- **Node-RED**: http://raspberrypi.local:1880 or http://192.168.1.50:1880
- **Portainer**: http://raspberrypi.local:9000 or http://192.168.1.50:9000

### 7.3 Verify Camera Feed

1. Open Frigate UI: http://raspberrypi.local:5000
2. You should see the "doorbell" camera
3. Click on it to view the live feed
4. Check for person detection working

**✅ Checkpoint:** You should see live video from your Pi Zero camera!

## Step 8: Configure Detection Zones (Optional)

### 8.1 Access Zone Editor

1. In Frigate UI, go to Settings (gear icon)
2. Click on "doorbell" camera
3. Click "Edit Zone" or "Mask Editor"

### 8.2 Define Your Zone

1. Draw a polygon around your doorway/area of interest
2. Copy the coordinates
3. Update `config/frigate.yml`:

```bash
nano config/frigate.yml
```

Find the `zones` section (line 123) and update coordinates:
```yaml
zones:
  doorway:
    coordinates: 320,0,960,0,960,720,320,720  # Update with your coordinates
```

### 8.3 Restart Frigate

```bash
docker-compose restart frigate
```

## Step 9: Set Up Portainer (Optional)

1. Open Portainer: http://raspberrypi.local:9000
2. Create an admin account:
   - Username: `admin`
   - Password: Your secure password
3. Select "Get Started" with the local Docker environment
4. You can now manage all containers from the web UI

## Troubleshooting

### No Video in Frigate

**Check Pi Zero stream:**
```bash
# Test RTSP stream from Pi 5
ffplay rtsp://YOUR_PI_ZERO_IP:8554/camera
# Install ffmpeg if needed: sudo apt install -y ffmpeg
```

**Check Frigate logs:**
```bash
docker-compose logs frigate | tail -50
```

**Verify camera IP in config:**
```bash
grep "rtsp://" config/frigate.yml
# Should show your Pi Zero IP
```

### Containers Won't Start

**Check Docker status:**
```bash
sudo systemctl status docker
```

**Check logs for specific container:**
```bash
docker-compose logs mqtt
docker-compose logs frigate
```

**Restart specific container:**
```bash
docker-compose restart frigate
```

### High CPU Usage

**Lower detection FPS:**
Edit `config/frigate.yml`:
```yaml
detect:
  fps: 3  # Lower from 5
```

**Consider adding Coral TPU:**
- Significantly reduces CPU usage
- Improves detection speed
- See "Optional Enhancements" below

### Can't Access Web UI

**Check firewall (if enabled):**
```bash
sudo ufw status
# If active, allow ports:
sudo ufw allow 5000/tcp  # Frigate
sudo ufw allow 1880/tcp  # Node-RED
sudo ufw allow 9000/tcp  # Portainer
```

**Check container is running:**
```bash
docker ps | grep frigate
```

**Try IP address instead of hostname:**
```
http://192.168.1.50:5000
```

### Storage Issues

**Check disk space:**
```bash
df -h
```

**Clean up old recordings:**
Frigate automatically cleans based on retention settings, but you can manually clean:
```bash
sudo rm -rf storage/frigate/recordings/YYYY-MM-DD/*
```

## Performance Optimization

### Use SSD Instead of SD Card

**Dramatically improves performance:**
- Faster recording writes
- Better database performance
- Longer lifespan

### Enable Active Cooling

Monitor temperature:
```bash
vcgencmd measure_temp
```

If consistently above 60°C, ensure your cooling solution is working.

### Adjust Frigate Settings

In `config/frigate.yml`:

**Lower detection FPS:**
```yaml
detect:
  fps: 3  # Default is 5
```

**Reduce recording quality:**
```yaml
record:
  enabled: true
  retain:
    days: 3  # Reduce from 7
```

**Disable audio (if not needed):**
```yaml
audio:
  enabled: false
```

## Optional Enhancements

### Add Google Coral TPU

**Benefits:**
- 10-20x faster AI detection
- Significantly lower CPU usage
- Can handle more cameras

**Setup:**
1. Connect Coral USB to Pi 5
2. Edit `docker-compose.yml` (uncomment Coral lines)
3. Edit `config/frigate.yml`:
```yaml
detectors:
  coral:
    type: edgetpu
    device: usb
```
4. Restart: `docker-compose restart frigate`

### Enable MQTT Authentication

**Secure your MQTT broker:**

```bash
# Create password file
docker exec -it mqtt mosquitto_passwd -c /mosquitto/config/passwd frigate
# Enter password when prompted

# Update mosquitto.conf
nano config/mosquitto/mosquitto.conf
```

Add these lines:
```
allow_anonymous false
password_file /mosquitto/config/passwd
```

**Update Frigate config:**
```bash
nano config/frigate.yml
```

Uncomment and update MQTT credentials:
```yaml
mqtt:
  user: frigate
  password: your_mqtt_password
```

**Restart services:**
```bash
docker-compose restart mqtt frigate
```

### Set Up Remote Access

**Option 1: Port Forwarding** (Less secure)
- Forward port 5000 on your router to Pi 5
- Use DDNS for dynamic IP

**Option 2: VPN** (Recommended)
- Install WireGuard or Tailscale on Pi 5
- Connect via VPN to access locally

**Option 3: Cloudflare Tunnel** (Best for beginners)
- No port forwarding needed
- Free tier available
- Secure HTTPS access

### Add More Cameras

1. Set up additional Pi Zero devices
2. Add to `config/frigate.yml`:

```yaml
cameras:
  doorbell:
    # ... existing config ...
  
  backyard:
    enabled: true
    ffmpeg:
      inputs:
        - path: rtsp://192.168.1.101:8554/camera
          roles:
            - detect
            - record
    # ... similar config to doorbell ...
```

## Management Scripts

Use the provided scripts for easy management:

```bash
# Start all services
./scripts/start.sh

# Stop all services
./scripts/stop.sh

# View logs
./scripts/logs.sh frigate

# Update containers
./scripts/update.sh

# Backup configuration
./scripts/backup.sh
```

## Maintenance

### Daily
- Check Frigate UI for any errors
- Verify recordings are being saved

### Weekly
- Check disk space: `df -h`
- Review detection events
- Check for false positives/negatives

### Monthly
- Update Docker images:
  ```bash
  cd ~/doorbellcam
  docker-compose pull
  docker-compose up -d
  ```
- Update Pi OS:
  ```bash
  sudo apt update && sudo apt upgrade -y
  ```
- Backup configuration files

### Quarterly
- Review and adjust detection settings
- Clean up old recordings if needed
- Check system temperature and cooling

## Security Best Practices

1. **Change all default passwords**
   - Pi user password
   - Frigate RTSP password
   - Portainer admin password

2. **Enable MQTT authentication**
   - See "Enable MQTT Authentication" above

3. **Use firewall**
   ```bash
   sudo apt install -y ufw
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   sudo ufw allow ssh
   sudo ufw allow 5000/tcp  # Frigate
   sudo ufw allow 1880/tcp  # Node-RED
   sudo ufw allow 9000/tcp  # Portainer
   sudo ufw enable
   ```

4. **Keep systems updated**
   ```bash
   sudo apt update && sudo apt upgrade -y
   docker-compose pull && docker-compose up -d
   ```

5. **Use VPN for remote access**
   - Never expose Frigate directly to the internet
   - Use WireGuard or Tailscale

6. **Regular backups**
   ```bash
   ./scripts/backup.sh
   ```

## Next Steps

Now that your Pi 5 NVR is set up:

1. ✅ Verify camera feed is working
2. ⬜ Configure detection zones
3. ⬜ Set up notifications with Node-RED
4. ⬜ Configure mobile access
5. ⬜ Add Coral TPU (optional)
6. ⬜ Set up automated backups

## Resources

- **Frigate Documentation**: https://docs.frigate.video
- **Docker Documentation**: https://docs.docker.com
- **Node-RED Documentation**: https://nodered.org/docs
- **Mosquitto Documentation**: https://mosquitto.org/documentation

## Support

For issues:
1. Check logs: `docker-compose logs frigate`
2. Review Frigate docs: https://docs.frigate.video
3. Check GitHub issues
4. Community forums

---

**Congratulations!** Your Raspberry Pi 5 NVR is now set up and running! 🎉

You can now monitor your doorbell camera with AI-powered person detection, 24/7 recording, and a beautiful web interface.
