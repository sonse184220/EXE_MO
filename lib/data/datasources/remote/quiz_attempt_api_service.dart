import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';

class QuizAttemptApiService {
  final DioClient _client;

  QuizAttemptApiService(this._client);

  Future<Response> getAllQuizAttempts() {
    return _client.get('innerchild/quizz/all-quizz-user-attempt');
  }

  Future<Response> getQuizAttemptDetail(String quizAttemptId) {
    return _client.get('innerchild/quizz/quizz-user-attempt-detail/$quizAttemptId');
  }
}