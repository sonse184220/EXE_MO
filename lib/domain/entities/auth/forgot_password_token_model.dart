class ForgotPasswordTokenModel {
  final String token;
  final DateTime expiry;

  ForgotPasswordTokenModel({
    required this.token,
    required this.expiry,
  });

  factory ForgotPasswordTokenModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordTokenModel(
      token: json['token'],
      expiry: DateTime.parse(json['expiry']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expiry': expiry.toIso8601String(),
    };
  }
}
