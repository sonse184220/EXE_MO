import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';

class QuizCategoryApiService {
  final DioClient _client;

  QuizCategoryApiService(this._client);

  Future<Response> getAllQuizCategories() {
    return _client.get('innerchild/quizz-category/all-quizz-category');
  }

  Future<Response> createQuizCategory(
    String quizCategoryName,
    String quizCategoryDescription,
  ) {
    final data = {
      'quizCategoryName': quizCategoryName,
      'quizCategoryDescription': quizCategoryDescription,
    };

    return _client.post(
      'innerchild/quizz-category/create-quizz-category',
      data: data,
    );
  }

  Future<Response> updateQuizCategory(
    String id,
    String quizCategoryName,
    String quizCategoryDescription,
  ) {
    final data = {
      'quizCategoryName': quizCategoryName,
      'quizCategoryDescription': quizCategoryDescription,
    };
    return _client.put('innerchild/quizz-category/update/$id', data: data);
  }
}
