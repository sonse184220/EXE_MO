import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/quiz/quiz_model.dart';
import 'package:inner_child_app/domain/entities/quiz/quiz_user_answer_model.dart';

abstract class IQuizRepository {
  Future<Result<List<QuizModel>>> getAllQuizzes();
  Future<Result<QuizModel>> getQuizDetail(String quizId);
  Future<Result<String>> submitQuiz(String quizId, List<QuizUserAnswerModel> data);
}