import 'package:inner_child_app/domain/entities/user_register_model.dart';
import 'package:inner_child_app/domain/repositories/i_auth_repository.dart';

import '../datasources/remote/authentication/authentication_api_service.dart';

class AuthRepository implements IAuthRepository {
  final AuthApiService apiService;

  AuthRepository(this.apiService);

  @override
  Future<void> register(UserRegisterModel user) async {
    // final data = {
    //   user
    // };
    await apiService.register(user);
  }
}