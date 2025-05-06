import 'package:dio/dio.dart';
import 'package:inner_child_app/domain/entities/user_register_model.dart';

import '../../../../core/utils/dio_instance.dart';

class AuthApiService {
  final DioClient _client = DioClient();

  Future<Response> register(UserRegisterModel data) {
    return _client.post('auth/register', data: data);
  }
}