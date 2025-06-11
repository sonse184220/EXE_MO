import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/audio_category_api_service.dart';
import 'package:inner_child_app/domain/entities/audio_category/audio_category.dart';
import 'package:inner_child_app/domain/repositories/i_audio_category_repository.dart';

class AudioCategoryRepository implements IAudioCategoryRepository {
  final AudioCategoryApiService _audioCategoryApiService;

  AudioCategoryRepository(this._audioCategoryApiService);

  @override
  Future<Result<List<AudioCategory>>> getAllAudioCategories() async {
    try {
      final response = await _audioCategoryApiService.getAllAudioCategories();

      if (response.statusCode == 200) {
        final data = response.data;

        final chatSessions =
        (data as List<dynamic>)
            .map((e) => AudioCategory.fromJson(e))
            .toList();
        return Result.success(chatSessions);
      }

      return Result.failure(
        'Failed to fetch all audio category: ${response.statusCode}',
      );
    } catch (e) {
      return Result.failure('Fetch all audio category error: $e');
    }
  }

  @override
  Future<Result<String>> createAudioCategory(String name) async {
    try {
      final response = await _audioCategoryApiService.createAudioCategory(name);

      if (response.statusCode == 201) {
        return Result.success('Audio Category created successfully');
      }

      return Result.failure(
        'Failed to create audio category: ${response.statusCode}',
      );
    } catch (e) {
      return Result.failure('Create audio category error: $e');
    }
  }

  @override
  Future<Result<String>> updateAudioCategory(String id, String name) async {
    try {
      final response = await _audioCategoryApiService.updateAudioCategory(id, name);

      if (response.statusCode == 204) {
        return Result.success('Audio Category updated successfully');
      }

      return Result.failure(
        'Failed to update audio category: ${response.statusCode}',
      );
    } catch (e) {
      return Result.failure('Update audio category error: $e');
    }
  }
}
