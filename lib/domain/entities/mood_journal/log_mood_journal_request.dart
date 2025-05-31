class LogMoodJournalRequest{
  final String moodJournalTitle;
  final String moodJournalEmotion;
  final String moodJournalDescription;
  final String moodJournalTypeId;

  LogMoodJournalRequest({
    required this.moodJournalTitle,
    required this.moodJournalEmotion,
    required this.moodJournalDescription,
    required this.moodJournalTypeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'moodJournalTitle': moodJournalTitle,
      'moodJournalEmotion': moodJournalEmotion,
      'moodJournalDescription': moodJournalDescription,
      'moodJournalTypeId': moodJournalTypeId,
    };
  }
}