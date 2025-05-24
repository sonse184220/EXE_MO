import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/audio_category/audio_category.dart';
import 'package:inner_child_app/domain/repositories/i_audio_category_repository.dart';

class AudioCategoryUsecase {
  final IAudioCategoryRepository _audioCategoryRepository;

  AudioCategoryUsecase(this._audioCategoryRepository);

  Future<Result<List<AudioCategory>>> getAllAudioCategories() {
    return _audioCategoryRepository.getAllAudioCategories();
  }
}
