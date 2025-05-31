import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/mood_journal/log_mood_journal_request.dart';
import 'package:inner_child_app/domain/repositories/i_mood_journal_repository.dart';

class MoodJournalUsecase {
  final IMoodJournalRepository _iMoodJournalRepository;

  MoodJournalUsecase(this._iMoodJournalRepository);

  Future<Result<String>> logMood(LogMoodJournalRequest request) {
    return _iMoodJournalRepository.logMood(request);
  }
}