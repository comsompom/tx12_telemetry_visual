# Quick Build Instructions

## Prerequisites

1. **macOS 13.0 (Ventura) or later**
2. **Xcode 14.0 or later** (download from Mac App Store)
3. **RadioMaster TX12** connected via USB

## Build Steps

### 1. Open Project in Xcode

```bash
cd radiomaster_tx12/macos_telemetry_visual
open TelemetryHUD.xcodeproj
```

### 2. Build and Run

1. In Xcode, select **Product > Build** (or press `Cmd + B`)
2. Wait for build to complete
3. Select **Product > Run** (or press `Cmd + R`)

### 3. Select USB Port

- When the app launches, a port selection dialog will appear
- Choose your USB serial port (e.g., `/dev/cu.usbmodem00000000001B1`)
- Click "Connect"

### 4. View Telemetry

The HUD will display real-time telemetry data once connected.

## Creating a Standalone App

To create a distributable `.app` file:

1. In Xcode: **Product > Archive**
2. Wait for archive to complete
3. Click **Distribute App**
4. Choose **Copy App**
5. Select destination folder

The resulting `TelemetryHUD.app` can be run on any Mac (macOS 13.0+).

## Troubleshooting

### Build Fails

- Ensure Xcode is up to date
- Try **Product > Clean Build Folder** (Shift+Cmd+K)
- Check that all Swift files are included in the project

### Can't Find USB Port

- Connect your radio via USB
- Run `ls /dev/cu.*` in Terminal to list ports
- The app should auto-detect available ports

### No Data Displayed

- Verify radio is configured for USB serial output
- Check that telemetry forwarding is enabled
- Ensure baud rate matches (default: 115200)

For detailed information, see `README_MACOS_APP.md`.

