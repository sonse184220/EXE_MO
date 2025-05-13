class UserLoginModel {
  String email;
  String password;

  UserLoginModel({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}