import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';

class AudioSubcategoryApiService {
  final DioClient _client;

  AudioSubcategoryApiService(this._client);

  Future<Response> getAllSubAudioCategories() async {
    return await _client.get('innerchild/subaudiocategory/all');
  }

  Future<Response> createAudioSubCategory(
    String categoryId,
    String name,
  ) async {
    final dataObject = {
      "subAudioCategoryName": name,
      "audioCategoryId": categoryId,
    };
    return await _client.post('innerchild/subaudiocategory/create', data: dataObject);
  }

  Future<Response> updateAudioSubCategory(
    String id,
    String categoryId,
    String name,
  ) async {
    final dataObject = {
      "subAudioCategoryName": name,
      "audioCategoryId": categoryId,
    };
    return await _client.put(
      'innerchild/subaudiocategory/update/$id',
      data: dataObject,
    );
  }
}
