import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/mood_journal_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/mood_journal_type_api_service.dart';
import 'package:inner_child_app/domain/entities/mood_journal_type/mood_journal_type_model.dart';
import 'package:inner_child_app/domain/repositories/i_mood_journal_repository.dart';
import 'package:inner_child_app/domain/repositories/i_mood_journal_type_repository.dart';

class MoodJournalTypeRepository implements IMoodJournalTypeRepository {
  final MoodJournalTypeApiService _apiService;

  MoodJournalTypeRepository(this._apiService);

  @override
  Future<Result<List<MoodJournalTypeModel>>> getAllTypes() async {
    try {
      final response = await _apiService.getAllTypes();

      if (response.statusCode == 200) {
        final data = response.data;

        final types =
        (data as List<dynamic>)
            .map((e) => MoodJournalTypeModel.fromJson(e))
            .toList();
        return Result.success(types);
      }
      return Result.failure('Fail to get all types. Please try again');
    } catch (e) {
      return Result.failure('Get all types error: $e');
    }
  }
}