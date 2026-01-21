#!/bin/bash
# Test script to verify camera is working on Raspberry Pi Zero 2 W

echo "=========================================="
echo "Camera Test Script"
echo "=========================================="
echo ""

# Check if camera is detected
echo "1. Checking if camera is detected..."
if vcgencmd get_camera | grep -q "detected=1"; then
    echo "✓ Camera detected!"
else
    echo "✗ Camera not detected. Please check connections."
    exit 1
fi

# Check camera status
echo ""
echo "2. Camera status:"
vcgencmd get_camera

# List video devices
echo ""
echo "3. Video devices:"
ls -l /dev/video*

# Check v4l2 capabilities
echo ""
echo "4. Camera capabilities:"
v4l2-ctl --list-devices

# Test image capture
echo ""
echo "5. Testing image capture..."
if command -v libcamera-still &> /dev/null; then
    echo "Capturing test image with libcamera..."
    libcamera-still -o /tmp/test.jpg -t 1000
    if [ -f /tmp/test.jpg ]; then
        echo "✓ Test image captured successfully: /tmp/test.jpg"
        ls -lh /tmp/test.jpg
    else
        echo "✗ Failed to capture test image"
    fi
else
    echo "libcamera-still not found, skipping image test"
fi

# Check audio devices
echo ""
echo "6. Audio devices:"
arecord -l

echo ""
echo "=========================================="
echo "Camera test complete!"
echo "=========================================="
