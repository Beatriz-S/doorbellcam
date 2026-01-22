# Ring-Like Doorbell Camera System

A complete DIY doorbell camera system using Raspberry Pi 5 and Pi Zero 2 W with AI-powered person detection.

## 🎯 Features

- **AI Person Detection** - Frigate NVR with TensorFlow object detection
- **24/7 Recording** - Continuous recording with smart retention
- **Low Latency Live View** - WebRTC for instant video access
- **MQTT Notifications** - Real-time alerts and automation
- **Modern Web UI** - Beautiful interface for monitoring and playback
- **Docker-Based** - Easy deployment and management

## 🏗️ Architecture

- **Raspberry Pi Zero 2 W**: Camera streaming (RTSP server)
- **Raspberry Pi 5**: NVR with Frigate, MQTT, Node-RED, and Portainer

## 🚀 Daily Usage (System Already Set Up)

**If your system is already installed and you just need to start it:**

👉 **[See STARTUP-GUIDE.md](STARTUP-GUIDE.md)** - Complete guide for:
- Starting/stopping both devices
- Accessing Frigate web UI
- Checking system status
- Troubleshooting common issues
- Quick command reference

**Quick start:** Just power on both devices, wait 2-3 minutes, then access Frigate at `http://YOUR_PI5_IP:5000`

---

## 📋 Initial Setup (First Time Installation)

### 1. Set Up Pi Zero 2 W (Camera)

See detailed instructions in [`pi-zero-setup/README.md`](pi-zero-setup/README.md)

```bash
# On Pi Zero 2 W
cd pi-zero-setup
sudo ./install-mediamtx.sh
sudo reboot
```

### 2. Set Up Pi 5 (NVR Server)

**Quick Start**: [`PI5-QUICK-START.md`](PI5-QUICK-START.md) - 20 minute setup  
**Detailed Guide**: [`PI5-SETUP.md`](PI5-SETUP.md) - Complete instructions  
**Original Guide**: [`SETUP.md`](SETUP.md) - Full system overview

```bash
# On Raspberry Pi 5
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Clone this repo
git clone https://github.com/yourusername/doorbellcam.git
cd doorbellcam

# Configure
cp env.template .env
nano .env  # Update with your settings
nano config/frigate.yml  # Update camera IP

# Start services
docker-compose up -d
```

### 3. Access Services

- **Frigate UI**: http://raspberrypi.local:5000
- **Node-RED**: http://raspberrypi.local:1880
- **Portainer**: http://raspberrypi.local:9000

## 📚 Documentation

### 📖 Documentation Guide - Which File Do I Need?

**Main Documentation:**

| File | Purpose | When to Use |
|------|---------|-------------|
| **[STARTUP-GUIDE.md](STARTUP-GUIDE.md)** | 🚀 Daily operations & troubleshooting | ⭐ System already set up - use this daily! |
| **[PI5-QUICK-START.md](PI5-QUICK-START.md)** | ⚡ Fast Pi 5 setup checklist | First time setup - want speed (20 min) |
| **[PI5-SETUP.md](PI5-SETUP.md)** | 📖 Complete Pi 5 guide | First time setup - want details & explanations |
| **[SETUP.md](SETUP.md)** | 🏗️ Full system overview | Understanding the complete architecture |
| **[pi-zero-setup/README.md](pi-zero-setup/README.md)** | 📷 Pi Zero camera setup | Setting up the camera device |
| **[ARCHITECTURE_COMPLIANCE.md](ARCHITECTURE_COMPLIANCE.md)** | 🏛️ Technical architecture | Understanding design decisions |

**Pi Zero Specific Documentation:**

| File | Purpose | When to Use |
|------|---------|-------------|
| **[pi-zero-setup/README.md](pi-zero-setup/README.md)** | 📷 Complete Pi Zero setup | Setting up camera streaming |
| **[pi-zero-setup/WORKING-CONFIG.md](pi-zero-setup/WORKING-CONFIG.md)** | ⚙️ Tested configurations | Reference working settings |
| **[pi-zero-setup/VIEWING-STREAM.md](pi-zero-setup/VIEWING-STREAM.md)** | 📺 Stream viewing methods | Testing camera stream |
| **[pi-zero-setup/LOW-LATENCY-GUIDE.md](pi-zero-setup/LOW-LATENCY-GUIDE.md)** | ⚡ Latency optimization | Reducing stream delay |

### 🎯 Quick Start Paths

**Path 1: Already Set Up?**
→ **[STARTUP-GUIDE.md](STARTUP-GUIDE.md)** (Daily operations)

**Path 2: First Time Setup?**
1. **[pi-zero-setup/README.md](pi-zero-setup/README.md)** (Set up camera)
2. **[PI5-QUICK-START.md](PI5-QUICK-START.md)** (Set up Pi 5 - fast) OR **[PI5-SETUP.md](PI5-SETUP.md)** (detailed)
3. **[STARTUP-GUIDE.md](STARTUP-GUIDE.md)** (Daily operations)

**Path 3: Want Full Understanding?**
→ **[SETUP.md](SETUP.md)** (Complete system overview)

### External Resources
- **[Frigate Documentation](https://docs.frigate.video)** - Official Frigate NVR docs
- **[MediaMTX Documentation](https://github.com/bluenviron/mediamtx)** - RTSP server docs
- **[Node-RED Documentation](https://nodered.org/docs/)** - Automation platform docs

## 🛠️ Management & Daily Operations

### Quick Commands

**On Pi 5:**
```bash
cd ~/doorbellcam

# Check status
docker compose ps

# Start all services
docker compose up -d

# Stop all services
docker compose down

# Restart Frigate
docker compose restart frigate

# View logs
docker compose logs -f frigate
```

**On Pi Zero:**
```bash
# Check camera service
sudo systemctl status mediamtx

# Restart camera
sudo systemctl restart mediamtx
```

### Management Scripts

```bash
# Start system
./scripts/start.sh

# Stop system
./scripts/stop.sh

# Update containers
./scripts/update.sh

# Backup configuration
./scripts/backup.sh

# View logs
./scripts/logs.sh frigate
```

📖 **[Full command reference in STARTUP-GUIDE.md](STARTUP-GUIDE.md)**

## 🔧 Configuration

### Main Configuration Files

- `docker-compose.yml` - Docker services configuration
- `config/frigate.yml` - Frigate NVR configuration
- `config/mosquitto/mosquitto.conf` - MQTT broker configuration
- `.env` - Environment variables

### Key Settings to Customize

1. **Camera IP** in `config/frigate.yml`:
   ```yaml
   cameras:
     doorbell:
       ffmpeg:
         inputs:
           - path: rtsp://YOUR_PI_ZERO_IP:8554/camera
   ```

2. **Timezone** in `config/frigate.yml`:
   ```yaml
   ui:
     timezone: America/New_York
   ```

3. **Detection Zones** - Use Frigate UI to define zones

## 🚀 Optional Enhancements

- **Google Coral TPU** - Add USB accelerator for 10x faster AI detection
- **Multiple Cameras** - Add more Pi Zero cameras
- **Audio Detection** - Enable audio event detection
- **Mobile Access** - Set up VPN or Cloudflare Tunnel
- **Home Assistant** - Integrate with Home Assistant

## 🔐 Security

- Change all default passwords
- Enable MQTT authentication
- Use VPN for remote access
- Keep systems updated
- Regular backups

## 📊 System Requirements

### Raspberry Pi 5 (NVR)
- 4GB+ RAM recommended
- 64GB+ storage (SSD recommended)
- Active cooling recommended
- Optional: Google Coral USB Accelerator

### Raspberry Pi Zero 2 W (Camera)
- 16GB+ microSD card
- Camera Module v2 or v3
- Optional: USB microphone

## 🐛 Troubleshooting

See the [Complete Setup Guide](SETUP.md#troubleshooting) for detailed troubleshooting steps.

Common issues:
- **No video**: Check Pi Zero stream and camera IP
- **High CPU**: Lower detection FPS or add Coral TPU
- **False detections**: Adjust thresholds and zones
- **Can't access UI**: Check Docker containers and firewall

## 📝 License

This project uses open-source components:
- Frigate (MIT License)
- MediaMTX (MIT License)
- Mosquitto (EPL/EDL License)
- Node-RED (Apache 2.0 License)

## 🙏 Acknowledgments

- [Frigate NVR](https://github.com/blakeblackshear/frigate) by Blake Blackshear
- [MediaMTX](https://github.com/bluenviron/mediamtx) by bluenviron
- [Eclipse Mosquitto](https://mosquitto.org/)
- [Node-RED](https://nodered.org/)

## 📧 Support

For issues and questions:
1. Check the [Setup Guide](SETUP.md) and [Troubleshooting](SETUP.md#troubleshooting)
2. Review [Frigate Documentation](https://docs.frigate.video)
3. Open an issue on GitHub

---

**Made with ❤️ for the DIY home automation community**
