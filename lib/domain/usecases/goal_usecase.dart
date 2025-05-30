import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/goal/create_goal_model.dart';
import 'package:inner_child_app/domain/entities/goal/goal_model.dart';
import 'package:inner_child_app/domain/repositories/i_goal_repository.dart';

class GoalUsecase {
  final IGoalRepository _goalRepository;

  GoalUsecase(this._goalRepository);

  Future<Result<List<GoalModel>>> getOwnGoals() {
    return _goalRepository.getOwnGoals();
  }

  Future<Result<String>> createOwnGoals(CreateGoalModel goal) {
    return _goalRepository.createOwnGoals(goal);
  }

  Future<Result<String>> updateOwnGoals(String goalId, CreateGoalModel goal) {
    return _goalRepository.updateOwnGoals(goalId, goal);
  }

  Future<Result<String>> deleteOwnGoals(String goalId) {
    return _goalRepository.deleteOwnGoals(goalId);
  }
}