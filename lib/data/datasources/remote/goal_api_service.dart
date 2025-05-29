import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';

class GoalApiService {
  final DioClient _client;

  GoalApiService(this._client);

  Future<Response> getOwnGoals() async {
    return await _client.get('innerchild/goal/get-own-goals');
  }

}