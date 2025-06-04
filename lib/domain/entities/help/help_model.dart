class HelpModel {
  final String helpId;
  final String helpQuestion;
  final String helpAnswer;
  final DateTime helpCreatedAt;
  final String helpCategoryId;

  HelpModel({
    required this.helpId,
    required this.helpQuestion,
    required this.helpAnswer,
    required this.helpCreatedAt,
    required this.helpCategoryId
  });
  factory HelpModel.fromJson(Map<String,dynamic> json){
    return HelpModel(
      helpId: json['helpId'] as String,
      helpQuestion: json['helpQuestion'] as String,
      helpAnswer: json['helpAnswer'] as String,
      helpCreatedAt: DateTime.parse(json['helpCreatedAt'] as String),
      helpCategoryId: json['helpCategoryId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'helpId': helpId,
      'helpQuestion': helpQuestion,
      'helpAnswer': helpAnswer,
      'helpCreatedAt': helpCreatedAt.toIso8601String(),
      'helpCategoryId': helpCategoryId,
    };
  }
}