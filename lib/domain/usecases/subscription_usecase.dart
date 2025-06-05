import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/subscription/subscription_model.dart';
import 'package:inner_child_app/domain/repositories/i_subscription_repository.dart';

class SubscriptionUsecase {
  final ISubscriptionRepository _iSubscriptionRepository;

  SubscriptionUsecase(this._iSubscriptionRepository);

  Future<Result<List<SubscriptionModel>>> getAllSubscriptions() {
    return _iSubscriptionRepository.getAllSubscriptions();
  }
}