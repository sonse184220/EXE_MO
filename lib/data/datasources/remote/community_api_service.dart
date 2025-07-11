import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';
import 'package:inner_child_app/domain/entities/community/create_comment_model.dart';
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

  Future<Response> updateCommunityPost(String postId, CreateCommunityPostModel post) async {
    final formdata = await post.toFormData();
    return await _client.put('innerchild/community/update-post/$postId', data: formdata);
  }

  Future<Response> getCommunityPostDetail(String postId) async {
    return await _client.get('innerchild/community/post-detail/$postId');
  }

  Future<Response> createCommunityGroup(String name, String description, String status) async {
    final formData = FormData.fromMap({
      'communityName': name,
      'communityDescription': description,
      'communityStatus': status,
    });
    return await _client.post('innerchild/community/create-community', data: formData);
  }

  Future<Response> updateCommunityGroup(String groupId, String name, String description, String status) async {
    final formData = FormData.fromMap({
      'communityName': name,
      'communityDescription': description,
      'communityStatus': status,
    });
    return await _client.put('innerchild/community/update-community/$groupId', data: formData);
  }

  Future<Response> likePost(String postId) async {
    return await _client.post(
      'innerchild/community/post-like/$postId',
    );
  }

  Future<Response> unlikePost(String postId) async {
    return await _client.delete(
      'innerchild/community/post-unlike/$postId',
    );
  }

  Future<Response> likeComment(String commentId) async {
    return await _client.post(
      'innerchild/community/comment-like/$commentId',
    );
  }

  Future<Response> unlikeComment(String commentId) async {
    return await _client.delete(
      'innerchild/community/comment-unlike/$commentId',
    );
  }

  Future<Response> createComment(CreateCommentModel comment) async {
    final formData = await comment.toFormData();
    return await _client.post(
      'innerchild/community/comment',
      data: formData,
    );
  }

  Future<Response> updateComment(
      String commentId,
      Map<String, dynamic> body,
      ) async {
    return await _client.put(
      'innerchild/community/comment-update/$commentId',
      data: body,
    );
  }

  Future<Response> deleteComment(String commentId) async {
    return await _client.delete(
      'innerchild/community/comment-delete/$commentId',
    );
  }
}