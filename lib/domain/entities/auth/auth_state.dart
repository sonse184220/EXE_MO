import 'package:inner_child_app/domain/entities/auth/auth_status_enum.dart';
import 'package:inner_child_app/domain/entities/auth/from_token_user_info.dart';

class AuthState {
  final AuthStatus status;
  final FromTokenUserInfo? userInfo;
  final String? token;

  const AuthState({
    required this.status,
    this.userInfo,
    this.token,
  });

  AuthState copyWith({
    AuthStatus? status,
    FromTokenUserInfo? userInfo,
    String? token,
    bool clearUserInfo = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      userInfo: clearUserInfo ? null : (userInfo ?? this.userInfo),
      token: token ?? this.token,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.userInfo == userInfo &&
        other.token == token;
  }

  @override
  int get hashCode => status.hashCode ^ userInfo.hashCode ^ token.hashCode;
}