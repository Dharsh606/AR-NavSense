# AR-NavSense

**Sense the Path. Navigate the World.**

AR-NavSense is a native Android accessibility and navigation application built with Flutter. It is designed to help visually impaired users move more independently through voice-first interaction, live GPS navigation, emergency safety tools, camera awareness, Bluetooth device support, and accessibility-focused mobile UI.

The app is built as a real native-feeling Android application, not a WebView, website wrapper, or static prototype.

## Download APK

The latest Android APK is published from the **GitHub Releases** section of this repository.

Direct download:

[Download AR-NavSense v1.0.4 APK](https://github.com/Dharsh606/AR-NavSense/releases/latest/download/AR-NavSense-v1.0.4.apk)

You can also open:

`Releases -> Latest -> Assets -> AR-NavSense APK`

Install note: uninstall any older AR-NavSense APK from your phone before installing a new build, so Android does not keep old cached app data.

## Key Features

- **Hey AR Voice Wake Mode**: say "Hey AR" to wake the assistant, then speak commands naturally.
- **Screen Auto-Read**: each major section speaks its purpose and available voice commands when opened.
- **Emergency SOS Workflow**: activate SOS by voice or long press, trigger vibration alert, and prepare live location SMS for saved contacts.
- **SOS Setup Wizard**: guides users to add trusted emergency contacts before they need help.
- **Voice Navigation**: destination search through speech recognition and spoken feedback.
- **Live GPS Navigation**: OpenStreetMap-based map experience with route display and navigation cards.
- **Smart Device Hub**: Bluetooth scanning and accessibility device management UI.
- **Camera Awareness**: native camera access prepared for environment awareness and future AI object detection.
- **AI Assistant Screen**: conversational accessibility and navigation support.
- **Accessibility Settings**: voice, haptic, contrast, and comfort controls.
- **Premium Mobile UI**: modern light theme, glassmorphism cards, gradients, animations, large touch targets, and high-readability text.

## Voice Commands

Examples:

```text
Hey AR
Open SOS
Emergency
Open voice navigation
Navigate to hospital
Open smart device hub
Scan nearby devices
Open camera
Open settings
Help
```

Emergency commands such as **"emergency"** and **"SOS"** are handled immediately from inside the app.

## Screens

- Animated splash screen
- Onboarding
- Home dashboard
- Voice navigation
- Live navigation map
- Smart Device Hub
- Camera awareness
- Emergency SOS
- Accessibility settings
- Profile and preferences
- AI assistant
- About project

## Tech Stack

- **Flutter**
- **Dart**
- **Android native permissions**
- **OpenStreetMap**
- **OpenRouteService-ready route architecture**
- **Android speech recognition**
- **Android Text-to-Speech**
- **Geolocation**
- **Bluetooth APIs through Flutter Blue Plus**
- **Camera APIs**
- **Vibration and emergency phone integrations**
- **SharedPreferences for local settings and contacts**

## Project Structure

```text
lib/
  constants/        App routes, storage keys, labels, and shared constants
  core/             App router and global navigation shell
  models/           Navigation and emergency contact models
  screens/          Production app screens
  services/         Voice, navigation, location, Bluetooth, camera, emergency services
  theme/            Premium app theme
  widgets/          Reusable glassmorphism and UI widgets

android/            Native Android project and permissions
assets/             Images, logo, icons, animations, and sound assets
test/               Flutter tests
```

## Getting Started

### Prerequisites

- Flutter SDK
- Android Studio or Android SDK
- Android device or emulator

### Install Dependencies

```bash
flutter pub get
```

### Run the App

```bash
flutter run
```

### Build Debug APK

```bash
flutter build apk --debug --target-platform android-arm,android-arm64 --dart-define=OPENROUTE_API_KEY=demo
```

The generated APK will be available at:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Android Permissions

AR-NavSense uses Android permissions for accessibility-focused native features:

- Microphone for speech recognition
- Location for GPS navigation and emergency live location sharing
- Bluetooth scanning and connection
- Camera for environment awareness
- Vibration for SOS haptic alerts
- Phone/SMS intents for emergency support

## Team

- **Dharshan V**
- **JohnDavid J**
- **Lokesh V**
- **Byresh A**

## Project Vision

AR-NavSense aims to provide a voice-first navigation experience where visually impaired users can open sections, request help, navigate to places, connect smart devices, and trigger emergency workflows with minimal touch dependency.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
