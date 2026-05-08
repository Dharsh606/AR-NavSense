import 'dart:convert';

class EmergencyContact {
  final String name;
  final String phone;

  const EmergencyContact({required this.name, required this.phone});

  Map<String, dynamic> toJson() => {'name': name, 'phone': phone};

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] as String? ?? 'Emergency contact',
      phone: json['phone'] as String? ?? '',
    );
  }

  static List<EmergencyContact> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    final data = jsonDecode(raw) as List<dynamic>;
    return data
        .map((item) => EmergencyContact.fromJson(item as Map<String, dynamic>))
        .where((contact) => contact.phone.trim().isNotEmpty)
        .toList();
  }

  static String encodeList(List<EmergencyContact> contacts) {
    return jsonEncode(contacts.map((contact) => contact.toJson()).toList());
  }
}
