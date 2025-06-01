import 'package:inner_child_app/domain/entities/quiz/quiz_answer_option_model.dart';

class QuizQuestionModel {
  final String? quizQuestionId;
  final String? quizQuestionContent;
  final int? quizQuestionOrder;
  final String? quizId;
  final List<QuizAnswerOptionModel>? options;

  QuizQuestionModel({
    this.quizQuestionId,
    this.quizQuestionContent,
    this.quizQuestionOrder,
    this.quizId,
    this.options,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      quizQuestionId: json['quizQuestionId'] as String?,
      quizQuestionContent: json['quizQuestionContent'] as String?,
      quizQuestionOrder: json['quizQuestionOrder'] as int?,
      quizId: json['quizId'] as String?,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => QuizAnswerOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizQuestionId': quizQuestionId,
      'quizQuestionContent': quizQuestionContent,
      'quizQuestionOrder': quizQuestionOrder,
      'quizId': quizId,
      'options': options?.map((e) => e.toJson()).toList(),
    };
  }
}