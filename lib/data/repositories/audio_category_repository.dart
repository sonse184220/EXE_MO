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


}
