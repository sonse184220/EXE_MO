import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';

class SubscriptionApiService {
  final DioClient _client;

  SubscriptionApiService(this._client);

  Future<Response> getAllSubscriptions(){
    return _client.get('innerchild/subscription/all');
  }
}