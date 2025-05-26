class FromTokenUserInfo {
  final String userId;
  final String email;
  final String profileId;
  final String sessionId;
  final String tokenType;
  final int expiration;
  final String issuer;
  final String audience;

  const FromTokenUserInfo({
    required this.userId,
    required this.email,
    required this.profileId,
    required this.sessionId,
    required this.tokenType,
    required this.expiration,
    required this.issuer,
    required this.audience,
  });

  /// Check if token is expired
  bool get isExpired {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= expiration;
  }

  /// Get expiration date
  DateTime get expirationDate {
    return DateTime.fromMillisecondsSinceEpoch(expiration * 1000);
  }

  factory FromTokenUserInfo.fromJwtPayload(Map<String, dynamic> payload) {
    return FromTokenUserInfo(
      userId: payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier']?.toString() ?? '',
      email: payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress']?.toString() ?? '',
      profileId: payload['ProfileId']?.toString() ?? '',
      sessionId: payload['SessionId']?.toString() ?? '',
      tokenType: payload['TokenType']?.toString() ?? '',
      expiration: payload['exp'] ?? 0,
      issuer: payload['iss']?.toString() ?? '',
      audience: payload['aud']?.toString() ?? '',
    );
  }

  FromTokenUserInfo copyWith({
    String? userId,
    String? email,
    String? profileId,
    String? sessionId,
    String? tokenType,
    int? expiration,
    String? issuer,
    String? audience,
  }) {
    return FromTokenUserInfo(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      profileId: profileId ?? this.profileId,
      sessionId: sessionId ?? this.sessionId,
      tokenType: tokenType ?? this.tokenType,
      expiration: expiration ?? this.expiration,
      issuer: issuer ?? this.issuer,
      audience: audience ?? this.audience,
    );
  }

  @override
  String toString() {
    return 'UserInfo(userId: $userId, email: $email, profileId: $profileId, sessionId: $sessionId, tokenType: $tokenType, expiration: $expiration, issuer: $issuer, audience: $audience)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FromTokenUserInfo &&
        other.userId == userId &&
        other.email == email &&
        other.profileId == profileId &&
        other.sessionId == sessionId &&
        other.tokenType == tokenType &&
        other.expiration == expiration &&
        other.issuer == issuer &&
        other.audience == audience;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
    email.hashCode ^
    profileId.hashCode ^
    sessionId.hashCode ^
    tokenType.hashCode ^
    expiration.hashCode ^
    issuer.hashCode ^
    audience.hashCode;
  }
}