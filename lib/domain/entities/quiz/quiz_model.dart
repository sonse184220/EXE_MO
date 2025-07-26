import 'package:inner_child_app/domain/entities/quiz/quiz_question_model.dart';

class QuizModel {
  final String? quizId;
  final String? quizTitle;
  final String? quizDescription;
  final String? quizStatus;
  final int? quizMaxScore;
  final String? quizCategoryId;
  final List<QuizQuestionModel>? questions;

  QuizModel({
    this.quizId,
    this.quizTitle,
    this.quizDescription,
    this.quizStatus,
    this.quizMaxScore,
    this.quizCategoryId,
    this.questions,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      quizId: json['quizId'] as String?,
      quizTitle: json['quizTitle'] as String?,
      quizDescription: json['quizDescription'] as String?,
      quizStatus: json['quizStatus'] as String?,
      quizMaxScore: json['quizMaxScore'] as int?,
      quizCategoryId: json['quizCategoryId'] as String?,
      questions: (json['questions'] as List<dynamic>?)
          ?.map((e) => QuizQuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'quizTitle': quizTitle,
      'quizDescription': quizDescription,
      'quizStatus': quizStatus,
      'quizMaxScore': quizMaxScore,
      'quizCategoryId': quizCategoryId,
      'questions': questions?.map((e) => e.toJson()).toList(),
    };
  }

  QuizModel copyWith({
    String? quizId,
    String? quizTitle,
    String? quizDescription,
    String? quizStatus,
    int? quizMaxScore,
    String? quizCategoryId,
    List<QuizQuestionModel>? questions,
  }) {
    return QuizModel(
      quizId: quizId ?? this.quizId,
      quizTitle: quizTitle ?? this.quizTitle,
      quizDescription: quizDescription ?? this.quizDescription,
      quizStatus: quizStatus ?? this.quizStatus,
      quizMaxScore: quizMaxScore ?? this.quizMaxScore,
      quizCategoryId: quizCategoryId ?? this.quizCategoryId,
      questions: questions ?? this.questions,
    );
  }
}