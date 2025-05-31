import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/mood_journal_type/mood_journal_type_model.dart';

abstract class IMoodJournalTypeRepository {
  Future<Result<List<MoodJournalTypeModel>>> getAllTypes();
}