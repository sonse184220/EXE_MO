import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';

class QuizCategoryApiService {
  final DioClient _client;

  QuizCategoryApiService(this._client);

  Future<Response> getAllQuizCategories(){
    return _client.get('innerchild/quizz-category/all-quizz-category');
  }
}