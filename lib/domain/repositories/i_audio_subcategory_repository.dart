import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/audio_subcategory/audio_subcategory_model.dart';

abstract class IAudioSubcategoryRepository {
  Future<Result<List<SubAudioCategoryModel>>> getAllSubAudioCategories();
}