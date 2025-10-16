# ResQLink - Quick Start Guide

## 🚀 Getting Started in 3 Minutes

### Installation
1. Build the APK:
   ```bash
   flutter build apk --release
   ```
2. Install on your Android device
3. Grant all requested permissions

### First-Time Setup
1. **Open the app** - You'll see the main screen with a big red SOS button
2. **Set your name** - Tap the person icon (👤) in the top-right corner
3. **Enter your name** - This helps rescuers identify you
4. **Done!** The app is now ready to use

## 📱 Main Features

### 1️⃣ Sending an SOS (Victim Mode)

**When to use:**
- In an emergency situation
- Need help but no cellular service
- Want to share your location with nearby rescuers

**How to send:**
1. Tap the large red **SOS** button
2. Wait a few seconds while the app gets your GPS location
3. Your emergency message is now broadcasting!
4. Keep the app open for best results

**What happens:**
- Your SOS message broadcasts every 10 seconds
- Continues for 5 minutes automatically
- Reaches all nearby devices (within ~10-30 meters)
- Messages relay through other devices (mesh network)

### 2️⃣ Receiving Messages (Rescuer Mode)

**When to use:**
- In a disaster area
- Want to help locate victims
- Acting as a relay node for the mesh network

**How to receive:**
1. Just keep the app open!
2. App automatically listens for nearby SOS messages
3. When a message arrives, you'll see it in the message list

**Viewing messages:**
1. Tap the list icon (📋) in the top-right
2. See all received SOS messages
3. Tap any message for full details
4. Tap the map icon (🗺️) to navigate to the location

### 3️⃣ Understanding Network Status

The network status indicator shows:
- **"Searching for Peers..."** - Looking for nearby devices
- **"Connected to X Peer(s)"** - Connected to X nearby devices
- **"Offline - Start Discovery"** - Not currently scanning

**Best practices:**
- More peers = better message relay
- Keep Bluetooth and Location enabled
- Stay within ~10-30 meters of other users for best range

## ⚠️ Important Tips

### For Best Performance:

✅ **DO:**
- Keep the app open and in foreground
- Enable Bluetooth
- Enable Location Services (GPS)
- Keep your device charged
- Stay relatively still when sending SOS (better GPS accuracy)
- Use multiple devices in a disaster area for better mesh coverage

❌ **DON'T:**
- Close the app while sending/receiving
- Disable Bluetooth or Location
- Expect long-range communication (>30 meters)
- Rely solely on this app (use with official emergency services)

### Testing the App:

**Need 2 devices minimum:**
1. Install app on both devices
2. Open on both devices
3. Wait 15-30 seconds for discovery
4. Send SOS from one device
5. Check if it appears on the other device

## 🔋 Battery Saving

The app is designed to be battery-efficient:
- Dark theme reduces screen power
- Bluetooth LE mode for low power consumption
- Automatic timeout after 5 minutes of broadcasting

**Tips to save more battery:**
- Reduce screen brightness
- Only broadcast when needed
- Act as a relay node intermittently

## 🗺️ Location Features

### Viewing Locations:
1. Open message list
2. Tap any SOS message
3. See coordinates displayed
4. Tap "Open in Maps" to navigate

### If Maps Don't Open:
- Ensure you have Google Maps or another map app installed
- Grant internet permission if available
- Copy coordinates manually if needed

## 🆘 Troubleshooting

### "No peers found"
- Ensure Bluetooth is enabled on both devices
- Check that Location is enabled
- Move devices closer together (<10 meters)
- Wait 30 seconds for discovery
- Restart the app

### "Failed to get location"
- Enable Location Services in device settings
- Ensure GPS permission is granted
- Move to an outdoor area for better GPS signal
- Wait a few seconds and try again

### "SOS not received on other device"
- Verify both devices have the app open
- Check network status shows connected peers
- Ensure devices are within range
- Check for Bluetooth interference

## 📞 Emergency Use

**In a REAL emergency:**
1. Try to call official emergency services first (911/112)
2. If no cellular service, use ResQLink
3. Send your SOS signal
4. Stay in place if possible (easier to locate)
5. Keep the app running
6. Conserve battery for prolonged situations

**This app is a BACKUP tool, not a replacement for official emergency services!**

## 🔐 Privacy & Security

- ✅ No data sent to servers
- ✅ Messages only transmitted peer-to-peer
- ✅ Location shared only when you tap SOS
- ✅ Your name is optional
- ✅ All data stored locally on your device

## 📊 Message Information

Each SOS message contains:
- **Sender's Name** - Who sent the SOS
- **Timestamp** - When the SOS was sent
- **GPS Coordinates** - Exact location (latitude/longitude)
- **Unique ID** - Prevents duplicate processing

## 🌐 Mesh Network Explained

**What is a mesh network?**
- Devices connect directly to each other
- Messages "hop" from device to device
- No central server or internet needed
- Each device can relay messages to others

**Example scenario:**
```
Victim (Device A) → Relay (Device B) → Rescuer (Device C)
```
Even if Device A and C can't directly connect, Device B relays the message!

**Maximum tested hops:** 3-4 devices

## 💡 Pro Tips

1. **For Disaster Preparedness:**
   - Install the app before disasters occur
   - Test with friends/family periodically
   - Keep power banks available
   - Familiarize yourself with the interface

2. **For Rescuers:**
   - Position yourself strategically for coverage
   - Act as a stationary relay node
   - Check message list frequently
   - Share received coordinates with official responders

3. **For Community Use:**
   - Encourage neighbors to install the app
   - Organize community drills
   - Create communication plans
   - Designate relay node locations

## 📱 Device Requirements

- **Minimum:** Android 5.0 (API 21)
- **Recommended:** Android 8.0 or higher
- **Required Features:**
  - Bluetooth 4.0 or higher
  - GPS/Location services
  - Sufficient storage for message history

## 🎯 Best Use Cases

✅ **Ideal for:**
- Natural disasters (earthquakes, floods, hurricanes)
- Remote areas with no cellular coverage
- Mass casualty incidents
- Building collapses
- Search and rescue operations
- Community emergency coordination

❌ **Not ideal for:**
- Long-distance communication (>100 meters)
- High-speed moving scenarios
- Dense urban areas with interference
- When cellular service is available

## 📞 Support

If you encounter issues:
1. Check this guide first
2. Verify permissions are granted
3. Restart the app
4. Reinstall if necessary
5. Report bugs on GitHub

---

**Remember: ResQLink is a supplementary tool. Always try official emergency services first when available!**

**Stay Safe! 🚨**
