import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/transaction/transaction_admin_view_model.dart';
import 'package:inner_child_app/domain/entities/transaction/transaction_detail_model.dart';
import 'package:inner_child_app/domain/entities/transaction/transaction_model.dart';
import 'package:inner_child_app/domain/repositories/i_payment_repository.dart';

class PaymentUsecase {
  final IPaymentRepository _iPaymentRepository;

  PaymentUsecase(this._iPaymentRepository);

  Future<Result<String>> createPayment(String subscriptionId) {
    return _iPaymentRepository.createPayment(subscriptionId);
  }

  Future<Result<List<TransactionModel>>> getPaymentTransactionHistory() {
    return _iPaymentRepository.getPaymentTransactionHistory();
  }

  Future<Result<TransactionDetailModel>> getTransactionDetailForAdmin(String transactionId) {
    return _iPaymentRepository.getTransactionDetailForAdmin(transactionId);
  }

  Future<Result<List<TransactionAdminViewModel>>> getTransactionsForAdmin() {
    return _iPaymentRepository.getTransactionsForAdmin();
  }
}