class MoodJournalTypeModel {
  final String moodJournalTypeId;
  final String moodJournalTypeName;
  // final List<dynamic> moodJournals;

  MoodJournalTypeModel({
    required this.moodJournalTypeId,
    required this.moodJournalTypeName,
    // required this.moodJournals,
  });

  factory MoodJournalTypeModel.fromJson(Map<String, dynamic> json) {
    return MoodJournalTypeModel(
      moodJournalTypeId: json['moodJournalTypeId'],
      moodJournalTypeName: json['moodJournalTypeName'],
      // moodJournals: json['moodJournals'] ?? [],
    );
  }
}