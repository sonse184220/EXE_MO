import 'dart:convert';

import '../../../domain/entities/auth/forgot_password_token_model.dart';
import '../../constants/app_constants.dart';
import '../secure_storage_utils.dart';

class AuthUtilMethods {
  static Map<String, dynamic> decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT format');
    }

    final payloadBase64 = base64Url.normalize(parts[1]);
    final payloadString = utf8.decode(base64Url.decode(payloadBase64));
    final payloadMap = json.decode(payloadString);

    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('Invalid JWT payload');
    }

    return payloadMap;
  }

  static Future<bool> isForgotPasswordTokenValid(SecureStorageUtils secureStorage) async {
    final tokenJson = await secureStorage.read(AppConstants.forgotPasswordToken);
    if (tokenJson == null || tokenJson.isEmpty) return false;

    try {
      final model = ForgotPasswordTokenModel.fromJson(jsonDecode(tokenJson));
      return DateTime.now().isBefore(model.expiry);
    } catch (e) {
      return false; // If parsing fails or date is invalid
    }
  }
}