import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';

class CommunityApiService {
  final DioClient _client;

  CommunityApiService(this._client);

  Future<Response> getAllCommunityGroups() async {
    return await _client.get('innerchild/community/all-communities');
  }

  Future<Response> getCommunityGroupById(String id) async {
    // final communityGroupIdObject = {
    //   "communityGroupId": id
    // }
    return await _client.get('innerchild/community/community-detail/$id');
  }
}