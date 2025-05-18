class NotificationModel {
  final String notificationId;
  final String notificationUrl;
  final String notificationName;
  final String notificationDescription;
  final String userId;

  NotificationModel({
    required this.notificationId,
    required this.notificationUrl,
    required this.notificationName,
    required this.notificationDescription,
    required this.userId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'] as String,
      notificationUrl: json['notificationUrl'] as String,
      notificationName: json['notificationName'] as String,
      notificationDescription: json['notificationDescription'] as String,
      userId: json['userId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'notificationUrl': notificationUrl,
      'notificationName': notificationName,
      'notificationDescription': notificationDescription,
      'userId': userId,
    };
  }
}