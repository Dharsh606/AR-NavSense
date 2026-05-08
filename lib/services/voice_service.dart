import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText speech = SpeechToText();
  final FlutterTts tts = FlutterTts();

  Future<bool> initialize() async {
    await tts.setLanguage('en-US');
    await tts.setSpeechRate(0.48);
    await tts.setPitch(1.0);
    return speech.initialize();
  }

  Future<void> speak(String text) async {
    await tts.stop();
    await tts.speak(text);
  }

  Future<void> listen({
    required void Function(String words, bool finalResult) onResult,
  }) async {
    final available = await speech.initialize();
    if (!available) {
      throw Exception('Speech recognition is not available on this device.');
    }
    await speech.listen(
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      listenMode: ListenMode.dictation,
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
    );
  }

  Future<void> stopListening() => speech.stop();
}
