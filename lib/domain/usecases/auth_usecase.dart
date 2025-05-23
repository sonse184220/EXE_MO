import 'package:inner_child_app/domain/entities/auth/account_profile.dart';
import 'package:inner_child_app/domain/entities/auth/profile_edit_model.dart';
import 'package:inner_child_app/domain/entities/auth/user_login_model.dart';
import 'package:inner_child_app/domain/entities/auth/user_register_model.dart';
import 'package:inner_child_app/domain/repositories/i_auth_repository.dart';

import '../../core/utils/result_model.dart';

class AuthUsecase {
  final IAuthRepository repository;

  AuthUsecase(this.repository);

  Future<Result<void>> register(UserRegisterModel user) {
    return repository.register(user);
  }

  Future<Result<void>> loginWithCredentials(UserLoginModel user) {
    return repository.loginWithCredentials(user);
  }

  Future<Result<void>> loginWithGoogle(String firebaseToken) {
    return repository.loginWithGoogle(firebaseToken);
  }

  Future<Result<List<AccountProfile>>> getAvailableProfiles() {
    return repository.getAvailableProfiles();
  }

  Future<Result<String>> loginWithProfile(String profileToken) {
    return repository.loginWithProfile(profileToken);
  }

  Future<Result<String>> editProfile(ProfileEditModel profile) {
    return repository.editProfile(profile);
  }

  Future<Result<String>> forgotPassword(String email) {
    return repository.forgotPassword(email);
  }

  Future<Result<String>> resetPassword(
    String password,
    String confirmPassword,
  ) {
    return repository.resetPassword(password, confirmPassword);
  }

  Future<Result<bool>> logout(
      ) {
    return repository.logout();
  }

  Future<Result<ProfileEditModel>> getPersonalDetail(){
    return repository.getPersonalDetail();
  }

  Future<Result<String>> changePassword(String currentPassword, String newPassword, String confirmPassword){
    return repository.changePassword(currentPassword, newPassword, confirmPassword);
  }
}
