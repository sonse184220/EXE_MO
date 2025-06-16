import 'package:inner_child_app/domain/entities/quiz/create_quiz_question_model.dart';

class CreateQuizModel {
  final String quizTitle;
  final String quizDescription;
  final int quizMaxScore;
  final String quizCategoryId;
  final List<CreateQuizQuestionModel> quizzQuestions;

  CreateQuizModel({
    required this.quizTitle,
    required this.quizDescription,
    required this.quizMaxScore,
    required this.quizCategoryId,
    required this.quizzQuestions,
  });

  Map<String, dynamic> toJson() => {
    "quizTitle": quizTitle,
    "quizDescription": quizDescription,
    "quizMaxScore": quizMaxScore,
    "quizCategoryId": quizCategoryId,
    "quizzQuestions": quizzQuestions.map((q) => q.toJson()).toList(),
  };
}