import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/community/community_model.dart';
import 'package:inner_child_app/domain/repositories/i_community_repository.dart';

class CommunityUsecase {
  final ICommunityRepository iCommunityRepository;

  CommunityUsecase(this.iCommunityRepository);

  Future<Result<List<CommunityModel>>> getAllCommunityGroups() {
    return iCommunityRepository.getAllCommunityGroups();
  }
}