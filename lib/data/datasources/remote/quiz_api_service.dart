import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';
import 'package:inner_child_app/domain/entities/quiz/quiz_user_answer_model.dart';

class QuizApiService {
  final DioClient _client;

  QuizApiService(this._client);

  Future<Response> getAllQuizzes() {
    return _client.get('innerchild/quizz/all-quizz');
  }

  Future<Response> getQuizDetail(String quizId) {
    return _client.get('innerchild/quizz/get-quizz-detail/$quizId');
  }

  Future<Response> submitQuiz(String quizId, List<QuizUserAnswerModel> data) {
    final requestBody = {
      'quizId': quizId,
      'quizUserAnswers': data.map((e) => e.toJson()).toList(),
    };
    return _client.post('innerchild/quizz/do-quizz', data: requestBody);
  }
}