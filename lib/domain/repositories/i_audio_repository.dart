import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/audio/audio_model.dart';
import 'package:inner_child_app/domain/entities/audio/create_audio_model.dart';

abstract class IAudioRepository {
  Future<Result<List<AudioModel>>> getAllAudios();
  Future<Result<List<AudioModel>>> getAllAudiosUser();
  Future<Result<AudioModel>> getAudioDetail(String audioId);
  Future<Result<String>> createAudio(CreateAudioModel audio);
  Future<Result<String>> updateAudio(String id, CreateAudioModel audio);
}