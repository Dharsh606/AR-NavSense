import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/assistant_message.dart';
import '../services/voice_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glassmorphic_container.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({Key? key}) : super(key: key);

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final _voice = VoiceService();
  final _controller = TextEditingController();
  final List<AssistantMessage> _messages = [
    AssistantMessage(
      text: 'Hi, I am NavSense. Ask me for navigation help, safety guidance, Bluetooth support, or accessibility settings.',
      isUser: false,
    ),
  ];
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _voice.initialize();
  }

  Future<void> _listen() async {
    setState(() => _listening = true);
    await _voice.listen(onResult: (words, finalResult) {
      if (finalResult && words.trim().isNotEmpty) {
        _send(words);
        setState(() => _listening = false);
      }
    });
  }

  Future<void> _send(String text) async {
    _controller.clear();
    final answer = _answerFor(text);
    setState(() {
      _messages.add(AssistantMessage(text: text, isUser: true));
      _messages.add(AssistantMessage(text: answer, isUser: false));
    });
    await _voice.speak(answer);
  }

  String _answerFor(String prompt) {
    final lower = prompt.toLowerCase();
    if (lower.contains('navigate') || lower.contains('route') || lower.contains('destination')) {
      return 'Say “navigate to” followed by the place name. I will search OpenStreetMap and create a walking route with OpenRouteService.';
    }
    if (lower.contains('bluetooth') || lower.contains('device')) {
      return 'Open Smart Device Hub and say “scan nearby devices” or “connect first device”. I can help pair earbuds, speakers, smart bands, and smart glasses.';
    }
    if (lower.contains('emergency') || lower.contains('sos')) {
      return 'Long press the SOS button. I will vibrate the phone and prepare your live OpenStreetMap location for emergency sharing.';
    }
    if (lower.contains('camera') || lower.contains('obstacle')) {
      return 'Camera Awareness opens the real Android camera and prepares the environment stream for object detection.';
    }
    if (lower.contains('settings') || lower.contains('voice speed')) {
      return 'Accessibility Settings lets you adjust voice speed, haptics, contrast, and touch comfort.';
    }
    return 'I can help you navigate, scan Bluetooth devices, use emergency SOS, adjust accessibility settings, and understand the safest next action.';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant'), centerTitle: true),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAFBF2), Color(0xFFE8F7FF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: GlassmorphicContainer(
                  padding: const EdgeInsets.all(18),
                  borderRadius: 28,
                  color: Colors.white,
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.accentBlue]),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Conversational accessibility guidance with voice responses',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 450.ms).slideY(begin: -.1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return Align(
                      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 310),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: message.isUser ? AppTheme.primaryGreen : Colors.white.withOpacity(.78),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 14, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(color: message.isUser ? Colors.white : AppTheme.textPrimary, height: 1.35),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: _send,
                        decoration: const InputDecoration(hintText: 'Ask NavSense...'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FloatingActionButton(
                      heroTag: 'assistantVoice',
                      onPressed: _listening ? null : _listen,
                      child: Icon(_listening ? Icons.graphic_eq : Icons.mic),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      heroTag: 'assistantSend',
                      onPressed: () {
                        final text = _controller.text.trim();
                        if (text.isNotEmpty) _send(text);
                      },
                      child: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
