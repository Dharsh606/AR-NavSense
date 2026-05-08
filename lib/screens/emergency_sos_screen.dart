import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../models/emergency_contact.dart';
import '../services/emergency_service.dart';
import '../services/location_service.dart';
import '../services/voice_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glassmorphic_container.dart';

class EmergencySOSScreen extends StatefulWidget {
  final bool autoActivate;

  const EmergencySOSScreen({Key? key, this.autoActivate = false})
      : super(key: key);

  @override
  State<EmergencySOSScreen> createState() => _EmergencySOSScreenState();
}

class _EmergencySOSScreenState extends State<EmergencySOSScreen> {
  late final EmergencyService _emergency = EmergencyService(LocationService());
  final _voice = VoiceService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final List<EmergencyContact> _contacts = [];
  Timer? _alarmTimer;
  String _status =
      'Say "emergency" from anywhere, or long press SOS to activate.';
  bool _active = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await _voice.initialize();
    await _loadContacts();
    await _maybeShowSetupWizard();
    if (widget.autoActivate && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _activate());
    }
  }

  @override
  void dispose() {
    _stopAlarm();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contacts =
        EmergencyContact.decodeList(prefs.getString(AppConstants.emergencyContactsKey));
    setState(() {
      _contacts
        ..clear()
        ..addAll(contacts);
    });
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.emergencyContactsKey,
      EmergencyContact.encodeList(_contacts),
    );
  }

  Future<void> _maybeShowSetupWizard() async {
    if (widget.autoActivate || _contacts.isNotEmpty || !mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(AppConstants.emergencySetupWizardSeenKey) ?? false;
    if (seen || !mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showSetupWizard();
    });
  }

  Future<void> _showSetupWizard() async {
    final wizardNameController = TextEditingController();
    final wizardPhoneController = TextEditingController();

    await _voice.speak(
      'SOS setup wizard. Add one trusted emergency contact so AR NavSense can prepare live location alerts.',
    );

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text(
            'SOS setup wizard',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add a trusted person now. During an emergency, the app prepares a live location SMS for this contact.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: wizardNameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Trusted contact name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: wizardPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          actions: [
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool(AppConstants.emergencySetupWizardSeenKey, true);
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
              child: const Text('Later'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final name = wizardNameController.text.trim();
                final phone = wizardPhoneController.text.trim();
                if (name.isEmpty || phone.isEmpty) {
                  await _voice.speak('Please enter contact name and phone number.');
                  return;
                }

                setState(() {
                  _contacts.add(EmergencyContact(name: name, phone: phone));
                });
                await _saveContacts();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool(AppConstants.emergencySetupWizardSeenKey, true);
                await _voice.speak('Emergency contact saved.');
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
              icon: const Icon(Icons.verified_user),
              label: const Text('Save contact'),
            ),
          ],
        );
      },
    );

    wizardNameController.dispose();
    wizardPhoneController.dispose();
  }

  Future<void> _openSetupWizardAgain() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.emergencySetupWizardSeenKey, false);
    await _showSetupWizard();
  }

  Future<void> _activate() async {
    if (_sending) return;
    setState(() {
      _active = true;
      _sending = true;
      _status = 'Emergency alarm active. Preparing live location alert...';
    });
    _startAlarm();
    await _voice.speak(
      'Emergency SOS activated. Alarm is on. Preparing location alert for your emergency contacts.',
    );

    try {
      if (_contacts.isEmpty) {
        setState(() {
          _sending = false;
          _status =
              'No emergency contacts saved. Add at least one trusted contact below.';
        });
        await _voice.speak('No emergency contacts are saved. Please add a contact.');
        return;
      }

      await _emergency.shareLocationToContacts(_contacts);
      setState(() {
        _sending = false;
        _status =
            'Alert prepared for ${_contacts.length} contact(s). Confirm the SMS in your phone messaging app.';
      });
      await _voice.speak(
        'Emergency message is ready. Please confirm sending in the SMS app.',
      );
    } catch (error) {
      setState(() {
        _sending = false;
        _status = error.toString();
      });
      await _voice.speak('Emergency alert could not be prepared.');
    }
  }

  void _startAlarm() {
    _alarmTimer?.cancel();
    _emergency.pulse();
    _alarmTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _emergency.pulse();
    });
  }

  void _stopAlarm() {
    _alarmTimer?.cancel();
    _alarmTimer = null;
  }

  void _cancelEmergency() {
    _stopAlarm();
    setState(() {
      _active = false;
      _sending = false;
      _status = 'Emergency alarm stopped. Voice assistant remains active.';
    });
    _voice.speak('Emergency alarm stopped.');
  }

  Future<void> _addContact() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) return;
    setState(() {
      _contacts.add(EmergencyContact(name: name, phone: phone));
      _nameController.clear();
      _phoneController.clear();
    });
    await _saveContacts();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.emergencySetupWizardSeenKey, true);
  }

  Future<void> _removeContact(int index) async {
    setState(() => _contacts.removeAt(index));
    await _saveContacts();
  }

  Future<void> _shareManually() async {
    if (_contacts.isEmpty) {
      setState(() => _status = 'Add an emergency contact first.');
      return;
    }
    await _emergency.shareLocationToContacts(_contacts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency SOS'), centerTitle: true),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF2F2), Color(0xFFE8F7FF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              _SosButton(
                active: _active,
                sending: _sending,
                onActivate: _activate,
                onCancel: _cancelEmergency,
              ),
              const SizedBox(height: 18),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 18),
              _EmergencyDetailsCard(contactCount: _contacts.length),
              const SizedBox(height: 14),
              _ContactsCard(
                contacts: _contacts,
                nameController: _nameController,
                phoneController: _phoneController,
                onAdd: _addContact,
                onRemove: _removeContact,
                onSetupWizard: _openSetupWizardAgain,
              ),
              const SizedBox(height: 14),
              GlassmorphicContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 28,
                color: Colors.white,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _shareManually,
                        icon: const Icon(Icons.sms),
                        label: const Text('Send live location alert'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: AppConstants.emergencyNumbers
                          .map(
                            (number) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: OutlinedButton(
                                  onPressed: () => _emergency.callEmergency(number),
                                  child: Text(number),
                                ),
                              ),
                            ),
                          )
                          .toList(),
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

class _SosButton extends StatelessWidget {
  final bool active;
  final bool sending;
  final VoidCallback onActivate;
  final VoidCallback onCancel;

  const _SosButton({
    required this.active,
    required this.sending,
    required this.onActivate,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onLongPress: onActivate,
          onDoubleTap: onActivate,
          child: Semantics(
            button: true,
            label: AppConstants.emergencyButtonLabel,
            hint: 'Long press or double tap to activate emergency SOS',
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF1744), Color(0xFFFF7043)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(active ? .55 : .32),
                    blurRadius: active ? 62 : 42,
                    spreadRadius: active ? 18 : 10,
                  ),
                ],
              ),
              child: Icon(
                sending ? Icons.sms : Icons.emergency_share,
                color: Colors.white,
                size: 90,
              ),
            ),
          ),
        )
            .animate(target: active ? 1 : 0, onPlay: (controller) {
              if (active) controller.repeat(reverse: true);
            })
            .scale(
              begin: const Offset(.96, .96),
              end: const Offset(1.06, 1.06),
              duration: 700.ms,
            ),
        const SizedBox(height: 14),
        if (active)
          OutlinedButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.stop_circle),
            label: const Text('Stop alarm'),
          ),
      ],
    );
  }
}

class _EmergencyDetailsCard extends StatelessWidget {
  final int contactCount;

  const _EmergencyDetailsCard({required this.contactCount});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 28,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Voice emergency workflow',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.record_voice_over,
            text: 'Say "emergency" or "SOS" from the app to activate this screen.',
          ),
          _DetailRow(
            icon: Icons.notifications_active,
            text: 'The phone plays an alert sound and strong vibration repeatedly.',
          ),
          _DetailRow(
            icon: Icons.location_on,
            text: 'A live OpenStreetMap location message is prepared automatically.',
          ),
          _DetailRow(
            icon: Icons.contacts,
            text: '$contactCount saved contact(s) will be addressed in the alert SMS.',
          ),
        ],
      ),
    );
  }
}

class _ContactsCard extends StatelessWidget {
  final List<EmergencyContact> contacts;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final VoidCallback onAdd;
  final VoidCallback onSetupWizard;
  final Future<void> Function(int index) onRemove;

  const _ContactsCard({
    required this.contacts,
    required this.nameController,
    required this.phoneController,
    required this.onAdd,
    required this.onSetupWizard,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 28,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chosen emergency contacts',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Contact name',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone number',
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.person_add),
              label: const Text('Add contact'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onSetupWizard,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Open guided SOS setup'),
            ),
          ),
          const SizedBox(height: 12),
          if (contacts.isEmpty)
            Text(
              'No contacts saved yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            )
          else
            ...contacts.asMap().entries.map(
                  (entry) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.verified_user, color: AppTheme.error),
                    title: Text(
                      entry.value.name,
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                    subtitle: Text(
                      entry.value.phone,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => onRemove(entry.key),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.error, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
