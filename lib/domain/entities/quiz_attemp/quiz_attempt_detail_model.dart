import 'package:inner_child_app/domain/entities/quiz_attemp/quiz_question_attempt_model.dart';

class QuizAttemptDetailModel {
  final String? quizId;
  final String? quizTitle;
  final String? quizDescription;
  final String? quizStatus;
  final int? quizMaxScore;
  final int? quizzFinalScore;
  final String? quizCategoryId;
  final List<QuizQuestionAttemptModel>? questions;
  final String? quizUserAttemptId;
  final DateTime? quizUserAnswerCreatedAt;
  final String? profileId;
  final String? resultLabel;
  final String? resultDescription;
  final String? resultColor;

  QuizAttemptDetailModel({
    this.quizId,
    this.quizTitle,
    this.quizDescription,
    this.quizStatus,
    this.quizMaxScore,
    this.quizzFinalScore,
    this.quizCategoryId,
    this.questions,
    this.quizUserAttemptId,
    this.quizUserAnswerCreatedAt,
    this.profileId,
    this.resultLabel,
    this.resultDescription,
    this.resultColor,
  });

  factory QuizAttemptDetailModel.fromJson(Map<String, dynamic> json) {
    return QuizAttemptDetailModel(
      quizId: json['quizId'] as String?,
      quizTitle: json['quizTitle'] as String?,
      quizDescription: json['quizDescription'] as String?,
      quizStatus: json['quizStatus'] as String?,
      quizMaxScore: json['quizMaxScore'] as int?,
      quizzFinalScore: json['quizzFinalScore'] as int?,
      quizCategoryId: json['quizCategoryId'] as String?,
      questions: (json['questions'] as List<dynamic>?)
          ?.map((e) => QuizQuestionAttemptModel.fromJson(e))
          .toList(),
      quizUserAttemptId: json['quizUserAttemptId'] as String?,
      quizUserAnswerCreatedAt: json['quizUserAnswerCreatedAt'] != null
          ? DateTime.tryParse(json['quizUserAnswerCreatedAt'])
          : null,
      profileId: json['profileId'] as String?,
      resultLabel: json['resultLabel'] as String?,
      resultDescription: json['resultDescription'] as String?,
      resultColor: json['resultColor'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'quizId': quizId,
    'quizTitle': quizTitle,
    'quizDescription': quizDescription,
    'quizStatus': quizStatus,
    'quizMaxScore': quizMaxScore,
    'quizzFinalScore': quizzFinalScore,
    'quizCategoryId': quizCategoryId,
    'questions': questions?.map((e) => e.toJson()).toList(),
    'quizUserAttemptId': quizUserAttemptId,
    'quizUserAnswerCreatedAt': quizUserAnswerCreatedAt?.toIso8601String(),
    'profileId': profileId,
    'resultLabel': resultLabel,
    'resultDescription': resultDescription,
    'resultColor': resultColor,
  };
}