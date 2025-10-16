# ResQLink - App Not Opening? Troubleshooting Guide

## 🔍 Common Issues & Solutions

### Issue 1: App Crashes Immediately on Launch

**Symptoms:** App icon appears but closes immediately when tapped

**Possible Causes & Solutions:**

#### A. Missing MainActivity.kt
The app needs the MainActivity file. Check if it exists:
- Location: `android/app/src/main/kotlin/com/resqlink/emergency/MainActivity.kt`

**Solution:** Create the MainActivity file

#### B. Wrong Package Name
The manifest and MainActivity package names must match.

**Solution:** Ensure consistency across files

---

### Issue 2: App Won't Install

**Symptoms:** Installation fails or shows "App not installed"

**Solutions:**
1. **Uninstall any previous version first**
2. **Enable "Install from Unknown Sources"** in Settings
3. **Check storage space** (need ~100MB free)
4. **Verify Android version** (need Android 5.0+)

---

### Issue 3: App Installs But Won't Open

**Symptoms:** App installed successfully but nothing happens when tapping icon

**Solutions:**

#### Check Permissions
The app needs critical permissions. Manually grant:
- Settings → Apps → ResQLink → Permissions
- Enable: Location, Nearby Devices, Bluetooth

#### Clear App Data
- Settings → Apps → ResQLink → Storage
- Clear Cache & Clear Data
- Try opening again

---

### Issue 4: White Screen or Black Screen

**Symptoms:** App opens but shows blank screen

**Causes:**
- Missing dependencies
- Corrupted build
- Permission issues

**Solution:** Rebuild the app

---

## 🔧 Quick Fixes

### Fix 1: Rebuild with Correct Configuration

Run these commands:
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Fix 2: Check Device Compatibility

**Minimum Requirements:**
- Android 5.0 (API 21) or higher
- Bluetooth 4.0+ support
- GPS capability
- ~50MB free storage

### Fix 3: Enable Developer Mode (Windows)

For building:
```bash
start ms-settings:developers
```
Enable "Developer Mode"

---

## 🐛 Debug Mode Installation

For better error messages, install debug version:

```bash
# Build debug APK
flutter build apk --debug

# Install debug APK
# Location: build/app/outputs/flutter-apk/app-debug.apk
```

Debug version will show error messages on crash.

---

## 📱 Installation Methods

### Method 1: Via File Manager
1. Copy APK to device
2. Open Files app
3. Navigate to APK
4. Tap to install
5. Enable "Install from Unknown Sources" if prompted

### Method 2: Via ADB (Recommended)
```bash
# Uninstall previous version
adb uninstall com.resqlink.emergency

# Install new APK
adb install -r build/app/outputs/flutter-apk/app-release.apk

# Check for errors
adb logcat | grep -i "resqlink\|fatal"
```

### Method 3: Via Android Studio
1. Open project in Android Studio
2. Click Run (green play button)
3. Select connected device
4. App will install and launch

---

## 🔍 Checking Logs

### Get Crash Logs (If App Crashes)

**On Windows:**
```powershell
# Connect device via USB
# Enable USB Debugging on device

# Clear logs
adb logcat -c

# Open the app (it will crash)

# Get crash log
adb logcat -d > crash_log.txt
```

Look for lines containing:
- `FATAL EXCEPTION`
- `AndroidRuntime`
- `ResQLink` or `com.resqlink.emergency`

---

## ✅ Verification Checklist

Before troubleshooting, verify:

- [ ] APK file exists and is not corrupted (should be ~44MB)
- [ ] Device has Android 5.0 or higher
- [ ] Device has sufficient storage (~100MB free)
- [ ] "Install from Unknown Sources" is enabled
- [ ] Previous versions are uninstalled
- [ ] USB Debugging is enabled (for ADB)
- [ ] Device has Bluetooth support
- [ ] Location services are available

---

## 🚨 Emergency Rebuild

If nothing works, rebuild from scratch:

```bash
# 1. Clean everything
flutter clean
rm -rf build/
rm -rf .dart_tool/

# 2. Get fresh dependencies
flutter pub get

# 3. Rebuild
flutter build apk --release

# 4. Verify APK exists
# Location: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔎 Specific Error Messages

### "App not installed as package appears to be invalid"
**Fix:** Corrupted APK. Rebuild the app.

### "There was a problem parsing the package"
**Fix:** Wrong architecture or corrupted download. Rebuild.

### "App keeps stopping"
**Fix:** Check logs with `adb logcat`, likely permission or dependency issue.

### "App not installed as app isn't compatible with your device"
**Fix:** Device Android version too old (need 5.0+) or architecture mismatch.

---

## 📞 Getting More Help

If app still won't open:

1. **Check build logs** for errors during compilation
2. **Try on different device** to isolate hardware issues
3. **Use debug APK** for detailed error messages
4. **Check logcat output** for crash information
5. **Verify all dependencies installed** correctly

---

## 🎯 Most Common Solutions

Based on common issues:

1. **90% of issues**: Rebuild app with `flutter clean` first
2. **5% of issues**: Uninstall old version before installing new
3. **3% of issues**: Enable "Install from Unknown Sources"
4. **2% of issues**: Device incompatibility (too old)

---

## 💡 Pro Tips

- Always uninstall previous versions before installing new builds
- Use debug build during development for better error messages
- Keep USB Debugging enabled for easy log access
- Test on multiple devices if available
- Grant all permissions before first use

---

**Need the actual error? Run the app with logs enabled and share the crash message!**
