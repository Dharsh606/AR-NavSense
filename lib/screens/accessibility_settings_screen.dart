import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../theme/app_theme.dart';
import '../widgets/glassmorphic_container.dart';

class AccessibilitySettingsScreen extends StatefulWidget {
  const AccessibilitySettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccessibilitySettingsScreen> createState() => _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState extends State<AccessibilitySettingsScreen> {
  double _speechRate = AppConstants.defaultSpeechRate;
  double _fontSize = AppConstants.defaultFontSize;
  double _vibration = .7;
  bool _voiceEnabled = true;
  bool _hapticEnabled = true;
  bool _highContrast = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _speechRate = prefs.getDouble(AppConstants.speechRateKey) ?? _speechRate;
      _fontSize = prefs.getDouble(AppConstants.fontSizeKey) ?? _fontSize;
      _voiceEnabled = prefs.getBool(AppConstants.voiceEnabledKey) ?? _voiceEnabled;
      _hapticEnabled = prefs.getBool(AppConstants.hapticEnabledKey) ?? _hapticEnabled;
      _highContrast = prefs.getBool('high_contrast') ?? _highContrast;
      _vibration = prefs.getDouble('vibration_intensity') ?? _vibration;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.speechRateKey, _speechRate);
    await prefs.setDouble(AppConstants.fontSizeKey, _fontSize);
    await prefs.setBool(AppConstants.voiceEnabledKey, _voiceEnabled);
    await prefs.setBool(AppConstants.hapticEnabledKey, _hapticEnabled);
    await prefs.setBool('high_contrast', _highContrast);
    await prefs.setDouble('vibration_intensity', _vibration);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accessibility Settings'), centerTitle: true),
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
              _Header(fontSize: _fontSize),
              _SettingsCard(
                title: 'Voice Guidance',
                icon: Icons.record_voice_over,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _voiceEnabled,
                    onChanged: (value) => setState(() {
                      _voiceEnabled = value;
                      _save();
                    }),
                    title: const Text('Voice-first interaction'),
                  ),
                  _SliderRow(
                    label: 'Voice speed',
                    value: _speechRate,
                    min: AppConstants.minSpeechRate,
                    max: AppConstants.maxSpeechRate,
                    onChanged: (value) => setState(() {
                      _speechRate = value;
                      _save();
                    }),
                  ),
                ],
              ),
              _SettingsCard(
                title: 'Touch and Haptics',
                icon: Icons.vibration,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _hapticEnabled,
                    onChanged: (value) => setState(() {
                      _hapticEnabled = value;
                      _save();
                    }),
                    title: const Text('Haptic feedback'),
                  ),
                  _SliderRow(
                    label: 'Vibration intensity',
                    value: _vibration,
                    min: 0,
                    max: 1,
                    onChanged: (value) => setState(() {
                      _vibration = value;
                      _save();
                    }),
                  ),
                ],
              ),
              _SettingsCard(
                title: 'Visual Comfort',
                icon: Icons.contrast,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _highContrast,
                    onChanged: (value) => setState(() {
                      _highContrast = value;
                      _save();
                    }),
                    title: const Text('High contrast mode'),
                  ),
                  _SliderRow(
                    label: 'Interface text size',
                    value: _fontSize,
                    min: AppConstants.minFontSize,
                    max: AppConstants.maxFontSize,
                    onChanged: (value) => setState(() {
                      _fontSize = value;
                      _save();
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final double fontSize;

  const _Header({required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      borderRadius: 28,
      color: Colors.white,
      child: Text(
        'Large touch targets, voice guidance, strong feedback, and readable controls are tuned here.',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: fontSize),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      borderRadius: 28,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryGreen),
              const SizedBox(width: 10),
              Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}
