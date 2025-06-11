import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/community/community_group_model.dart';
import 'package:inner_child_app/domain/entities/community/community_post_model.dart';
import 'package:inner_child_app/domain/entities/community/create_community_post_model.dart';

abstract class ICommunityRepository{
  Future<Result<List<CommunityGroupModel>>> getAllCommunityGroups();
  Future<Result<CommunityGroupModel>> getCommunityGroupById(String id);
  Future<Result<String>> createCommunityPost(CreateCommunityPostModel post);
  Future<Result<String>> joinCommunity(String communityGroupId);
  Future<Result<String>> leaveCommunity(String communityGroupId);
  Future<Result<String>> updateCommunityPost(String postId, CreateCommunityPostModel post);
  Future<Result<CommunityPostModel>> getCommunityPostDetail(String postId);
  Future<Result<String>> createCommunityGroup(String name, String description, String status);
  Future<Result<String>> updateCommunityGroup(String groupId, String name, String description, String status);
}