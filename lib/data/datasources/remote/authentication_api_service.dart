import 'package:dio/dio.dart';
import 'package:inner_child_app/domain/entities/auth/profile_edit_model.dart';
import 'package:inner_child_app/domain/entities/auth/user_login_model.dart';
import 'package:inner_child_app/domain/entities/auth/user_register_model.dart';

import '../../../core/utils/dio_instance.dart';

class AuthApiService {
  final DioClient _client;

  AuthApiService(this._client);

  Future<Response> register(UserRegisterModel user) {
    final formData = FormData.fromMap({
      'Email': user.emailAddress,
      'Password': user.password,
      'ConfirmPassword': user.confirmPassword,
      'FullName': user.fullName,
      'DateOfBirth': user.dateOfBirth.toIso8601String(), // or format as needed
      'gender': user.gender,
      'PhoneNumber': user.phoneNumber,
    });

    return _client.post('innerchild/auth/register', data: formData);
  }

  Future<Response> loginWithCredentials(UserLoginModel user){
    var userCredentialsJson = user.toJson();
    return _client.post('innerchild/auth/check-login', data: userCredentialsJson);
  }

  Future<Response> loginWithGoogle(String firebaseToken){
    var tokenObject =
      {
        "firebaseToken": firebaseToken
      };

    return _client.post('innerchild/auth/check-login-firebase', data: tokenObject);
  }

  Future<Response> loginWithProfile(String profileToken){
    var tokenObject =
    {
      "token": profileToken
    };

    return _client.post('innerchild/auth/login', data: tokenObject);
  }

  Future<Response> editProfile(String userId, ProfileEditModel profile) {
    final formData = FormData.fromMap({
      'FullName': profile.fullName,
      'DateOfBirth': profile.dateOfBirth?.toIso8601String(), // or format as needed
      'Gender': profile.gender,
      'PhoneNumber': profile.phoneNumber,
      'ProfilePicture': profile.profileImage
    });
    
    return _client.put('/innerchild/auth/update-profile/$userId', data: formData);
  }
}