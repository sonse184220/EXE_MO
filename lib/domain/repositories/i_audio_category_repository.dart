import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/audio_category/audio_category.dart';

abstract class IAudioCategoryRepository {
  Future<Result<List<AudioCategory>>> getAllAudioCategories();
}