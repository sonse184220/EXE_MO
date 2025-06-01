import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/mood_journal/log_mood_journal_request.dart';
import 'package:inner_child_app/domain/entities/mood_journal/mood_journal_model.dart';

abstract class IMoodJournalRepository {
  Future<Result<String>> logMood(LogMoodJournalRequest request);
  Future<Result<List<MoodJournalModel>>> getMoodJournalHistory();
  Future<Result<String>> updateMoodJournal(String moodJournalId, LogMoodJournalRequest request);
}