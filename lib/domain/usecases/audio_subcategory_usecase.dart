import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/audio_subcategory/audio_subcategory_model.dart';
import 'package:inner_child_app/domain/repositories/i_audio_subcategory_repository.dart';

class AudioSubcategoryUsecase {
  final IAudioSubcategoryRepository _audioSubcategoryRepository;

  AudioSubcategoryUsecase(this._audioSubcategoryRepository);

  Future<Result<List<SubAudioCategoryModel>>> getAllSubAudioCategories() {
    return _audioSubcategoryRepository.getAllSubAudioCategories();
  }

  Future<Result<String>> createAudioSubCategory(
    String categoryId,
    String name,
  ) {
    return _audioSubcategoryRepository.createAudioSubCategory(categoryId, name);
  }

  Future<Result<String>> updateAudioSubCategory(
    String id,
    String categoryId,
    String name,
  ) {
    return _audioSubcategoryRepository.updateAudioSubCategory(
      id,
      categoryId,
      name,
    );
  }
}
