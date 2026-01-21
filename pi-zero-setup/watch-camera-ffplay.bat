@echo off
REM Ultra-low latency camera viewer using ffplay (part of ffmpeg)
REM ffplay typically has lower latency than VLC

echo Starting ultra-low latency camera stream with ffplay...
echo.

REM Check if ffplay is available
where ffplay >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: ffplay not found!
    echo.
    echo ffplay is part of ffmpeg. To install:
    echo 1. Download ffmpeg from https://ffmpeg.org/download.html
    echo 2. Extract and add to your PATH, or
    echo 3. Install via chocolatey: choco install ffmpeg
    echo 4. Or install via winget: winget install ffmpeg
    echo.
    pause
    exit /b 1
)

REM Camera IP address - edit this if different
set CAMERA_IP=10.0.0.18
set RTSP_PORT=8554
set STREAM_PATH=camera

echo Connecting to rtsp://%CAMERA_IP%:%RTSP_PORT%/%STREAM_PATH%
echo.
echo Controls:
echo - Q or ESC: Quit
echo - F: Toggle fullscreen
echo - P or SPACE: Pause
echo.

REM Launch ffplay with ultra-low latency settings
ffplay ^
    -fflags nobuffer ^
    -flags low_delay ^
    -framedrop ^
    -strict experimental ^
    -vf setpts=0 ^
    -sync ext ^
    -rtsp_transport tcp ^
    rtsp://%CAMERA_IP%:%RTSP_PORT%/%STREAM_PATH%

echo.
echo ffplay closed.
pause
