# Working Configuration Summary

✅ **TESTED AND WORKING** on Raspberry Pi Zero 2 W with 5MP USB Camera

## Stream Details

- **Resolution**: 640x480
- **Frame Rate**: 10 fps
- **Bitrate**: 500 kbps
- **Encoder**: h264_v4l2m2m (hardware accelerated)
- **Format**: H.264 baseline profile, YUV420p
- **Protocol**: RTSP over TCP
- **Port**: 8554
- **Path**: `/camera`

## Access the Stream

**From Windows PC with VLC:**
```
rtsp://10.0.0.18:8554/camera
```

**Recommended VLC Settings:**
- Network Caching: `300 ms` (adjust 100-500ms as needed)
- Protocol: RTSP over TCP

**Quick Launch:**
- Double-click `watch-camera-lowlatency.bat` in this folder

## MediaMTX Configuration

Location on Pi Zero: `/opt/mediamtx/mediamtx.yml`

```yaml
paths:
  camera:
    source: publisher
    runOnInit: ffmpeg -f v4l2 -input_format mjpeg -video_size 640x480 -framerate 10 -i /dev/video0 -pix_fmt yuv420p -c:v h264_v4l2m2m -num_output_buffers 32 -num_capture_buffers 16 -b:v 500k -f rtsp rtsp://localhost:$RTSP_PORT/$MTX_PATH
    runOnInitRestart: true
```

## Key Configuration Points

### 1. Hardware Encoding (Critical for Pi Zero)
- **Encoder**: `h264_v4l2m2m` (GPU encoding)
- **Why**: Software encoding (libx264) is too CPU-intensive for Pi Zero 2 W
- **Benefit**: ~5-10% CPU usage vs 90%+ with software encoding

### 2. Pixel Format Conversion
- **Parameter**: `-pix_fmt yuv420p`
- **Why**: Camera outputs YUV422, but encoders require YUV420
- **Placement**: Must come AFTER the input (`-i /dev/video0`) and BEFORE the encoder

### 3. Resolution & Frame Rate
- **640x480 @ 10fps**: Balanced for Pi Zero performance
- **Lower settings work**: 320x240 @ 5fps if you need ultra-low CPU
- **Higher settings**: May cause CPU overload and lag

### 4. Buffer Settings
- **`-num_output_buffers 32`**: Output buffer count
- **`-num_capture_buffers 16`**: Capture buffer count
- **Why**: Optimized for the hardware encoder

## Performance Metrics

On Pi Zero 2 W:
- **CPU Usage**: ~5-15% (very efficient)
- **Memory**: ~50MB for mediamtx + ffmpeg
- **Latency**: ~0.5-1.5 seconds (with 300ms VLC caching)
- **Network**: ~500 kbps (~4MB per minute)

## Common Issues & Solutions

### Issue: Stream won't start
```bash
# Check logs
sudo journalctl -u mediamtx -n 30 --no-pager

# Restart service
sudo systemctl restart mediamtx
```

### Issue: VLC can't connect
1. Check Pi Zero is reachable: `ping 10.0.0.18`
2. Verify mediamtx is running: `sudo systemctl status mediamtx`
3. Check firewall: `sudo ufw allow 8554/tcp`
4. Try different VLC caching values (100-1000ms)

### Issue: Video stutters/freezes
1. Increase VLC caching (500-1000ms)
2. Check network: `ping 10.0.0.18` should be <10ms
3. Lower resolution/fps on Pi Zero if needed

### Issue: High CPU on Pi Zero
1. Verify hardware encoding is active: `sudo journalctl -u mediamtx | grep h264_v4l2m2m`
2. Should see "encoder: h264_v4l2m2m" in logs
3. If using libx264, CPU will be 90%+ (wrong encoder)

## Upgrading Quality

To increase resolution/frame rate, edit on Pi Zero:

```bash
sudo nano /opt/mediamtx/mediamtx.yml
```

Try incremental upgrades:
1. **640x480 @ 15fps** - Minor CPU increase
2. **1280x720 @ 10fps** - Moderate CPU increase  
3. **1280x720 @ 15fps** - May be too much for Pi Zero 2 W

After changes:
```bash
sudo systemctl restart mediamtx
```

Monitor CPU: `htop`

## Backup & Restore

**Backup working config:**
```bash
sudo cp /opt/mediamtx/mediamtx.yml ~/mediamtx-working.yml
```

**Restore:**
```bash
sudo cp ~/mediamtx-working.yml /opt/mediamtx/mediamtx.yml
sudo systemctl restart mediamtx
```

## Next Steps

1. ✅ Camera streaming works
2. Update Frigate config to use this stream
3. Set up motion detection
4. Configure notifications

See main `README.md` for full setup instructions.
