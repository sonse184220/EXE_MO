import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/quiz_attemp/quiz_attempt_detail_model.dart';
import 'package:inner_child_app/domain/entities/quiz_attemp/quiz_attempt_model.dart';

abstract class IQuizAttemptRepository {
  Future<Result<List<QuizAttemptModel>>> getAllQuizAttempts();
  Future<Result<QuizAttemptDetailModel>> getQuizAttemptDetail(String quizAttemptId);
}