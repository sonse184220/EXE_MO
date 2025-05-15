import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/community_api_service.dart';
import 'package:inner_child_app/domain/entities/community_model.dart';
import 'package:inner_child_app/domain/repositories/i_community_repository.dart';

class CommunityRepository implements ICommunityRepository {
  final CommunityApiService apiService;

  CommunityRepository(this.apiService);

  @override
  Future<Result<List<CommunityModel>>> getAllCommunityGroups() {
    // TODO: implement getAllCommunityGroups
    throw UnimplementedError();
  }
}