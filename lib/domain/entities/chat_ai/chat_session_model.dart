import 'package:inner_child_app/domain/entities/chat_ai/chat_message_model.dart';

class ChatSessionModel {
  final String aiChatSessionId;
  final String aichatSessionTitle;
  final DateTime aichatSessionCreatedAt;
  final String profileId;
  final List<ChatMessageModel> aiChatMessages;

  ChatSessionModel(this.aiChatMessages, {
    required this.aiChatSessionId,
    required this.aichatSessionTitle,
    required this.aichatSessionCreatedAt,
    required this.profileId,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      aiChatSessionId: json['aiChatSessionId'],
      aichatSessionTitle: json['aichatSessionTitle'],
      aichatSessionCreatedAt: DateTime.parse(json['aichatSessionCreatedAt']),
      profileId: json['profileId'],
      (json['aiChatMessages'] as List<dynamic>?)
          ?.map((e) => ChatMessageModel.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aiChatSessionId': aiChatSessionId,
      'aichatSessionTitle': aichatSessionTitle,
      'aichatSessionCreatedAt': aichatSessionCreatedAt.toIso8601String(),
      'profileId': profileId,
      'aiChatMessages': aiChatMessages.map((e) => e.toJson()).toList(),
    };
  }
}