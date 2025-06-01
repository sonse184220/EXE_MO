import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/quiz_category_api_service.dart';
import 'package:inner_child_app/domain/entities/quiz_category/quiz_category_model.dart';
import 'package:inner_child_app/domain/repositories/i_quiz_category_repository.dart';

class QuizCategoryRepository implements IQuizCategoryRepository {
  final QuizCategoryApiService _quizCategoryApiService;

  QuizCategoryRepository(this._quizCategoryApiService);

  @override
  Future<Result<List<QuizCategoryModel>>> getAllQuizCategories() async {
    try {
      final response = await _quizCategoryApiService.getAllQuizCategories();

      if (response.statusCode == 200) {
        final data = response.data;

        final quizCategories =
        (data as List<dynamic>)
            .map((e) => QuizCategoryModel.fromJson(e))
            .toList();
        return Result.success(quizCategories);
      }
      return Result.failure('Fail to get all quiz categories. Please try again');
    } catch (e) {
      return Result.failure('Get all quiz categories error: $e');
    }
  }
}