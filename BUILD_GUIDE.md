# ResQLink - Build & Deploy Guide

## 🚀 Quick Build Commands

### For Testing (Debug Build)
```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Run on connected device
flutter run
```

### For Release (Production Build)
```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Output location:
# build/app/outputs/flutter-apk/app-release.apk
```

### For App Bundle (Google Play Store)
```bash
flutter build appbundle --release

# Output location:
# build/app/outputs/bundle/release/app-release.aab
```

---

## 📱 Installation Methods

### Method 1: Direct Install (ADB)
```bash
# Build and install in one command
flutter install

# Or manually with ADB
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Method 2: File Transfer
1. Build the APK (see above)
2. Copy `app-release.apk` to your device
3. Enable "Install from Unknown Sources" in device settings
4. Tap the APK file to install

### Method 3: QR Code Transfer
1. Upload APK to file sharing service
2. Generate QR code
3. Scan with device to download & install

---

## 🔍 Pre-Build Checklist

Before building, verify:
- ✅ All dependencies installed (`flutter pub get`)
- ✅ No errors (`flutter analyze`)
- ✅ Tests pass (`flutter test`)
- ✅ Android device/emulator connected
- ✅ Correct package name in build.gradle
- ✅ Version code/name set in build.gradle

---

## 🛠️ Build Configuration

### Current Configuration
- **App Name**: ResQLink
- **Package**: com.resqlink.emergency
- **Version**: 1.0.0 (Build 1)
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: 34 (Android 14)

### Modify Version
Edit `android/app/build.gradle.kts`:
```kotlin
versionCode = 1        // Increment for each release
versionName = "1.0.0"  // User-visible version
```

---

## 📊 Build Output Information

### Debug Build
- **Size**: ~30-40 MB
- **Signing**: Debug keystore (auto-generated)
- **ProGuard**: Disabled
- **Optimization**: None

### Release Build
- **Size**: ~25-35 MB (compressed)
- **Signing**: Debug keystore (change for production!)
- **ProGuard**: Enabled
- **Optimization**: Full

---

## 🔐 Signing Configuration (For Production)

### Generate Keystore
```bash
keytool -genkey -v -keystore resqlink-release.keystore \
  -alias resqlink -keyalg RSA -keysize 2048 -validity 10000
```

### Configure Signing
Create `android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=resqlink
storeFile=path/to/resqlink-release.keystore
```

Update `android/app/build.gradle.kts` to use the keystore.

⚠️ **IMPORTANT**: Never commit keystores or passwords to version control!

---

## 🧪 Testing Checklist

### Before Release
- [ ] Test on multiple Android versions (5.0, 8.0, 11, 14)
- [ ] Test on different screen sizes
- [ ] Test all permissions work correctly
- [ ] Test P2P connectivity with 2+ devices
- [ ] Test in airplane mode (ensure offline works)
- [ ] Test GPS location capture
- [ ] Test message storage and retrieval
- [ ] Test map intent launches
- [ ] Check for memory leaks
- [ ] Verify battery consumption is acceptable

### Device Requirements for Testing
- **Minimum**: 2 physical Android devices (API 21+)
- **Recommended**: 3+ devices for mesh relay testing
- **Bluetooth**: All devices must support BLE
- **Location**: GPS capability required

---

## 📤 Distribution Options

### Option 1: Direct Distribution
- Build release APK
- Share via file transfer, USB, email, etc.
- Users install manually

### Option 2: Google Play Store
- Build app bundle (`.aab`)
- Create Google Play Developer account ($25 one-time fee)
- Upload to Play Console
- Complete store listing
- Submit for review

### Option 3: Alternative App Stores
- Amazon Appstore
- Samsung Galaxy Store
- F-Droid (requires open source)
- APKPure, Aptoide, etc.

### Option 4: Enterprise Distribution
- Set up MDM (Mobile Device Management)
- Deploy via company app store
- Use for organizational emergency preparedness

---

## 🔧 Troubleshooting Build Issues

### Common Issues

#### "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### "SDK version mismatch"
Check `compileSdk` and `targetSdk` in `build.gradle.kts` match your installed SDK.

#### "Permission denied" (Linux/Mac)
```bash
chmod +x android/gradlew
```

#### "Out of memory"
Add to `android/gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx4096m
```

#### "Dependency conflict"
```bash
flutter pub upgrade --major-versions
flutter pub get
```

---

## 📋 Build Logs

### View Build Logs
```bash
# Verbose output
flutter build apk --release --verbose

# Save to file
flutter build apk --release --verbose > build_log.txt 2>&1
```

### Analyze APK Size
```bash
# Install analyzer
flutter pub global activate --source git https://github.com/flutter/devtools.git

# Analyze APK
flutter build apk --release --analyze-size
```

---

## 🚦 Deployment Steps

### For Hackathon Demo
1. ✅ Build release APK
2. ✅ Install on 2+ demo devices
3. ✅ Verify all features work
4. ✅ Prepare presentation
5. ✅ Have backup APK file ready

### For Production Release
1. ✅ Complete all testing
2. ✅ Generate production keystore
3. ✅ Configure signing
4. ✅ Build signed release
5. ✅ Test signed APK
6. ✅ Prepare store listing
7. ✅ Submit for review

---

## 📦 What to Submit

### For Hackathon
- ✅ Source code (GitHub repository)
- ✅ Release APK file
- ✅ README.md documentation
- ✅ Demo video (optional)
- ✅ Presentation slides

### Recommended Archive Structure
```
ResQLink_Submission/
├── source_code/
│   └── (full Flutter project)
├── apk/
│   └── app-release.apk
├── documentation/
│   ├── README.md
│   ├── QUICK_START.md
│   └── DEVELOPMENT_SUMMARY.md
├── demo/
│   ├── screenshots/
│   └── demo_video.mp4 (if available)
└── presentation/
    └── slides.pdf (if available)
```

---

## ✅ Final Verification

Before submission, ensure:
- [ ] Code builds without errors
- [ ] APK installs on test device
- [ ] All core features functional
- [ ] Documentation is complete
- [ ] No sensitive information in code
- [ ] License file included
- [ ] README has setup instructions
- [ ] Version numbers are correct

---

## 🎯 Quick Commands Reference

```bash
# Install dependencies
flutter pub get

# Check for errors
flutter analyze

# Run tests
flutter test

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Install on device
flutter install

# Run app
flutter run

# Clean build
flutter clean
```

---

## 📞 Support

If you encounter build issues:
1. Check Flutter version: `flutter --version`
2. Check Android SDK installed
3. Verify device drivers installed
4. Review error messages carefully
5. Check GitHub issues for similar problems

---

## 🎉 Ready to Build!

Everything is configured and ready. Run:

```bash
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

**Good luck with your hackathon! 🚀**
