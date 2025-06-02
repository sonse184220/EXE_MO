import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/quiz_api_service.dart';
import 'package:inner_child_app/domain/entities/quiz/quiz_model.dart';
import 'package:inner_child_app/domain/entities/quiz/quiz_user_answer_model.dart';
import 'package:inner_child_app/domain/repositories/i_quiz_repository.dart';

class QuizRepository implements IQuizRepository {
  final QuizApiService _quizApiService;

  QuizRepository(this._quizApiService);

  @override
  Future<Result<List<QuizModel>>> getAllQuizzes() async {
    try {
      final response = await _quizApiService.getAllQuizzes();

      if (response.statusCode == 200) {
        final data = response.data;

        final quizzes =
        (data as List<dynamic>)
            .map((e) => QuizModel.fromJson(e))
            .toList();
        return Result.success(quizzes);
      }
      return Result.failure('Fail to get all quizzes. Please try again');
    } catch (e) {
      return Result.failure('Get all quizzes error: $e');
    }
  }

  @override
  Future<Result<QuizModel>> getQuizDetail(String quizId) async {
    try {
      final response = await _quizApiService.getQuizDetail(quizId);

      if (response.statusCode == 200) {
        final data = response.data;

        final quiz = QuizModel.fromJson(data);
        return Result.success(quiz);
      }
      return Result.failure('Fail to get quiz detail. Please try again');
    } catch (e) {
      return Result.failure('Get quiz detail error: $e');
    }
  }

  @override
  Future<Result<String>> submitQuiz(String quizId, List<QuizUserAnswerModel> data) async {
    try {
      final response = await _quizApiService.submitQuiz(quizId, data);

      if (response.statusCode == 201) {
        final data = response.data;

        // final quiz = QuizModel.fromJson(data);
        return Result.success('Quiz submited successfully');
      }
      return Result.failure('Fail to submit quiz. Please try again');
    } catch (e) {
      return Result.failure('Submit quiz error: $e');
    }
  }
}