class TransactionAdminViewModel {
  final String? transactionId;
  final String? transactionPaymentGateway;
  final int? transactionAmount;
  final String? transactionCurrency;
  final String? transactionStatus;
  final String? transactionPaymentStatus;
  final String? transactionCode;
  final DateTime? transactionCreatedAt;
  final String? subscriptionType;
  final String? subscriptionDescription;
  final String? subscriptionId;
  final String? userId;
  final String? userName;

  TransactionAdminViewModel({
    this.transactionId,
    this.transactionPaymentGateway,
    this.transactionAmount,
    this.transactionCurrency,
    this.transactionStatus,
    this.transactionPaymentStatus,
    this.transactionCode,
    this.transactionCreatedAt,
    this.subscriptionType,
    this.subscriptionDescription,
    this.subscriptionId,
    this.userId,
    this.userName,
  });

  factory TransactionAdminViewModel.fromJson(Map<String, dynamic> json) {
    return TransactionAdminViewModel(
      transactionId: json['transactionId'] as String?,
      transactionPaymentGateway: json['transactionPaymentGateway'] as String?,
      transactionAmount: json['transactionAmount'] as int?,
      transactionCurrency: json['transactionCurrency'] as String?,
      transactionStatus: json['transactionStatus'] as String?,
      transactionPaymentStatus: json['transactionPaymentStatus'] as String?,
      transactionCode: json['transactionCode'] as String?,
      transactionCreatedAt: json['transactionCreatedAt'] != null
          ? DateTime.tryParse(json['transactionCreatedAt'])
          : null,
      subscriptionType: json['subscriptionType'] as String?,
      subscriptionDescription: json['subscriptionDescription'] as String?,
      subscriptionId: json['subscriptionId'] as String?,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'transactionPaymentGateway': transactionPaymentGateway,
      'transactionAmount': transactionAmount,
      'transactionCurrency': transactionCurrency,
      'transactionStatus': transactionStatus,
      'transactionPaymentStatus': transactionPaymentStatus,
      'transactionCode': transactionCode,
      'transactionCreatedAt': transactionCreatedAt?.toIso8601String(),
      'subscriptionType': subscriptionType,
      'subscriptionDescription': subscriptionDescription,
      'subscriptionId': subscriptionId,
      'userId': userId,
      'userName': userName,
    };
  }
}
