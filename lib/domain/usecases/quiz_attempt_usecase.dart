import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/quiz_attemp/quiz_attempt_detail_model.dart';
import 'package:inner_child_app/domain/entities/quiz_attemp/quiz_attempt_model.dart';
import 'package:inner_child_app/domain/repositories/i_quiz_attempt_repository.dart';

class QuizAttemptUsecase {
  final IQuizAttemptRepository _iQuizAttemptRepository;

  QuizAttemptUsecase(this._iQuizAttemptRepository);

  Future<Result<List<QuizAttemptModel>>> getAllQuizAttempts() {
    return _iQuizAttemptRepository.getAllQuizAttempts();
  }

  Future<Result<QuizAttemptDetailModel>> getQuizAttemptDetail(String quizAttemptId) {
    return _iQuizAttemptRepository.getQuizAttemptDetail(quizAttemptId);
  }
}