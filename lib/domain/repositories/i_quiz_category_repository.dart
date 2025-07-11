import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/quiz_category/quiz_category_model.dart';

abstract class IQuizCategoryRepository {
  Future<Result<List<QuizCategoryModel>>> getAllQuizCategories();

  Future<Result<String>> createQuizCategory(
    String quizCategoryName,
    String quizCategoryDescription,
  );

  Future<Result<String>> updateQuizCategory(
    String quizCategoryId,
    String quizCategoryName,
    String quizCategoryDescription,
  );
}
