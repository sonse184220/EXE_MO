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

  @override
  Future<Result<String>> createType(String typeName) async {
    try {
      final response = await _apiService.createType(typeName);

      if (response.statusCode == 201) {
        return Result.success('Type created successfully');
      }
      return Result.failure('Fail to create type. Please try again');
    } catch (e) {
      return Result.failure('Create type error');
    }
  }

  @override
  Future<Result<String>> updateType(String id, String typeName) async {
    try {
      final response = await _apiService.updateType(id, typeName);

      if (response.statusCode == 204) {
        return Result.success('Type updated successfully');
      }
      return Result.failure('Fail to update type. Please try again');
    } catch (e) {
      return Result.failure('Update type error');
    }
  }
}