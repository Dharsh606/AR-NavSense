import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../theme/app_theme.dart';
import '../widgets/glassmorphic_container.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? AppTheme.premiumDarkBackground : AppTheme.premiumBackground,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 150),
            children: [
              _TopBar(isDark: isDark),
              const SizedBox(height: 18),
              _HeroPanel(isDark: isDark),
              const SizedBox(height: 18),
              _VoiceCommandPanel(isDark: isDark),
              const SizedBox(height: 20),
              Text(
                'Core controls',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: isDark ? Colors.white : AppTheme.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              _ActionGrid(),
              const SizedBox(height: 20),
              _SafetyStrip(isDark: isDark),
              const SizedBox(height: 18),
              _RecentRoutes(isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool isDark;

  const _TopBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlassmorphicContainer(
          width: 58,
          height: 58,
          borderRadius: 18,
          color: Colors.white.withOpacity(isDark ? 0.12 : 0.88),
          borderColor: isDark ? Colors.white.withOpacity(0.12) : AppTheme.premiumLine,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Image.asset('assets/images/app_logo_icon.png'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppTheme.textPrimary,
                    ),
              ),
              Text(
                AppConstants.tagline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? Colors.white.withOpacity(0.72)
                          : AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        _StatusBadge(isDark: isDark),
      ],
    ).animate().fadeIn(duration: 420.ms).slideY(begin: -.08);
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isDark;

  const _StatusBadge({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.12) : AppTheme.premiumLine,
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, size: 18, color: AppTheme.primaryGreen),
          SizedBox(width: 6),
          Text('Active'),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final bool isDark;

  const _HeroPanel({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00A870), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentBlue.withOpacity(0.22),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Voice-first navigation is ready',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                ),
              ),
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.35)),
                ),
                child: const Icon(Icons.graphic_eq, color: Colors.white, size: 42),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Say "navigate to hospital", "open SOS", or "scan nearby devices".',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.92),
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _MetricPill(icon: Icons.mic, label: 'Listening'),
              const SizedBox(width: 10),
              _MetricPill(icon: Icons.location_on, label: 'GPS ready'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 520.ms).slideY(begin: .08);
  }
}

class _MetricPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.28)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceCommandPanel extends StatelessWidget {
  final bool isDark;

  const _VoiceCommandPanel({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 26,
      color: isDark ? const Color(0xFF102D38) : Colors.white,
      borderColor: isDark ? Colors.white.withOpacity(0.12) : AppTheme.premiumLine,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryGreen.withOpacity(0.12),
                ),
                child: const Icon(Icons.record_voice_over, color: AppTheme.primaryGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Hands-free command layer',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppTheme.textPrimary,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _CommandChip(label: 'emergency'),
              _CommandChip(label: 'open SOS'),
              _CommandChip(label: 'navigate to home'),
              _CommandChip(label: 'open devices'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommandChip extends StatelessWidget {
  final String label;

  const _CommandChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.aquaMist,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.premiumLine),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.darkBlue,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData('Voice Navigation', Icons.mic, AppTheme.primaryGreen, AppConstants.voiceNavigationRoute),
      _ActionData('Smart Devices', Icons.bluetooth, AppTheme.accentBlue, AppConstants.smartDeviceHubRoute),
      _ActionData('Live Map', Icons.navigation, AppTheme.darkGreen, AppConstants.liveNavigationRoute),
      _ActionData('AI Assistant', Icons.auto_awesome, const Color(0xFF7C3AED), AppConstants.aiAssistantRoute),
      _ActionData('Camera Awareness', Icons.camera_alt, const Color(0xFF0F766E), AppConstants.cameraAwarenessRoute),
      _ActionData('Emergency SOS', Icons.emergency_share, AppTheme.error, AppConstants.emergencySOSRoute),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.04,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return _ActionCard(action: action, delay: Duration(milliseconds: 60 * index));
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  final _ActionData action;
  final Duration delay;

  const _ActionCard({required this.action, required this.delay});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: action.title,
      child: GestureDetector(
        onTap: () => context.push(action.route),
        child: GlassmorphicContainer(
          padding: const EdgeInsets.all(15),
          borderRadius: 24,
          color: isDark ? const Color(0xFF102D38) : Colors.white,
          borderColor: action.color.withOpacity(0.28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(action.icon, color: action.color, size: 28),
              ),
              const Spacer(),
              Text(
                action.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 5),
              Text(
                'Open',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: action.color,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 360.ms, delay: delay).slideY(begin: .08);
  }
}

class _SafetyStrip extends StatelessWidget {
  final bool isDark;

  const _SafetyStrip({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 26,
      color: isDark ? const Color(0xFF102D38) : Colors.white,
      borderColor: AppTheme.error.withOpacity(0.28),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.emergency_share, color: AppTheme.error),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency ready',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppTheme.textPrimary,
                      ),
                ),
                Text(
                  'Say "emergency" to open SOS, start alarm, and prepare live-location SMS.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push(AppConstants.emergencySOSRoute),
            icon: const Icon(Icons.arrow_forward, color: AppTheme.error),
          ),
        ],
      ),
    );
  }
}

class _RecentRoutes extends StatelessWidget {
  final bool isDark;

  const _RecentRoutes({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 26,
      color: isDark ? const Color(0xFF102D38) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accessible presets',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          const _PresetRow(icon: Icons.home, title: 'Home', subtitle: 'Saved safe destination'),
          const _PresetRow(icon: Icons.local_hospital, title: 'Hospital', subtitle: 'Emergency navigation phrase'),
          const _PresetRow(icon: Icons.directions_bus, title: 'Bus stop', subtitle: 'Nearby public transit support'),
          const SizedBox(height: 12),
          Text(
            'Build ${AppConstants.version}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white.withOpacity(0.55) : AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _PresetRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PresetRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionData {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  const _ActionData(this.title, this.icon, this.color, this.route);
}
