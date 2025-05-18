import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/audio/audio_model.dart';
import 'package:inner_child_app/domain/repositories/i_audio_repository.dart';

class AudioUseCase {
  final IAudioRepository iAudioRepository;

  AudioUseCase(this.iAudioRepository);

  Future<Result<List<AudioModel>>> getAllAudios() {
    return iAudioRepository.getAllAudios();
  }
}