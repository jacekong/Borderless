class NotificationData {
  final String notification;
  final String receiver;
  final String timestamp;

  NotificationData({
    required this.notification,
    required this.receiver,
    required this.timestamp,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      notification: json['notification'],
      receiver: json['receiver'],
      timestamp: json['timestamp'],
    );
  }
}