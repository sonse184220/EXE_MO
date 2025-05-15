import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';

class AudioApiService {
  final DioClient _client;

  AudioApiService(this._client);
  
  Future<Response> getAllAudios() async {
    return await _client.get('innerchild/audio/all');
  }
}