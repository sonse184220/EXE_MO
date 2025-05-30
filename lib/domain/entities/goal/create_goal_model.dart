class CreateGoalModel {
  final String goalTitle;
  final String goalDescription;
  final String goalType;
  final DateTime goalStartDate;
  final DateTime goalEndDate;
  final int goalTargetCount;
  final int goalPeriodDays;
  // final String goalStatus;
  // final DateTime goalCompletedAt;

  CreateGoalModel({
    required this.goalTitle,
    required this.goalDescription,
    required this.goalType,
    required this.goalStartDate,
    required this.goalEndDate,
    required this.goalTargetCount,
    required this.goalPeriodDays,
    // required this.goalStatus,
    // required this.goalCompletedAt,
  });

  factory CreateGoalModel.fromJson(Map<String, dynamic> json) {
    return CreateGoalModel(
      goalTitle: json['goalTitle'] as String,
      goalDescription: json['goalDescription'] as String,
      goalType: json['goalType'] as String,
      goalStartDate: DateTime.parse(json['goalStartDate'] as String),
      goalEndDate: DateTime.parse(json['goalEndDate'] as String),
      goalTargetCount: json['goalTargetCount'] as int,
      goalPeriodDays: json['goalPeriodDays'] as int,
      // goalStatus: json['goalStatus'] as String,
      // goalCompletedAt: DateTime.parse(json['goalCompletedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goalTitle': goalTitle,
      'goalDescription': goalDescription,
      'goalType': goalType,
      'goalStartDate': goalStartDate.toIso8601String(),
      'goalEndDate': goalEndDate.toIso8601String(),
      'goalTargetCount': goalTargetCount,
      'goalPeriodDays': goalPeriodDays,
      // 'goalStatus': goalStatus,
      // 'goalCompletedAt': goalCompletedAt.toIso8601String(),
    };
  }
}
