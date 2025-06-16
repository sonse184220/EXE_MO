import 'package:inner_child_app/domain/entities/quiz/create_quiz_option_model.dart';

class CreateQuizQuestionModel {
  final String quizQuestionContent;
  final int quizQuestionOrder;
  final List<CreateQuizOptionModel> quizzOptions;

  CreateQuizQuestionModel({
    required this.quizQuestionContent,
    required this.quizQuestionOrder,
    required this.quizzOptions,
  });

  Map<String, dynamic> toJson() => {
    "quizQuestionContent": quizQuestionContent,
    "quizQuestionOrder": quizQuestionOrder,
    "quizzOptions": quizzOptions.map((o) => o.toJson()).toList(),
  };
}
