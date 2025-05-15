import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';

class CommunityApiService {
  final DioClient _client;

  CommunityApiService(this._client);

  Future<Response> getAllCommunityGroups() async {
    return await _client.get('innerchild/article/all');
  }
}