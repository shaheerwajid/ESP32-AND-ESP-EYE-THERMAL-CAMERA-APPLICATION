# ESP32 and ESP-EYE Thermal Camera Application

A Flutter mobile application for controlling thermal cameras via ESP32 and ESP-EYE devices using Bluetooth Low Energy (BLE) communication.

## Features

- 🔵 **Bluetooth Connectivity**: Scan and connect to ESP32/ESP-EYE devices via BLE
- 📷 **Camera Controls**: 
  - Normal/White Mode
  - Detail Mode
  - Adjustable Brightness (25%, 50%, 75%)
- 🎨 **Polarity/Color Palette Controls**:
  - White Hot
  - Rainbow
  - Sepia
  - Blackhot Fire
  - Iron
  - Ironbow
  - Blackhot
  - Hot Iron
  - White Hot Fire
- 🎬 **Animated Splash Screens**: Beautiful animated startup experience
- 📱 **Cross-Platform**: Supports Android and iOS

## Technologies Used

- **Flutter** - Cross-platform mobile framework
- **flutter_blue_plus** - Bluetooth Low Energy communication
- **permission_handler** - Handle device permissions
- **audioplayers** - Sound effects
- **flutter_animate** - Animation library
- **responsive_sizer** - Responsive UI components

## Getting Started

### Prerequisites

- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- ESP32 or ESP-EYE device with thermal camera firmware

### Installation

1. Clone the repository:
```bash
git clone https://github.com/shaheerwajid/ESP-32-AND-ESP-EYE-THERMAL-CAMERA-APPLICATION.git
cd ESP-32-AND-ESP-EYE-THERMAL-CAMERA-APPLICATION
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## Usage

1. **Launch the app** - You'll see an animated splash screen
2. **Scan for devices** - Tap "Scan" to discover nearby ESP32/ESP-EYE devices
3. **Connect** - Select your thermal camera device from the list
4. **Control Camera** - Use the "Camera Controller" button to adjust modes and brightness
5. **Change Polarity** - Use the "Polarity Controller" button to switch color palettes

## Project Structure

```
lib/
├── main.dart              # Main application entry point and LEOS controller
├── splash_screen.dart     # Initial splash screen
└── animated_splash.dart   # Animated splash screen with LEOS branding

assets/
├── images/                # App logos and images
└── sounds/                # Sound effects
```

## Permissions

The app requires the following permissions:
- Location (required for Bluetooth scanning on Android)
- Bluetooth
- Bluetooth Connect
- Bluetooth Scan

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available for educational and research purposes.

## Credits

- Powered by TeamAI
- LEOS (Laser & Electro Optical Solutions)

## Repository

🔗 **GitHub**: [https://github.com/shaheerwajid/ESP-32-AND-ESP-EYE-THERMAL-CAMERA-APPLICATION](https://github.com/shaheerwajid/ESP-32-AND-ESP-EYE-THERMAL-CAMERA-APPLICATION)
