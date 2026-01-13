# Raspberry Pi Zero 2 W Setup Guide

This directory contains scripts to set up your Raspberry Pi Zero 2 W as a camera streaming device for the doorbell system.

## Prerequisites

- Raspberry Pi Zero 2 W
- Raspberry Pi Camera Module (v2 or v3 recommended)
- MicroSD card (16GB+ recommended)
- USB microphone (optional, for audio)
- Power supply
- Network connection (WiFi or Ethernet adapter)

## Initial Setup

### 1. Install Raspberry Pi OS

1. Download and install [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
2. Flash **Raspberry Pi OS Lite (64-bit)** to your microSD card
3. Before ejecting, enable SSH:
   - Create an empty file named `ssh` in the boot partition
4. Configure WiFi (optional):
   - Create `wpa_supplicant.conf` in the boot partition:
   ```
   country=US
   ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
   update_config=1
   
   network={
       ssid="YourWiFiName"
       psk="YourWiFiPassword"
   }
   ```

### 2. Connect Camera Module

1. Power off the Pi Zero
2. Connect the camera ribbon cable to the camera port
3. Ensure the blue side faces the Ethernet port
4. Power on the Pi Zero

### 3. Initial Configuration

SSH into your Pi Zero:
```bash
ssh pi@raspberrypi.local
# Default password: raspberry
```

Change the default password:
```bash
passwd
```

Set hostname (optional):
```bash
sudo raspi-config
# System Options > Hostname > doorbell-camera
```

### 4. Copy Setup Scripts

From your main computer, copy the setup scripts to the Pi Zero:
```bash
scp -r pi-zero-setup pi@raspberrypi.local:~/
```

Or manually create the files on the Pi Zero.

## Installation Options

You have two options for streaming: **MediaMTX (Recommended)** or **FFmpeg**.

### Option A: MediaMTX (Recommended)

MediaMTX is more efficient and has better performance on the Pi Zero.

```bash
cd ~/pi-zero-setup
sudo chmod +x install-mediamtx.sh
sudo ./install-mediamtx.sh
```

### Option B: FFmpeg

FFmpeg is simpler but uses more CPU.

```bash
cd ~/pi-zero-setup
sudo chmod +x install-camera-stream.sh
sudo ./install-camera-stream.sh
```

## Testing

### Test Camera Hardware

```bash
cd ~/pi-zero-setup
chmod +x test-camera.sh
./test-camera.sh
```

### Test RTSP Stream

After installation and reboot, test the stream from another computer:

```bash
# Using ffplay (part of ffmpeg)
ffplay rtsp://RASPBERRY_PI_IP:8554/camera

# Using VLC
vlc rtsp://RASPBERRY_PI_IP:8554/camera
```

Replace `RASPBERRY_PI_IP` with your Pi Zero's IP address.

## Service Management

### Start/Stop/Restart Service

For MediaMTX:
```bash
sudo systemctl start mediamtx
sudo systemctl stop mediamtx
sudo systemctl restart mediamtx
sudo systemctl status mediamtx
```

For FFmpeg:
```bash
sudo systemctl start doorbell-camera
sudo systemctl stop doorbell-camera
sudo systemctl restart doorbell-camera
sudo systemctl status doorbell-camera
```

### View Logs

For MediaMTX:
```bash
sudo journalctl -u mediamtx -f
```

For FFmpeg:
```bash
sudo journalctl -u doorbell-camera -f
```

## Configuration

### MediaMTX Configuration

Edit `/opt/mediamtx/mediamtx.yml`:
```bash
sudo nano /opt/mediamtx/mediamtx.yml
```

Key settings:
- `rpiCameraWidth`: Video width (default: 1280)
- `rpiCameraHeight`: Video height (default: 720)
- `rpiCameraFPS`: Frame rate (default: 15)
- `rpiCameraBitrate`: Bitrate in bps (default: 1000000)

### FFmpeg Configuration

Edit `/opt/doorbell-camera/stream-camera.sh`:
```bash
sudo nano /opt/doorbell-camera/stream-camera.sh
```

Key settings:
- `VIDEO_WIDTH`: Video width
- `VIDEO_HEIGHT`: Video height
- `VIDEO_FPS`: Frame rate
- `VIDEO_BITRATE`: Bitrate
- `AUDIO_ENABLED`: Enable/disable audio

After changes, restart the service:
```bash
sudo systemctl restart mediamtx  # or doorbell-camera
```

## Troubleshooting

### Camera Not Detected

1. Check camera connection
2. Enable camera interface:
   ```bash
   sudo raspi-config
   # Interface Options > Camera > Enable
   ```
3. Reboot: `sudo reboot`

### Stream Not Working

1. Check service status:
   ```bash
   sudo systemctl status mediamtx  # or doorbell-camera
   ```
2. View logs:
   ```bash
   sudo journalctl -u mediamtx -n 50  # or doorbell-camera
   ```
3. Check firewall:
   ```bash
   sudo ufw allow 8554/tcp
   ```

### Poor Performance

1. Lower resolution (720p → 480p)
2. Reduce frame rate (15 → 10 fps)
3. Lower bitrate
4. Disable audio if not needed

### Network Issues

Check IP address:
```bash
hostname -I
```

Test network connectivity:
```bash
ping 8.8.8.8
```

## Getting the Pi Zero IP Address

```bash
hostname -I
```

Or from your router's admin panel, look for "doorbell-camera" in connected devices.

## Next Steps

Once your Pi Zero is streaming, update the Frigate configuration on your Raspberry Pi 5:

1. Edit `config/frigate.yml`
2. Update the camera RTSP path:
   ```yaml
   cameras:
     doorbell:
       ffmpeg:
         inputs:
           - path: rtsp://YOUR_PI_ZERO_IP:8554/camera
   ```
3. Restart Frigate

## Security Recommendations

1. Change default passwords
2. Enable authentication in MediaMTX (edit mediamtx.yml)
3. Use a firewall to restrict access
4. Keep system updated:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
