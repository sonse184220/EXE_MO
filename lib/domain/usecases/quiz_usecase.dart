import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/quiz/quiz_model.dart';
import 'package:inner_child_app/domain/entities/quiz/quiz_user_answer_model.dart';
import 'package:inner_child_app/domain/repositories/i_quiz_repository.dart';

class QuizUsecase {
  final IQuizRepository _iQuizRepository;

  QuizUsecase(this._iQuizRepository);

  Future<Result<List<QuizModel>>> getAllQuizzes() {
    return _iQuizRepository.getAllQuizzes();
  }

  Future<Result<QuizModel>> getQuizDetail(String quizId) {
    return _iQuizRepository.getQuizDetail(quizId);
  }

  Future<Result<String>> submitQuiz(String quizId, List<QuizUserAnswerModel> data) {
    return _iQuizRepository.submitQuiz(quizId, data);
  }
}