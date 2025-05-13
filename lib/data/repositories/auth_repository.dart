import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:inner_child_app/core/constants/app_constants.dart';
import 'package:inner_child_app/core/utils/secure_storage_utils.dart';
import 'package:inner_child_app/domain/entities/auth/account_profile.dart';
import 'package:inner_child_app/domain/entities/auth/profile_edit_model.dart';
import 'package:inner_child_app/domain/entities/auth/token_model.dart';
import 'package:inner_child_app/domain/entities/auth/user_login_model.dart';
import 'package:inner_child_app/domain/entities/auth/user_register_model.dart';
import 'package:inner_child_app/domain/repositories/i_auth_repository.dart';

import '../../core/utils/result_model.dart';
import '../datasources/remote/authentication_api_service.dart';

class AuthRepository implements IAuthRepository {
  final AuthApiService apiService;
  final SecureStorageUtils _secureStorageUtils;

  AuthRepository(this.apiService, this._secureStorageUtils);

  @override
  Future<Result<String>> register(UserRegisterModel user) async {
    try {
      final response = await apiService.register(user);
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
      final response = await apiService.loginWithCredentials(user);
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
      final response = await apiService.loginWithGoogle(firebaseToken);
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
      final response = await apiService.loginWithProfile(profileToken);

      if (response.statusCode == 200) {
        final data = response.data;
        final tokenModel =  TokenModel.fromJson(data);
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
      final jsonString  = await _secureStorageUtils.read(AppConstants.profiles);

      if (jsonString  == null || jsonString .isEmpty) {
        return Result.failure('No profiles found in your login session.');
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<AccountProfile> profiles = jsonList
          .map(
            (json) => AccountProfile.fromJson(json as Map<String, dynamic>),
      )
          .toList();

      if (profiles.isNotEmpty) {
        final firstProfile = profiles[0];
        final userId = firstProfile.userId;

        final response = await apiService.editProfile(userId, profile);
        return Result.success('okla update profile');
      } else {
        return Result.failure('No profiles available.');
      }

    } on DioException catch (e) {
      return Result.failure(
        e.response?.data['message'] ?? 'Update failed',
      );
    } catch (e) {
      return Result.failure('Unexpected error: $e');
    }
  }
}
