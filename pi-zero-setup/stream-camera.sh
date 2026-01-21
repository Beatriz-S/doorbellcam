#!/bin/bash
# Camera streaming script for Raspberry Pi Zero 2 W
# Modified for USB Camera (MJPEG input)

# Configuration
RTSP_PORT=8554
VIDEO_WIDTH=1280
VIDEO_HEIGHT=720
VIDEO_FPS=15
VIDEO_BITRATE=1000k
AUDIO_ENABLED=false

# Start streaming using ffmpeg
echo "Starting USB camera stream..."

if [ "$AUDIO_ENABLED" = true ]; then
    # Stream with audio
    ffmpeg -f v4l2 \
        -input_format mjpeg \
        -video_size ${VIDEO_WIDTH}x${VIDEO_HEIGHT} \
        -framerate ${VIDEO_FPS} \
        -i /dev/video0 \
        -f alsa \
        -i hw:0 \
        -c:v libx264 \
        -preset ultrafast \
        -tune zerolatency \
        -b:v ${VIDEO_BITRATE} \
        -c:a aac \
        -b:a 128k \
        -f rtsp \
        -rtsp_transport tcp \
        rtsp://0.0.0.0:${RTSP_PORT}/camera
else
    # Stream video only
    ffmpeg -f v4l2 \
        -input_format mjpeg \
        -video_size ${VIDEO_WIDTH}x${VIDEO_HEIGHT} \
        -framerate ${VIDEO_FPS} \
        -i /dev/video0 \
        -c:v libx264 \
        -preset ultrafast \
        -tune zerolatency \
        -b:v ${VIDEO_BITRATE} \
        -f rtsp \
        -rtsp_transport tcp \
        rtsp://0.0.0.0:${RTSP_PORT}/camera
fi
