class QuizAnswerAttemptModel {
  final String? quizAnswerOptionId;
  final String? quizContent;
  final int? quizScoreValue;
  final String? questionId;

  QuizAnswerAttemptModel({
    this.quizAnswerOptionId,
    this.quizContent,
    this.quizScoreValue,
    this.questionId,
  });

  factory QuizAnswerAttemptModel.fromJson(Map<String, dynamic> json) {
    return QuizAnswerAttemptModel(
      quizAnswerOptionId: json['quizAnswerOptionId'] as String?,
      quizContent: json['quizContent'] as String?,
      quizScoreValue: json['quizScoreValue'] as int?,
      questionId: json['questionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'quizAnswerOptionId': quizAnswerOptionId,
    'quizContent': quizContent,
    'quizScoreValue': quizScoreValue,
    'questionId': questionId,
  };
}