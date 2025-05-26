import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';
import 'package:inner_child_app/domain/entities/community/create_community_post_model.dart';

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
  Future<Response> createCommunityPost(CreateCommunityPostModel post) async {
    final data = await post.toFormData();
    return await _client.post('innerchild/community/create-post', data: data);
  }

  Future<Response> joinCommunity(String communityGroupId) async {
    final data = {
      "communityGroupId": communityGroupId
    };
    return await _client.post('innerchild/community/join-community', data: data);
  }

  Future<Response> leaveCommunity(String communityGroupId) async {
    return await _client.post('innerchild/community/leave-community/$communityGroupId');
  }
}