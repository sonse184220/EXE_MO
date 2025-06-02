import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/quiz_attempt_api_service.dart';
import 'package:inner_child_app/domain/entities/quiz_attemp/quiz_attempt_detail_model.dart';
import 'package:inner_child_app/domain/entities/quiz_attemp/quiz_attempt_model.dart';
import 'package:inner_child_app/domain/repositories/i_quiz_attempt_repository.dart';

class QuizAttemptRepository implements IQuizAttemptRepository {
  final QuizAttemptApiService _quizAttemptApiService;

  QuizAttemptRepository(this._quizAttemptApiService);

  @override
  Future<Result<List<QuizAttemptModel>>> getAllQuizAttempts() async {
    try {
      final response = await _quizAttemptApiService.getAllQuizAttempts();

      if (response.statusCode == 200) {
        final data = response.data;

        final quizzAttempts =
        (data as List<dynamic>)
            .map((e) => QuizAttemptModel.fromJson(e))
            .toList();
        return Result.success(quizzAttempts);
      }
      return Result.failure('Fail to get all quiz attempts. Please try again');
    } catch (e) {
      return Result.failure('Get all quiz attempts error: $e');
    }
  }

  @override
  Future<Result<QuizAttemptDetailModel>> getQuizAttemptDetail(String quizAttemptId) async {
    try {
      final response = await _quizAttemptApiService.getQuizAttemptDetail(quizAttemptId);

      if (response.statusCode == 200) {
        final data = response.data;

        final quizzAttempt =
        QuizAttemptDetailModel.fromJson(data);
        return Result.success(quizzAttempt);
      }
      return Result.failure('Fail to get quiz attempt: $quizAttemptId. Please try again');
    } catch (e) {
      return Result.failure('Get quiz attempt: $quizAttemptId error: $e');
    }
  }
}