import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/community_api_service.dart';
import 'package:inner_child_app/domain/entities/community/community_model.dart';
import 'package:inner_child_app/domain/repositories/i_community_repository.dart';

class CommunityRepository implements ICommunityRepository {
  final CommunityApiService apiService;

  CommunityRepository(this.apiService);

  @override
  Future<Result<List<CommunityModel>>> getAllCommunityGroups() async {
    try{
      final response = await apiService.getAllCommunityGroups();

      if(response.statusCode == 200) {
        final data = response.data;

        final communities =
        (data as List<dynamic>)
            .map((e) => CommunityModel.fromJson(e))
            .toList();
        return Result.success(communities);
      }

      return Result.success(null);
    }catch(e){
      return Result.failure('Fetch community groups error: $e');
    }
  }
}