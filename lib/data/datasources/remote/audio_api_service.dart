import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';
import 'package:inner_child_app/domain/entities/audio/create_audio_model.dart';

class AudioApiService {
  final DioClient _client;

  AudioApiService(this._client);
  
  Future<Response> getAllAudios() async {
    return await _client.get('innerchild/audio/all');
  }

  Future<Response> getAllAudiosUser() async {
    return await _client.get('innerchild/audio/get/user-audio');
  }

  Future<Response> getAudioDetail(String audioId) async {
    return await _client.get('innerchild/audio/detail/$audioId');
  }

  Future<Response> createAudio(CreateAudioModel audio) async {
    final formData = await audio.toFormData();

    // 🔍 DEBUG: Print each field in the FormData
    formData.fields.forEach((field) {
      print('📝 Field: ${field.key} = ${field.value}');
    });

    formData.files.forEach((file) {
      print('📁 File field: ${file.key}, filename: ${file.value.filename}, contentType: ${file.value.contentType}');
    });


    return await _client.post('innerchild/audio/create', data: formData);
    // return await _client.post('https://httpbin.org/post', data: formData);
  }

  Future<Response> updateAudio(String id, CreateAudioModel audio) async {
    final formData = await audio.toFormData();
    return await _client.put('innerchild/audio/update/$id', data: formData);
  }
}