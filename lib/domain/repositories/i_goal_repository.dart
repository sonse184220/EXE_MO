import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/goal/create_goal_model.dart';
import 'package:inner_child_app/domain/entities/goal/goal_model.dart';

abstract class IGoalRepository {
  Future<Result<List<GoalModel>>> getOwnGoals();
  Future<Result<String>> createOwnGoals(CreateGoalModel goal);
  Future<Result<String>> updateOwnGoals(String goalId, CreateGoalModel goal);
  Future<Result<String>> deleteOwnGoals(String goalId);
}