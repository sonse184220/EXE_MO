import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/subscription/subscription_model.dart';

abstract class ISubscriptionRepository {
  Future<Result<List<SubscriptionModel>>> getAllSubscriptions();
}