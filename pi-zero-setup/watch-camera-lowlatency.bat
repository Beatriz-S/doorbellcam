@echo off
REM Low-latency camera viewer for Windows
REM This script launches VLC with optimized settings for minimum delay

echo Starting low-latency camera stream...
echo.
echo If VLC is not in your PATH, you may need to edit this script
echo to specify the full path to vlc.exe
echo.

REM Try common VLC installation paths
set VLC_PATH=""

if exist "C:\Program Files\VideoLAN\VLC\vlc.exe" (
    set VLC_PATH="C:\Program Files\VideoLAN\VLC\vlc.exe"
) else if exist "C:\Program Files (x86)\VideoLAN\VLC\vlc.exe" (
    set VLC_PATH="C:\Program Files (x86)\VideoLAN\VLC\vlc.exe"
) else (
    REM Try using vlc from PATH
    where vlc >nul 2>&1
    if %errorlevel% equ 0 (
        set VLC_PATH=vlc
    ) else (
        echo ERROR: VLC not found!
        echo Please install VLC from https://www.videolan.org/
        echo Or edit this script to specify the VLC installation path
        pause
        exit /b 1
    )
)

REM Camera IP address - edit this if different
set CAMERA_IP=10.0.0.18
set RTSP_PORT=8554
set STREAM_PATH=camera

echo Connecting to rtsp://%CAMERA_IP%:%RTSP_PORT%/%STREAM_PATH%
echo.
echo Stream Info:
echo - Resolution: 640x480 @ 10fps
echo - Encoder: Hardware (h264_v4l2m2m)
echo - Recommended Caching: 300ms
echo.

REM Launch VLC with low-latency settings
REM Using 300ms caching for balanced performance (adjust if needed)
%VLC_PATH% rtsp://%CAMERA_IP%:%RTSP_PORT%/%STREAM_PATH% ^
    --network-caching=300 ^
    --rtsp-tcp ^
    --no-audio ^
    --live-caching=300

echo.
echo VLC closed.
pause
