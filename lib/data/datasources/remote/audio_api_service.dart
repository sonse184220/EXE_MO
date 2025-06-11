import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';
import 'package:inner_child_app/domain/entities/audio/create_audio_model.dart';

class AudioApiService {
  final DioClient _client;

  AudioApiService(this._client);
  
  Future<Response> getAllAudios() async {
    return await _client.get('innerchild/audio/all');
  }

  Future<Response> getAudioDetail(String audioId) async {
    return await _client.get('innerchild/audio/detail/$audioId');
  }

  Future<Response> createAudio(CreateAudioModel audio) async {
    final formData = await audio.toFormData();
    return await _client.post('innerchild/audio/create', data: formData);
  }

  Future<Response> updateAudio(String id, CreateAudioModel audio) async {
    final formData = await audio.toFormData();
    return await _client.put('innerchild/audio/update/$id', data: formData);
  }
}