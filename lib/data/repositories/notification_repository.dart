import 'package:inner_child_app/data/datasources/remote/notification_api_service.dart';
import 'package:inner_child_app/domain/repositories/i_notification_repository.dart';

class NotificationRepository implements INotificationRepository {
  final NotificationApiService apiService;

  NotificationRepository(this.apiService);
}