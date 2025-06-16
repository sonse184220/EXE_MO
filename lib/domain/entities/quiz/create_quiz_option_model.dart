class CreateQuizOptionModel {
  final String quizContent;
  final int quizScoreValue;

  CreateQuizOptionModel({
    required this.quizContent,
    required this.quizScoreValue,
  });

  Map<String, dynamic> toJson() => {
    "quizContent": quizContent,
    "quizScoreValue": quizScoreValue,
  };
}