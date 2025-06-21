import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/notification/notification_model.dart';
import 'package:inner_child_app/domain/repositories/i_notification_repository.dart';

class NotificationUseCase {
  final INotificationRepository iNotificationRepository;

  NotificationUseCase(this.iNotificationRepository);

  Future<Result<List<NotificationModel>>> getAllNotifications() {
    return iNotificationRepository.getAllNotifications();
  }
}