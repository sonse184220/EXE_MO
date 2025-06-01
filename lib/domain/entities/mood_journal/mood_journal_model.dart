class MoodJournalModel {
  final String moodJournalId;
  final String moodJournalTitle;
  final String moodJournalEmotion;
  final String moodJournalDescription;
  final DateTime moodJournalCreatedAt;
  final String moodJournalTypeId;
  final String profileId;
  final String moodJournalTypeName;

  MoodJournalModel({
    required this.moodJournalId,
    required this.moodJournalTitle,
    required this.moodJournalEmotion,
    required this.moodJournalDescription,
    required this.moodJournalCreatedAt,
    required this.moodJournalTypeId,
    required this.profileId,
    required this.moodJournalTypeName,
  });

  factory MoodJournalModel.fromJson(Map<String, dynamic> json) {
    return MoodJournalModel(
      moodJournalId: json['moodJournalId'] as String,
      moodJournalTitle: json['moodJournalTitle'] as String,
      moodJournalEmotion: json['moodJournalEmotion'] as String,
      moodJournalDescription: json['moodJournalDescription'] as String,
      moodJournalCreatedAt: DateTime.parse(json['moodJournalCreatedAt'] as String),
      moodJournalTypeId: json['moodJournalTypeId'] as String,
      profileId: json['profileId'] as String,
      moodJournalTypeName: json['moodJournalTypeName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moodJournalId': moodJournalId,
      'moodJournalTitle': moodJournalTitle,
      'moodJournalEmotion': moodJournalEmotion,
      'moodJournalDescription': moodJournalDescription,
      'moodJournalCreatedAt': moodJournalCreatedAt.toIso8601String(),
      'moodJournalTypeId': moodJournalTypeId,
      'profileId': profileId,
      'moodJournalTypeName': moodJournalTypeName,
    };
  }
}