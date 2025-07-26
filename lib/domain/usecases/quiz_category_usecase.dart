import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/quiz_category/quiz_category_model.dart';
import 'package:inner_child_app/domain/repositories/i_quiz_category_repository.dart';

class QuizCategoryUsecase {
  final IQuizCategoryRepository _quizCategoryRepository;

  QuizCategoryUsecase(this._quizCategoryRepository);

  Future<Result<List<QuizCategoryModel>>> getAllQuizCategories() {
    return _quizCategoryRepository.getAllQuizCategories();
  }

  Future<Result<String>> createQuizCategory(
    String quizCategoryName,
    String quizCategoryDescription,
  ) {
    return _quizCategoryRepository.createQuizCategory(
      quizCategoryName,
      quizCategoryDescription,
    );
  }

  Future<Result<String>> updateQuizCategory(
    String quizCategoryId,
    String quizCategoryName,
    String quizCategoryDescription,
  ) {
    return _quizCategoryRepository.updateQuizCategory(
      quizCategoryId,
      quizCategoryName,
      quizCategoryDescription,
    );
  }
}
