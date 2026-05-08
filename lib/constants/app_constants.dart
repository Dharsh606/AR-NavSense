class AppConstants {
  // App Information
  static const String appName = 'AR-NavSense';
  static const String tagline = 'Sense the Path. Navigate the World.';
  static const String version = '1.0.4 Wake Voice SOS Wizard';

  // Navigation Routes
  static const String splashRoute = '/splash';
  static const String onboardingRoute = '/onboarding';
  static const String homeRoute = '/home';
  static const String voiceNavigationRoute = '/voice-navigation';
  static const String liveNavigationRoute = '/live-navigation';
  static const String smartDeviceHubRoute = '/smart-device-hub';
  static const String cameraAwarenessRoute = '/camera-awareness';
  static const String emergencySOSRoute = '/emergency-sos';
  static const String accessibilitySettingsRoute = '/accessibility-settings';
  static const String profileRoute = '/profile';
  static const String aiAssistantRoute = '/ai-assistant';
  static const String aboutRoute = '/about';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
  static const Duration splashAnimationDuration = Duration(milliseconds: 2500);

  // API Keys (Replace with actual keys)
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  static const String openWeatherApiKey = 'YOUR_OPENWEATHER_API_KEY';

  // Bluetooth Constants
  static const String bluetoothServiceUuid =
      '00001101-0000-1000-8000-00805F9B34FB';
  static const String bluetoothCharacteristicUuid =
      '00001101-0000-1000-8000-00805F9B34FB';

  // Voice Commands
  static const List<String> voiceCommands = [
    'navigate to',
    'take me to',
    'directions to',
    'find',
    'search',
    'connect bluetooth',
    'emergency',
    'help',
    'stop navigation',
    'cancel',
  ];

  // Emergency Contacts
  static const List<String> emergencyNumbers = ['911', '112', '999'];

  // Haptic Feedback Patterns
  static const Duration lightHaptic = Duration(milliseconds: 50);
  static const Duration mediumHaptic = Duration(milliseconds: 100);
  static const Duration heavyHaptic = Duration(milliseconds: 200);

  // Map Settings
  static const double defaultZoom = 15.0;
  static const double maxZoom = 20.0;
  static const double minZoom = 2.0;

  // UI Constants
  static const double borderRadius = 20.0;
  static const double smallBorderRadius = 12.0;
  static const double largeBorderRadius = 30.0;
  static const double padding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Accessibility Settings
  static const double defaultFontSize = 16.0;
  static const double maxFontSize = 24.0;
  static const double minFontSize = 12.0;

  // Voice Settings
  static const double defaultSpeechRate = 1.0;
  static const double maxSpeechRate = 2.0;
  static const double minSpeechRate = 0.5;

  // Camera Settings
  static const double defaultCameraZoom = 1.0;
  static const double maxCameraZoom = 10.0;

  // Navigation Settings
  static const Duration navigationUpdateInterval = Duration(milliseconds: 1000);
  static const Duration locationUpdateInterval = Duration(milliseconds: 5000);

  // Battery Optimization
  static const Duration lowPowerModeInterval = Duration(seconds: 30);
  static const Duration normalModeInterval = Duration(seconds: 5);

  // Error Messages
  static const String networkErrorMessage =
      'Please check your internet connection';
  static const String locationErrorMessage = 'Unable to get your location';
  static const String bluetoothErrorMessage = 'Bluetooth is not available';
  static const String cameraErrorMessage = 'Camera permission is required';
  static const String microphoneErrorMessage =
      'Microphone permission is required';

  // Success Messages
  static const String navigationStartedMessage = 'Navigation started';
  static const String bluetoothConnectedMessage = 'Bluetooth device connected';
  static const String emergencyMessage = 'Emergency services contacted';
  static const String locationPermissionGrantedMessage =
      'Location permission granted';

  // Accessibility Labels
  static const String navigationButtonLabel = 'Start Navigation';
  static const String voiceInputButtonLabel = 'Voice Input';
  static const String emergencyButtonLabel = 'Emergency SOS';
  static const String bluetoothButtonLabel = 'Bluetooth Settings';
  static const String settingsButtonLabel = 'Settings';
  static const String profileButtonLabel = 'Profile';

  // Storage Keys
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String themeKey = 'theme';
  static const String fontSizeKey = 'font_size';
  static const String speechRateKey = 'speech_rate';
  static const String voiceEnabledKey = 'voice_enabled';
  static const String hapticEnabledKey = 'haptic_enabled';
  static const String bluetoothDevicesKey = 'bluetooth_devices';
  static const String emergencyContactsKey = 'emergency_contacts';
  static const String emergencyAutoActivateKey = 'emergency_auto_activate';
  static const String emergencySetupWizardSeenKey = 'emergency_setup_wizard_seen';
  static const String navigationHistoryKey = 'navigation_history';
  static const String userPreferencesKey = 'user_preferences';

  // Glassmorphism Values
  static const double glassOpacity = 0.1;
  static const double glassBorderOpacity = 0.2;
  static const double glassBlur = 10.0;

  // Gradient Colors
  static const List<String> gradientColors = [
    '#4CAF50', // Green
    '#2196F3', // Blue
    '#FF9800', // Orange
    '#9C27B0', // Purple
    '#F44336', // Red
    '#00BCD4', // Cyan
  ];

  // Device Types
  static const List<String> supportedDeviceTypes = [
    'Earphones',
    'Smart Glasses',
    'Smart Bands',
    'Speakers',
    'Accessibility Devices',
    'Smart Watches',
  ];

  // Navigation Modes
  static const List<String> navigationModes = [
    'Driving',
    'Walking',
    'Transit',
    'Cycling',
  ];

  // Voice Languages
  static const List<String> supportedLanguages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
    'Korean',
  ];
}
