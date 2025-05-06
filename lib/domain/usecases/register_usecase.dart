import 'package:inner_child_app/domain/entities/user_register_model.dart';
import 'package:inner_child_app/domain/repositories/i_auth_repository.dart';

class RegisterUseCase {
  final IAuthRepository repository;

  RegisterUseCase(this.repository);

  Future<void> call(UserRegisterModel user) {
    return repository.register(user);
  }
}