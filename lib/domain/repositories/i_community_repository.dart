import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/community/community_group_model.dart';

abstract class ICommunityRepository{
  Future<Result<List<CommunityGroupModel>>> getAllCommunityGroups();
  Future<Result<CommunityGroupModel>> getCommunityGroupById(String id);
}