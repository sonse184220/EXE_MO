import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/goal/goal_model.dart';

abstract class IGoalRepository {
  Future<Result<List<GoalModel>>> getOwnGoals();
}