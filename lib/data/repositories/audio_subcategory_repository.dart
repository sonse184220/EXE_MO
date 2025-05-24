import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/audio_subcategory_api_service.dart';
import 'package:inner_child_app/domain/entities/audio_subcategory/audio_subcategory_model.dart';
import 'package:inner_child_app/domain/repositories/i_audio_subcategory_repository.dart';

class AudioSubcategoryRepository implements IAudioSubcategoryRepository {
  final AudioSubcategoryApiService _audioSubcategoryApiService;

  AudioSubcategoryRepository(this._audioSubcategoryApiService);

  @override
  Future<Result<List<SubAudioCategoryModel>>> getAllSubAudioCategories() async {
    try {
          final response = await _audioSubcategoryApiService.getAllSubAudioCategories();

          if (response.statusCode == 200) {
            final data = response.data;

            final chatSessions =
            (data as List<dynamic>)
                .map((e) => SubAudioCategoryModel.fromJson(e))
                .toList();
            return Result.success(chatSessions);
          }

          return Result.failure(
            'Failed to fetch all AudioCategory: ${response.statusCode}',
          );
        } catch (e) {
          return Result.failure('Fetch all AudioCategory error: $e');
        }
  }
}
