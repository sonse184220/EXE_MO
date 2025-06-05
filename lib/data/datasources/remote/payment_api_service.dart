import 'package:dio/dio.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';

class PaymentApiService {
  final DioClient _client;

  PaymentApiService(this._client);

  Future<Response> createPayment(String subscriptionId){
    final dataObject ={
      "subscriptionId": subscriptionId
    };
    return _client.post('innerchild/payment/payment-create', data: dataObject);
  }

  Future<Response> getPaymentTransactionHistory() {
    return _client.get('innerchild/payment/all-own-transaction');
  }
}