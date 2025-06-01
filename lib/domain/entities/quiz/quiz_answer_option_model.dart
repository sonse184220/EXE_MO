class QuizAnswerOptionModel {
  final String? quizAnswerOptionId;
  final String? quizContent;
  final int? quizScoreValue;
  final String? questionId;

  QuizAnswerOptionModel({
    this.quizAnswerOptionId,
    this.quizContent,
    this.quizScoreValue,
    this.questionId,
  });

  factory QuizAnswerOptionModel.fromJson(Map<String, dynamic> json) {
    return QuizAnswerOptionModel(
      quizAnswerOptionId: json['quizAnswerOptionId'] as String?,
      quizContent: json['quizContent'] as String?,
      quizScoreValue: json['quizScoreValue'] as int?,
      questionId: json['questionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizAnswerOptionId': quizAnswerOptionId,
      'quizContent': quizContent,
      'quizScoreValue': quizScoreValue,
      'questionId': questionId,
    };
  }
}