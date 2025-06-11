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
      final response =
          await _audioSubcategoryApiService.getAllSubAudioCategories();

      if (response.statusCode == 200) {
        final data = response.data;

        final subCategories =
            (data as List<dynamic>)
                .map((e) => SubAudioCategoryModel.fromJson(e))
                .toList();
        return Result.success(subCategories);
      }

      return Result.failure(
        'Failed to fetch all sub AudioCategory: ${response.statusCode}',
      );
    } catch (e) {
      return Result.failure('Fetch all sub AudioCategory error: $e');
    }
  }

  @override
  Future<Result<String>> createAudioSubCategory(
    String categoryId,
    String name,
  ) async {
    try {
      final response =
          await _audioSubcategoryApiService.createAudioSubCategory(categoryId, name);

      if (response.statusCode == 201) {
        return Result.success('Create sub audiocategory successfully');
      }

      return Result.failure(
        'Failed to create sub audiocategory: ${response.statusCode}',
      );
    } catch (e) {
      return Result.failure('Create sub audiocategory error: $e');
    }
  }

  @override
  Future<Result<String>> updateAudioSubCategory(
    String id,
    String categoryId,
    String name,
  ) async {
    try {
      final response =
          await _audioSubcategoryApiService.updateAudioSubCategory(id, categoryId, name);

      if (response.statusCode == 204) {
        return Result.success('Update sub audiocategory successfully');
      }

      return Result.failure(
        'Failed to update sub audiocategory: ${response.statusCode}',
      );
    } catch (e) {
      return Result.failure('Update sub audiocategory error: $e');
    }
  }
}
