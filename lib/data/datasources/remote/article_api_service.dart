import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';

class ArticleApiService {
  final DioClient _client;

  ArticleApiService(this._client);

  Future<Response> getAllArticle() async {
    return await _client.get('article');
  }
}