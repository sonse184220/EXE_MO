import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:inner_child_app/core/constants/app_constants.dart';
import 'package:inner_child_app/domain/entities/auth/token_model.dart';
import '../utils/secure_storage_utils.dart';

class DioClient {
  final Dio dio;
  final SecureStorageUtils _storage;
  final Dio _refreshDio;

  DioClient(SecureStorageUtils storage)
    :_storage = storage, dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.baseURL,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      ),
      _refreshDio = Dio(
        BaseOptions(
          baseUrl: AppConstants.baseURL,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // String accessToken = AppConstants.accessToken;
          // final token = await storage.read(accessToken);
          final jsonString = await storage.read(AppConstants.tokenModel);
          if (jsonString != null) {
            final tokenModel = TokenModel.fromJson(jsonDecode(jsonString));
            final token = tokenModel.accessToken;

            if (token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          // 🔍 Debug logging
          if (kDebugMode) {
            print('📤 [REQUEST]');
            print('➡️ URL: ${options.uri}');
            print('➡️ Method: ${options.method}');
            print('➡️ Headers: ${options.headers}');
            print('➡️ Data: ${options.data}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('✅ [RESPONSE]');
            print('⬅️ URL: ${response.requestOptions.uri}');
            print('⬅️ Status Code: ${response.statusCode}');
            print('⬅️ Headers: ${response.headers}');
            print('⬅️ Data: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (e, handler) async {
          if (kDebugMode) {
            print('''❌ ⛔️ [ERROR]
[URL]     ${e.requestOptions.uri}
[Message] ${e.message}
[Status]  ${e.response?.statusCode}
[Data]    ${e.response?.data}
[Headers] ${e.response?.headers}
''');
          }

          if (e.response?.statusCode == 401) {
            try {
              final refreshed = await _refreshToken();
              if (refreshed) {
                // Retry the original request with new token
                final retryResponse = await _retryRequest(e.requestOptions);
                return handler.resolve(retryResponse);
              }
            } catch (refreshError) {
              if (kDebugMode) {
                print('Token refresh failed: $refreshError');
              }
              // Let the original error continue
            }
          }

          return handler.next(e);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final jsonString = await _storage.read(AppConstants.tokenModel);
      if (jsonString == null) return false;

      final tokenModel = TokenModel.fromJson(jsonDecode(jsonString));
      print('refreshtoken: ${tokenModel.refreshToken}');

      // Call refresh token API
      final response = await _refreshDio.post(
        'innerchild/auth/refresh-token', // Replace with your actual refresh endpoint
        data: {'refreshToken': tokenModel.refreshToken},
      );

      if (response.statusCode == 200) {
        final newTokenModel = TokenModel.fromJson(response.data);
        final newTokenJson = jsonEncode(newTokenModel.toJson());
        await _storage.write(AppConstants.tokenModel, newTokenJson);

        if (kDebugMode) {
          print('✅ Token refreshed successfully');
        }
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Token refresh error: $e');
      }
      return false;
    }
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    // Get the new token
    final jsonString = await _storage.read(AppConstants.tokenModel);
    if (jsonString != null) {
      final tokenModel = TokenModel.fromJson(jsonDecode(jsonString));
      requestOptions.headers['Authorization'] = 'Bearer ${tokenModel.accessToken}';
    }

    // Retry the request
    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      ),
    );
  }

  /// GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) {
    if (kDebugMode) {
      print('📡 GET → $path');
    }
    return dio.get(path, queryParameters: queryParams);
  }

  /// POST request
  Future<Response> post(String path, {dynamic data}) {
    if (kDebugMode) {
      print('📡 POST → $path');
    }
    return dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    if (kDebugMode) {
      print('📡 PUT → $path');
    }
    return dio.put(path, data: data);
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParams,
    dynamic data,
  }) {
    if (kDebugMode) {
      print('📡 DELETE → $path');
    }
    return dio.delete(path, queryParameters: queryParams, data: data);
  }
}

// import 'package:dio/dio.dart';
//
// class DioClient {
//   static final DioClient _instance = DioClient._internal();
//
//   factory DioClient() => _instance;
//
//   late Dio dio;
//
//   DioClient._internal() {
//     dio = Dio(
//       BaseOptions(
//         baseUrl: 'https://innerchild.somee.com/',
//         connectTimeout: Duration(seconds: 10),
//         receiveTimeout: Duration(seconds: 10),
//         // headers: {
//         //   'Content-Type': 'application/json',
//         //   // 'Authorization': 'Bearer your_token_here', // Optional: add later
//         // },
//       ),
//     );
//
//     // Optional: Add interceptors here
//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) {
//           print('📤 [REQUEST]');
//           print('➡️ URL: ${options.uri}');
//           print('➡️ Method: ${options.method}');
//           print('➡️ Headers: ${options.headers}');
//
//           if (options.data is FormData) {
//             final formData = options.data as FormData;
//             print('➡️ FormData fields:');
//             for (var field in formData.fields) {
//               print('   ${field.key}: ${field.value}');
//             }
//             if (formData.files.isNotEmpty) {
//               print('➡️ FormData files:');
//               for (var file in formData.files) {
//                 print('   ${file.key}: ${file.value.filename}');
//               }
//             }
//           } else {
//             print('➡️ Data: ${options.data}');
//           }
//
//           return handler.next(options);
//         },
//         onResponse: (response, handler) {
//           print('✅ [RESPONSE]');
//           print('⬅️ URL: ${response.requestOptions.uri}');
//           print('⬅️ Status Code: ${response.statusCode}');
//           print('⬅️ Headers: ${response.headers}');
//           print('⬅️ Data: ${response.data}');
//           return handler.next(response);
//         },
//
//         onError: (DioException e, handler) {
//           print('''❌ ⛔️ [ERROR]
// [URL]     ${e.requestOptions.uri}
// [Message] ${e.message}
// [Status]  ${e.response?.statusCode}
// [Data]    ${e.response?.data}
// [Headers] ${e.response?.headers}
// ''');
//           print('[DioException Type] ${e.type}');
//           print('[StackTrace] ${e.stackTrace}');
//
//           return handler.next(e);
//         },
//       ),
//     );
//   }
//
//   // Example GET request
//   Future<Response> get(String path, {Map<String, dynamic>? queryParams}) {
//     return dio.get(path, queryParameters: queryParams);
//   }
//
//   // Example POST request
//   Future<Response> post(String path, {dynamic data}) {
//     return dio.post(path, data: data);
//   }
// }
