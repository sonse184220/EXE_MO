import 'package:inner_child_app/domain/entities/quiz_attemp/quiz_answer_attempt_model.dart';

class QuizQuestionAttemptModel {
  final String? quizQuestionId;
  final String? quizQuestionContent;
  final int? quizQuestionOrder;
  final String? quizId;
  final String? userSelectedOptionId;
  final String? userSelectedAnswerText;
  final List<QuizAnswerAttemptModel>? options;

  QuizQuestionAttemptModel({
    this.quizQuestionId,
    this.quizQuestionContent,
    this.quizQuestionOrder,
    this.quizId,
    this.userSelectedOptionId,
    this.userSelectedAnswerText,
    this.options,
  });

  factory QuizQuestionAttemptModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionAttemptModel(
      quizQuestionId: json['quizQuestionId'] as String?,
      quizQuestionContent: json['quizQuestionContent'] as String?,
      quizQuestionOrder: json['quizQuestionOrder'] as int?,
      quizId: json['quizId'] as String?,
      userSelectedOptionId: json['userSelectedOptionId'] as String?,
      userSelectedAnswerText: json['userSelectedAnswerText'] as String?,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => QuizAnswerAttemptModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'quizQuestionId': quizQuestionId,
    'quizQuestionContent': quizQuestionContent,
    'quizQuestionOrder': quizQuestionOrder,
    'quizId': quizId,
    'userSelectedOptionId': userSelectedOptionId,
    'userSelectedAnswerText': userSelectedAnswerText,
    'options': options?.map((e) => e.toJson()).toList(),
  };
}