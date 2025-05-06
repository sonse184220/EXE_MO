import 'package:inner_child_app/domain/entities/user_register_model.dart';

abstract class IAuthRepository {
  Future<void> register(UserRegisterModel user);
}