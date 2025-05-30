import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';
import 'package:inner_child_app/domain/entities/goal/create_goal_model.dart';

class GoalApiService {
  final DioClient _client;

  GoalApiService(this._client);

  Future<Response> getOwnGoals() async {
    return await _client.get('innerchild/goal/get-own-goals');
  }

  Future<Response> createOwnGoals(CreateGoalModel goal) async {
    final dataObject = goal.toJson();
    return await _client.post('innerchild/goal/create-own-goal', data: dataObject);
  }

  Future<Response> updateOwnGoals(String goalId, CreateGoalModel goal) async {
    final dataObject = goal.toJson();
    return await _client.put('innerchild/goal/update-own-goal/$goalId', data: dataObject);
  }

  Future<Response> deleteOwnGoals(String goalId) async {
    return await _client.delete('innerchild/goal/delete-own-goal/$goalId');
  }
}