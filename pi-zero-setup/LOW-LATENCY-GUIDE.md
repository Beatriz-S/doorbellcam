# Low Latency Streaming Guide

This guide explains how to reduce delay/latency when viewing the camera stream.

## Quick Fixes (Test These First!)

### 1. VLC Player Settings (Windows)

#### Method 1: GUI (Easiest)
1. Open VLC → Media → Open Network Stream
2. Enter: `rtsp://10.0.0.18:8554/camera`
3. Check "Show more options" at the bottom
4. Set **Caching** to `0 ms` (or 100-300 ms if stuttering occurs)
5. Click Play

#### Method 2: Command Line (Best Performance)
```powershell
vlc rtsp://10.0.0.18:8554/camera --network-caching=0 --rtsp-tcp --no-audio
```

#### Method 3: Permanent VLC Settings
1. Tools → Preferences
2. Show settings: **All**
3. Input / Codecs → Network
4. Set "Network caching" to `0` ms
5. Save and restart VLC

### 2. FFplay (Part of FFmpeg) - Lower Latency Alternative

If you have ffmpeg installed on Windows:
```powershell
ffplay -fflags nobuffer -flags low_delay -framedrop -strict experimental rtsp://10.0.0.18:8554/camera
```

## Apply Optimized Configuration to Pi Zero

The configuration files have been updated with low-latency optimizations. To apply them:

### If Using MediaMTX (Recommended):

1. **SSH into your Pi Zero:**
   ```bash
   ssh pi@10.0.0.18
   ```

2. **Backup current config:**
   ```bash
   sudo cp /opt/mediamtx/mediamtx.yml /opt/mediamtx/mediamtx.yml.backup
   ```

3. **Copy the new config from this repo:**
   ```bash
   cd ~/pi-zero-setup
   sudo cp mediamtx-usb.yml /opt/mediamtx/mediamtx.yml
   ```

4. **Restart the service:**
   ```bash
   sudo systemctl restart mediamtx
   ```

5. **Check status:**
   ```bash
   sudo systemctl status mediamtx
   ```

### If Using FFmpeg Directly:

1. **SSH into your Pi Zero:**
   ```bash
   ssh pi@10.0.0.18
   ```

2. **Backup current script:**
   ```bash
   sudo cp /opt/doorbell-camera/stream-camera.sh /opt/doorbell-camera/stream-camera.sh.backup
   ```

3. **Copy the new script:**
   ```bash
   cd ~/pi-zero-setup
   sudo cp stream-camera.sh /opt/doorbell-camera/stream-camera.sh
   sudo chmod +x /opt/doorbell-camera/stream-camera.sh
   ```

4. **Restart the service:**
   ```bash
   sudo systemctl restart doorbell-camera
   ```

## What These Optimizations Do

### FFmpeg Parameters Explained:

| Parameter | What It Does |
|-----------|-------------|
| `-preset ultrafast` | Fastest encoding (less CPU, lower compression) |
| `-tune zerolatency` | Removes encoding delays |
| `-profile:v baseline` | Simple H.264 profile for faster decoding |
| `-g 15` | Keyframe every 15 frames (1 second at 15fps) |
| `-keyint_min 15` | Minimum keyframe interval |
| `-sc_threshold 0` | Disable scene change detection |
| `-bufsize 500k` | Small buffer (less buffering delay) |
| `-probesize 32` | Quick format detection |
| `-analyzeduration 0` | Skip stream analysis |
| `-fflags nobuffer` | Disable input buffering |
| `-flags low_delay` | Enable low delay mode |
| `-maxrate 1000k` | Prevent bitrate spikes |

### MediaMTX Parameters:
- `readBufferCount: 256` - Reduced from 512 for lower latency

## Expected Results

With these optimizations, you should see:
- **Delay reduced to**: ~0.5-1.5 seconds (from typical 3-5+ seconds)
- **Current working config**: 640x480 @ 10fps with hardware encoding
- **Trade-offs**: 
  - Lower resolution (640x480 instead of 1280x720) for Pi Zero performance
  - Hardware encoding is very efficient (low CPU usage)
  - Potentially more frame drops under poor network conditions

## Note on Pi Zero 2 W Performance

The Pi Zero 2 W has limited CPU power. The working configuration uses:
- **Hardware encoding** (h264_v4l2m2m) - Uses GPU instead of CPU
- **640x480 resolution** - Balanced quality/performance
- **10 fps** - Smooth enough for doorbell monitoring
- **500 kbps bitrate** - Good quality at this resolution

If you need higher resolution/framerate, consider upgrading to a Raspberry Pi 4 or 5.

## Troubleshooting

### If Video Stutters/Freezes:

1. **Increase VLC caching slightly:**
   - Try 200ms, then 500ms if needed

2. **Reduce resolution on Pi Zero:**
   ```bash
   sudo nano /opt/mediamtx/mediamtx.yml
   # Change: -video_size 1280x720 to -video_size 640x480
   sudo systemctl restart mediamtx
   ```

3. **Lower frame rate:**
   ```bash
   # Change: -framerate 15 to -framerate 10
   ```

### If Delay Still Too High:

1. **Check network latency:**
   ```powershell
   ping 10.0.0.18
   ```
   - Should be <10ms on local network

2. **Use wired connection** instead of WiFi if possible

3. **Try UDP instead of TCP** (less reliable but lower latency):
   ```bash
   vlc rtsp://10.0.0.18:8554/camera --network-caching=0 --rtsp-udp
   ```

### If CPU Usage Too High on Pi Zero:

1. **Lower resolution** (1280x720 → 640x480)
2. **Lower frame rate** (15fps → 10fps)
3. **Lower bitrate** (1000k → 750k)

## Testing & Verification

1. **Check current delay:**
   - Wave your hand in front of camera
   - Note the delay on screen
   - Should be ~0.5-1.5 seconds with optimizations

2. **Monitor Pi Zero CPU:**
   ```bash
   ssh pi@10.0.0.18
   htop
   ```
   - Should be 50-80% with current settings

3. **Check stream info:**
   ```bash
   sudo journalctl -u mediamtx -f
   ```

## Alternative Low-Latency Players

### MPV Player (Better than VLC for low latency)
```powershell
mpv --no-cache --untimed --profile=low-latency rtsp://10.0.0.18:8554/camera
```

### OBS Studio
1. Add Source → Media Source
2. Uncheck "Local File"
3. Input: `rtsp://10.0.0.18:8554/camera`
4. Uncheck "Restart playback when source becomes active"

## Reverting Changes

If you need to restore the original configuration:

```bash
# MediaMTX
sudo cp /opt/mediamtx/mediamtx.yml.backup /opt/mediamtx/mediamtx.yml
sudo systemctl restart mediamtx

# FFmpeg
sudo cp /opt/doorbell-camera/stream-camera.sh.backup /opt/doorbell-camera/stream-camera.sh
sudo systemctl restart doorbell-camera
```

## Further Optimization

For absolute minimum latency (~200-500ms), consider:
- Using WebRTC instead of RTSP (MediaMTX supports this)
- Hardware encoding with Raspberry Pi's GPU (h264_v4l2m2m)
- Direct camera access without re-encoding (limited compatibility)
