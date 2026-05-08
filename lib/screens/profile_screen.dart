import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../theme/app_theme.dart';
import '../widgets/glassmorphic_container.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Preferences'), centerTitle: true),
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
                padding: const EdgeInsets.all(20),
                borderRadius: 28,
                color: Colors.white,
                child: Row(
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.accentBlue]),
                      ),
                      child: const Icon(Icons.accessibility_new, color: Colors.white, size: 38),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('NavSense User', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text(AppConstants.tagline, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _ProfileTile(icon: Icons.settings_accessibility, title: 'Accessibility Settings', onTap: () => context.push(AppConstants.accessibilitySettingsRoute)),
              _ProfileTile(icon: Icons.camera_alt, title: 'Camera Awareness', onTap: () => context.push(AppConstants.cameraAwarenessRoute)),
              _ProfileTile(icon: Icons.emergency_share, title: 'Emergency Contacts & SOS', onTap: () => context.push(AppConstants.emergencySOSRoute)),
              _ProfileTile(icon: Icons.info, title: 'About Project', onTap: () => context.push(AppConstants.aboutRoute)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(4),
      borderRadius: 24,
      color: Colors.white,
      child: ListTile(
        minVerticalPadding: 16,
        leading: Icon(icon, color: AppTheme.primaryGreen),
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
