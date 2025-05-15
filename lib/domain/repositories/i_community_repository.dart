import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/community/community_model.dart';

abstract class ICommunityRepository{
  Future<Result<List<CommunityModel>>> getAllCommunityGroups();
}