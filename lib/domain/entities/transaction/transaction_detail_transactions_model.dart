class TransactionDetailTransactionsModel {
  final String? reference;
  final int? amount;
  final String? accountNumber;
  final String? description;
  final DateTime? transactionDateTime;
  final String? virtualAccountName;
  final String? virtualAccountNumber;
  final String? counterAccountBankId;
  final String? counterAccountBankName;
  final String? counterAccountName;
  final String? counterAccountNumber;

  TransactionDetailTransactionsModel({
    this.reference,
    this.amount,
    this.accountNumber,
    this.description,
    this.transactionDateTime,
    this.virtualAccountName,
    this.virtualAccountNumber,
    this.counterAccountBankId,
    this.counterAccountBankName,
    this.counterAccountName,
    this.counterAccountNumber,
  });

  factory TransactionDetailTransactionsModel.fromJson(Map<String, dynamic> json) {
    return TransactionDetailTransactionsModel(
      reference: json['reference'] as String?,
      amount: json['amount'] as int?,
      accountNumber: json['accountNumber'] as String?,
      description: json['description'] as String?,
      transactionDateTime: json['transactionDateTime'] != null
          ? DateTime.tryParse(json['transactionDateTime'])
          : null,
      virtualAccountName: json['virtualAccountName'] as String?,
      virtualAccountNumber: json['virtualAccountNumber'] as String?,
      counterAccountBankId: json['counterAccountBankId'] as String?,
      counterAccountBankName: json['counterAccountBankName'] as String?,
      counterAccountName: json['counterAccountName'] as String?,
      counterAccountNumber: json['counterAccountNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'amount': amount,
      'accountNumber': accountNumber,
      'description': description,
      'transactionDateTime': transactionDateTime?.toIso8601String(),
      'virtualAccountName': virtualAccountName,
      'virtualAccountNumber': virtualAccountNumber,
      'counterAccountBankId': counterAccountBankId,
      'counterAccountBankName': counterAccountBankName,
      'counterAccountName': counterAccountName,
      'counterAccountNumber': counterAccountNumber,
    };
  }
}
