# CntrlSuite iOS App

A professional audio controller application built with SwiftUI, featuring customizable gesture-based interfaces and Bluetooth MIDI connectivity.

## Overview

CntrlSuite is a professional audio controller app that allows you to create custom touch interfaces for controlling audio software and hardware via MIDI. Built with the unified AudioUI framework, it provides professional-grade controls with beautiful theming and responsive touch interaction.

## Features

### 🎛️ **Professional Audio Controls**
- Knobs, faders, XY pads, and drum pads
- Hardware-inspired neumorphic design
- Real-time value feedback with smooth animations
- Customizable component sizing and positioning

### 🎨 **Advanced Theming**
- Multiple built-in themes (Dark Pro, Sunset, Ocean, Ultra Clean)
- Neumorphic and minimal design options
- Real-time theme switching
- Professional color schemes optimized for studio environments

### 🔗 **Bluetooth MIDI Connectivity**
- Wireless MIDI device connection
- Central and peripheral mode support
- Real-time MIDI parameter transmission
- Multi-device connection management

### ✨ **Gesture Canvas**
- Intuitive drag-and-drop component placement
- Pinch-to-zoom and pan navigation
- Multi-touch gesture support
- Edit mode with visual feedback

### 📱 **Native iOS Experience**
- SwiftUI-based modern interface
- iOS 18+ optimized
- Smooth 60fps animations
- Professional glassmorphic design

## Architecture

```
CntrlSuite/
├── BluetoothMIDI/           # Main app source files
│   ├── BluetoothMIDIApp.swift    # App entry point
│   ├── ContentView.swift         # Main navigation
│   ├── CanvasView.swift          # Gesture canvas interface
│   ├── SettingsView.swift        # App configuration
│   ├── ComponentPaletteView.swift # Component selection
│   ├── InspectorPanel.swift      # Component inspector
│   ├── CanvasDelegate.swift      # Canvas interaction delegate
│   ├── CanvasGrid.swift          # Canvas grid overlay
│   └── MIDIHelper.swift          # MIDI connectivity
├── Images.xcassets/         # App icons and images
└── Info.plist              # App configuration
```

## Dependencies

### Core Frameworks
- **AudioUI** - Unified audio interface framework
- **GestureCanvasKit** - Gesture-based canvas system
- **MappingKit** - MIDI parameter mapping
- **MIDIKitIO** - MIDI connectivity and communication

### System Requirements
- iOS 18.0+
- Xcode 16+
- Swift 6.0+

## Getting Started

### 1. Clone and Setup

```bash
git clone [repository-url]
cd CntrlSuiteNew/CntrliOSAudioUISPM
open CntrlMIDI.xcodeproj
```

### 2. Build and Run

1. Open `CntrlMIDI.xcodeproj` in Xcode
2. Select your target device or simulator
3. Press Cmd+R to build and run

### 3. First Launch

1. Grant Bluetooth permissions when prompted
2. Enable MIDI access in iOS Settings if needed
3. Explore the canvas interface in edit mode
4. Add components from the component palette

## Usage Guide

### Creating Custom Layouts

1. **Enter Edit Mode**: Tap the "Edit" button in the toolbar
2. **Add Components**: Tap the + button to open the component palette
3. **Position Components**: Drag components to desired locations
4. **Configure Components**: Tap components to access the inspector
5. **Save Layout**: Exit edit mode to save your layout

### Connecting MIDI Devices

1. **Open Settings**: Navigate to the Settings tab
2. **Bluetooth MIDI**: Tap "Connect to Device" or "Share this Device"
3. **Device Discovery**: Select from available MIDI devices
4. **Connection Status**: Monitor connection status in settings

### Customizing Themes

1. **Theme Selection**: Use quick theme buttons in settings
2. **Visual Preview**: See real-time color previews
3. **System Integration**: Themes automatically adapt to system appearance

## Component Types

| Component | Description | MIDI Output | Use Cases |
|-----------|-------------|-------------|-----------|
| **Knob** | Rotary control with 270° range | CC values 0-127 | Volume, frequency, gain controls |
| **Vertical Fader** | Linear slider control | CC values 0-127 | Channel levels, send amounts |
| **Horizontal Fader** | Horizontal slider control | CC values 0-127 | Timeline scrubbing, panorama |
| **XY Pad** | Two-dimensional surface | Dual CC output | Spatial effects, filter control |
| **Crossfader** | DJ-style crossfade control | CC values 0-127 | Channel blending, transitions |
| **Pad Grid** | Velocity-sensitive grid | Note on/off + velocity | Drum machines, sample triggers |
| **Modulation Wheel** | Vertical modulation control | CC1 (standard) | Expression, vibrato, tremolo |

## Configuration

### MIDI Mapping

Components automatically map to MIDI parameters:
- **Channel**: 1-16 (configurable per component)
- **Parameter**: CC 1-127 (auto-assigned or manual)
- **Range**: 0-127 (standard MIDI range)

### Canvas Settings

- **Grid Snap**: Enable/disable grid snapping
- **Value Labels**: Show/hide real-time values
- **Zoom Range**: 0.5x to 3.0x magnification
- **Performance**: 60fps optimized rendering

## Troubleshooting

### Common Issues

**Bluetooth Connection Failed**
- Ensure Bluetooth is enabled in iOS Settings
- Reset network settings if persistent issues
- Check MIDI app permissions in iOS Settings

**Components Not Responding**
- Verify MIDI connection status
- Check component parameter assignments
- Restart the app if needed

**Performance Issues**
- Reduce component count for older devices
- Disable value labels during performance
- Use minimal themes for better performance

### Debug Information

Enable debug logging in `MIDIHelper.swift`:
```swift
// Uncomment for detailed MIDI logging
// print("MIDI Debug: \(message)")
```

## Contributing

### Development Setup

1. Install Xcode 16+
2. Clone all related packages in the same directory
3. Open the main project file
4. Run tests with Cmd+U

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftUI best practices
- Document public APIs with DocC comments
- Include unit tests for new features

## License

© 2025 CohenConcepts • Licensed under MIT License

## Support

- **Issues**: Report bugs and feature requests on GitHub
- **Documentation**: See individual package READMEs for detailed API docs
- **Community**: Join discussions for help and updates

---

**CntrlSuite** - Professional audio control, reimagined for iOS. 