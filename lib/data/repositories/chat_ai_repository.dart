import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/chat_ai_api_service.dart';
import 'package:inner_child_app/domain/entities/chat_ai/chat_session_model.dart';
import 'package:inner_child_app/domain/repositories/i_chat_ai_repository.dart';

class ChatAiRepository implements IChatAiRepository {
  final ChatAiApiService _chatAiService;

  ChatAiRepository(this._chatAiService);

  @override
  Future<Result<List<ChatSessionModel>>> getAllChatSessions() async {
    try {
      final response = await _chatAiService.getAllChatSessions();

      if (response.statusCode == 200) {
        final data = response.data;

        final chatSessions =
            (data as List<dynamic>)
                .map((e) => ChatSessionModel.fromJson(e))
                .toList();
        return Result.success(chatSessions);
      }

      return Result.failure(
        'Failed to fetch all chat sessions: ${response.statusCode}',
      );
    } catch (e) {
      return Result.failure('Fetch all chat sessions error: $e');
    }
  }

  @override
  Future<Result<ChatSessionModel>> getChatSessionById(String id) async {
    try {
      final response = await _chatAiService.getChatSessionById(id);

      if (response.statusCode == 200) {
        final data = response.data;

        final chatSession = ChatSessionModel.fromJson(data);
        return Result.success(chatSession);
      }

      return Result.failure(
        'Failed to fetch chat session by id: ${response.statusCode}',
      );
    } catch (e) {
      return Result.failure('Fetch chat session by id error: $e');
    }
  }

  @override
  Future<Result<String>> createNewChatSession(String title) async {
    try {
      final response = await _chatAiService.createNewChatSession(title);

      if (response.statusCode == 201) {
        // final data = response.data;

        return Result.success('Session $title created successfully');
      }

      return Result.failure(
        'Failed to create session: ${response.statusCode}',
      );
    } catch (e) {
      return Result.failure('Create session error: $e');
    }
  }

  @override
  Future<Result<String>> sendChatMessage(String message, String chatSessionId) async {
    try {
      final response = await _chatAiService.sendChatMessage(message, chatSessionId);

      if (response.statusCode == 200) {
        final data = response.data;

        return Result.success(data);
      }

      return Result.failure(
        'Failed to create session: ${response.statusCode}',
      );
    } catch (e) {
      return Result.failure('Create session error: $e');
    }
  }
}
