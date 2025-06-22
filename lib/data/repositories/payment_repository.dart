import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/payment_api_service.dart';
import 'package:inner_child_app/domain/entities/transaction/transaction_admin_view_model.dart';
import 'package:inner_child_app/domain/entities/transaction/transaction_detail_model.dart';
import 'package:inner_child_app/domain/entities/transaction/transaction_model.dart';
import 'package:inner_child_app/domain/repositories/i_payment_repository.dart';

class PaymentRepository implements IPaymentRepository {
  final PaymentApiService _paymentApiService;

  PaymentRepository(this._paymentApiService);

  @override
  Future<Result<String>> createPayment(String subscriptionId) async {
    try {
      final response = await _paymentApiService.createPayment(subscriptionId);

      if (response.statusCode == 200) {
        final data = response.data;

        // final subscriptions =
        // (data as List<dynamic>)
        //     .map((e) => SubscriptionModel.fromJson(e))
        //     .toList();
        return Result.success(data);
      }
      return Result.failure('Fail to process payment. Please try again');
    } catch (e) {
      return Result.failure('Processing payment error: $e');
    }
  }

  @override
  Future<Result<List<TransactionModel>>> getPaymentTransactionHistory() async {
    try {
      final response = await _paymentApiService.getPaymentTransactionHistory();

      if (response.statusCode == 200) {
        final data = response.data;

        final paymentTransactions =
        (data as List<dynamic>)
            .map((e) => TransactionModel.fromJson(e))
            .toList();
        return Result.success(paymentTransactions);
      }
      return Result.failure('Fail to get payment transaction list. Please try again');
    } catch (e) {
      return Result.failure('Get payment transaction list error: $e');
    }
  }

  @override
  Future<Result<TransactionDetailModel>> getTransactionDetailForAdmin(String transactionId) async {
    try {
      final response = await _paymentApiService.getTransactionDetailForAdmin(transactionId);

      if (response.statusCode == 200) {
        final data = response.data;

        final paymentTransaction =
       TransactionDetailModel.fromJson(data);
        return Result.success(paymentTransaction);
      }
      return Result.failure('Fail to get payment transaction detail for admin. Please try again');
    } catch (e) {
      return Result.failure('Get payment transaction detail for admin error');
    }
  }

  @override
  Future<Result<List<TransactionAdminViewModel>>> getTransactionsForAdmin() async {
    try {
      final response = await _paymentApiService.getTransactionsForAdmin();

      if (response.statusCode == 200) {
        final data = response.data;

        final paymentTransactions =
        (data as List<dynamic>)
            .map((e) => TransactionAdminViewModel.fromJson(e))
            .toList();
        return Result.success(paymentTransactions);
      }
      return Result.failure('Fail to get payment transaction list for admin. Please try again');
    } catch (e) {
      return Result.failure('Get payment transaction list for admin error: $e');
    }
  }
}