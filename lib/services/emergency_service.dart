import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

import '../models/emergency_contact.dart';
import 'location_service.dart';

class EmergencyService {
  final LocationService _locationService;

  EmergencyService(this._locationService);

  Future<void> pulse() async {
    await SystemSound.play(SystemSoundType.alert);
    if (await Vibration.hasVibrator()) {
      await Vibration.vibrate(pattern: [0, 350, 120, 700, 120, 1000]);
    }
  }

  Future<String> liveLocationMessage() async {
    final Position position = await _locationService.currentPosition();
    final url =
        'https://www.openstreetmap.org/?mlat=${position.latitude}&mlon=${position.longitude}#map=18/${position.latitude}/${position.longitude}';
    return 'Emergency SOS from AR-NavSense. My live location is $url';
  }

  Future<void> shareLocation() async {
    final message = Uri.encodeComponent(await liveLocationMessage());
    final uri = Uri.parse('sms:?body=$message');
    if (!await launchUrl(uri)) {
      throw Exception('No SMS app available for emergency sharing.');
    }
  }

  Future<void> shareLocationToContacts(List<EmergencyContact> contacts) async {
    final message = await liveLocationMessage();
    final phones = contacts
        .map((contact) => contact.phone.replaceAll(RegExp(r'\s+'), ''))
        .where((phone) => phone.isNotEmpty)
        .join(';');
    final uri = Uri(
      scheme: 'sms',
      path: phones,
      queryParameters: {'body': message},
    );
    if (!await launchUrl(uri)) {
      throw Exception('No SMS app available for emergency sharing.');
    }
  }

  Future<void> callEmergency(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (!await launchUrl(uri)) {
      throw Exception('No phone app available.');
    }
  }
}
