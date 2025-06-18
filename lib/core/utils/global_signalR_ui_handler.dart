// Create a global SignalR message state
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';

// @freezed
// class SignalRMessage with _$SignalRMessage {
//   const factory SignalRMessage({
//     required String type,
//     required Map<String, dynamic> data,
//     required DateTime timestamp,
//   }) = _SignalRMessage;
// }

class SignalRMessage {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  SignalRMessage({
    required this.type,
    required this.data,
    required this.timestamp,
  });
}

// SignalR messages stream provider
final signalRMessagesProvider =
    StateNotifierProvider<SignalRMessagesNotifier, List<SignalRMessage>>((ref) {
      return SignalRMessagesNotifier();
    });

class SignalRMessagesNotifier extends StateNotifier<List<SignalRMessage>> {
  SignalRMessagesNotifier() : super([]);

  void addMessage(String type, Map<String, dynamic> data) {
    final message = SignalRMessage(
      type: type,
      data: data,
      timestamp: DateTime.now(),
    );

    state = [...state, message];

    // Keep only last 50 messages to prevent memory issues
    if (state.length > 50) {
      state = state.sublist(state.length - 50);
    }
  }

  void clearMessages() {
    state = [];
  }
}

// Global SignalR UI Handler
class GlobalSignalRUIHandler extends ConsumerWidget {
  final Widget child;

  const GlobalSignalRUIHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to SignalR messages
    ref.listen<List<SignalRMessage>>(signalRMessagesProvider, (
      previous,
      current,
    ) {
      if (current.isNotEmpty) {
        final latestMessage = current.last;
        _handleSignalRMessage(context, ref, latestMessage);
      }
    });

    return child;
  }

  void _handleSignalRMessage(
    BuildContext context,
    WidgetRef ref,
    SignalRMessage message,
  ) {
    switch (message.type) {
      case 'ReceiveMessage':
        _handleReceiveMessage(context, message.data);
        break;
      case 'UserOnline':
        _handleUserOnline(context, message.data);
        break;
      case 'UserOffline':
        _handleUserOffline(context, message.data);
        break;
      case 'NewNotification':
        _handleNewNotification(context, ref, message.data);
        break;
      case 'SystemMaintenance':
        _handleSystemMaintenance(context, message.data);
        break;
      case 'ForceLogout':
        _handleForceLogout(context, ref);
        break;
      // Add more message types as needed
      default:
        debugPrint('🔔 Unhandled SignalR message type: ${message.type}');
    }
  }

  void _handleReceiveMessage(BuildContext context, Map<String, dynamic> data) {
    // Handle chat messages
    final message = data['message'] as String?;
    final sender = data['sender'] as String?;

    if (message != null && sender != null) {
      // Show in-app notification for new messages
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New message from $sender: $message'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              // Navigate to chat screen
              // context.go('/chat');
            },
          ),
        ),
      );
    }
  }

  void _handleUserOnline(BuildContext context, Map<String, dynamic> data) {
    final userId = data['userId'] as String?;
    final username = data['username'] as String?;

    debugPrint('👤 User $username ($userId) is now online');

    // Update online users list or show toast
    // You can dispatch to other providers here
  }

  void _handleUserOffline(BuildContext context, Map<String, dynamic> data) {
    final userId = data['userId'] as String?;
    final username = data['username'] as String?;

    debugPrint('👤 User $username ($userId) went offline');
  }

  void _handleNewNotification(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> data,
  ) {
    final title = data['title'] as String?;
    final body = data['body'] as String?;
    final type = data['type'] as String?;

    // Show system notification or update notification badge
    if (title != null && body != null) {
      _showGlobalNotification(context, title, body, type);

      // Update notification count in your notification provider
      // ref.read(notificationProvider.notifier).incrementUnreadCount();
    }
  }

  void _handleSystemMaintenance(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final message = data['message'] as String?;
    final maintenanceTime = data['maintenanceTime'] as String?;

    // Show system maintenance dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('System Maintenance'),
            content: Text(message ?? 'System will undergo maintenance soon.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _handleForceLogout(BuildContext context, WidgetRef ref) {
    // Force logout user
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Session Ended'),
            content: const Text(
              'Your session has been terminated. Please log in again.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(authNotifierProvider.notifier).logout();
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showGlobalNotification(
    BuildContext context,
    String title,
    String body,
    String? type,
  ) {
    // Show overlay notification or use flutter_local_notifications
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(body),
          ],
        ),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Navigate based on notification type
            switch (type) {
              case 'chat':
                // context.go('/chat');
                break;
              case 'friend_request':
                // context.go('/friends');
                break;
              // Add more navigation cases
            }
          },
        ),
      ),
    );
  }
}
