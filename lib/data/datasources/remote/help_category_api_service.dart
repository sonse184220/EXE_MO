import 'package:dio/dio.dart';

import '../../../core/utils/dio_instance.dart';

class HelpCategoryApiService {
  final DioClient _client;

  HelpCategoryApiService(this._client);

  Future<Response> getAllHelpCategory() async {
    return await _client.get('innerchild/help/all-helpcategory');
  }


}