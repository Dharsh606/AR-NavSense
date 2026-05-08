import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue;

import '../constants/app_constants.dart';
import '../services/bluetooth_service.dart';
import '../services/voice_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glassmorphic_button.dart';
import '../widgets/glassmorphic_container.dart';

class SmartDeviceHubScreen extends StatefulWidget {
  const SmartDeviceHubScreen({Key? key}) : super(key: key);

  @override
  State<SmartDeviceHubScreen> createState() => _SmartDeviceHubScreenState();
}

class _SmartDeviceHubScreenState extends State<SmartDeviceHubScreen> {
  final _bluetooth = BluetoothService();
  final _voice = VoiceService();
  StreamSubscription? _scanSub;
  final List<blue.ScanResult> _devices = [];
  bool _isListening = false;
  bool _isScanning = false;
  String _voiceCommand = 'Say “scan nearby devices”';

  @override
  void initState() {
    super.initState();
    _voice.initialize();
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _bluetooth.stopScan();
    super.dispose();
  }

  Future<void> _startListening() async {
    setState(() => _isListening = true);
    try {
      await _voice.listen(onResult: (words, finalResult) {
        setState(() => _voiceCommand = words);
        if (finalResult) _processVoiceCommand(words.toLowerCase());
      });
    } catch (error) {
      setState(() {
        _isListening = false;
        _voiceCommand = error.toString();
      });
    }
  }

  Future<void> _stopListening() async {
    await _voice.stopListening();
    setState(() => _isListening = false);
  }

  Future<void> _processVoiceCommand(String command) async {
    if (command.contains('scan')) {
      await _startScanning();
    } else if (command.contains('connect first')) {
      if (_devices.isEmpty) {
        await _voice.speak('No devices found yet. Say scan nearby devices.');
      } else {
        await _connectToDevice(_devices.first.device);
      }
    } else if (command.contains('disconnect')) {
      for (final result in _devices) {
        await result.device.disconnect();
      }
      await _voice.speak('Bluetooth devices disconnected.');
      setState(() {});
    } else if (command.contains('open smart glasses') || command.contains('smart glasses')) {
      final match = _devices.where((item) {
        final name = _deviceName(item).toLowerCase();
        return name.contains('glass') || name.contains('vision');
      }).toList();
      if (match.isEmpty) {
        await _voice.speak('No smart glasses found. I can scan again.');
        await _startScanning();
      } else {
        await _connectToDevice(match.first.device);
      }
    }
  }

  Future<void> _startScanning() async {
    await _scanSub?.cancel();
    setState(() {
      _isScanning = true;
      _devices.clear();
      _voiceCommand = 'Scanning nearby Bluetooth devices...';
    });
    await _voice.speak('Scanning nearby Bluetooth devices.');
    _scanSub = _bluetooth.scan().listen((results) {
      final visible = results.where((result) => _deviceName(result).isNotEmpty).toList()
        ..sort((a, b) => b.rssi.compareTo(a.rssi));
      setState(() {
        _devices
          ..clear()
          ..addAll(visible);
      });
    }, onError: (error) {
      setState(() {
        _isScanning = false;
        _voiceCommand = error.toString();
      });
    }, onDone: () async {
      setState(() => _isScanning = false);
      await _voice.speak('Found ${_devices.length} visible Bluetooth devices.');
    });
    Future.delayed(const Duration(seconds: 9), () {
      if (mounted) setState(() => _isScanning = false);
    });
  }

  Future<void> _connectToDevice(blue.BluetoothDevice device) async {
    final name = device.platformName.isNotEmpty ? device.platformName : 'selected device';
    await _voice.speak('Connecting to $name.');
    try {
      await _bluetooth.connect(device);
      await _voice.speak('$name connected.');
      setState(() {});
    } catch (error) {
      await _voice.speak('Connection failed.');
      setState(() => _voiceCommand = error.toString());
    }
  }

  String _deviceName(blue.ScanResult result) {
    if (result.device.platformName.isNotEmpty) return result.device.platformName;
    return result.advertisementData.advName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Device Hub'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [Color(0xFFEAFBF2), Color(0xFFE8F7FF), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              _BluetoothHalo(scanning: _isScanning).animate().fadeIn(duration: 500.ms),
              Padding(
                padding: const EdgeInsets.all(16),
                child: GlassmorphicContainer(
                  padding: const EdgeInsets.all(18),
                  borderRadius: 28,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Text(
                        _voiceCommand.isEmpty ? 'Bluetooth voice control ready' : _voiceCommand,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          GlassmorphicButton(
                            onPressed: _isListening ? _stopListening : _startListening,
                            backgroundColor: _isListening ? AppTheme.error : AppTheme.primaryGreen,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(_isListening ? 'Listening' : 'Voice'),
                              ],
                            ),
                          ),
                          GlassmorphicButton(
                            onPressed: _startScanning,
                            backgroundColor: AppTheme.accentBlue,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.bluetooth_searching, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Scan'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: _devices.isEmpty
                    ? _EmptyDeviceState(scanning: _isScanning)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: _devices.length,
                        itemBuilder: (context, index) {
                          final result = _devices[index];
                          return _DeviceCard(
                            result: result,
                            name: _deviceName(result),
                            onTap: () => _connectToDevice(result.device),
                          ).animate().fadeIn(delay: (70 * index).ms).slideX(begin: .08);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BluetoothHalo extends StatelessWidget {
  final bool scanning;

  const _BluetoothHalo({required this.scanning});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < 3; i++)
            Container(
              width: 110 + (i * 42),
              height: 110 + (i * 42),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accentBlue.withOpacity(.24), width: 2),
              ),
            )
                .animate(target: scanning ? 1 : 0, onPlay: (controller) {
                  if (scanning) controller.repeat();
                })
                .scale(begin: const Offset(.82, .82), end: const Offset(1.12, 1.12), duration: (1200 + i * 300).ms)
                .fade(begin: .65, end: .08),
          Container(
            width: 118,
            height: 118,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.accentBlue]),
            ),
            child: const Icon(Icons.bluetooth_connected, size: 58, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _EmptyDeviceState extends StatelessWidget {
  final bool scanning;

  const _EmptyDeviceState({required this.scanning});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        scanning ? 'Scanning nearby hardware...' : 'No visible Bluetooth devices yet',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final blue.ScanResult result;
  final String name;
  final VoidCallback onTap;

  const _DeviceCard({required this.result, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final icon = _iconFor(name);
    final color = result.rssi > -65 ? AppTheme.success : AppTheme.warning;

    return Semantics(
      button: true,
      label: 'Connect to $name, signal ${result.rssi} dBm',
      child: GestureDetector(
        onTap: onTap,
        child: GlassmorphicContainer(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          borderRadius: 24,
          color: Colors.white,
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentBlue.withOpacity(.12),
                  border: Border.all(color: AppTheme.accentBlue.withOpacity(.55)),
                ),
                child: Icon(icon, color: AppTheme.accentBlue),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_typeFor(name)} • ${result.rssi} dBm',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.signal_cellular_alt, color: color),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('glass')) return Icons.visibility;
    if (lower.contains('band') || lower.contains('watch')) return Icons.watch;
    if (lower.contains('speaker')) return Icons.speaker;
    if (lower.contains('bud') || lower.contains('head') || lower.contains('airpod')) return Icons.headphones;
    return Icons.bluetooth;
  }

  String _typeFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('glass')) return 'Smart glasses';
    if (lower.contains('band') || lower.contains('watch')) return 'Smart band';
    if (lower.contains('speaker')) return 'Speaker';
    if (lower.contains('bud') || lower.contains('head') || lower.contains('airpod')) return 'Earbuds';
    return AppConstants.supportedDeviceTypes.last;
  }
}
