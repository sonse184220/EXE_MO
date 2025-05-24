import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';

class AudioSubcategoryApiService {
  final DioClient _client;

  AudioSubcategoryApiService(this._client);

  Future<Response> getAllSubAudioCategories() async {
    return await _client.get('innerchild/subaudiocategory/all');
  }

}