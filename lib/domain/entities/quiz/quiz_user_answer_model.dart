class QuizUserAnswerModel {
  final String quizQuestionId;
  final String quizAnswerOptionId;

  QuizUserAnswerModel({
    required this.quizQuestionId,
    required this.quizAnswerOptionId,
  });

  Map<String, dynamic> toJson() => {
    'quizQuestionId': quizQuestionId,
    'quizAnswerOptionId': quizAnswerOptionId,
  };
}