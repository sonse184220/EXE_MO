import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/notification/notification_model.dart';
import 'package:inner_child_app/domain/usecases/notification_usecase.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  NotificationState createState() => NotificationState();
}

class NotificationState extends ConsumerState<NotificationPage>
    with TickerProviderStateMixin {
  List<NotificationModel> apiNotifications = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  late final NotificationUseCase _notificationUseCase;

  static const Color raspberry = Color(0xFFE37083);
  static const Color papaya = Color(0xFFFFB876);
  static const Color iceCream = Color(0xFFF49AA2);
  static const Color meadow = Color(0xFFA8BF8A);
  static const Color sunshine = Color(0xFFFFCB7C);
  static const Color springSky = Color(0xFF89B7C2);

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // @override
  // void initState() {
  //   super.initState();
  //   _notificationUseCase = ref.read(notificationUseCaseProvider);
  //   fetchNotifications();
  // }

  @override
  void initState() {
    super.initState();
    _notificationUseCase = ref.read(notificationUseCaseProvider);

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    fetchNotifications();
  }

  // Add dispose method
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    try {
      final result = await _notificationUseCase.getAllNotifications();

      if (result.isSuccess) {
        setState(() {
          apiNotifications = result.data ?? [];
          isLoading = false;
          hasError = false;
        });

        _fadeController.forward();
        _slideController.forward();
      } else {
        // Handle API failure case
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = result.error ?? 'Failed to load notifications';
          apiNotifications = [];
        });

        Notify.showFlushbar(
          result.error ?? 'Failed to load notifications',
          isError: true,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Network error: Unable to load notifications';
        apiNotifications = [];
      });

      Notify.showFlushbar(
        'Network error: Unable to load notifications',
        isError: true,
      );
    }
  }

  // Widget _buildErrorWidget() {
  //   return Center(
  //     child: Padding(
  //       padding: const EdgeInsets.all(20.0),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             Icons.error_outline,
  //             size: 64,
  //             color: Colors.grey.shade400,
  //           ),
  //           const SizedBox(height: 16),
  //           Text(
  //             'Oops! Something went wrong',
  //             style: TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.w600,
  //               color: Colors.grey.shade600,
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             errorMessage,
  //             style: TextStyle(
  //               fontSize: 14,
  //               color: Colors.grey.shade500,
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //           const SizedBox(height: 24),
  //           ElevatedButton.icon(
  //             onPressed: fetchNotifications,
  //             icon: const Icon(Icons.refresh),
  //             label: const Text('Try Again'),
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.blue,
  //               foregroundColor: Colors.white,
  //               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _buildEmptyWidget() {
  //   return Center(
  //     child: Padding(
  //       padding: const EdgeInsets.all(20.0),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             Icons.notifications_none,
  //             size: 64,
  //             color: Colors.grey.shade400,
  //           ),
  //           const SizedBox(height: 16),
  //           Text(
  //             'No notifications yet',
  //             style: TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.w600,
  //               color: Colors.grey.shade600,
  //             ),
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             'We\'ll notify you when something new arrives',
  //             style: TextStyle(
  //               fontSize: 14,
  //               color: Colors.grey.shade500,
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _buildLoadingWidget() {
  //   return const Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         CircularProgressIndicator(),
  //         SizedBox(height: 16),
  //         Text(
  //           'Loading notifications...',
  //           style: TextStyle(
  //             fontSize: 16,
  //             color: Colors.grey,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget _buildNotificationsList() {
  //   if (apiNotifications.isEmpty) {
  //     return _buildEmptyWidget();
  //   }
  //
  //   return RefreshIndicator(
  //     onRefresh: fetchNotifications,
  //     child: ListView.builder(
  //       physics: const AlwaysScrollableScrollPhysics(),
  //       itemCount: apiNotifications.length,
  //       itemBuilder: (context, index) {
  //         return notificationMap(apiNotifications[index]);
  //       },
  //     ),
  //   );
  // }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: raspberry.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(Icons.error_outline, size: 48, color: raspberry),
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: fetchNotifications,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: springSky,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Update your _buildEmptyWidget method
  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: meadow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(Icons.notifications_none, size: 48, color: meadow),
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ll notify you when something new arrives',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Update your _buildLoadingWidget method
  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(springSky),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading notifications...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Update your _buildNotificationsList method
  Widget _buildNotificationsList() {
    if (apiNotifications.isEmpty) {
      return _buildEmptyWidget();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          onRefresh: fetchNotifications,
          color: springSky,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: apiNotifications.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _slideController,
                builder: (context, child) {
                  final delay = index * 0.1;
                  final animationValue = Curves.easeOutCubic.transform(
                    (_slideController.value - delay).clamp(0.0, 1.0),
                  );

                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - animationValue)),
                    child:notificationMap(apiNotifications[index], index),
                    // Opacity(
                    //   opacity: animationValue,
                    //   child:
                    // ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Widget notificationMap(NotificationModel noti) {
  //   return NotificationCard(
  //     icon: Icons.favorite,
  //     iconColor: Colors.orange,
  //     title: noti.notificationName,
  //     description: noti.notificationDescription,
  //     time: '14h',
  //     // buttons: [
  //     //   NotificationButton(
  //     //     text: 'Try now',
  //     //     color: Colors.blue,
  //     //     textColor: Colors.white,
  //     //     onPressed: () {},
  //     //   ),
  //     // ],
  //   );
  // }

  Widget notificationMap(NotificationModel noti, int index) {
    // Calculate time difference
    // String timeAgo = _calculateTimeAgo(noti.createdAt); // Assuming createdAt exists

    // Get color based on index
    Color iconColor = _getNotificationColor(index);

    return NotificationCard(
      icon: _getNotificationIcon('message'), // Assuming type exists
      iconColor: iconColor,
      title: noti.notificationName,
      description: noti.notificationDescription,
      // time: timeAgo,
    );
  }

  String _calculateTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Now';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Now';
    }
  }

  Color _getNotificationColor(int index) {
    final colors = [springSky, meadow, sunshine, papaya, iceCream, raspberry];
    return colors[index % colors.length];
  }

  IconData _getNotificationIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'message':
        return Icons.message;
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'share':
        return Icons.share;
      case 'follow':
        return Icons.person_add;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        if (!isLoading &&
                            !hasError &&
                            apiNotifications.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: springSky.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${apiNotifications.length}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: springSky,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Content Area
                    Expanded(
                      child:
                          isLoading
                              ? _buildLoadingWidget()
                              : hasError
                              ? _buildErrorWidget()
                              : _buildNotificationsList(),
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

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: SafeArea(
  //       child: LayoutBuilder(
  //         builder: (context, constraints) {
  //           return ConstrainedBox(
  //             constraints: BoxConstraints(minHeight: constraints.maxHeight),
  //             child: Container(
  //               width: double.infinity,
  //               height: double.infinity,
  //               padding: const EdgeInsets.all(20),
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(16),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black12,
  //                     blurRadius: 10,
  //                     offset: Offset(0, 5),
  //                   ),
  //                 ],
  //               ),
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   // Header
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       const Text(
  //                         'Notifications',
  //                         style: TextStyle(
  //                           fontSize: 24,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                       Row(
  //                         children: [
  //                           // IconButton(
  //                           //   icon: const Icon(Icons.filter_list),
  //                           //   onPressed: () {},
  //                           // ),
  //                           // IconButton(
  //                           //   icon: const Icon(Icons.more_vert),
  //                           //   onPressed: () {},
  //                           // ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                   // Content Area
  //                   Expanded(
  //                     child: isLoading
  //                         ? _buildLoadingWidget()
  //                         : hasError
  //                         ? _buildErrorWidget()
  //                         : _buildNotificationsList(),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }
}

// Regular notification card with icon
// class NotificationCard extends StatelessWidget {
//   final IconData icon;
//   final Color iconColor;
//   final String title;
//   final String? description;
//   final String time;
//   final List<Widget>? buttons;
//
//   const NotificationCard({
//     super.key,
//     required this.icon,
//     required this.iconColor,
//     required this.title,
//     this.description,
//     required this.time,
//     this.buttons,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Icon
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: iconColor.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: iconColor, size: 24),
//           ),
//           const SizedBox(width: 12),
//           // Content
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 if (description != null) ...[
//                   const SizedBox(height: 4),
//                   Text(
//                     description!,
//                     style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
//                   ),
//                 ],
//                 if (buttons != null && buttons!.isNotEmpty) ...[
//                   const SizedBox(height: 8),
//                   Row(children: buttons!),
//                 ],
//               ],
//             ),
//           ),
//           // Time and Options
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 time,
//                 style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
//               ),
//               const SizedBox(height: 4),
//               Icon(Icons.more_horiz, color: Colors.grey.shade400, size: 20),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

class NotificationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? description;

  // final String time;
  final List<Widget>? buttons;

  const NotificationCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.description,
    // required this.time,
    this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
                if (buttons != null && buttons!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(children: buttons!),
                ],
              ],
            ),
          ),
          // Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Text(
              //   time,
              //   style: TextStyle(
              //     fontSize: 12,
              //     color: Colors.grey.shade500,
              //     fontWeight: FontWeight.w500,
              //   ),
              // ),
              const SizedBox(height: 8),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
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
