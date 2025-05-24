import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:inner_child_app/core/constants/app_constants.dart';
import 'package:inner_child_app/domain/entities/auth/token_model.dart';
import '../utils/secure_storage_utils.dart';

class DioClient {
  final Dio dio;

  DioClient(SecureStorageUtils storage)
    : dio = Dio(
        BaseOptions(
          // baseUrl: 'http://178.128.218.214:5000/',
          baseUrl: 'http://127.0.0.1:5000/',
          // baseUrl: 'http://10.0.2.2:5000/',
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
          print('📤 [REQUEST]');
          print('➡️ URL: ${options.uri}');
          print('➡️ Method: ${options.method}');
          print('➡️ Headers: ${options.headers}');
          print('➡️ Data: ${options.data}');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ [RESPONSE]');
          print('⬅️ URL: ${response.requestOptions.uri}');
          print('⬅️ Status Code: ${response.statusCode}');
          print('⬅️ Headers: ${response.headers}');
          print('⬅️ Data: ${response.data}');
          return handler.next(response);
        },
        onError: (e, handler) {
          print('''❌ ⛔️ [ERROR]
[URL]     ${e.requestOptions.uri}
[Message] ${e.message}
[Status]  ${e.response?.statusCode}
[Data]    ${e.response?.data}
[Headers] ${e.response?.headers}
''');
          return handler.next(e);
        },
      ),
    );
  }

  /// GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) {
    print('📡 GET → $path');
    return dio.get(path, queryParameters: queryParams);
  }

  /// POST request
  Future<Response> post(String path, {dynamic data}) {
    print('📡 POST → $path');
    return dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    print('📡 PUT → $path');
    return dio.put(path, data: data);
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
