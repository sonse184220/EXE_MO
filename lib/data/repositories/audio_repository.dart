import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/audio_api_service.dart';
import 'package:inner_child_app/domain/entities/audio/audio_model.dart';
import 'package:inner_child_app/domain/repositories/i_audio_repository.dart';

class AudioRepository implements IAudioRepository {
  final AudioApiService audioApiService;

  AudioRepository(this.audioApiService);

  @override
  Future<Result<List<AudioModel>>> getAllAudios() async {
      try{
        final response = await audioApiService.getAllAudios();

        if(response.statusCode == 200) {
          final data = response.data;

          final audios =
          (data as List<dynamic>)
              .map((e) => AudioModel.fromJson(e))
              .toList();
          return Result.success(audios);
        }

        return Result.failure('Failed to fetch audios: ${response.statusCode}');
      }catch(e){
        return Result.failure('Fetch audios error: $e');
      }
    }
}