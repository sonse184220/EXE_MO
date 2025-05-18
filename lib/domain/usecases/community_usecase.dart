import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/community/community_group_model.dart';
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
}