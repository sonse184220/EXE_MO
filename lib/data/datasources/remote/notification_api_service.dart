import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';

class NotificationApiService {
  final DioClient _client;

  NotificationApiService(this._client);

  Future<Response> getAllNotifications() {
    return _client.get('innerchild/notification/all-own-notification');
  }
}