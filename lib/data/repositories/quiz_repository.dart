import 'package:inner_child_app/data/datasources/remote/quiz_api_service.dart';
import 'package:inner_child_app/domain/repositories/i_quiz_repository.dart';

class QuizRepository implements IQuizRepository {
  final QuizApiService _quizApiService;

  QuizRepository(this._quizApiService);
}