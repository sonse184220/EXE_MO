import 'package:inner_child_app/domain/entities/chat_ai/chat_message_model.dart';

class ChatSessionModel {
  final String aiChatSessionId;
  final String aiChatSessionTitle;
  final DateTime aiChatSessionCreatedAt;
  final String profileId;
  final List<ChatMessageModel> aiChatMessages;

  ChatSessionModel(this.aiChatMessages, {
    required this.aiChatSessionId,
    required this.aiChatSessionTitle,
    required this.aiChatSessionCreatedAt,
    required this.profileId,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      aiChatSessionId: json['aiChatSessionId'],
      aiChatSessionTitle: json['aiChatSessionTitle'],
      aiChatSessionCreatedAt: DateTime.parse(json['aiChatSessionCreatedAt']),
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
      'aiChatSessionTitle': aiChatSessionTitle,
      'aiChatSessionCreatedAt': aiChatSessionCreatedAt.toIso8601String(),
      'profileId': profileId,
      'aiChatMessages': aiChatMessages.map((e) => e.toJson()).toList(),
    };
  }
}