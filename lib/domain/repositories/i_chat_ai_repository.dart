import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/chat_ai/chat_session_model.dart';

abstract class IChatAiRepository {
  Future<Result<List<ChatSessionModel>>> getAllChatSessions();
  Future<Result<ChatSessionModel>> getChatSessionById(String id);
  Future<Result<String>> createNewChatSession(String title);
  Future<Result<String>> sendChatMessage(String message, String chatSessionId);
}