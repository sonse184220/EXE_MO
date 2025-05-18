import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/audio/audio_model.dart';

abstract class IAudioRepository {
  Future<Result<List<AudioModel>>> getAllAudios();
}