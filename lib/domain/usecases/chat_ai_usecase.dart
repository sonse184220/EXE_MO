import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/chat_ai/chat_message_model.dart';
import 'package:inner_child_app/domain/entities/chat_ai/chat_session_model.dart';
import 'package:inner_child_app/domain/repositories/i_chat_ai_repository.dart';

class ChatAIUseCase {
  final IChatAiRepository _chatAiRepository;

  ChatAIUseCase(this._chatAiRepository);

  Future<Result<List<ChatSessionModel>>> getAllChatSessions() {
    return _chatAiRepository.getAllChatSessions();
  }

  Future<Result<ChatSessionModel>> getChatSessionById(String id) {
    return _chatAiRepository.getChatSessionById(id);
  }

  Future<Result<String>> createNewChatSession(String title) {
    return _chatAiRepository.createNewChatSession(title);
  }

  Future<Result<String>> sendChatMessage(String message, String chatSessionId) {
    return _chatAiRepository.sendChatMessage(message, chatSessionId);
  }
}