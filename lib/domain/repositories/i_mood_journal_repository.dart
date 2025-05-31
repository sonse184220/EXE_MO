import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/mood_journal/log_mood_journal_request.dart';

abstract class IMoodJournalRepository {
  Future<Result<String>> logMood(LogMoodJournalRequest request);
}