import 'package:dio/dio.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();

  factory DioClient() => _instance;

  late Dio dio;

  DioClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: 'https://api.example.com/',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer your_token_here', // Optional: add later
      },
    ));

    // Optional: Add interceptors here
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('Requesting: ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('Response: ${response.statusCode}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('Error: ${e.message}');
        return handler.next(e);
      },
    ));
  }

  // Example GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) {
    return dio.get(path, queryParameters: queryParams);
  }

  // Example POST request
  Future<Response> post(String path, {dynamic data}) {
    return dio.post(path, data: data);
  }
}