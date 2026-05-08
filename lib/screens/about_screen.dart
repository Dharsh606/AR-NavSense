import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_theme.dart';
import '../widgets/glassmorphic_container.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Project'), centerTitle: true),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAFBF2), Color(0xFFE8F7FF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GlassmorphicContainer(
                padding: const EdgeInsets.all(22),
                borderRadius: 30,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppConstants.appName, style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text(AppConstants.tagline, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.primaryGreen)),
                    const SizedBox(height: 18),
                    const Text(
                      'A native Flutter Android accessibility navigation product built around voice-first interaction, OpenStreetMap routing, real device permissions, Bluetooth scanning, camera awareness, emergency location sharing, haptics, and Android speech/TTS.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _Capability(title: 'Open navigation stack', body: 'OpenStreetMap tiles, Nominatim place search, and OpenRouteService walking directions.'),
              _Capability(title: 'Native Android capabilities', body: 'Location, camera, microphone, Bluetooth scan/connect, vibration, SMS sharing, and phone intents.'),
              _Capability(title: 'Accessibility-first UX', body: 'Large touch targets, voice responses, haptic feedback, high contrast preference controls, and minimal touch dependency.'),
              _Capability(title: 'Production path', body: 'Build with a free OpenRouteService key using --dart-define=OPENROUTE_API_KEY=your_key. Version ${AppConstants.version}.'),
            ],
          ),
        ),
      ),
    );
  }
}

class _Capability extends StatelessWidget {
  final String title;
  final String body;

  const _Capability({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppTheme.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
