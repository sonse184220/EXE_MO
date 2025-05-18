import 'package:inner_child_app/domain/entities/auth/account_profile.dart';
import 'package:inner_child_app/domain/entities/auth/profile_edit_model.dart';
import 'package:inner_child_app/domain/entities/auth/user_login_model.dart';
import '../../core/utils/result_model.dart';
import '../entities/auth/user_register_model.dart';

abstract class IAuthRepository {
  Future<Result<void>> register(UserRegisterModel user);
  Future<Result<void>> loginWithCredentials(UserLoginModel user);
  Future<Result<void>> loginWithGoogle(String firebaseToken);
  Future<Result<List<AccountProfile>>> getAvailableProfiles();
  Future<Result<String>> loginWithProfile(String profileToken);
  Future<Result<String>> editProfile(ProfileEditModel profile);
  Future<Result<String>> forgotPassword(String email);
  Future<Result<String>> resetPassword(String password, String confirmPassword);
  Future<Result<bool>> logout();
}