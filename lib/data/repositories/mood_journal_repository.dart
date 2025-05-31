import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/mood_journal_api_service.dart';
import 'package:inner_child_app/domain/entities/mood_journal/log_mood_journal_request.dart';
import 'package:inner_child_app/domain/repositories/i_mood_journal_repository.dart';

class MoodJournalRepository implements IMoodJournalRepository {
  final MoodJournalApiService _apiService;

  MoodJournalRepository(this._apiService);

  @override
  Future<Result<String>> logMood(LogMoodJournalRequest request) async {
    try {
      final response = await _apiService.logMood(request);

      if (response.statusCode == 201) {
        final data = response.data;

        // final types =
        // (data as List<dynamic>)
        //     .map((e) => MoodJournalTypeModel.fromJson(e))
        //     .toList();
        return Result.success('Log created successfully');
      }
      return Result.failure('Fail to create log. Please try again');
    } catch (e) {
      return Result.failure('Create log error: $e');
    }
  }
}