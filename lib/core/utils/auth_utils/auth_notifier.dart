import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/constants/app_constants.dart';
import 'package:inner_child_app/core/utils/secure_storage_utils.dart';
import 'package:inner_child_app/domain/entities/auth/auth_status_enum.dart';

/// Auth notifier for authentication state management
class AuthNotifier extends StateNotifier<AuthStatus> {
  final SecureStorageUtils _storage;
  final tokenModel = AppConstants.tokenModel;

  AuthNotifier(this._storage) : super(AuthStatus.loading) {
    _initialize();
  }

  /// Initialize auth state by checking for stored token
  Future<void> _initialize() async {
    final token = await _storage.read(tokenModel);
    state = token != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  }

  /// Login user and update auth state
  Future<void> login(String token) async {
    try {
      state = AuthStatus.loading;
      await _storage.write(tokenModel, token);
      state = AuthStatus.authenticated;
    } catch (e) {
      state = AuthStatus.unauthenticated;
      rethrow;
    }
  }

  /// Logout user and update auth state
  Future<void> logout() async {
    try {
      state = AuthStatus.loading;
      await _storage.delete(tokenModel);
      state = AuthStatus.unauthenticated;
    } catch (e) {
      // Revert to previous authenticated state if logout fails
      state = AuthStatus.authenticated;
      rethrow;
    }
  }

  /// Verify if token is still valid
  Future<void> checkAuthStatus() async {
    final token = await _storage.read(tokenModel);
    final newState = token != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;

    if (state != newState) {
      state = newState;
    }
  }
}

/// Change notifier wrapper for GoRouter's refreshListenable
class AuthStateChangeNotifier extends ChangeNotifier {
  final StateNotifierProvider<AuthNotifier, AuthStatus> provider;
  final Ref ref;
  AuthStatus _previousState;

  AuthStateChangeNotifier(this.provider, this.ref)
      : _previousState = ref.read(provider) {
    ref.listen<AuthStatus>(provider, (previous, next) {
      if (previous != next) {
        _previousState = next;
        notifyListeners();
      }
    });
  }

  AuthStatus get authStatus => _previousState;
}