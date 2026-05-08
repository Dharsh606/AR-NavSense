import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../constants/app_constants.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/home_screen.dart';
import '../screens/voice_navigation_screen.dart';
import '../screens/live_navigation_screen.dart';
import '../screens/smart_device_hub_screen.dart';
import '../screens/camera_awareness_screen.dart';
import '../screens/emergency_sos_screen.dart';
import '../screens/accessibility_settings_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/ai_assistant_screen.dart';
import '../screens/about_screen.dart';
import '../models/navigation_models.dart';
import '../services/voice_command_service.dart';
import '../theme/app_theme.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.splashRoute,
    routes: [
      // Splash Screen
      GoRoute(
        path: AppConstants.splashRoute,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding Screen
      GoRoute(
        path: AppConstants.onboardingRoute,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main App Routes with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationScreen(child: child);
        },
        routes: [
          // Home Screen
          GoRoute(
            path: AppConstants.homeRoute,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Voice Navigation Screen
          GoRoute(
            path: AppConstants.voiceNavigationRoute,
            name: 'voice-navigation',
            builder: (context, state) => const VoiceNavigationScreen(),
          ),

          // Smart Device Hub Screen
          GoRoute(
            path: AppConstants.smartDeviceHubRoute,
            name: 'smart-device-hub',
            builder: (context, state) => const SmartDeviceHubScreen(),
          ),

          // AI Assistant Screen
          GoRoute(
            path: AppConstants.aiAssistantRoute,
            name: 'ai-assistant',
            builder: (context, state) => const AIAssistantScreen(),
          ),

          // Profile Screen
          GoRoute(
            path: AppConstants.profileRoute,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),

          GoRoute(
            path: AppConstants.emergencySOSRoute,
            name: 'emergency-sos',
            builder: (context, state) => EmergencySOSScreen(
              autoActivate: state.extra == true,
            ),
          ),

          GoRoute(
            path: AppConstants.liveNavigationRoute,
            name: 'live-navigation',
            builder: (context, state) => LiveNavigationScreen(
              destination: state.extra is PlaceSuggestion
                  ? state.extra as PlaceSuggestion
                  : null,
            ),
          ),

          GoRoute(
            path: AppConstants.cameraAwarenessRoute,
            name: 'camera-awareness',
            builder: (context, state) => const CameraAwarenessScreen(),
          ),

          GoRoute(
            path: AppConstants.accessibilitySettingsRoute,
            name: 'accessibility-settings',
            builder: (context, state) => const AccessibilitySettingsScreen(),
          ),

          GoRoute(
            path: AppConstants.aboutRoute,
            name: 'about',
            builder: (context, state) => const AboutScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you\'re looking for doesn\'t exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.homeRoute),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

class MainNavigationScreen extends StatefulWidget {
  final Widget child;

  const MainNavigationScreen({Key? key, required this.child}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late final VoiceCommandService _voiceCommands;
  String _voiceStatus = 'Voice assistant starting...';
  bool _voiceReady = false;
  String? _lastAnnouncedLocation;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home,
      label: 'Home',
      route: AppConstants.homeRoute,
    ),
    NavigationItem(
      icon: Icons.mic,
      label: 'Voice',
      route: AppConstants.voiceNavigationRoute,
    ),
    NavigationItem(
      icon: Icons.bluetooth,
      label: 'Devices',
      route: AppConstants.smartDeviceHubRoute,
    ),
    NavigationItem(
      icon: Icons.smart_toy,
      label: 'AI',
      route: AppConstants.aiAssistantRoute,
    ),
    NavigationItem(
      icon: Icons.person,
      label: 'Profile',
      route: AppConstants.profileRoute,
    ),
    NavigationItem(
      icon: Icons.emergency_share,
      label: 'SOS',
      route: AppConstants.emergencySOSRoute,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _voiceCommands = VoiceCommandService();
    _updateCurrentIndex();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startVoiceLayer());
  }

  @override
  void dispose() {
    _voiceCommands.dispose();
    super.dispose();
  }

  Future<void> _startVoiceLayer() async {
    await _voiceCommands.initialize();
    if (!mounted) return;
    setState(() {
      _voiceReady = true;
      _voiceStatus = 'Say "Hey AR" to wake me, or say "emergency".';
    });
    await _voiceCommands.speak(
      'AR NavSense voice assistant is active. Say Hey AR to wake me, or say emergency for SOS.',
    );
    if (!mounted) return;
    await _voiceCommands.startContinuousListening(
      onHeard: (words) {
        if (mounted) setState(() => _voiceStatus = words);
      },
      onCommand: _handleVoiceCommand,
    );
  }

  Future<void> _handleVoiceCommand(VoiceCommandResult result) async {
    await _voiceCommands.speak(result.spokenReply);
    if (!mounted) return;

    if (result.emergency) {
      setState(() => _currentIndex = _navigationItems.length - 1);
      context.go(AppConstants.emergencySOSRoute, extra: true);
      return;
    }

    final route = result.route;
    if (route == null) return;

    if (route == AppConstants.liveNavigationRoute && result.destination != null) {
      context.push(route, extra: result.destination);
      return;
    }

    if (_navigationItems.any((item) => item.route == route)) {
      final index = _navigationItems.indexWhere((item) => item.route == route);
      if (index >= 0) setState(() => _currentIndex = index);
      context.go(route);
    } else {
      context.push(route);
    }
  }

  void _syncScreenAccessibility() {
    final router = GoRouter.of(context);
    final location = router.routeInformationProvider.value.uri.toString();

    final index = _navigationItems.indexWhere((item) => location.contains(item.route));
    if (index >= 0 && index != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentIndex = index);
      });
    }

    if (location == _lastAnnouncedLocation || !_voiceReady) return;
    _lastAnnouncedLocation = location;
    final announcement = _screenAnnouncement(location);
    if (announcement == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _voiceCommands.speak(announcement);
    });
  }

  String? _screenAnnouncement(String location) {
    if (location.contains(AppConstants.homeRoute)) {
      return 'Home dashboard. Say Hey AR, then say open navigation, open devices, open camera, or emergency.';
    }
    if (location.contains(AppConstants.voiceNavigationRoute)) {
      return 'Voice navigation. Say Hey AR, then say navigate to followed by your destination.';
    }
    if (location.contains(AppConstants.liveNavigationRoute)) {
      return 'Live map navigation. Say Hey AR for commands, or say emergency anytime.';
    }
    if (location.contains(AppConstants.smartDeviceHubRoute)) {
      return 'Smart Device Hub. Say Hey AR, then say scan nearby devices, connect first device, or disconnect Bluetooth.';
    }
    if (location.contains(AppConstants.cameraAwarenessRoute)) {
      return 'Camera awareness. Point your phone forward. Say Hey AR for navigation commands, or emergency for SOS.';
    }
    if (location.contains(AppConstants.aiAssistantRoute)) {
      return 'AI assistant. Say Hey AR, then ask for accessibility or navigation help.';
    }
    if (location.contains(AppConstants.profileRoute)) {
      return 'Profile and preferences. Say Hey AR, then open settings or open SOS.';
    }
    if (location.contains(AppConstants.emergencySOSRoute)) {
      return 'Emergency SOS. Long press the SOS button, add trusted contacts, or say emergency to activate the alarm.';
    }
    if (location.contains(AppConstants.accessibilitySettingsRoute)) {
      return 'Accessibility settings. Adjust voice speed, haptics, contrast, and comfort controls.';
    }
    if (location.contains(AppConstants.aboutRoute)) {
      return 'About AR NavSense. Project details and app information.';
    }
    return null;
  }

  void _updateCurrentIndex() {
    final router = GoRouter.of(context);
    final location = router.routeInformationProvider.value.uri.toString();
    for (int i = 0; i < _navigationItems.length; i++) {
      if (location.contains(_navigationItems[i].route)) {
        setState(() {
          _currentIndex = i;
        });
        break;
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    context.go(_navigationItems[index].route);
  }

  @override
  Widget build(BuildContext context) {
    _syncScreenAccessibility();
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          Positioned(
            left: 16,
            right: 16,
            bottom: 108,
            child: _VoiceListeningBanner(
              ready: _voiceReady,
              status: _voiceStatus,
              onHelp: () => _handleVoiceCommand(
                const VoiceCommandResult(
                  spokenReply:
                      'Say Hey AR to wake me. Then say open home, open navigation, open devices, open assistant, open camera, open settings, emergency, or navigate to followed by a place name.',
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: GlassmorphicBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: _navigationItems,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() => _currentIndex = _navigationItems.length - 1);
                context.go(AppConstants.emergencySOSRoute);
              },
              backgroundColor: AppTheme.error,
              icon: const Icon(Icons.emergency_share),
              label: const Text('SOS'),
            )
          : null,
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class _VoiceListeningBanner extends StatelessWidget {
  final bool ready;
  final String status;
  final VoidCallback onHelp;

  const _VoiceListeningBanner({
    required this.ready,
    required this.status,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      liveRegion: true,
      label: ready
          ? 'Voice assistant active. Last heard: $status'
          : 'Voice assistant is starting',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryGreen.withOpacity(0.96),
                  AppTheme.accentBlue.withOpacity(0.96),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentBlue.withOpacity(0.26),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.18),
                    border: Border.all(color: Colors.white.withOpacity(0.35)),
                  ),
                  child: Icon(
                    ready ? Icons.graphic_eq : Icons.mic_none,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ready ? 'Listening automatically' : 'Starting voice assistant',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(isDark ? 0.92 : 0.86),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onHelp,
                  tooltip: 'Speak voice commands',
                  icon: const Icon(Icons.help_outline, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GlassmorphicBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavigationItem> items;

  const GlassmorphicBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 76,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0B2029).withOpacity(0.92)
            : Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : AppTheme.premiumLine,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.ink.withOpacity(isDark ? 0.35 : 0.12),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  label: item.label,
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.primaryColor.withOpacity(isDark ? 0.22 : 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected
                                ? theme.primaryColor
                                : (isDark
                                      ? Colors.white.withOpacity(0.58)
                                      : AppTheme.textSecondary),
                            size: 22,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected
                                  ? theme.primaryColor
                                  : (isDark
                                        ? Colors.white.withOpacity(0.58)
                                        : AppTheme.textSecondary),
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
