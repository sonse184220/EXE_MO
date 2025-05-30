import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/goal_api_service.dart';
import 'package:inner_child_app/domain/entities/goal/create_goal_model.dart';
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

  @override
  Future<Result<String>> createOwnGoals(CreateGoalModel goal) async {
    try {
      final response = await _goalApiService.createOwnGoals(goal);

      if (response.statusCode == 201) {
        final data = response.data;

        // final goals =
        // (data as List<dynamic>)
        //     .map((e) => GoalModel.fromJson(e))
        //     .toList();
        return Result.success('Success create');
      }
      return Result.failure('Fail to create goal. Please try again');
    } catch (e) {
      return Result.failure('Create goal error: $e');
    }
  }

  @override
  Future<Result<String>> updateOwnGoals(String goalId, CreateGoalModel goal) async {
    try {
      final response = await _goalApiService.updateOwnGoals(goalId, goal);

      if (response.statusCode == 204) {
        final data = response.data;

        // final goals =
        // (data as List<dynamic>)
        //     .map((e) => GoalModel.fromJson(e))
        //     .toList();
        return Result.success('Success update');
      }
      return Result.failure('Fail to update goal. Please try again');
    } catch (e) {
      return Result.failure('Update goal error: $e');
    }
  }

  @override
  Future<Result<String>> deleteOwnGoals(String goalId) async {
    try {
      final response = await _goalApiService.deleteOwnGoals(goalId);

      if (response.statusCode == 200) {
        final data = response.data;

        // final goals =
        // (data as List<dynamic>)
        //     .map((e) => GoalModel.fromJson(e))
        //     .toList();
        return Result.success('Success update');
      }
      return Result.failure('Fail to update goal. Please try again');
    } catch (e) {
      return Result.failure('Update goal error: $e');
    }
  }
}