import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:inner_child_app/core/constants/app_constants.dart';
import 'package:inner_child_app/core/utils/auth_utils/auth_notifier.dart';
import 'package:inner_child_app/core/utils/auth_utils/auth_util_methods.dart';
import 'package:inner_child_app/core/utils/secure_storage_utils.dart';
import 'package:inner_child_app/domain/entities/auth/account_profile.dart';
import 'package:inner_child_app/domain/entities/auth/profile_edit_model.dart';
import 'package:inner_child_app/domain/entities/auth/token_model.dart';
import 'package:inner_child_app/domain/entities/auth/user_login_model.dart';
import 'package:inner_child_app/domain/entities/auth/user_register_model.dart';
import 'package:inner_child_app/domain/repositories/i_auth_repository.dart';

import '../../core/utils/result_model.dart';
import '../../domain/entities/auth/forgot_password_token_model.dart';
import '../datasources/remote/authentication_api_service.dart';

class AuthRepository implements IAuthRepository {
  final AuthApiService _apiService;
  final SecureStorageUtils _secureStorageUtils;
  final AuthNotifier _authNotifier;

  AuthRepository(
    this._apiService,
    this._secureStorageUtils,
    this._authNotifier,
  );

  @override
  Future<Result<String>> register(UserRegisterModel user) async {
    try {
      final response = await _apiService.register(user);
      final message = response.data['message'] ?? 'Registered successfully';
      return Result.success(message);
    } on DioException catch (e) {
      return Result.failure(
        e.response?.data['message'] ?? 'Registration failed',
      );
    } catch (e) {
      return Result.failure('Unexpected error: $e');
    }
  }

  @override
  Future<Result<String>> loginWithCredentials(UserLoginModel user) async {
    try {
      final response = await _apiService.loginWithCredentials(user);
      if (response.statusCode == 200) {
        final data = response.data;

        final profiles =
            (data as List<dynamic>)
                .map((e) => AccountProfile.fromJson(e))
                .toList();
        final profilesJson = jsonEncode(
          profiles.map((p) => p.toJson()).toList(),
        );
        String profilesKey = AppConstants.profiles;
        await _secureStorageUtils.write(profilesKey, profilesJson);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }

      return Result.success('Login Successfully');
    } on DioException catch (e) {
      final responseData = e.response?.data;

      final errorMessage =
          responseData is String
              ? responseData
              : (responseData is Map<String, dynamic> &&
                  responseData['message'] != null)
              ? responseData['message']
              : 'Login failed';

      return Result.failure(errorMessage);
    } catch (e) {
      return Result.failure('Unexpected error: $e');
    }
  }

  @override
  Future<Result<String>> loginWithGoogle(String firebaseToken) async {
    try {
      final response = await _apiService.loginWithGoogle(firebaseToken);
      // final message = response.data['message'] ?? 'Login successfully';
      // return Result.success(message);
      return Result.success('message for gg success');
    } on DioException catch (e) {
      final responseData = e.response?.data;

      final errorMessage =
          responseData is String
              ? responseData
              : (responseData is Map<String, dynamic> &&
                  responseData['message'] != null)
              ? responseData['message']
              : 'Login with google account failed. Please try again later!';

      return Result.failure(errorMessage);
    } catch (e) {
      return Result.failure('Unexpected error: $e');
    }
  }

  @override
  Future<Result<List<AccountProfile>>> getAvailableProfiles() async {
    try {
      String profilesKey = AppConstants.profiles;
      final String? jsonString = await _secureStorageUtils.read(profilesKey);

      if (jsonString == null || jsonString.isEmpty) {
        return Result.failure('No profiles found in secure storage.');
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<AccountProfile> profiles =
          jsonList
              .map(
                (json) => AccountProfile.fromJson(json as Map<String, dynamic>),
              )
              .toList();

      return Result.success(profiles);
    } catch (e) {
      return Result.failure('Unexpected error: $e');
    }
  }

  @override
  Future<Result<String>> loginWithProfile(String profileToken) async {
    try {
      final response = await _apiService.loginWithProfile(profileToken);

      if (response.statusCode == 200) {
        final data = response.data;
        final tokenModel = TokenModel.fromJson(data);
        final tokenModelToJson = jsonEncode(tokenModel.toJson());
        String tokenModelString = AppConstants.tokenModel;
        await _secureStorageUtils.write(tokenModelString, tokenModelToJson);

        return Result.success('Profile login success');
      } else {
        throw Exception('Login with profile failed: ${response.statusCode}');
      }
    } catch (e) {
      return Result.failure('Unexpected error: $e');
    }
  }

  @override
  Future<Result<String>> editProfile(ProfileEditModel profile) async {
    try {
      // final jsonString  = await _secureStorageUtils.read(AppConstants.profiles);
      //
      // if (jsonString  == null || jsonString .isEmpty) {
      //   return Result.failure('No profiles found in your login session.');
      // }

      // final List<dynamic> jsonList = jsonDecode(jsonString);
      // final List<AccountProfile> profiles = jsonList
      //     .map(
      //       (json) => AccountProfile.fromJson(json as Map<String, dynamic>),
      // )
      //     .toList();
      final response = await _apiService.editProfile(profile);
      return Result.success('okla update profile');
    } on DioException catch (e) {
      return Result.failure(e.response?.data['message'] ?? 'Update failed');
    } catch (e) {
      return Result.failure('Unexpected error: $e');
    }
  }

  @override
  Future<Result<String>> forgotPassword(String email) async {
    try {
      final response = await _apiService.forgotPassword(email);

      if (response.statusCode == 200) {
        final data = response.data;

        final payload = AuthUtilMethods.decodeJwtPayload(data);
        final int expiryUnix = payload['exp'];
        final expirationTime = DateTime.fromMillisecondsSinceEpoch(
          expiryUnix * 1000,
        );

        final tokenModel = ForgotPasswordTokenModel(
          token: data,
          expiry: expirationTime,
        );

        final tokenJson = jsonEncode(tokenModel.toJson());
        await _secureStorageUtils.write(
          AppConstants.forgotPasswordToken,
          tokenJson,
        );
        return Result.success(
          'Success: Please move to your password reset page for next step',
        );
      } else {
        throw Exception('An error occured: ${response.statusCode}');
      }
    } catch (e) {
      return Result.failure('An error occured: $e');
    }
  }

  @override
  Future<Result<String>> resetPassword(
    String password,
    String confirmPassword,
  ) async {
    try {
      // Read stored forgot password token model JSON
      final tokenJson = await _secureStorageUtils.read(
        AppConstants.forgotPasswordToken,
      );
      if (tokenJson == null || tokenJson.isEmpty) {
        return Result.failure(
          'No valid reset password request found. Please request a new password reset.',
        );
      }

      // Decode token model
      final tokenModel = ForgotPasswordTokenModel.fromJson(
        jsonDecode(tokenJson),
      );

      // Check token validity
      if (DateTime.now().isAfter(tokenModel.expiry)) {
        return Result.failure(
          'Reset password request expired. Please request a new password reset.',
        );
      }

      // Call reset password API with token and new passwords
      final response = await _apiService.resetPassword(
        tokenModel.token,
        password,
        confirmPassword,
      );

      if (response.statusCode == 200) {
        // Optionally, clear stored token after success
        await _secureStorageUtils.delete(AppConstants.forgotPasswordToken);
        return Result.success(
          'Password reset email has been sent successfully. Please check your email to confirm.',
        );
      } else {
        return Result.failure(
          'Failed to send email reset password. Please try again.',
        );
      }
    } catch (e) {
      return Result.failure('An error occurred: $e');
    }
  }

  @override
  Future<Result<bool>> logout() async {
    try {
      await _authNotifier.logout();
      return Result.success(true);
    } catch (e) {
      return Result.failure('An error occurred: $e');
    }
  }

  @override
  Future<Result<ProfileEditModel>> getPersonalDetail() async {
    try {
      final response = await _apiService.getPersonalDetail();

      if (response.statusCode == 200) {
        final data = response.data!;

        final userData = ProfileEditModel.fromJson(data);

        return Result.success(userData);
      }else{
        return Result.failure('Load profile data fail');
      }
    } catch (e) {
      return Result.failure('An error occurred: $e');
    }
  }

  @override
  Future<Result<String>> changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    try {
      final response = await _apiService.changePassword(currentPassword, newPassword, confirmPassword);

      if (response.statusCode == 200) {
        final data = response.data!;

        // final userData = ProfileEditModel.fromJson(data);

        return Result.success(data);
      }else{
        return Result.failure('Change password fail');
      }
    } catch (e) {
      return Result.failure('An error occurred: $e');
    }
  }
}
