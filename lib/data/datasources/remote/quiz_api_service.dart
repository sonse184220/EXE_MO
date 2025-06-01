import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';

class QuizApiService {
  final DioClient _client;

  QuizApiService(this._client);

  Future<Response> getAllQuizzes() {
    return _client.get('innerchild/quizz/all-quizz');
  }

  Future<Response> getQuizDetail(String quizId) {
    return _client.get('innerchild/quizz/get-quizz-detail/$quizId');
  }
}