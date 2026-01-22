# Doorbell Camera System - Startup Guide

Quick reference for starting and managing your doorbell camera system.

## 🚀 Quick Start (Both Devices)

### Power On Sequence

1. **Power on Pi Zero 2 W** (Camera)
   - Wait 1-2 minutes for boot
   - MediaMTX starts automatically

2. **Power on Raspberry Pi 5** (NVR)
   - Wait 1-2 minutes for boot
   - Docker containers start automatically

3. **Access Frigate**
   - Open browser: `http://YOUR_PI5_IP:5000`
   - You should see your camera feed!

**That's it!** Everything should start automatically. If not, see troubleshooting below.

---

## 📷 Pi Zero 2 W (Camera Device)

### What Runs Automatically
- **MediaMTX** - RTSP streaming service
- Starts on boot automatically
- Streams camera at: `rtsp://10.0.0.18:8554/camera`

### Check Status

```bash
# SSH into Pi Zero
ssh pi@10.0.0.18

# Check MediaMTX service
sudo systemctl status mediamtx
```

**Expected output:** `active (running)`

### Start/Stop/Restart

```bash
# Start MediaMTX
sudo systemctl start mediamtx

# Stop MediaMTX
sudo systemctl stop mediamtx

# Restart MediaMTX
sudo systemctl restart mediamtx

# View logs
sudo journalctl -u mediamtx -f
```

### Test Camera Stream

From any computer on your network:

```bash
# Using ffplay
ffplay rtsp://10.0.0.18:8554/camera

# Using VLC
vlc rtsp://10.0.0.18:8554/camera
```

Or use the Windows batch file:
```
pi-zero-setup\watch-camera-ffplay.bat
```

---

## 🖥️ Raspberry Pi 5 (NVR Server)

### What Runs Automatically
- **Frigate** - AI video processing (Port 5000)
- **MQTT** - Message broker (Port 1883)
- **Node-RED** - Automation (Port 1880)
- **Portainer** - Docker management (Port 9000)

All Docker containers start on boot automatically.

### Check Status

```bash
# SSH into Pi 5
ssh pi@raspberrypi.local

# Navigate to project
cd ~/doorbellcam

# Check all containers
docker compose ps
```

**Expected output:** All 4 containers showing "Up"

```
NAME        STATUS
frigate     Up X minutes (healthy)
mqtt        Up X minutes
nodered     Up X minutes (healthy)
portainer   Up X minutes
```

### Start All Services

```bash
cd ~/doorbellcam
docker compose up -d
```

### Stop All Services

```bash
cd ~/doorbellcam
docker compose down
```

### Restart Specific Service

```bash
# Restart Frigate
docker compose restart frigate

# Restart all services
docker compose restart
```

### View Logs

```bash
# View Frigate logs
docker compose logs frigate

# Follow logs in real-time
docker compose logs -f frigate

# View last 50 lines
docker compose logs frigate --tail 50

# View all service logs
docker compose logs
```

### Using the Management Scripts

```bash
cd ~/doorbellcam

# Start system
./scripts/start.sh

# Stop system
./scripts/stop.sh

# View logs
./scripts/logs.sh frigate

# Update containers
./scripts/update.sh
```

---

## 🌐 Access Web Interfaces

### Find Your Pi 5 IP Address

```bash
# On Pi 5
hostname -I
```

Example output: `10.0.0.25`

### Web URLs

Replace `YOUR_PI5_IP` with the actual IP address:

| Service | URL | Purpose |
|---------|-----|---------|
| **Frigate** | http://YOUR_PI5_IP:5000 | Main camera interface |
| **Node-RED** | http://YOUR_PI5_IP:1880 | Automation flows |
| **Portainer** | http://YOUR_PI5_IP:9000 | Docker management |

Or use hostname (if your network supports it):
- http://raspberrypi.local:5000
- http://raspberrypi.local:1880
- http://raspberrypi.local:9000

---

## ✅ System Health Check

### Complete Verification

Run these checks to ensure everything is working:

#### 1. Check Pi Zero Camera
```bash
# From Pi 5 or Windows
ffplay rtsp://10.0.0.18:8554/camera
```
✅ You should see live video (press Q to quit)

#### 2. Check Pi 5 Containers
```bash
# On Pi 5
cd ~/doorbellcam
docker compose ps
```
✅ All 4 containers should show "Up"

#### 3. Check Frigate Web UI
- Open: http://YOUR_PI5_IP:5000
- ✅ Should load Frigate interface
- ✅ Should see "doorbell" camera
- ✅ Click camera to see live video

#### 4. Check Person Detection
- Walk in front of camera
- ✅ Should see detection box around you
- ✅ Check Events tab in Frigate

---

## 🔧 Troubleshooting

### Pi Zero Issues

#### Camera Not Streaming

```bash
# SSH into Pi Zero
ssh pi@10.0.0.18

# Check MediaMTX status
sudo systemctl status mediamtx

# View logs
sudo journalctl -u mediamtx -n 50

# Restart service
sudo systemctl restart mediamtx

# Test camera hardware
libcamera-hello --list-cameras
```

#### Can't SSH into Pi Zero

- Check power supply (needs 5V 2.5A)
- Check network connection
- Try IP address instead of hostname
- Check router for device "doorbell-camera" or "raspberrypi"

### Pi 5 Issues

#### Containers Not Running

```bash
# Check Docker service
sudo systemctl status docker

# Start Docker
sudo systemctl start docker

# Start containers
cd ~/doorbellcam
docker compose up -d

# Check logs for errors
docker compose logs
```

#### Frigate Won't Start

```bash
# View Frigate logs
docker compose logs frigate --tail 50

# Common fixes:
# 1. Check config syntax
docker compose config

# 2. Restart Frigate
docker compose restart frigate

# 3. Check camera connection
ffplay rtsp://10.0.0.18:8554/camera
```

#### Can't Access Web UI

1. **Check firewall:**
   ```bash
   sudo ufw status
   sudo ufw allow 5000/tcp
   ```

2. **Verify container is running:**
   ```bash
   docker ps | grep frigate
   ```

3. **Try IP address instead of hostname**

4. **Check from Pi 5 itself:**
   ```bash
   curl http://localhost:5000
   ```

#### High CPU Usage

Edit `config/frigate.yml`:
```yaml
detect:
  fps: 3  # Lower from 5
```

Then restart:
```bash
docker compose restart frigate
```

### Network Issues

#### Find Device IP Addresses

```bash
# On Pi Zero
hostname -I

# On Pi 5
hostname -I

# From Windows (scan network)
arp -a
```

#### Test Network Connectivity

```bash
# From Pi 5, ping Pi Zero
ping 10.0.0.18

# From Pi Zero, ping Pi 5
ping 10.0.0.25  # Use your Pi 5 IP
```

---

## 🔄 Daily Operations

### Normal Startup
1. Power on both devices
2. Wait 2-3 minutes
3. Access Frigate: http://YOUR_PI5_IP:5000
4. Verify camera feed is working

### Normal Shutdown
1. On Pi 5: `cd ~/doorbellcam && docker compose down`
2. On Pi 5: `sudo shutdown now`
3. On Pi Zero: `sudo shutdown now`
4. Wait 30 seconds, then disconnect power

### Restart After Power Loss
1. Simply power on both devices
2. Wait 2-3 minutes for auto-start
3. Verify services are running

---

## 📊 Monitoring

### Check Disk Space

```bash
# On Pi 5
df -h

# Check Frigate storage
du -sh ~/doorbellcam/storage/frigate
```

### Check System Resources

```bash
# CPU temperature
vcgencmd measure_temp

# Memory usage
free -h

# Top processes
htop
```

### View Recording Storage

In Frigate UI:
- Go to Settings → Storage
- See disk usage and retention

---

## 🔐 Important Information

### Device Information

| Device | IP Address | Hostname | Username |
|--------|------------|----------|----------|
| Pi Zero | 10.0.0.18 | doorbell-camera | pi |
| Pi 5 | (your IP) | raspberrypi | silentwatchtower |

### Stream URLs

- **Direct from Pi Zero:** `rtsp://10.0.0.18:8554/camera`
- **Through Frigate (go2rtc):** `rtsp://YOUR_PI5_IP:8554/doorbell`

### Configuration Files

Located on Pi 5 in `~/doorbellcam/`:
- `config/frigate.yml` - Main Frigate config
- `docker-compose.yml` - Docker services
- `.env` - Environment variables (contains passwords)

### Passwords

- **Frigate RTSP Password:** Set in `.env` file
- **MQTT:** No authentication by default (can be enabled)
- **Portainer:** Set on first login

---

## 🆘 Quick Commands Reference

### Pi Zero Commands

```bash
# SSH into Pi Zero
ssh pi@10.0.0.18

# Check camera service
sudo systemctl status mediamtx

# Restart camera service
sudo systemctl restart mediamtx

# View camera logs
sudo journalctl -u mediamtx -f

# Reboot Pi Zero
sudo reboot
```

### Pi 5 Commands

```bash
# SSH into Pi 5
ssh pi@raspberrypi.local

# Go to project
cd ~/doorbellcam

# Check containers
docker compose ps

# Start all services
docker compose up -d

# Stop all services
docker compose down

# Restart Frigate
docker compose restart frigate

# View Frigate logs
docker compose logs -f frigate

# Get IP address
hostname -I

# Reboot Pi 5
sudo reboot
```

---

## 📱 Mobile Access

### Local Network Only (Default)
Access Frigate from any device on your network:
- http://YOUR_PI5_IP:5000

### Remote Access (Optional)
For access from outside your home network:
1. **VPN (Recommended):** Set up WireGuard or Tailscale
2. **Port Forwarding:** Forward port 5000 (less secure)
3. **Cloudflare Tunnel:** Secure remote access without port forwarding

See [PI5-SETUP.md](PI5-SETUP.md#set-up-remote-access) for details.

---

## 🎯 Next Steps

Once everything is running:

- [ ] Configure detection zones in Frigate
- [ ] Set up notifications with Node-RED
- [ ] Adjust recording retention settings
- [ ] Consider adding Google Coral TPU
- [ ] Set up automated backups
- [ ] Configure mobile access

See [SETUP.md](SETUP.md) for complete configuration guide.

---

## 📚 Additional Documentation

- **[Complete Setup Guide](SETUP.md)** - Full system setup
- **[Pi 5 Setup Guide](PI5-SETUP.md)** - Detailed Pi 5 instructions
- **[Pi 5 Quick Start](PI5-QUICK-START.md)** - Fast Pi 5 setup
- **[Pi Zero Setup](pi-zero-setup/README.md)** - Camera setup guide
- **[Frigate Documentation](https://docs.frigate.video)** - Official Frigate docs

---

## 💡 Tips

1. **Bookmark Frigate URL** on your phone/computer
2. **Check disk space weekly** with `df -h`
3. **Update monthly** with `docker compose pull && docker compose up -d`
4. **Keep Pi 5 cool** - use active cooling for best performance
5. **Use SSD on Pi 5** instead of SD card for better reliability
6. **Backup config files** regularly with `./scripts/backup.sh`

---

**System Status Quick Check:**
```bash
# One-liner to check everything (run on Pi 5)
echo "=== Pi Zero Stream ===" && \
timeout 2 ffmpeg -i rtsp://10.0.0.18:8554/camera -frames:v 1 -f null - 2>&1 | grep -i "Stream" && \
echo "=== Docker Containers ===" && \
docker compose ps && \
echo "=== Frigate Health ===" && \
curl -s http://localhost:5000/api/version | python3 -m json.tool
```

---

**Made with ❤️ for easy home surveillance**
