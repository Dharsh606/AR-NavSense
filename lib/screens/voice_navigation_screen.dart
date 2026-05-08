import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../models/navigation_models.dart';
import '../services/navigation_api_service.dart';
import '../services/voice_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glassmorphic_container.dart';

class VoiceNavigationScreen extends StatefulWidget {
  const VoiceNavigationScreen({Key? key}) : super(key: key);

  @override
  State<VoiceNavigationScreen> createState() => _VoiceNavigationScreenState();
}

class _VoiceNavigationScreenState extends State<VoiceNavigationScreen> {
  final _voice = VoiceService();
  final _api = NavigationApiService();
  bool _ready = false;
  bool _listening = false;
  String _heard = 'Say “navigate to railway station”';
  List<PlaceSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final ready = await _voice.initialize();
    setState(() => _ready = ready);
    if (ready) {
      await _voice.speak('Voice navigation is ready. Tell me where you want to go.');
    }
  }

  Future<void> _toggleListening() async {
    if (_listening) {
      await _voice.stopListening();
      setState(() => _listening = false);
      return;
    }
    setState(() {
      _listening = true;
      _heard = 'Listening...';
    });
    try {
      await _voice.listen(onResult: (words, finalResult) {
        setState(() => _heard = words.isEmpty ? 'Listening...' : words);
        if (finalResult) {
          _process(words);
        }
      });
    } catch (error) {
      setState(() {
        _listening = false;
        _heard = error.toString();
      });
    }
  }

  Future<void> _process(String command) async {
    final destination = command
        .toLowerCase()
        .replaceAll('navigate to', '')
        .replaceAll('take me to', '')
        .replaceAll('directions to', '')
        .replaceAll('find', '')
        .trim();
    if (destination.isEmpty) {
      await _voice.speak('Please say a destination after navigate to.');
      return;
    }
    setState(() => _heard = 'Searching for $destination');
    try {
      final places = await _api.searchPlaces(destination);
      setState(() {
        _suggestions = places;
        _listening = false;
      });
      if (places.isEmpty) {
        await _voice.speak('I could not find $destination.');
      } else {
        await _voice.speak('I found ${places.first.name}. Starting live navigation.');
        if (mounted) {
          context.push(AppConstants.liveNavigationRoute, extra: places.first);
        }
      }
    } catch (error) {
      setState(() {
        _listening = false;
        _heard = error.toString();
      });
      await _voice.speak('Search failed. Please check your internet connection.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Navigation'), centerTitle: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [Color(0xFFEAFBF2), Color(0xFFE8F7FF), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Spacer(),
                _VoiceOrb(active: _listening, enabled: _ready, onTap: _toggleListening),
                const SizedBox(height: 28),
                Text(
                  _listening ? 'Listening for destination' : 'Voice-first navigation',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  _heard,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                GlassmorphicContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 26,
                  color: Colors.white,
                  child: Column(
                    children: [
                      _CommandChip(text: 'Navigate to hospital'),
                      _CommandChip(text: 'Take me to bus stop'),
                      _CommandChip(text: 'Find pharmacy nearby'),
                      if (_suggestions.isNotEmpty)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.place, color: AppTheme.primaryGreen),
                          title: Text(
                            _suggestions.first.name,
                            style: const TextStyle(color: AppTheme.textPrimary),
                          ),
                          subtitle: Text(
                            _suggestions.first.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                        ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: .15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VoiceOrb extends StatelessWidget {
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  const _VoiceOrb({required this.active, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: active ? 'Stop listening' : 'Start voice navigation listening',
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.accentBlue]),
            boxShadow: [
              BoxShadow(
                color: (active ? AppTheme.accentBlue : AppTheme.primaryGreen).withOpacity(.38),
                blurRadius: 42,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Icon(active ? Icons.graphic_eq : Icons.mic, color: Colors.white, size: 82),
        )
            .animate(target: active ? 1 : 0, onPlay: (controller) {
              if (active) controller.repeat(reverse: true);
            })
            .scale(begin: const Offset(.96, .96), end: const Offset(1.06, 1.06), duration: 850.ms),
      ),
    );
  }
}

class _CommandChip extends StatelessWidget {
  final String text;

  const _CommandChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.record_voice_over, color: AppTheme.accentBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
