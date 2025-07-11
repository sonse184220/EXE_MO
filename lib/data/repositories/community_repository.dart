import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/community_api_service.dart';
import 'package:inner_child_app/domain/entities/community/community_group_model.dart';
import 'package:inner_child_app/domain/entities/community/community_post_model.dart';
import 'package:inner_child_app/domain/entities/community/create_comment_model.dart';
import 'package:inner_child_app/domain/entities/community/create_community_post_model.dart';
import 'package:inner_child_app/domain/repositories/i_community_repository.dart';

class CommunityRepository implements ICommunityRepository {
  final CommunityApiService _apiService;

  CommunityRepository(this._apiService);

  @override
  Future<Result<List<CommunityGroupModel>>> getAllCommunityGroups() async {
    try {
      final response = await _apiService.getAllCommunityGroups();

      if (response.statusCode == 200) {
        final data = response.data;

        final communities =
            (data as List<dynamic>)
                .map((e) => CommunityGroupModel.fromJson(e))
                .toList();
        return Result.success(communities);
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure('Fetch community groups error');
    }
  }

  @override
  Future<Result<CommunityGroupModel>> getCommunityGroupById(String id) async {
    try {
      final response = await _apiService.getCommunityGroupById(id);

      if (response.statusCode == 200) {
        final data = response.data;

        final community = CommunityGroupModel.fromJson(data);
        return Result.success(community);
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure('Fetch community group by Id error');
    }
  }

  @override
  Future<Result<String>> createCommunityPost(CreateCommunityPostModel post) async {
    try {
      final response = await _apiService.createCommunityPost(post);

      if (response.statusCode == 201) {
        // final data = response.data;

        // final community = CommunityGroupModel.fromJson(data);
        return Result.success('Post created succesfully');
      }
      return Result.failure('Fail to create community post. Please try again');
    } catch (e) {
      return Result.failure('Create community post error');
    }
  }

  @override
  Future<Result<String>> joinCommunity(String communityGroupId) async {
    try {
      final response = await _apiService.joinCommunity(communityGroupId);

      if (response.statusCode == 201) {
        // final data = response.data;

        // final community = CommunityGroupModel.fromJson(data);
        return Result.success('Join community succesfully');
      }
      return Result.failure('Fail to Join community. Please try again');
    } catch (e) {
      return Result.failure('Join community error');
    }
  }

  @override
  Future<Result<String>> leaveCommunity(String communityGroupId) async {
    try {
      final response = await _apiService.leaveCommunity(communityGroupId);

      if (response.statusCode == 200) {
        // final data = response.data;

        // final community = CommunityGroupModel.fromJson(data);
        return Result.success('Leave community succesfully');
      }
      return Result.failure('Fail to leave community. Please try again');
    } catch (e) {
      return Result.failure('Leave community error');
    }
  }

  @override
  Future<Result<String>> updateCommunityPost(String postId, CreateCommunityPostModel post) async {
    try {
      final response = await _apiService.updateCommunityPost(postId, post);

      if (response.statusCode == 204) {
        // final data = response.data;

        // final community = CommunityGroupModel.fromJson(data);
        return Result.success('Post updated succesfully');
      }
      return Result.failure('Fail to update post. Please try again');
    } catch (e) {
      return Result.failure('Update post error');
    }
  }

  @override
  Future<Result<CommunityPostModel>> getCommunityPostDetail(String postId) async {
    try {
      final response = await _apiService.getCommunityPostDetail(postId);

      if (response.statusCode == 200) {
        final data = response.data;

        final communityPostDetail = CommunityPostModel.fromJson(data);
        return Result.success(communityPostDetail);
      }
      return Result.failure('Fail to get post detail. Please try again');
    } catch (e) {
      return Result.failure('Get post detail error');
    }
  }

  @override
  Future<Result<String>> createCommunityGroup(String name, String description, String status) async {
    try {
      final response = await _apiService.createCommunityGroup(name, description, status);

      if (response.statusCode == 201) {
        // final data = response.data;

        // final community = CommunityGroupModel.fromJson(data);
        return Result.success('Group created succesfully');
      }
      return Result.failure('Fail to create community group. Please try again');
    } catch (e) {
      return Result.failure('Create community group error');
    }
  }

  @override
  Future<Result<String>> updateCommunityGroup(String groupId, String name, String description, String status) async {
    try {
      final response = await _apiService.updateCommunityGroup(groupId, name, description, status);

      if (response.statusCode == 204) {
        // final data = response.data;

        // final community = CommunityGroupModel.fromJson(data);
        return Result.success('Group updated succesfully');
      }
      return Result.failure('Fail to update community group. Please try again');
    } catch (e) {
      return Result.failure('Update community group error');
    }
  }

  @override
  Future<Result<String>> likePost(String postId) async {
    try {
      final response = await _apiService.likePost(postId);

      if (response.statusCode == 200) {
        // final data = response.data;

        // final community = CommunityGroupModel.fromJson(data);
        return Result.success('Like post succesfully');
      }
      return Result.failure('Fail to like post. Please try again');
    } catch (e) {
      return Result.failure('Like post error');
    }
  }

  @override
  Future<Result<String>> unlikePost(String postId) async {
    try {
      final response = await _apiService.unlikePost(postId);

      if (response.statusCode == 200) {
        return Result.success('Post unliked successfully');
      }
      return Result.failure('Fail to unlike post. Please try again');
    } catch (e) {
      return Result.failure('Unlike post error');
    }
  }

  @override
  Future<Result<String>> likeComment(String commentId) async {
    try {
      final response = await _apiService.likeComment(commentId);

      if (response.statusCode == 200) {
        return Result.success('Comment liked successfully');
      }
      return Result.failure('Fail to like comment. Please try again');
    } catch (e) {
      return Result.failure('Like comment error');
    }
  }

  @override
  Future<Result<String>> unlikeComment(String commentId) async {
    try {
      final response = await _apiService.unlikeComment(commentId);

      if (response.statusCode == 200) {
        return Result.success('Comment unliked successfully');
      }
      return Result.failure('Fail to unlike comment. Please try again');
    } catch (e) {
      return Result.failure('Unlike comment error');
    }
  }

  @override
  Future<Result<String>> createComment(CreateCommentModel comment) async {
    try {
      final response = await _apiService.createComment(comment);

      if (response.statusCode == 200) {
        return Result.success('Comment created successfully');
      }
      return Result.failure('Fail to create comment. Please try again');
    } catch (e) {
      return Result.failure('Create comment error');
    }
  }

  // @override
  // Future<Result<String>> updateComment(
  //     String commentId, CreateCommentModel comment) async {
  //   try {
  //     final response = await _apiService.updateComment(commentId, comment);
  //
  //     if (response.statusCode == 204) {
  //       return Result.success('Comment updated successfully');
  //     }
  //     return Result.failure('Fail to update comment. Please try again');
  //   } catch (e) {
  //     return Result.failure('Update comment error: $e');
  //   }
  // }

  @override
  Future<Result<String>> deleteComment(String commentId) async {
    try {
      final response = await _apiService.deleteComment(commentId);

      if (response.statusCode == 200) {
        return Result.success('Comment deleted successfully');
      }
      return Result.failure('Fail to delete comment. Please try again');
    } catch (e) {
      return Result.failure('Delete comment error');
    }
  }
}
