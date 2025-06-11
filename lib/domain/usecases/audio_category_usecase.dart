import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/audio_category/audio_category.dart';
import 'package:inner_child_app/domain/repositories/i_audio_category_repository.dart';

class AudioCategoryUsecase {
  final IAudioCategoryRepository _audioCategoryRepository;

  AudioCategoryUsecase(this._audioCategoryRepository);

  Future<Result<List<AudioCategory>>> getAllAudioCategories() {
    return _audioCategoryRepository.getAllAudioCategories();
  }

  Future<Result<String>> createAudioCategory(String name) {
    return _audioCategoryRepository.createAudioCategory(name);
  }

  Future<Result<String>> updateAudioCategory(String id, String name) {
    return _audioCategoryRepository.updateAudioCategory(id, name);
  }
}
