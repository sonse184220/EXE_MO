import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/notification/notification_model.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  NotificationState createState() => NotificationState();
}

class NotificationState extends ConsumerState<NotificationPage> {
  List<NotificationModel> apiNotifications = [];
  bool isLoading = true;

  late final _notificationUseCase;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _notificationUseCase = ref.read(notificationUseCaseProvider);
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    // In a real app, you would replace this with your actual API endpoint
    // For now, we'll simulate an API call and use the provided JSON data
    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // This is where you would normally fetch from an API
      // final response = await http.get(Uri.parse('your-api-endpoint'));

      // Using the sample JSON you provided
      const String sampleJsonData = '''
      [
        {
          "notificationId": "N001",
          "notificationUrl": "notification/welcome",
          "notificationName": "Welcome Notification",
          "notificationDescription": "Welcome to our application",
          "userId": "U001",
          "user": null
        },
        {
          "notificationId": "N002",
          "notificationUrl": "notification/renewal",
          "notificationName": "Renewal Notification",
          "notificationDescription": "Your subscription will renew soon",
          "userId": "U002",
          "user": null
        },
        {
          "notificationId": "N003",
          "notificationUrl": "notification/feature",
          "notificationName": "Feature Notification",
          "notificationDescription": "We have added new features",
          "userId": "U003",
          "user": null
        }
      ]
      ''';

      final List<dynamic> jsonData = jsonDecode(sampleJsonData);

      setState(() {
        apiNotifications =
            jsonData.map((item) => NotificationModel.fromJson(item)).toList();
        isLoading = false;
      });
    } catch (e) {
      // setState(() {
      //   errorMessage = 'Failed to load notifications: $e';
      //   isLoading = false;
      // });
      Notify.showFlushbar(
        'Failed to load notifications: $e',
        isError: true,
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget notificationMap(NotificationModel noti) {
    return NotificationCard(
      icon: Icons.favorite,
      iconColor: Colors.orange,
      title: noti.notificationName,
      description:
      noti.notificationDescription,
      time: '14h',
      buttons: [
        NotificationButton(
          text: 'Try now',
          color: Colors.blue,
          textColor: Colors.white,
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                // child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.filter_list),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Notification List (Scrollable)
                    Expanded(
                      child:
                          isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : RefreshIndicator(
                                onRefresh: fetchNotifications,
                                child: ListView(
                                  children: [
                                    ...apiNotifications.map(notificationMap),
                                    // // First notification with buttons
                                    // NotificationCard(
                                    //   icon: Icons.favorite,
                                    //   iconColor: Colors.orange,
                                    //   title:
                                    //       'I have listed few things to help you improve your emotion',
                                    //   time: '2m',
                                    //   buttons: [
                                    //     NotificationButton(
                                    //       text: 'View Now',
                                    //       color: Colors.blue,
                                    //       textColor: Colors.white,
                                    //       onPressed: () {},
                                    //     ),
                                    //     NotificationButton(
                                    //       text: 'Ignore',
                                    //       color: Colors.transparent,
                                    //       textColor: Colors.black54,
                                    //       onPressed: () {},
                                    //     ),
                                    //   ],
                                    // ),
                                    //
                                    // // Second notification with buttons
                                    // NotificationCard(
                                    //   icon: Icons.favorite,
                                    //   iconColor: Colors.orange,
                                    //   title: 'Have you written mood journal',
                                    //   time: '2m',
                                    //   buttons: [
                                    //     NotificationButton(
                                    //       text: 'Do now',
                                    //       color: Colors.blue,
                                    //       textColor: Colors.white,
                                    //       onPressed: () {},
                                    //     ),
                                    //     NotificationButton(
                                    //       text: 'Ignore',
                                    //       color: Colors.transparent,
                                    //       textColor: Colors.black54,
                                    //       onPressed: () {},
                                    //     ),
                                    //   ],
                                    // ),
                                    //
                                    // // Comment notification with profile picture
                                    // CommentNotificationCard(
                                    //   profileImageUrl:
                                    //       'https://randomuser.me/api/portraits/men/32.jpg',
                                    //   name: 'Hùng',
                                    //   action: 'added a comment on',
                                    //   contentTitle: 'My daily file',
                                    //   time: '8h',
                                    //   comment:
                                    //       '"Nice, how do you control your emotion?"',
                                    // ),
                                    //
                                    // // Feature alert notification
                                    // NotificationCard(
                                    //   icon: Icons.favorite,
                                    //   iconColor: Colors.orange,
                                    //   title: 'New Feature Alert!',
                                    //   description:
                                    //       'We\'re pleased to introduce the latest enhancements in our app experience.',
                                    //   time: '14h',
                                    //   buttons: [
                                    //     NotificationButton(
                                    //       text: 'Try now',
                                    //       color: Colors.blue,
                                    //       textColor: Colors.white,
                                    //       onPressed: () {},
                                    //     ),
                                    //   ],
                                    // ),
                                    //
                                    // // File share notification with profile picture
                                    // FileShareNotificationCard(
                                    //   profileImageUrl:
                                    //       'https://randomuser.me/api/portraits/women/33.jpg',
                                    //   name: 'Vy',
                                    //   action: 'has shared a file with you',
                                    //   time: '14h',
                                    //   fileName: 'MoodTracker.pdf',
                                    //   fileSize: '2.2 MB',
                                    // ),
                                    //
                                    // NotificationCard(
                                    //   icon: Icons.favorite,
                                    //   iconColor: Colors.orange,
                                    //   title: 'New Feature Alert!',
                                    //   description:
                                    //       'We\'re pleased to introduce the latest enhancements in our app experience.',
                                    //   time: '14h',
                                    //   buttons: [
                                    //     NotificationButton(
                                    //       text: 'Try now',
                                    //       color: Colors.blue,
                                    //       textColor: Colors.white,
                                    //       onPressed: () {},
                                    //     ),
                                    //   ],
                                    // ),
                                    // NotificationCard(
                                    //   icon: Icons.favorite,
                                    //   iconColor: Colors.orange,
                                    //   title: 'New Feature Alert!',
                                    //   description:
                                    //       'We\'re pleased to introduce the latest enhancements in our app experience.',
                                    //   time: '14h',
                                    //   buttons: [
                                    //     NotificationButton(
                                    //       text: 'Try now',
                                    //       color: Colors.blue,
                                    //       textColor: Colors.white,
                                    //       onPressed: () {},
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Regular notification card with icon
class NotificationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? description;
  final String time;
  final List<Widget>? buttons;

  const NotificationCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.description,
    required this.time,
    this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
                if (buttons != null && buttons!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(children: buttons!),
                ],
              ],
            ),
          ),

          // Time and Options
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 4),
              Icon(Icons.more_horiz, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

// Button for notification actions
class NotificationButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const NotificationButton({
    super.key,
    required this.text,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Comment notification with profile picture
class CommentNotificationCard extends StatelessWidget {
  final String profileImageUrl;
  final String name;
  final String action;
  final String contentTitle;
  final String time;
  final String comment;

  const CommentNotificationCard({
    super.key,
    required this.profileImageUrl,
    required this.name,
    required this.action,
    required this.contentTitle,
    required this.time,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(profileImageUrl),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    children: [
                      TextSpan(
                        text: name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' $action '),
                      TextSpan(
                        text: contentTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    comment,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Time and Options
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 4),
              Icon(Icons.more_horiz, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

// File share notification with profile picture
class FileShareNotificationCard extends StatelessWidget {
  final String profileImageUrl;
  final String name;
  final String action;
  final String time;
  final String fileName;
  final String fileSize;

  const FileShareNotificationCard({
    super.key,
    required this.profileImageUrl,
    required this.name,
    required this.action,
    required this.time,
    required this.fileName,
    required this.fileSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(profileImageUrl),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    children: [
                      TextSpan(
                        text: name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' $action'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.insert_drive_file,
                        color: Colors.blue.shade300,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            fileSize,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Time and Options
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 4),
              Icon(Icons.more_horiz, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
