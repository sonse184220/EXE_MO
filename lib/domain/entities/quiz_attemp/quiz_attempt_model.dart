import 'package:inner_child_app/domain/entities/quiz_attemp/quiz_attempt_detail_model.dart';

class QuizAttemptModel {
  final String? quizId;
  final String? quizTitle;
  final List<QuizAttemptDetailModel>? attempts;

  QuizAttemptModel({this.quizId, this.quizTitle, this.attempts});

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) {
    return QuizAttemptModel(
      quizId: json['quizId'] as String?,
      quizTitle: json['quizTitle'] as String?,
      attempts: (json['attempts'] as List<dynamic>?)
          ?.map((e) => QuizAttemptDetailModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'quizId': quizId,
    'quizTitle': quizTitle,
    'attempts': attempts?.map((e) => e.toJson()).toList(),
  };
}