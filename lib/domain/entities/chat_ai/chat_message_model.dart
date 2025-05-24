class ChatMessageModel  {
  final String id;
  final String senderType; // "User" or "System"
  final DateTime sentAt;
  final String content;

  ChatMessageModel({
    required this.id,
    required this.senderType,
    required this.sentAt,
    required this.content,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['aiChatMessageId'] ?? '',
      senderType: json['aiChatMessageSenderType'] ?? '',
      sentAt: DateTime.parse(json['aiChatMessageSentAt']),
      content: json['aiChatMessageContent'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aiChatMessageId': id,
      'aiChatMessageSenderType': senderType,
      'aiChatMessageSentAt': sentAt.toIso8601String(),
      'aiChatMessageContent': content,
    };
  }
}