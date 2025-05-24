class LocalChatMessageModel {
  final String content;
  final String senderType;
  final DateTime sentAt;
  MessageStatus status;

  LocalChatMessageModel({
    required this.content,
    required this.senderType,
    required this.sentAt,
    this.status = MessageStatus.sending,
  });
}

enum MessageStatus { sending, sent, failed }