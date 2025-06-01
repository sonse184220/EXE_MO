class QuizCategoryModel {
  final String? quizCategoryId;
  final String? quizCategoryName;
  final String? quizCategoryDescription;

  QuizCategoryModel({
    this.quizCategoryId,
    this.quizCategoryName,
    this.quizCategoryDescription,
  });

  factory QuizCategoryModel.fromJson(Map<String, dynamic> json) {
    return QuizCategoryModel(
      quizCategoryId: json['quizCategoryId'] as String?,
      quizCategoryName: json['quizCategoryName'] as String?,
      quizCategoryDescription: json['quizCategoryDescription'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizCategoryId': quizCategoryId,
      'quizCategoryName': quizCategoryName,
      'quizCategoryDescription': quizCategoryDescription,
    };
  }
}