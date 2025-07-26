import 'package:inner_child_app/domain/entities/quiz/create_quiz_logic_score_model.dart';
import 'package:inner_child_app/domain/entities/quiz/create_quiz_question_model.dart';

class CreateQuizModel {
  final String quizTitle;
  final String quizDescription;
  final int quizMaxScore;
  final String quizCategoryId;
  final List<CreateQuizQuestionModel> quizzQuestions;
  final List<CreateQuizLogicScoreModel> quizzLogicScores;

  CreateQuizModel({
    required this.quizTitle,
    required this.quizDescription,
    required this.quizMaxScore,
    required this.quizCategoryId,
    required this.quizzQuestions,
    required this.quizzLogicScores,
  });

  Map<String, dynamic> toJson() => {
    "quizTitle": quizTitle,
    "quizDescription": quizDescription,
    "quizMaxScore": quizMaxScore,
    "quizCategoryId": quizCategoryId,
    "quizzQuestions": quizzQuestions.map((q) => q.toJson()).toList(),
    "quizzLogicScores": quizzLogicScores.map((l) => l.toJson()).toList(),
  };
}