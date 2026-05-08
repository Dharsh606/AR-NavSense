class AssistantMessage {
  final String text;
  final bool isUser;
  final DateTime createdAt;

  AssistantMessage({
    required this.text,
    required this.isUser,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
