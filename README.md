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

## 📋 Quick Start

### 1. Set Up Pi Zero 2 W (Camera)

See detailed instructions in [`pi-zero-setup/README.md`](pi-zero-setup/README.md)

```bash
# On Pi Zero 2 W
cd pi-zero-setup
sudo ./install-mediamtx.sh
sudo reboot
```

### 2. Set Up Pi 5 (NVR Server)

See complete guide in [`SETUP.md`](SETUP.md)

```bash
# On Raspberry Pi 5
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Clone this repo
git clone https://github.com/yourusername/doorbellcam.git
cd doorbellcam

# Configure
cp .env.example .env
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

- **[Complete Setup Guide](SETUP.md)** - Detailed step-by-step instructions
- **[Pi Zero Setup](pi-zero-setup/README.md)** - Camera streaming setup
- **[Architecture Compliance](ARCHITECTURE_COMPLIANCE.md)** - How we follow Frigate best practices
- **[Frigate Documentation](https://docs.frigate.video)** - Official Frigate docs

## 🛠️ Management Scripts

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
