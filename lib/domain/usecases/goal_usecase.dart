import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/goal/goal_model.dart';
import 'package:inner_child_app/domain/repositories/i_goal_repository.dart';

class GoalUsecase {
  final IGoalRepository _goalRepository;

  GoalUsecase(this._goalRepository);

  Future<Result<List<GoalModel>>> getOwnGoals() {
    return _goalRepository.getOwnGoals();
  }
}