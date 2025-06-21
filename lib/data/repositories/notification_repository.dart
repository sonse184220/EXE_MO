import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/notification_api_service.dart';
import 'package:inner_child_app/domain/entities/notification/notification_model.dart';
import 'package:inner_child_app/domain/repositories/i_notification_repository.dart';

class NotificationRepository implements INotificationRepository {
  final NotificationApiService apiService;

  NotificationRepository(this.apiService);

  @override
  Future<Result<List<NotificationModel>>> getAllNotifications() async {
    try {
      final response = await apiService.getAllNotifications();

      if (response.statusCode == 200) {
        final data = response.data;

        final types =
        (data as List<dynamic>)
            .map((e) => NotificationModel.fromJson(e))
            .toList();
        return Result.success(types);
      }
      return Result.failure('Fail to get all notifications. Please try again');
    } catch (e) {
      return Result.failure('Get all notifications error: $e');
    }
  }
}