import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/constants/app_constants.dart';
import 'package:inner_child_app/core/utils/auth_utils/auth_util_methods.dart';
import 'package:inner_child_app/core/utils/secure_storage_utils.dart';
import 'package:inner_child_app/domain/entities/auth/auth_state.dart';
import 'package:inner_child_app/domain/entities/auth/auth_status_enum.dart';
import 'package:inner_child_app/domain/entities/auth/from_token_user_info.dart';
import 'package:inner_child_app/domain/entities/auth/token_model.dart';

/// Auth notifier for authentication state management
class AuthNotifier extends StateNotifier<AuthState> {
  final SecureStorageUtils _storage;
  final tokenModel = AppConstants.tokenModel;

  AuthNotifier(this._storage)
    : super(const AuthState(status: AuthStatus.loading)) {
    _initialize();
  }

  /// Initialize auth state by checking for stored token
  // Future<void> _initialize() async {
  //   final token = await _storage.read(tokenModel);
  //   state = token != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  // }

  Future<void> _initialize() async {
    try {
      final tokenModelJson = await _storage.read(tokenModel);

      // Check if token data exists
      if (tokenModelJson == null) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      TokenModel tokenModelObject;

      // If stored as JSON string, parse it
      final Map<String, dynamic> jsonMap = json.decode(tokenModelJson);
      tokenModelObject = TokenModel.fromJson(jsonMap);
      print(tokenModelObject.accessToken);

      final userInfo = _extractUserInfoFromToken(tokenModelObject.accessToken);

      // Check if token is expired
      if (userInfo != null && !userInfo.isExpired) {
        state = AuthState(
          status: AuthStatus.authenticated,
          userInfo: userInfo,
          token: tokenModelObject.accessToken,
        );
      } else {
        // Token is expired, remove it
        await _storage.delete(tokenModel);
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      debugPrint('Error initializing auth state: $e');
      // Clean up invalid token data
      await _storage.delete(tokenModel);
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  FromTokenUserInfo? _extractUserInfoFromToken(String token) {
    try {
      // Use the utility method for JWT decoding
      final payloadMap = AuthUtilMethods.decodeJwtPayload(token);

      print(token);

      // Create UserInfo from payload
      return FromTokenUserInfo.fromJwtPayload(payloadMap);
    } catch (e) {
      debugPrint('Error extracting user info from token: $e');
      return null;
    }
    // try {
    //   // Split the token into parts
    //   final parts = token.split('.');
    //   if (parts.length != 3) return null;
    //
    //   // Decode the payload (second part)
    //   final payload = parts[1];
    //
    //   // Add padding if necessary
    //   final normalizedPayload = base64Url.normalize(payload);
    //   final decoded = utf8.decode(base64Url.decode(normalizedPayload));
    //
    //   // Parse JSON
    //   final Map<String, dynamic> payloadMap = json.decode(decoded);
    //
    //   // Create UserInfo from payload
    //   return FromTokenUserInfo.fromJwtPayload(payloadMap);
    // } catch (e) {
    //   debugPrint('Error extracting user info from token: $e');
    //   return null;
    // }
  }

  /// Login user and update auth state
  Future<void> login(TokenModel tokenModel) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);

      final userInfo = _extractUserInfoFromToken(tokenModel.accessToken);

      if (userInfo == null) {
        throw Exception('Invalid token format');
      }

      if (userInfo.isExpired) {
        throw Exception('Token is expired');
      }

      final tokenModelToJson = jsonEncode(tokenModel.toJson());
      String tokenModelString = AppConstants.tokenModel;

      await _storage.write(tokenModelString, tokenModelToJson);

      state = AuthState(
        status: AuthStatus.authenticated,
        userInfo: userInfo,
        token: tokenModel.accessToken,
      );
    } catch (e) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      rethrow;
    }
  }

  // Future<void> login(String token) async {
  //   try {
  //     state = AuthStatus.loading;
  //     await _storage.write(tokenModel, token);
  //     state = AuthStatus.authenticated;
  //   } catch (e) {
  //     state = AuthStatus.unauthenticated;
  //     rethrow;
  //   }
  // }

  /// Logout user and update auth state
  Future<void> logout() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _storage.delete(tokenModel);
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      // Revert to previous authenticated state if logout fails
      state = state.copyWith(status: AuthStatus.authenticated);
      rethrow;
    }
  }

  // Future<void> logout() async {
  //   try {
  //     state = AuthStatus.loading;
  //     await _storage.delete(tokenModel);
  //     state = AuthStatus.unauthenticated;
  //   } catch (e) {
  //     // Revert to previous authenticated state if logout fails
  //     state = AuthStatus.authenticated;
  //     rethrow;
  //   }
  // }

  /// Verify if token is still valid
  Future<void> checkAuthStatus() async {
    try {
      final tokenModelJson = await _storage.read(tokenModel);

      if (tokenModelJson == null) {
        if (state.status != AuthStatus.unauthenticated) {
          state = const AuthState(status: AuthStatus.unauthenticated);
        }
        return;
      }

      // Parse stored token data
      TokenModel tokenModelObject;

      final Map<String, dynamic> jsonMap = json.decode(tokenModelJson);
      tokenModelObject = TokenModel.fromJson(jsonMap);

      final userInfo = _extractUserInfoFromToken(tokenModelObject.accessToken);

      if (userInfo != null && !userInfo.isExpired) {
        final newState = AuthState(
          status: AuthStatus.authenticated,
          userInfo: userInfo,
          token: tokenModelObject.accessToken,
        );

        if (state != newState) {
          state = newState;
        }
      } else {
        // Token is expired or invalid, remove it
        await _storage.delete(tokenModel);
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      await _storage.delete(tokenModel);
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  // Future<void> checkAuthStatus() async {
  //   final token = await _storage.read(tokenModel);
  //   final newState = token != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  //
  //   if (state != newState) {
  //     state = newState;
  //   }
  // }

  bool get shouldRefreshToken {
    if (state.userInfo == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final timeUntilExpiry = state.userInfo!.expiration - now;
    return timeUntilExpiry <= 300; // 5 minutes
  }

  // Public getters for accessing user information safely
  String? get currentUserId => state.userInfo?.userId;

  String? get currentUserEmail => state.userInfo?.email;

  String? get currentProfileId => state.userInfo?.profileId;

  String? get currentSessionId => state.userInfo?.sessionId;

  String? get tokenType => state.userInfo?.tokenType;

  String? get currentToken => state.token;

  FromTokenUserInfo? get currentUserInfo => state.userInfo;

  bool get isAuthenticated => state.status == AuthStatus.authenticated;

  bool get isLoading => state.status == AuthStatus.loading;

  bool get isTokenExpired => state.userInfo?.isExpired ?? true;

  DateTime? get tokenExpirationDate => state.userInfo?.expirationDate;
}

/// Change notifier wrapper for GoRouter's refreshListenable
class AuthStateChangeNotifier extends ChangeNotifier {
  final StateNotifierProvider<AuthNotifier, AuthState> provider;
  final Ref ref;
  AuthState _previousState;

  AuthStateChangeNotifier(this.provider, this.ref)
    : _previousState = ref.read(provider) {
    ref.listen<AuthState>(provider, (previous, next) {
      if (previous != next) {
        _previousState = next;
        notifyListeners();
      }
    });
  }

  // AuthStatus get authStatus => _previousState;
  AuthState get authState => _previousState;

  AuthStatus get authStatus => _previousState.status;

  String? get userId => _previousState.userInfo?.userId;

  String? get userEmail => _previousState.userInfo?.email;

  String? get profileId => _previousState.userInfo?.profileId;

  FromTokenUserInfo? get userInfo => _previousState.userInfo;
}
