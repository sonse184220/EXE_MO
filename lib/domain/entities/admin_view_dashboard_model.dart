class AdminViewDashboardModel {
  final String time;
  final int revenue;

  AdminViewDashboardModel({
    required this.time,
    required this.revenue,
  });

  // Factory constructor to create an instance from JSON
  factory AdminViewDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminViewDashboardModel(
      time: json['time'] as String,
      revenue: json['revenue'] as int,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'revenue': revenue,
    };
  }
}