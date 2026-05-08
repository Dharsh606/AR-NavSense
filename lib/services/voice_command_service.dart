import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/navigation_models.dart';
import 'navigation_api_service.dart';
import 'voice_service.dart';

class VoiceCommandResult {
  final String spokenReply;
  final String? route;
  final PlaceSuggestion? destination;
  final bool emergency;

  const VoiceCommandResult({
    required this.spokenReply,
    this.route,
    this.destination,
    this.emergency = false,
  });
}

class VoiceCommandService {
  final VoiceService _voice;
  final NavigationApiService _navigationApi;
  bool _isListening = false;
  bool _isDisposed = false;
  bool _wakeArmed = false;
  Timer? _wakeTimer;

  VoiceCommandService({
    VoiceService? voice,
    NavigationApiService? navigationApi,
  })  : _voice = voice ?? VoiceService(),
        _navigationApi = navigationApi ?? NavigationApiService();

  bool get isListening => _isListening;

  Future<void> initialize() => _voice.initialize();

  Future<void> speak(String text) => _voice.speak(text);

  Future<void> startContinuousListening({
    required ValueChanged<String> onHeard,
    required Future<void> Function(VoiceCommandResult result) onCommand,
  }) async {
    if (_isDisposed || _isListening) return;
    _isListening = true;

    try {
      await _voice.listen(onResult: (words, finalResult) async {
        final cleanWords = words.trim();
        if (cleanWords.isNotEmpty) onHeard(cleanWords);
        if (!finalResult || cleanWords.isEmpty) return;

        final result = await process(cleanWords);
        if (result != null) {
          await _voice.stopListening();
          _isListening = false;
          await onCommand(result);
          _restart(onHeard: onHeard, onCommand: onCommand);
        }
      });
    } catch (_) {
      _isListening = false;
      _restart(onHeard: onHeard, onCommand: onCommand, delay: const Duration(seconds: 3));
    }
  }

  Future<void> stop() async {
    _isListening = false;
    await _voice.stopListening();
  }

  Future<VoiceCommandResult?> process(String command) async {
    final lower = command.toLowerCase().trim();

    if (_isEmergencyCommand(lower)) {
      _disarmWake();
      return const VoiceCommandResult(
        spokenReply: 'Emergency detected. Opening SOS and starting alert.',
        emergency: true,
      );
    }

    final wakeRemainder = _extractWakeRemainder(lower);
    if (wakeRemainder != null) {
      _armWake();
      if (wakeRemainder.isEmpty) {
        return const VoiceCommandResult(
          spokenReply:
              'Yes, I am listening. Say a command like navigate to home, open SOS, scan devices, or open camera.',
        );
      }

      final result = await _processCommand(wakeRemainder);
      _disarmWake();
      return result ??
          VoiceCommandResult(
            spokenReply:
                'I heard $wakeRemainder, but I need a clearer command. Say help for examples.',
          );
    }

    if (!_wakeArmed) return null;

    _disarmWake();
    return _processCommand(lower);
  }

  Future<VoiceCommandResult?> _processCommand(String lower) async {
    if (lower.contains('help') || lower.contains('what can i say')) {
      return const VoiceCommandResult(
        spokenReply:
            'Wake me by saying Hey AR. Then say open home, open navigation, open devices, open assistant, open camera, open settings, emergency, or navigate to followed by a place name.',
      );
    }
    if (_isEmergencyCommand(lower)) {
      return const VoiceCommandResult(
        spokenReply: 'Emergency detected. Opening SOS and starting alert.',
        emergency: true,
      );
    }
    if (lower.contains('open home') || lower == 'home') {
      return const VoiceCommandResult(spokenReply: 'Opening home dashboard.', route: '/home');
    }
    if (lower.contains('open navigation') || lower.contains('voice navigation')) {
      return const VoiceCommandResult(spokenReply: 'Opening voice navigation.', route: '/voice-navigation');
    }
    if (lower.contains('open devices') ||
        lower.contains('smart device') ||
        lower.contains('bluetooth') ||
        lower.contains('scan nearby devices') ||
        lower.contains('connect first device') ||
        lower.contains('disconnect bluetooth') ||
        lower.contains('open smart glasses')) {
      return const VoiceCommandResult(spokenReply: 'Opening smart device hub.', route: '/smart-device-hub');
    }
    if (lower.contains('open assistant') || lower.contains('ai assistant')) {
      return const VoiceCommandResult(spokenReply: 'Opening AI assistant.', route: '/ai-assistant');
    }
    if (lower.contains('open profile') || lower.contains('preferences')) {
      return const VoiceCommandResult(spokenReply: 'Opening profile and preferences.', route: '/profile');
    }
    if (lower.contains('open camera') || lower.contains('camera awareness')) {
      return const VoiceCommandResult(spokenReply: 'Opening camera awareness.', route: '/camera-awareness');
    }
    if (lower.contains('open settings') || lower.contains('accessibility settings')) {
      return const VoiceCommandResult(spokenReply: 'Opening accessibility settings.', route: '/accessibility-settings');
    }

    final destinationQuery = _extractDestination(lower);
    if (destinationQuery != null && destinationQuery.length > 2) {
      final places = await _navigationApi.searchPlaces(destinationQuery);
      if (places.isEmpty) {
        return VoiceCommandResult(spokenReply: 'I could not find $destinationQuery.');
      }
      return VoiceCommandResult(
        spokenReply: 'I found ${places.first.name}. Opening live navigation.',
        route: '/live-navigation',
        destination: places.first,
      );
    }

    return null;
  }

  bool _isEmergencyCommand(String lower) {
    return lower.contains('emergency') ||
        lower.contains('sos') ||
        lower.contains('open sos') ||
        lower.contains('open emergency');
  }

  String? _extractWakeRemainder(String lower) {
    const wakePhrases = [
      'hey ar',
      'hay ar',
      'hello ar',
      'hi ar',
      'hey a r',
      'hay a r',
      'hello a r',
    ];

    for (final phrase in wakePhrases) {
      final index = lower.indexOf(phrase);
      if (index >= 0) {
        return lower.substring(index + phrase.length).trim();
      }
    }
    return null;
  }

  void _armWake() {
    _wakeArmed = true;
    _wakeTimer?.cancel();
    _wakeTimer = Timer(const Duration(seconds: 12), _disarmWake);
  }

  void _disarmWake() {
    _wakeArmed = false;
    _wakeTimer?.cancel();
    _wakeTimer = null;
  }

  String? _extractDestination(String lower) {
    const triggers = ['navigate to ', 'take me to ', 'directions to ', 'go to ', 'find '];
    for (final trigger in triggers) {
      final index = lower.indexOf(trigger);
      if (index >= 0) {
        return lower.substring(index + trigger.length).trim();
      }
    }
    return null;
  }

  void _restart({
    required ValueChanged<String> onHeard,
    required Future<void> Function(VoiceCommandResult result) onCommand,
    Duration delay = const Duration(milliseconds: 900),
  }) {
    if (_isDisposed) return;
    Timer(delay, () {
      if (!_isDisposed) {
        startContinuousListening(onHeard: onHeard, onCommand: onCommand);
      }
    });
  }

  void dispose() {
    _isDisposed = true;
    _wakeTimer?.cancel();
    stop();
  }
}
