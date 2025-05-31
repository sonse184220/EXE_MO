class GoalModel {
  final String? goalId;
  final String? goalTitle;
  final String? goalDescription;
  final String? goalType;
  final DateTime? goalStartDate;
  final DateTime? goalEndDate;
  final int? goalTargetCount;
  late final int? goalPeriodDays;
  final String? goalStatus;
  final DateTime? goalCreatedAt;
  final DateTime? goalUpdatedAt;
  final DateTime? goalCompletedAt;
  final String? profileId;
  // final dynamic profile; // You can replace dynamic with a specific ProfileModel if needed

  GoalModel({
    this.goalId,
    this.goalTitle,
    this.goalDescription,
    this.goalType,
    this.goalStartDate,
    this.goalEndDate,
    this.goalTargetCount,
    this.goalPeriodDays,
    this.goalStatus,
    this.goalCreatedAt,
    this.goalUpdatedAt,
    this.goalCompletedAt,
    this.profileId,
    // this.profile,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      goalId: json['goalId'] as String?,
      goalTitle: json['goalTitle'] as String?,
      goalDescription: json['goalDescription'] as String?,
      goalType: json['goalType'] as String?,
      goalStartDate: json['goalStartDate'] != null ? DateTime.parse(json['goalStartDate']) : null,
      goalEndDate: json['goalEndDate'] != null ? DateTime.parse(json['goalEndDate']) : null,
      goalTargetCount: json['goalTargetCount'] as int?,
      goalPeriodDays: json['goalPeriodDays'] as int?,
      goalStatus: json['goalStatus'] as String?,
      goalCreatedAt: json['goalCreatedAt'] != null ? DateTime.parse(json['goalCreatedAt']) : null,
      goalUpdatedAt: json['goalUpdatedAt'] != null ? DateTime.parse(json['goalUpdatedAt']) : null,
      goalCompletedAt: json['goalCompletedAt'] != null ? DateTime.parse(json['goalCompletedAt']) : null,
      profileId: json['profileId'] as String?,
      // profile: json['profile'], // Replace this with ProfileModel.fromJson(json['profile']) if needed
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goalId': goalId,
      'goalTitle': goalTitle,
      'goalDescription': goalDescription,
      'goalType': goalType,
      'goalStartDate': goalStartDate?.toIso8601String(),
      'goalEndDate': goalEndDate?.toIso8601String(),
      'goalTargetCount': goalTargetCount,
      'goalPeriodDays': goalPeriodDays,
      'goalStatus': goalStatus,
      'goalCreatedAt': goalCreatedAt?.toIso8601String(),
      'goalUpdatedAt': goalUpdatedAt?.toIso8601String(),
      'goalCompletedAt': goalCompletedAt?.toIso8601String(),
      'profileId': profileId,
      // 'profile': profile, // Replace with profile?.toJson() if using a model
    };
  }
}
