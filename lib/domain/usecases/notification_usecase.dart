import 'package:inner_child_app/domain/repositories/i_notification_repository.dart';

class NotificationUseCase {
  final INotificationRepository iNotificationRepository;

  NotificationUseCase(this.iNotificationRepository);
}