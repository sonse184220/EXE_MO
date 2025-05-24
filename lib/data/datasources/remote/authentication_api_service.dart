import 'package:dio/dio.dart';
import 'package:inner_child_app/domain/entities/auth/profile_edit_model.dart';
import 'package:inner_child_app/domain/entities/auth/user_login_model.dart';
import 'package:inner_child_app/domain/entities/auth/user_register_model.dart';

import '../../../core/utils/dio_instance.dart';

class AuthApiService {
  final DioClient _client;

  AuthApiService(this._client);

  Future<Response> register(UserRegisterModel user) async {
    final formData = FormData.fromMap({
      'Email': user.emailAddress,
      'Password': user.password,
      'ConfirmPassword': user.confirmPassword,
      'FullName': user.fullName,
      'DateOfBirth': user.dateOfBirth.toIso8601String(), // or format as needed
      'gender': user.gender,
      'PhoneNumber': user.phoneNumber,
    });

    return await _client.post('innerchild/auth/register', data: formData);
  }

  Future<Response> loginWithCredentials(UserLoginModel user) async {
    var userCredentialsJson = user.toJson();
    return await _client.post(
      'innerchild/auth/check-login',
      data: userCredentialsJson,
    );
  }

  Future<Response> loginWithGoogle(String firebaseToken) async {
    var tokenObject = {"firebaseToken": firebaseToken};

    return await _client.post(
      'innerchild/auth/check-login-firebase',
      data: tokenObject,
    );
  }

  Future<Response> loginWithProfile(String profileToken) async {
    var tokenObject = {"token": profileToken};

    return await _client.post('innerchild/auth/login', data: tokenObject);
  }

  Future<Response> editProfile(ProfileEditModel profile) async {
    final formData = FormData.fromMap({
      'FullName': profile.fullName,
      'DateOfBirth': profile.dateOfBirth?.toIso8601String(),
      // or format as needed
      'Gender': profile.gender,
      'PhoneNumber': profile.phoneNumber,
      'ProfilePicture': profile.profileImage,
    });

    return await _client.put(
      'innerchild/auth/update-user',
      data: formData,
    );
  }

  Future<Response> forgotPassword(String email) async {
    final emailObject = {"email": email};
    return await _client.post(
      'innerchild/auth/forgot-password',
      data: emailObject,
    );
  }

  Future<Response> resetPassword(
    String token,
    String password,
    String confirmPassword,
  ) async {
    final resetPasswordObject = {
      "token": token,
      "newPassword": password,
      "confirmNewPassword": confirmPassword,
    };
    return await _client.post(
      'innerchild/auth/reset-password',
      data: resetPasswordObject,
    );
  }

  Future<Response> getPersonalDetail() async {
    return await _client.get('innerchild/auth/personal-detail');
  }

  Future<Response> changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    final dataObject = {
      "currentPassword": currentPassword,
      "newPassword": newPassword,
      "confirmPassword": newPassword
    };
    return await _client.post('innerchild/auth/change-password', data: dataObject);
  }
}
