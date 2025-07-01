import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/audio_api_service.dart';
import 'package:inner_child_app/domain/entities/audio/audio_model.dart';
import 'package:inner_child_app/domain/entities/audio/create_audio_model.dart';
import 'package:inner_child_app/domain/repositories/i_audio_repository.dart';

class AudioRepository implements IAudioRepository {
  final AudioApiService audioApiService;

  AudioRepository(this.audioApiService);

  @override
  Future<Result<List<AudioModel>>> getAllAudios() async {
    try {
      final response = await audioApiService.getAllAudios();

      if (response.statusCode == 200) {
        final data = response.data;

        final audios =
            (data as List<dynamic>).map((e) => AudioModel.fromJson(e)).toList();
        return Result.success(audios);
      }

      return Result.failure('Failed to fetch audios: ${response.statusCode}');
    } catch (e) {
      return Result.failure('Fetch audios error: $e');
    }
  }

  @override
  Future<Result<List<AudioModel>>> getAllAudiosUser() async {
    try {
      final response = await audioApiService.getAllAudiosUser();

      if (response.statusCode == 200) {
        final data = response.data;

        final audios =
        (data as List<dynamic>).map((e) => AudioModel.fromJson(e)).toList();
        return Result.success(audios);
      }

      return Result.failure('Failed to fetch audios user: ${response.statusCode}');
    } catch (e) {
      return Result.failure('Fetch audios user error: $e');
    }
  }

  @override
  Future<Result<AudioModel>> getAudioDetail(String audioId) async {
    try {
      final response = await audioApiService.getAudioDetail(audioId);

      if (response.statusCode == 200) {
        final data = response.data;

        final audioDetail = AudioModel.fromJson(data);
        return Result.success(audioDetail);
      }

      return Result.failure(
        'Failed to fetch audio detail: ${response.statusCode}',
      );
    } catch (e) {
      return Result.failure('Fetch audio detail error: $e');
    }
  }

  @override
  Future<Result<String>> createAudio(CreateAudioModel audio) async {
    try {
      final response = await audioApiService.createAudio(audio);

      if (response.statusCode == 201) {
        return Result.success('Audio created successfully');
      }

      return Result.failure('Failed to create audio: ${response.statusCode}');
    } catch (e) {
      return Result.failure('Create audio error: $e');
    }
  }

  @override
  Future<Result<String>> updateAudio(String id, CreateAudioModel audio) async {
    try {
      final response = await audioApiService.updateAudio(id, audio);

      if (response.statusCode == 200) {
        return Result.success('Audio uodated successfully');
      }

      return Result.failure('Failed to update audio: ${response.statusCode}');
    } catch (e) {
      return Result.failure('Update audio error: $e');
    }
  }
}
