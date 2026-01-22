# How to View the Camera Stream

This guide explains how to start the camera on your Raspberry Pi Zero and view the stream on your Windows computer.

## Step 1: Start the Camera on Raspberry Pi Zero

SSH into your Raspberry Pi Zero:

```bash
ssh spotter@raspberrypi
```

### Start MediaMTX Service

```bash
# Start the camera streaming service
sudo systemctl start mediamtx

# Check if it's running
sudo systemctl status mediamtx

# View live logs (optional)
sudo journalctl -u mediamtx -f
```

Press `Ctrl+C` to exit the logs view.

### Enable Auto-Start on Boot (Optional)

To have the camera start automatically when the Pi boots:

```bash
sudo systemctl enable mediamtx
```

## Step 2: Get Your Pi Zero's IP Address

On the Raspberry Pi Zero, run:

```bash
hostname -I
```

This will show your IP address (e.g., `10.0.0.18`). Make note of this.

## Step 3: View the Stream on Windows

You have multiple options to view the stream:

### Option A: Use the ffplay Batch File (Recommended - Lowest Latency)

1. Make sure ffmpeg is installed on Windows:
   - Via winget: `winget install ffmpeg`
   - Via chocolatey: `choco install ffmpeg`
   - Or download from: https://ffmpeg.org/download.html

2. If your Pi's IP is different from `10.0.0.18`, edit the batch file:
   - Right-click `watch-camera-ffplay.bat` → Edit
   - Change the line: `set CAMERA_IP=10.0.0.18` to your actual IP

3. Double-click `watch-camera-ffplay.bat`

**Controls:**
- `Q` or `ESC`: Quit
- `F`: Toggle fullscreen
- `P` or `SPACE`: Pause

### Option B: Use the VLC Batch File

1. Install VLC from https://www.videolan.org/

2. If your Pi's IP is different from `10.0.0.18`, edit the batch file:
   - Right-click `watch-camera-lowlatency.bat` → Edit
   - Change the line: `set CAMERA_IP=10.0.0.18` to your actual IP

3. Double-click `watch-camera-lowlatency.bat`

### Option C: Manually Open in VLC

1. Open VLC Media Player
2. Go to **Media** → **Open Network Stream**
3. Enter the URL: `rtsp://YOUR_PI_IP:8554/camera`
   - Replace `YOUR_PI_IP` with your Pi Zero's IP address
   - Example: `rtsp://10.0.0.18:8554/camera`
4. Click **Play**

For better latency, add these options:
- Network Caching: 300ms
- Use RTSP over TCP

## Troubleshooting

### Camera Not Streaming

Check if MediaMTX is running:

```bash
sudo systemctl status mediamtx
```

If it's not active, start it:

```bash
sudo systemctl start mediamtx
```

Check the logs for errors:

```bash
sudo journalctl -u mediamtx -n 50
```

### Cannot Connect to Stream

1. **Verify the Pi's IP address:**
   ```bash
   hostname -I
   ```

2. **Test network connectivity from Windows:**
   ```cmd
   ping YOUR_PI_IP
   ```

3. **Check if port 8554 is open on the Pi:**
   ```bash
   sudo ufw allow 8554/tcp
   ```

### Poor Video Quality / Packet Loss

If you see warnings about "RTP packets lost" in the logs, or the stream stutters:

1. **Lower the video resolution/bitrate:**
   ```bash
   sudo nano /opt/mediamtx/mediamtx.yml
   ```

2. **Find and adjust these settings:**
   ```yaml
   rpiCameraWidth: 640        # Lower from 1280
   rpiCameraHeight: 480       # Lower from 720
   rpiCameraFPS: 10           # Lower from 15
   rpiCameraBitrate: 500000   # Lower from 1000000
   ```

3. **Restart MediaMTX:**
   ```bash
   sudo systemctl restart mediamtx
   ```

4. **Check WiFi signal strength:**
   ```bash
   iwconfig wlan0 | grep -i signal
   ```

### Stream Has High Latency

- Use the `watch-camera-ffplay.bat` script (lowest latency)
- Or add `--rtsp-tcp --network-caching=300` when using VLC
- Make sure you're on the same network as the Pi Zero
- Consider using a wired Ethernet connection if possible

## Managing the Camera Service

### Stop the Camera

```bash
sudo systemctl stop mediamtx
```

### Restart the Camera

```bash
sudo systemctl restart mediamtx
```

### Disable Auto-Start on Boot

```bash
sudo systemctl disable mediamtx
```

### View Recent Logs

```bash
sudo journalctl -u mediamtx -n 50
```

### View Live Logs

```bash
sudo journalctl -u mediamtx -f
```

## Stream URL

The RTSP stream is available at:

```
rtsp://YOUR_PI_ZERO_IP:8554/camera
```

This URL can be used by:
- VLC Media Player
- ffplay
- Frigate (for recording/AI detection)
- Any RTSP-compatible video player

## Next Steps

Once your camera is streaming reliably, you can:
1. Configure Frigate on your Raspberry Pi 5 to connect to this stream
2. Set up motion detection and recording
3. Configure push notifications for detected events

See the main [README.md](../README.md) for the complete system setup.
