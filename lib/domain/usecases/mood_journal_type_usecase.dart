import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/mood_journal_type/mood_journal_type_model.dart';
import 'package:inner_child_app/domain/repositories/i_mood_journal_repository.dart';
import 'package:inner_child_app/domain/repositories/i_mood_journal_type_repository.dart';

class MoodJournalTypeUsecase {
  final IMoodJournalTypeRepository _iMoodJournalTypeRepository;

  MoodJournalTypeUsecase(this._iMoodJournalTypeRepository);

  Future<Result<List<MoodJournalTypeModel>>> getAllTypes() {
    return _iMoodJournalTypeRepository.getAllTypes();
  }
}
