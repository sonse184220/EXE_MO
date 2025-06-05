import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/payment_api_service.dart';
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
}