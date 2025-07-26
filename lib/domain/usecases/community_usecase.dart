import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/community/community_group_model.dart';
import 'package:inner_child_app/domain/entities/community/community_post_model.dart';
import 'package:inner_child_app/domain/entities/community/create_comment_model.dart';
import 'package:inner_child_app/domain/entities/community/create_community_post_model.dart';
import 'package:inner_child_app/domain/repositories/i_community_repository.dart';

class CommunityUsecase {
  final ICommunityRepository iCommunityRepository;

  CommunityUsecase(this.iCommunityRepository);

  Future<Result<List<CommunityGroupModel>>> getAllCommunityGroups() {
    return iCommunityRepository.getAllCommunityGroups();
  }

  Future<Result<CommunityGroupModel>> getCommunityGroupById(String id) {
    return iCommunityRepository.getCommunityGroupById(id);
  }

  Future<Result<String>> createCommunityPost(CreateCommunityPostModel post) {
    return iCommunityRepository.createCommunityPost(post);
  }

  Future<Result<String>> joinCommunity(String communityGroupId) {
    return iCommunityRepository.joinCommunity(communityGroupId);
  }

  Future<Result<String>> leaveCommunity(String communityGroupId) {
    return iCommunityRepository.leaveCommunity(communityGroupId);
  }

  Future<Result<String>> updateCommunityPost(String postId, CreateCommunityPostModel post) {
    return iCommunityRepository.updateCommunityPost(postId, post);
  }

  Future<Result<CommunityPostModel>> getCommunityPostDetail(String postId) {
    return iCommunityRepository.getCommunityPostDetail(postId);
  }

  Future<Result<String>> createCommunityGroup(String name, String description, String status) {
    return iCommunityRepository.createCommunityGroup(name, description, status);
  }

  Future<Result<String>> updateCommunityGroup(String groupId, String name, String description, String status) {
    return iCommunityRepository.updateCommunityGroup(groupId, name, description, status);
  }

  Future<Result<String>> likePost(String postId) {
    return iCommunityRepository.likePost(postId);
  }

  Future<Result<String>> unlikePost(String postId) {
    return iCommunityRepository.unlikePost(postId);
  }

  Future<Result<String>> likeComment(String commentId) {
    return iCommunityRepository.likeComment(commentId);
  }

  Future<Result<String>> unlikeComment(String commentId) {
    return iCommunityRepository.unlikeComment(commentId);
  }

  Future<Result<String>> createComment(CreateCommentModel comment) {
    return iCommunityRepository.createComment(comment);
  }

  // Future<Result<String>> updateComment(String commentId, CreateCommentModel comment) {
  //   return iCommunityRepository.updateComment(commentId, comment);
  // }

  Future<Result<String>> deleteComment(String commentId) {
    return iCommunityRepository.deleteComment(commentId);
  }
}