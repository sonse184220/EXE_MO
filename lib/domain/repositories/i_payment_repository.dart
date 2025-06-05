import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/transaction/transaction_model.dart';

abstract class IPaymentRepository {
  Future<Result<String>> createPayment(String subscriptionId);
  Future<Result<List<TransactionModel>>> getPaymentTransactionHistory();
}