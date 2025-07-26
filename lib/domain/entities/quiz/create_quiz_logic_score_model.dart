class CreateQuizLogicScoreModel {
  final int fromScore;
  final int toScore;
  final String resultLabel;
  final String resultDescription;
  final int priority;
  final String resultColor;

  CreateQuizLogicScoreModel({
    required this.fromScore,
    required this.toScore,
    required this.resultLabel,
    required this.resultDescription,
    required this.priority,
    required this.resultColor,
  });

  factory CreateQuizLogicScoreModel.fromJson(Map<String, dynamic> json) {
    return CreateQuizLogicScoreModel(
      fromScore: json["fromScore"] as int,
      toScore: json["toScore"] as int,
      resultLabel: json["resultLabel"] as String,
      resultDescription: json["resultDescription"] as String,
      priority: json["priority"] as int,
      resultColor: json["resultColor"] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    "fromScore": fromScore,
    "toScore": toScore,
    "resultLabel": resultLabel,
    "resultDescription": resultDescription,
    "priority": priority,
    "resultColor": resultColor,
  };
}
