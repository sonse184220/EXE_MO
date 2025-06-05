class SubscriptionModel  {
  final String? subscriptionId;
  final String? subscriptionType;
  final String? subscriptionDescription;
  final double? subscriptionPrice;
  final List<dynamic>? purchases;
  // final List<TransactionModel>? transactions;

  SubscriptionModel({
    this.subscriptionId,
    this.subscriptionType,
    this.subscriptionDescription,
    this.subscriptionPrice,
    this.purchases,
    // this.transactions,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      subscriptionId: json['subscriptionId'] as String?,
      subscriptionType: json['subscriptionType'] as String?,
      subscriptionDescription: json['subscriptionDescription'] as String?,
      subscriptionPrice: (json['subscriptionPrice'] != null)
          ? (json['subscriptionPrice'] as num).toDouble()
          : null,
      purchases: json['purchases'] as List<dynamic>?,
      // transactions: (json['transactions'] as List<dynamic>?)
      //     ?.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
      //     .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptionId': subscriptionId,
      'subscriptionType': subscriptionType,
      'subscriptionDescription': subscriptionDescription,
      'subscriptionPrice': subscriptionPrice,
      'purchases': purchases,
      // 'transactions': transactions?.map((e) => e.toJson()).toList(),
    };
  }
}