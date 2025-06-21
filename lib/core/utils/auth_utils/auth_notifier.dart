import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/constants/app_constants.dart';
import 'package:inner_child_app/core/utils/auth_utils/auth_util_methods.dart';
import 'package:inner_child_app/core/utils/global_signalR_ui_handler.dart';
import 'package:inner_child_app/core/utils/secure_storage_utils.dart';
import 'package:inner_child_app/core/utils/signalr_service.dart';
import 'package:inner_child_app/domain/entities/auth/account_profile.dart';
import 'package:inner_child_app/domain/entities/auth/auth_state.dart';
import 'package:inner_child_app/domain/entities/auth/auth_status_enum.dart';
import 'package:inner_child_app/domain/entities/auth/from_token_user_info.dart';
import 'package:inner_child_app/domain/entities/auth/token_model.dart';

/// Auth notifier for authentication state management
class AuthNotifier extends StateNotifier<AuthState> {
  final SecureStorageUtils _storage;
  final Dio _refreshDio;
  final SignalRService _signalRService;
  final SignalRMessagesNotifier _messagesNotifier;

  Timer? _countdownTimer;
  int _remainingSeconds = 0;

  final tokenModel = AppConstants.tokenModel;

  AuthNotifier(this._storage, this._signalRService, this._messagesNotifier)
    : _refreshDio = Dio(
        BaseOptions(
          baseUrl: AppConstants.baseURL, // Replace with your base URL
          // connectTimeout: const Duration(seconds: 60),
          // receiveTimeout: const Duration(seconds: 60),
        ),
      ),
      super(const AuthState(status: AuthStatus.loading)) {
    _initialize();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// Start countdown timer for token expiry
  void _startTokenExpiryCountdown() {
    _countdownTimer?.cancel();

    if (state.userInfo == null) return;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _remainingSeconds = state.userInfo!.expiration - now;

    if (_remainingSeconds <= 0) {
      // Token already expired, refresh immediately
      _handleTokenExpiry();
      return;
    }

    if (kDebugMode) {
      print('🕐 Token expires in $_remainingSeconds seconds');
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;

      if (_remainingSeconds % 60 == 0) {
        if (kDebugMode) {
          print('🕐 Token expires in ${_remainingSeconds ~/ 60} minutes');
        }
      }

      if (_remainingSeconds <= 0) {
        timer.cancel();
        _handleTokenExpiry();
      }
    });
  }

  /// Handle token expiry by attempting to refresh
  Future<void> _handleTokenExpiry() async {
    if (kDebugMode) {
      print('⏰ Token expired, attempting refresh...');
    }

    // state = state.copyWith(status: AuthStatus.loading);

    final refreshed = await _refreshToken();
    if (refreshed) {
      await _updateStateWithNewToken();
      _startTokenExpiryCountdown(); // Restart countdown with new token

      // Try to connect SignalR after successful token refresh
      try {
        await initSignalRAuthorize();
        // If SignalR connects successfully, maintain authenticated state
        state = state.copyWith(status: AuthStatus.authenticated);
      } catch (e) {
        debugPrint('❌ SignalR connection failed after token refresh: $e');
        // Set error state if SignalR fails
        state = state.copyWith(status: AuthStatus.error);
      }
    } else {
      // Refresh failed, logout user
      await _storage.delete(tokenModel);
      state = const AuthState(status: AuthStatus.unauthenticated);
      if (kDebugMode) {
        print('❌ Token refresh failed, user logged out');
      }
    }
  }

  /// Initialize auth state by checking for stored token AND connecting SignalR
  Future<void> _initialize() async {
    if (kDebugMode) {
      print('🚀 AuthNotifier: Starting initialization...');
    }

    try {
      // First, try to connect SignalR
      // await _initSignalR();

      // Then proceed with auth initialization
      await _initializeAuth();

      if (state.status == AuthStatus.authenticated) {
        try {
          state = state.copyWith(status: AuthStatus.loading);
          await initSignalRAuthorize();
          state = state.copyWith(status: AuthStatus.authenticated);
        } catch (e) {
          debugPrint('❌ SignalR connection failed during initialization: $e');
          // Set error status but keep user info and token
          state = state.copyWith(status: AuthStatus.error);
        }
      }

      if (kDebugMode) {
        print(
          '✅ AuthNotifier: Full initialization completed with status: ${state.status}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error during initialization: $e');
      // If SignalR fails, we set error state instead of continuing
      state = AuthState(status: AuthStatus.error);
    }
  }

  Future<void> _initSignalR() async {
    try {
      await _signalRService.initConnection();

      // Subscribe to all SignalR events and forward to global handler
      _signalRService.onMessage((args) {
        if (args != null && args.isNotEmpty) {
          try {
            // Assuming the first arg is the message type and second is data
            final messageType = args[0] as String? ?? 'ReceiveMessage';
            // final messageData = args.length > 1 ? args[1] as Map<String, dynamic>? ?? {} : {};

            final messageData =
                args.length > 1
                    ? Map<String, dynamic>.from(args[1] as Map)
                    : <String, dynamic>{};

            // Forward to global message handler
            _messagesNotifier.addMessage(messageType, messageData);

            if (kDebugMode) {
              print(
                "🔔 SignalR message forwarded: $messageType - $messageData",
              );
            }
          } catch (e) {
            debugPrint('Error processing SignalR message: $e');
          }
        }
      });

      // Subscribe to specific events if your SignalR service supports multiple event types
      _signalRService.onUserOnline((args) {
        if (args != null && args.isNotEmpty) {
          final data = args[0] as Map<String, dynamic>? ?? {};
          _messagesNotifier.addMessage('UserOnline', data);
        }
      });

      _signalRService.onUserOffline((args) {
        if (args != null && args.isNotEmpty) {
          final data = args[0] as Map<String, dynamic>? ?? {};
          _messagesNotifier.addMessage('UserOffline', data);
        }
      });

      _signalRService.onNotification((args) {
        if (args != null && args.isNotEmpty) {
          final data = args[0] as Map<String, dynamic>? ?? {};
          _messagesNotifier.addMessage('NewNotification', data);
        }
      });

      if (kDebugMode) {
        print('✅ SignalR connected successfully');
      }
    } catch (e) {
      debugPrint('❌ SignalR connection failed: $e');
      rethrow; // Rethrow to be caught by _initialize
    }
  }

  Future<void> initSignalRAuthorize() async {
    try {
      final tokenModelJson = await _storage.read(tokenModel);

      // Check if token data exists
      if (tokenModelJson == null) {
        if (kDebugMode) {
          print(
            '🚀 AuthNotifier: No token available for SignalR connection...',
          );
        }
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      TokenModel tokenModelObject;

      // If stored as JSON string, parse it
      final Map<String, dynamic> jsonMap = json.decode(tokenModelJson);
      tokenModelObject = TokenModel.fromJson(jsonMap);
      if (kDebugMode) {
        print(tokenModelObject.accessToken);
      }

      await _signalRService.initConnectionAuthorize(
        tokenModelObject.accessToken,
      );

      _signalRService.onForceLogout((args) {
        print("⚠️ force_logout received: $args");

        String message = 'Your session has been terminated by the administrator.';
        if (args != null && args.isNotEmpty) {
          message = args[0] as String? ?? message;
          print("⚠️ force_logout message: $message");
        }

        // Forward to global message handler with the logout message
        _messagesNotifier.addMessage('ForceLogout', {
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        });
      });

      // Subscribe to all SignalR events and forward to global handler
      _signalRService.onMessage((args) {
        if (args != null && args.isNotEmpty) {
          try {
            // Assuming the first arg is the message type and second is data
            final messageType = args[0] as String? ?? 'ReceiveMessage';
            // final messageData = args.length > 1 ? args[1] as Map<String, dynamic>? ?? {} : {};

            final messageData =
                args.length > 1
                    ? Map<String, dynamic>.from(args[1] as Map)
                    : <String, dynamic>{};

            // Forward to global message handler
            _messagesNotifier.addMessage(messageType, messageData);

            if (kDebugMode) {
              print(
                "🔔 SignalR message forwarded: $messageType - $messageData",
              );
            }
          } catch (e) {
            debugPrint('Error processing SignalR message: $e');
          }
        }
      });

      // Subscribe to specific events if your SignalR service supports multiple event types
      _signalRService.onUserOnline((args) {
        if (args != null && args.isNotEmpty) {
          final data = args[0] as Map<String, dynamic>? ?? {};
          _messagesNotifier.addMessage('UserOnline', data);
        }
      });

      _signalRService.onUserOffline((args) {
        if (args != null && args.isNotEmpty) {
          final data = args[0] as Map<String, dynamic>? ?? {};
          _messagesNotifier.addMessage('UserOffline', data);
        }
      });

      _signalRService.onNotification((args) {
        if (args != null && args.isNotEmpty) {
          final data = args[0] as Map<String, dynamic>? ?? {};
          _messagesNotifier.addMessage('NewNotification', data);
        }
      });

      if (kDebugMode) {
        print('✅ SignalR connected successfully');
      }
    } catch (e) {
      debugPrint('❌ SignalR connection failed: $e');
      rethrow; // Rethrow to be caught by _initialize
    }
  }

  Future<void> _initializeAuth() async {
    try {
      final tokenModelJson = await _storage.read(tokenModel);

      // Check if token data exists
      if (tokenModelJson == null) {
        if (kDebugMode) {
          print(
            '🚀 AuthNotifier: Token null in secure storage initialization...',
          );
        }
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      TokenModel tokenModelObject;

      // If stored as JSON string, parse it
      final Map<String, dynamic> jsonMap = json.decode(tokenModelJson);
      tokenModelObject = TokenModel.fromJson(jsonMap);
      if (kDebugMode) {
        print(tokenModelObject.accessToken);
      }

      final userInfo = _extractUserInfoFromToken(tokenModelObject.accessToken);
      if (userInfo == null) {
        // Invalid token format, remove it
        await _storage.delete(tokenModel);
        state = const AuthState(status: AuthStatus.unauthenticated);
        // return;
      }else{
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Re-read the new token and update state
          await _updateStateWithNewToken();
          _startTokenExpiryCountdown();
          // await initSignalRAuthorize();
          state = AuthState(
            status: AuthStatus.authenticated,
            userInfo: userInfo,
            token: tokenModelObject.accessToken,
          );
        } else {
          // Refresh failed, remove token
          await _storage.delete(tokenModel);
          state = const AuthState(status: AuthStatus.unauthenticated);
        }
      }



      // Check if token is expired or close to expiry
      // if (userInfo != null) {
      //   if (userInfo.isExpired) {
      //     // Try to refresh token first
      //     final refreshed = await _refreshToken();
      //     if (refreshed) {
      //       // Re-read the new token and update state
      //       await _updateStateWithNewToken();
      //       _startTokenExpiryCountdown();
      //       // await initSignalRAuthorize();
      //       state = AuthState(
      //         status: AuthStatus.authenticated,
      //         userInfo: userInfo,
      //         token: tokenModelObject.accessToken,
      //       );
      //
      //     } else {
      //       // Refresh failed, remove token
      //       await _storage.delete(tokenModel);
      //       state = const AuthState(status: AuthStatus.unauthenticated);
      //     }
      //   } else if (shouldRefreshToken) {
      //     // Token is close to expiry, proactively refresh
      //     await _refreshToken();
      //     await _updateStateWithNewToken();
      //     _startTokenExpiryCountdown();
      //     // await retrySignalRConnectionAuthorize();
      //     state = AuthState(
      //       status: AuthStatus.authenticated,
      //       userInfo: userInfo,
      //       token: tokenModelObject.accessToken,
      //     );
      //
      //   } else {
      //     // Token is valid
      //     state = AuthState(
      //       status: AuthStatus.authenticated,
      //       userInfo: userInfo,
      //       token: tokenModelObject.accessToken,
      //     );
      //     _startTokenExpiryCountdown();
      //     // await initSignalRAuthorize();
      //   }
      // } else {
      //   // Invalid token format, remove it
      //   await _storage.delete(tokenModel);
      //   state = const AuthState(status: AuthStatus.unauthenticated);
      // }
    } catch (e) {
      debugPrint('Error initializing auth state: $e');
      // Clean up invalid token data
      await _storage.delete(tokenModel);
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  // Add retry method for SignalR connection
  Future<void> retrySignalRConnection() async {
    try {
      // state = state.copyWith(status: AuthStatus.loading);

      await _initSignalR();

      // After successful SignalR connection, re-initialize auth
      await _initializeAuth();
    } catch (e) {
      debugPrint('❌ SignalR retry failed: $e');
      state = const AuthState(status: AuthStatus.error);
    }
  }

  Future<void> retrySignalRConnectionAuthorize() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);

      // await _signalRService.disconnect();
      await initSignalRAuthorize();

      state = state.copyWith(status: AuthStatus.authenticated);
      // After successful SignalR connection, re-initialize auth
      // await _initializeAuth();
    } catch (e) {
      debugPrint('❌ SignalR retry failed: $e');
      state = const AuthState(status: AuthStatus.error);
    }
  }

  /// Initialize auth state by checking for stored token
  // Future<void> _initialize() async {
  //   if (kDebugMode) {
  //     print('🚀 AuthNotifier: Starting initialization...');
  //   }
  //   try {
  //     final tokenModelJson = await _storage.read(tokenModel);
  //
  //     // Check if token data exists
  //     if (tokenModelJson == null) {
  //       if (kDebugMode) {
  //         print('🚀 AuthNotifier: Token null in secure storage initialization...');
  //       }
  //       state = const AuthState(status: AuthStatus.unauthenticated);
  //       return;
  //     }
  //
  //     TokenModel tokenModelObject;
  //
  //     // If stored as JSON string, parse it
  //     final Map<String, dynamic> jsonMap = json.decode(tokenModelJson);
  //     tokenModelObject = TokenModel.fromJson(jsonMap);
  //     if (kDebugMode) {
  //       print(tokenModelObject.accessToken);
  //     }
  //
  //     final userInfo = _extractUserInfoFromToken(tokenModelObject.accessToken);
  //
  //     // Check if token is expired or close to expiry
  //     if (userInfo != null) {
  //       if (userInfo.isExpired) {
  //         // Try to refresh token first
  //         final refreshed = await _refreshToken();
  //         if (refreshed) {
  //           // Re-read the new token and update state
  //           await _updateStateWithNewToken();
  //           _startTokenExpiryCountdown();
  //           state = AuthState(
  //             status: AuthStatus.authenticated,
  //             userInfo: userInfo,
  //             token: tokenModelObject.accessToken,
  //           );
  //         } else {
  //           // Refresh failed, remove token
  //           await _storage.delete(tokenModel);
  //           state = const AuthState(status: AuthStatus.unauthenticated);
  //         }
  //       } else if (shouldRefreshToken) {
  //         // Token is close to expiry, proactively refresh
  //         await _refreshToken();
  //         await _updateStateWithNewToken();
  //         _startTokenExpiryCountdown();
  //         state = AuthState(
  //           status: AuthStatus.authenticated,
  //           userInfo: userInfo,
  //           token: tokenModelObject.accessToken,
  //         );
  //       } else {
  //         // Token is valid
  //         state = AuthState(
  //           status: AuthStatus.authenticated,
  //           userInfo: userInfo,
  //           token: tokenModelObject.accessToken,
  //         );
  //         _startTokenExpiryCountdown();
  //       }
  //     } else {
  //       // Invalid token format, remove it
  //       await _storage.delete(tokenModel);
  //       state = const AuthState(status: AuthStatus.unauthenticated);
  //     }
  //
  //     if (kDebugMode) {
  //       print('✅ AuthNotifier: Initialization completed with status: ${state.status}');
  //     }
  //
  //     // // Check if token is expired
  //     // if (userInfo != null && !userInfo.isExpired) {
  //     //   state = AuthState(
  //     //     status: AuthStatus.authenticated,
  //     //     userInfo: userInfo,
  //     //     token: tokenModelObject.accessToken,
  //     //   );
  //     // } else {
  //     //   // Token is expired, remove it
  //     //   await _storage.delete(tokenModel);
  //     //   state = const AuthState(status: AuthStatus.unauthenticated);
  //     // }
  //   } catch (e) {
  //     debugPrint('Error initializing auth state: $e');
  //     // Clean up invalid token data
  //     await _storage.delete(tokenModel);
  //     state = const AuthState(status: AuthStatus.unauthenticated);
  //   }
  // }

  Future<void> _updateStateWithNewToken() async {
    try {
      final tokenModelJson = await _storage.read(tokenModel);
      if (tokenModelJson != null) {
        final tokenModelObject = TokenModel.fromJson(
          json.decode(tokenModelJson),
        );
        final userInfo = _extractUserInfoFromToken(
          tokenModelObject.accessToken,
        );

        if (userInfo != null && !userInfo.isExpired) {
          state = AuthState(
            status: AuthStatus.authenticated,
            userInfo: userInfo,
            token: tokenModelObject.accessToken,
          );
        }
      }
    } catch (e) {
      debugPrint('Error updating state with new token: $e');
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final tokenModelJson = await _storage.read(tokenModel);
      if (tokenModelJson == null) return false;

      final tokenModelObject = TokenModel.fromJson(json.decode(tokenModelJson));

      // Call refresh token API
      final response = await _refreshDio.post(
        'innerchild/auth/refresh-token',
        // Replace with your actual refresh endpoint
        data: {'refreshToken': tokenModelObject.refreshToken},
      );

      if (response.statusCode == 200) {
        final newTokenModel = TokenModel.fromJson(response.data);
        final newTokenJson = jsonEncode(newTokenModel.toJson());
        await _storage.write(tokenModel, newTokenJson);

        // await retrySignalRConnectionAuthorize();

        if (kDebugMode) {
          print('✅ Token refreshed successfully in AuthNotifier');
        }
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Token refresh error in AuthNotifier: $e');
      return false;
    }
  }

  // Public method to handle token refresh from UI
  Future<bool> refreshTokenIfNeeded() async {
    if (shouldRefreshToken || (state.userInfo?.isExpired ?? true)) {
      state = state.copyWith(status: AuthStatus.loading);

      final refreshed = await _refreshToken();
      if (refreshed) {
        await _updateStateWithNewToken();
        _startTokenExpiryCountdown();

        try {
          await initSignalRAuthorize();
          // If SignalR connects successfully, maintain authenticated state
          state = state.copyWith(status: AuthStatus.authenticated);
        } catch (e) {
          debugPrint(
            '❌ SignalR connection failed after manual token refresh: $e',
          );
          // Set error state if SignalR fails
          state = state.copyWith(status: AuthStatus.error);
        }
      } else {
        // Token refresh failed
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
      return refreshed;
    }
    return true; // Token is still valid
  }

  FromTokenUserInfo? _extractUserInfoFromToken(String token) {
    try {
      // Use the utility method for JWT decoding
      final payloadMap = AuthUtilMethods.decodeJwtPayload(token);

      if (kDebugMode) {
        print(token);
      }

      // Create UserInfo from payload
      return FromTokenUserInfo.fromJwtPayload(payloadMap);
    } catch (e) {
      debugPrint('Error extracting user info from token: $e');
      return null;
    }
  }

  Future<void> loginWithProfileToken(List<AccountProfile> profiles) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);

      if (profiles.isEmpty) {
        throw Exception('Invalid profiles format');
      }

      final profilesJson = jsonEncode(profiles.map((p) => p.toJson()).toList());
      String profilesKey = AppConstants.profiles;
      await _storage.write(profilesKey, profilesJson);

      // final userInfo = _extractUserInfoFromToken(tokenModel.accessToken);

      // if (userInfo == null) {
      //   throw Exception('Invalid token format');
      // }
      //
      // if (userInfo.isExpired) {
      //   throw Exception('Token is expired');
      // }

      // final tokenModelToJson = jsonEncode(tokenModel.toJson());
      // String tokenModelString = AppConstants.tokenModel;
      //
      // await _storage.write(tokenModelString, tokenModelToJson);

      // Set to profileSelection status instead of authenticated
      state = AuthState(
        status: AuthStatus.profileSelection,
        userInfo: null,
        token: null,
      );
      if (kDebugMode) {
        print('setState profileSelection: ${state.status}');
      }
    } catch (e) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      if (kDebugMode) {
        print('Error setState profileSelection: $e');
      }
      rethrow;
    }
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
        status: AuthStatus.loading,
        userInfo: userInfo,
        token: tokenModel.accessToken,
      );

      _startTokenExpiryCountdown();

      try {
        await initSignalRAuthorize();
        // If SignalR connects successfully, set to authenticated
        state = state.copyWith(status: AuthStatus.authenticated);
        if (kDebugMode) {
          print('✅ Login successful with SignalR connection');
        }
      } catch (e) {
        debugPrint('❌ SignalR connection failed during login: $e');
        // Set error status but keep user info and token for retry
        state = state.copyWith(status: AuthStatus.error);
      }
    } catch (e) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      rethrow;
    }
  }

  /// Logout user and update auth state
  Future<void> logout() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _storage.delete(tokenModel);
      String profilesKey = AppConstants.profiles;
      await _storage.delete(profilesKey);
      _countdownTimer?.cancel();
      state = const AuthState(status: AuthStatus.unauthenticated);
      if (kDebugMode) {
        print('setState unauthenticated: ${state.status}');
      }
    } catch (e) {
      // Revert to previous authenticated state if logout fails
      state = state.copyWith(status: AuthStatus.authenticated);
      rethrow;
    }
  }

  Future<void> switchToProfileChoosing() async {
    try {
      await _storage.delete(tokenModel);
      state = const AuthState(status: AuthStatus.profileSelection, token: null, userInfo: null);
      if (kDebugMode) {
        print('setState profile selection: ${state.status}');
      }
    } catch (e) {
      // Revert to previous authenticated state if logout fails
      state = state.copyWith(status: AuthStatus.authenticated);
      rethrow;
    }
  }

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
          _startTokenExpiryCountdown();
        }
      } else {
        // Token is expired, try to refresh
        final refreshed = await _refreshToken();
        if (refreshed) {
          await _updateStateWithNewToken();
          _startTokenExpiryCountdown();

          try {
            await initSignalRAuthorize();
            // If SignalR connects successfully, set to authenticated
            state = state.copyWith(status: AuthStatus.authenticated);
          } catch (e) {
            debugPrint('❌ SignalR connection failed during auth check: $e');
            // Set error state if SignalR fails
            state = state.copyWith(status: AuthStatus.error);
          }
        } else {
          // Refresh failed, remove token
          await _storage.delete(tokenModel);
          state = const AuthState(status: AuthStatus.unauthenticated);
        }
        // // Token is expired or invalid, remove it
        // await _storage.delete(tokenModel);
        // state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      await _storage.delete(tokenModel);
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  bool get shouldRefreshToken {
    if (state.userInfo == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final timeUntilExpiry = state.userInfo!.expiration - now;
    return timeUntilExpiry <= 60; // 5 minutes
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
