import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/goal_api_service.dart';
import 'package:inner_child_app/domain/entities/goal/goal_model.dart';
import 'package:inner_child_app/domain/repositories/i_goal_repository.dart';

class GoalRepository implements IGoalRepository {
  final GoalApiService _goalApiService;

  GoalRepository(this._goalApiService);

  @override
  Future<Result<List<GoalModel>>> getOwnGoals() async {
    try {
      final response = await _goalApiService.getOwnGoals();

      if (response.statusCode == 200) {
        final data = response.data;

        final goals =
        (data as List<dynamic>)
            .map((e) => GoalModel.fromJson(e))
            .toList();
        return Result.success(goals);
      }
      return Result.failure('Fail to get own goals. Please try again');
    } catch (e) {
      return Result.failure('Get own goals error: $e');
    }
  }
}