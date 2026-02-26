# Hello Android - Setup Guide

## Prerequisites

### 1. Install Flutter
```
winget install Google.Flutter
```
Then restart your terminal and run:
```
flutter doctor
```

### 2. Install Android Studio
- Download from https://developer.android.com/studio
- During install, include: Android SDK, Android SDK Platform, Android Virtual Device

### 3. Accept Android licenses
```
flutter doctor --android-licenses
```

## Run the app

### On a physical Android device:
1. Enable Developer Options on your phone:
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times
2. Enable USB Debugging in Developer Options
3. Connect phone via USB
4. Run:
```
cd hello_android
flutter run
```

### On an emulator:
1. Open Android Studio > Device Manager > Create Virtual Device
2. Then run:
```
flutter run
```

## Build APK for release
```
flutter build apk --release
```
APK will be at: `build/app/outputs/flutter-apk/app-release.apk`
