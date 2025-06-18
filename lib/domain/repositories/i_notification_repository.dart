import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/notification/notification_model.dart';

abstract class INotificationRepository {
  Future<Result<List<NotificationModel>>> getAllNotifications();
}