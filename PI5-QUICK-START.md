# Raspberry Pi 5 - Quick Start Checklist

Follow this checklist to get your Pi 5 NVR server up and running quickly!

## 📋 Pre-Setup Checklist

- [ ] Pi Zero is set up and streaming at `rtsp://YOUR_IP:8554/camera`
- [ ] You know your Pi Zero's IP address (e.g., 192.168.1.100)
- [ ] Pi 5 has Raspberry Pi OS installed
- [ ] You can SSH into your Pi 5
- [ ] Internet connection is working

## 🚀 Quick Setup (20-30 minutes)

### 1. Connect to Pi 5
```bash
ssh pi@raspberrypi.local
```

### 2. Update System
```bash
sudo apt update && sudo apt upgrade -y
sudo reboot
```
⏱️ Wait 1-2 minutes, then SSH back in

### 3. Install Docker
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt-get install -y docker-compose

# Enable Docker
sudo systemctl enable docker

# Log out and back in
exit
```
SSH back in: `ssh pi@raspberrypi.local`

### 4. Get the Project Files

**Option A: If files are on GitHub**
```bash
cd ~
git clone https://github.com/yourusername/doorbellcam.git
cd doorbellcam
```

**Option B: Transfer from Windows**

From Windows PowerShell:
```powershell
cd C:\Users\santos\Desktop\Github\doorbellcam
scp -r * pi@raspberrypi.local:~/doorbellcam/
```

Then on Pi 5:
```bash
cd ~/doorbellcam
```

### 5. Create Directories
```bash
mkdir -p storage/{frigate,mosquitto/{data,log},nodered,portainer}
sudo chown -R 1883:1883 storage/mosquitto
sudo chown -R 1000:1000 storage/nodered
```

### 6. Configure Environment
```bash
# Create environment file
cp env.template .env

# Edit with your settings
nano .env
```

**Update these 3 things:**
1. `TZ=America/New_York` → Your timezone
2. `FRIGATE_RTSP_PASSWORD=` → A secure password
3. `DOORBELL_CAMERA_IP=192.168.1.100` → Your Pi Zero IP

Save: `Ctrl+X` → `Y` → `Enter`

### 7. Update Frigate Config
```bash
nano config/frigate.yml
```

**Update line 14:**
```yaml
- rtsp://YOUR_PI_ZERO_IP:8554/camera
```
Change `YOUR_PI_ZERO_IP` to your actual Pi Zero IP (e.g., 192.168.1.100)

**Update line 163:**
```yaml
timezone: America/New_York
```
Change to your timezone

Save: `Ctrl+X` → `Y` → `Enter`

### 8. Start Everything!
```bash
# Pull Docker images (5-10 minutes)
docker-compose pull

# Start all services
docker-compose up -d

# Check status
docker-compose ps
```

All containers should show "Up"!

### 9. Access Web UI

Find your Pi 5 IP:
```bash
hostname -I
```

Open in browser:
- **Frigate**: http://raspberrypi.local:5000
- **Node-RED**: http://raspberrypi.local:1880
- **Portainer**: http://raspberrypi.local:9000

Or use IP: http://192.168.1.50:5000 (replace with your IP)

### 10. Verify Camera Feed

1. Open Frigate UI
2. You should see "doorbell" camera
3. Click on it to see live video
4. Check that person detection is working!

## ✅ Success!

If you can see your camera feed in Frigate, congratulations! Your NVR is working!

## 🔧 Quick Troubleshooting

### No video in Frigate?

**Test Pi Zero stream:**
```bash
# On Pi 5
ffplay rtsp://YOUR_PI_ZERO_IP:8554/camera
# Install ffmpeg if needed: sudo apt install -y ffmpeg
```

**Check Frigate logs:**
```bash
docker-compose logs frigate | tail -50
```

**Verify IP in config:**
```bash
grep "rtsp://" config/frigate.yml
```

### Containers won't start?

```bash
# Check Docker status
sudo systemctl status docker

# View logs
docker-compose logs

# Restart a container
docker-compose restart frigate
```

### Can't access web UI?

1. Check container is running:
   ```bash
   docker ps | grep frigate
   ```

2. Try IP address instead of hostname:
   ```
   http://192.168.1.50:5000
   ```

3. Check firewall (if enabled):
   ```bash
   sudo ufw status
   sudo ufw allow 5000/tcp
   ```

## 📖 Next Steps

- [ ] Configure detection zones in Frigate UI
- [ ] Set up notifications with Node-RED
- [ ] Configure mobile access (VPN recommended)
- [ ] Consider adding Google Coral TPU for better performance
- [ ] Set up automated backups

## 📚 Full Documentation

For detailed information, see:
- **Complete Pi 5 Guide**: [PI5-SETUP.md](PI5-SETUP.md)
- **Full Setup Guide**: [SETUP.md](SETUP.md)
- **Pi Zero Setup**: [pi-zero-setup/README.md](pi-zero-setup/README.md)

## 🆘 Need Help?

1. Check logs: `docker-compose logs frigate`
2. Review [PI5-SETUP.md](PI5-SETUP.md) troubleshooting section
3. Check Frigate docs: https://docs.frigate.video

## 🎯 Management Commands

```bash
# Start system
./scripts/start.sh

# Stop system
./scripts/stop.sh

# View logs
./scripts/logs.sh frigate

# Update containers
./scripts/update.sh

# Backup config
./scripts/backup.sh
```

---

**Total Setup Time**: 20-30 minutes  
**Difficulty**: Beginner-Friendly  
**Result**: Professional-grade AI doorbell camera system! 🎉
