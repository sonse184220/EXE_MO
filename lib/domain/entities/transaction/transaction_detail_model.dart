import 'package:inner_child_app/domain/entities/transaction/transaction_detail_transactions_model.dart';

class TransactionDetailModel {
  final String? id;
  final int? orderCode;
  final int? amount;
  final int? amountPaid;
  final int? amountRemaining;
  final String? status;
  final DateTime? createdAt;
  final List<TransactionDetailTransactionsModel>? transactions;
  final DateTime? canceledAt;
  final String? cancellationReason;

  TransactionDetailModel({
    this.id,
    this.orderCode,
    this.amount,
    this.amountPaid,
    this.amountRemaining,
    this.status,
    this.createdAt,
    this.transactions,
    this.canceledAt,
    this.cancellationReason,
  });

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    return TransactionDetailModel(
      id: json['id'] as String?,
      orderCode: json['orderCode'] as int?,
      amount: json['amount'] as int?,
      amountPaid: json['amountPaid'] as int?,
      amountRemaining: json['amountRemaining'] as int?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      transactions: (json['transactions'] as List<dynamic>?)
          ?.map((e) => TransactionDetailTransactionsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      canceledAt: json['canceledAt'] != null
          ? DateTime.tryParse(json['canceledAt'])
          : null,
      cancellationReason: json['cancellationReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderCode': orderCode,
      'amount': amount,
      'amountPaid': amountPaid,
      'amountRemaining': amountRemaining,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'transactions': transactions?.map((e) => e.toJson()).toList(),
      'canceledAt': canceledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
    };
  }
}
