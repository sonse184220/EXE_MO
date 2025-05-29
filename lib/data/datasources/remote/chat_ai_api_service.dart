import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';

class ChatAiApiService {
  final DioClient _client;

  ChatAiApiService(this._client);

  Future<Response> getAllChatSessions() async {
    return await _client.get('innerchild/aichat/all-sessions');
  }

  Future<Response> getChatSessionById(String id) async {
    return await _client.get('innerchild/aichat/load-all-messages/$id');
  }

  Future<Response> createNewChatSession(String title) async {
    final dataObject = {
      "sessionTitle": title
    };
    return await _client.post('innerchild/aichat/create-session', data: dataObject);
  }

  Future<Response> sendChatMessage(String message, String chatSessionId) async {
    final dataObject = {
      "message": message,
      "aiChatSessionId": chatSessionId
    };
    return await _client.post('innerchild/aichat/send-chat', data: dataObject);
  }
}