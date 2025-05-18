import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/community_api_service.dart';
import 'package:inner_child_app/domain/entities/community/community_group_model.dart';
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
      return Result.failure('Fetch community groups error: $e');
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
      return Result.failure('Fetch community group by Id error: $e');
    }
  }
}
