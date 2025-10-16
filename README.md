# ResQLink - Offline Emergency Communication System

![ResQLink Logo](https://img.shields.io/badge/ResQLink-Emergency%20Communication-red)
![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## 🚨 Project Overview

**ResQLink** is an offline emergency communication Android application designed for disaster scenarios where traditional cellular and internet infrastructure fails. The app uses **Peer-to-Peer (P2P) mesh networking** to create a device-to-device communication network, enabling SOS message broadcasting and location sharing without requiring internet connectivity.

### Theme
Disaster Resilient Infrastructure / Emergency Communication Networks

## 🎯 Key Features

### ✅ Implemented MVP Features

1. **One-Tap SOS Broadcasting**
   - Large, prominent red SOS button
   - Captures GPS location automatically
   - Broadcasts emergency message to nearby devices
   - Automatic re-broadcast every 10 seconds for 5 minutes

2. **P2P Mesh Networking**
   - Uses Android Nearby Connections API
   - Automatic peer discovery and connection
   - Message relay functionality (mesh hop)
   - Duplicate message prevention
   - No internet or cellular network required

3. **Location Services**
   - Real-time GPS location capture
   - Fallback to last known location
   - High-accuracy positioning
   - Location displayed in messages

4. **Message Management**
   - Local storage using SharedPreferences
   - View all received emergency messages
   - Message details with timestamp and coordinates
   - Open locations in external maps app

5. **User Interface**
   - Dark theme optimized for battery efficiency
   - High-contrast design for emergency situations
   - Real-time connectivity status display
   - User profile management

## 🛠️ Technical Architecture

### Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Platform** | Flutter (Dart) | Cross-platform development |
| **P2P Connectivity** | Nearby Connections API | Device discovery and mesh networking |
| **Location** | Geolocator | GPS positioning |
| **Storage** | SharedPreferences | Local message and profile storage |
| **Permissions** | Permission Handler | Runtime permission management |
| **State Management** | Provider | App state management |
| **Map Integration** | URL Launcher | External map app launching |

### Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   └── resq_message.dart             # Message data model
├── services/
│   ├── connectivity_manager.dart     # P2P mesh networking
│   ├── location_service.dart         # GPS services
│   └── message_storage.dart          # Local storage
└── screens/
    ├── main_screen.dart              # SOS button interface
    └── message_list_screen.dart      # Message viewer
```

## 📱 Core Data Structure

### ResQMessage Model

```dart
{
  "id": "UUID",              // Unique message identifier
  "name": "User Name",       // Sender's name
  "lat": 12.345678,         // Latitude
  "lon": 78.901234,         // Longitude
  "timestamp": 1696723200000 // Unix timestamp (ms)
}
```

## 🔧 Installation & Setup

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Android Studio / VS Code
- Android device (API 21+) for testing
- Two or more physical devices for P2P testing

### Step 1: Clone the Repository

```bash
git clone https://github.com/KumarRitik5/RBCET-STEM-SATION-HACkathon.git
cd RBCET-STEM-SATION-HACkathon/flutter_application_1
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Build and Run

```bash
# For debug build
flutter run

# For release build
flutter build apk --release
```

## 📋 Required Permissions

The app requests the following permissions:

- ✅ **Bluetooth** - For P2P device discovery
- ✅ **Bluetooth Scan/Advertise** - For mesh networking
- ✅ **Location** - For GPS and P2P (Android requirement)
- ✅ **Nearby WiFi Devices** - For enhanced P2P connectivity
- ✅ **Internet** - For opening external maps (optional)

## 🎮 How to Use

### For Emergency Victims (Sending SOS)

1. **Set Your Name** (Optional)
   - Tap the person icon in the top-right
   - Enter your name
   - This helps rescuers identify you

2. **Send SOS**
   - Tap the large red **SOS** button
   - App automatically captures your GPS location
   - Message broadcasts to all nearby devices
   - Continues broadcasting for 5 minutes

3. **Monitor Status**
   - Check "Network Status" to see connected peers
   - View "Searching for Peers..." or "Connected to X Peer(s)"

### For Rescuers/Relay Nodes

1. **Keep App Running**
   - Simply keep the app open
   - App automatically discovers nearby devices
   - Receives and relays emergency messages

2. **View Messages**
   - Tap the list icon in the top-right
   - See all received SOS messages
   - Tap any message for details

3. **Open Location**
   - Tap the map icon on any message
   - Opens location in Google Maps/default map app
   - Navigate to emergency location

## 🔐 Security & Privacy

- ✅ All communication is peer-to-peer (no server)
- ✅ Messages stored locally on device only
- ✅ No data sent to external servers
- ✅ User name is optional and user-controlled
- ✅ Location shared only when SOS is triggered

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Testing Requirements

**Important**: P2P functionality requires testing on physical devices. Emulators cannot test Bluetooth/WiFi Direct features.

**Minimum Testing Setup:**
- 2 physical Android devices (API 21+)
- Bluetooth enabled on both devices
- Location services enabled
- Both devices should be within Bluetooth range (~10-30 meters)

**Test Procedure:**
1. Install app on both devices
2. Open app on both devices
3. Wait for peer discovery (15-30 seconds)
4. Send SOS from Device 1
5. Verify message appears on Device 2
6. Test relay: Add Device 3 in range of Device 2 (but not Device 1)
7. Verify Device 3 receives the message via Device 2

## ⚡ Performance Optimization

- **Low Power Mode**: Uses Bluetooth LE for efficiency
- **Battery Efficient**: Dark theme reduces screen power consumption
- **Smart Broadcasting**: Messages broadcast only every 10 seconds
- **Duplicate Prevention**: Seen messages cached to prevent loops
- **Automatic Timeout**: SOS broadcast stops after 5 minutes

## 🐛 Known Limitations

1. **Range**: Limited to Bluetooth/WiFi Direct range (~10-30 meters)
2. **Mesh Depth**: Message relay tested up to 3-4 hops
3. **Device Count**: Optimal performance with <10 connected peers
4. **Platform**: Currently Android-only (iOS has P2P restrictions)
5. **Testing**: Requires physical devices (cannot test on emulators)

## 🚀 Future Enhancements

- [ ] Add message encryption for security
- [ ] Implement message acknowledgment system
- [ ] Add voice message support
- [ ] Battery level sharing in messages
- [ ] Offline map caching
- [ ] Support for group identification (family/team)
- [ ] Message priority levels
- [ ] Enhanced relay routing algorithms

## 📦 Dependencies

```yaml
dependencies:
  nearby_connections: ^3.2.0      # P2P mesh networking
  geolocator: ^10.1.0             # Location services
  permission_handler: ^11.1.0     # Permission management
  shared_preferences: ^2.2.2      # Local storage
  uuid: ^4.3.3                    # Unique IDs
  url_launcher: ^6.2.3            # External map launching
  provider: ^6.1.1                # State management
```

## 🤝 Contributing

This project was developed for the RBCET STEM-SATION Hackathon. Contributions, issues, and feature requests are welcome!

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Team

- **Developer**: RBCET Development Team
- **Institution**: RBCET (Rajiv Gandhi Institute of Technology)
- **Event**: STEM-SATION Hackathon 2025

## 🆘 Support & Issues

For technical support or bug reports:
1. Open an issue on GitHub
2. Provide device model, Android version, and logs
3. Include steps to reproduce the issue

## 📸 Screenshots

### Main Screen
- Large red SOS button
- Network status indicator
- User identity display
- Emergency instructions

### Message List
- All received SOS messages
- Timestamp and location for each
- Quick map navigation
- Message details view

## 🎓 Educational Purpose

This project demonstrates:
- P2P mesh networking implementation
- Offline-first mobile architecture
- Emergency communication system design
- Real-world application of networking concepts
- Disaster-resilient technology solutions

---

**⚠️ Disclaimer**: This is a proof-of-concept application developed for educational and hackathon purposes. While functional, it should be used alongside, not as a replacement for, official emergency services (911, 112, etc.).

**Built with ❤️ for disaster preparedness and community resilience.**
#   S O S - s e r v i c e - a p p  
 