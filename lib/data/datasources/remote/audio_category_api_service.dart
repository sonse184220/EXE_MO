import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';

class AudioCategoryApiService {
  final DioClient _client;

  AudioCategoryApiService(this._client);

  Future<Response> getAllAudioCategories() async {
    return await _client.get('innerchild/audiocategory/all');
  }
}