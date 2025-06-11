import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';

class AudioCategoryApiService {
  final DioClient _client;

  AudioCategoryApiService(this._client);

  Future<Response> getAllAudioCategories() async {
    return await _client.get('innerchild/audiocategory/all');
  }

  Future<Response> createAudioCategory(String name) async {
    final dataObject = {
      "audioCategoryName": name
    };
    return await _client.post('innerchild/audiocategory/create', data: dataObject);
  }

  Future<Response> updateAudioCategory(String id, String name) async {
    final dataObject = {
      "audioCategoryName": name
    };
    return await _client.put('innerchild/audiocategory/update/$id', data: dataObject);
  }
}