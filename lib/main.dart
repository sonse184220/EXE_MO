import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:inner_child_app/core/utils/auth_utils/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:inner_child_app/presentation/pages/main_pages/main_screen.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<MainScreenState> mainScreenKey = GlobalKey<MainScreenState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // const storage = FlutterSecureStorage();
  // await storage.deleteAll();
  runApp(
    ProviderScope(
      child: InnerChildApp(),
      // MaterialApp(
      //   navigatorKey: navigatorKey,
      //   home: const Login(),
      //   debugShowCheckedModeBanner: false,
      // ),
    ),
  );
}

class InnerChildApp extends ConsumerWidget {
  const InnerChildApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'InnerChildApp',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      builder: (context, child) => GlobalVersionChecker(
        child: child ?? const SizedBox.shrink(),
      ),
      // Inject GlobalAuthWrapper *inside* MaterialApp
      // builder: (context, child) =>
      //     GlobalAuthWrapper(child: child ?? const SizedBox.shrink()),
    );
    // return GlobalAuthWrapper(child: MaterialApp.router(
    //   // navigatorKey: navigatorKey,
    //   // home: const Login(),
    //   debugShowCheckedModeBanner: false,
    //   routerConfig: router,
    // ));
  }
}

class GlobalVersionChecker extends StatefulWidget {
  final Widget child;

  const GlobalVersionChecker({super.key, required this.child});

  @override
  State<GlobalVersionChecker> createState() => _GlobalVersionCheckerState();
}

class _GlobalVersionCheckerState extends State<GlobalVersionChecker> {
  bool _versionChecked = false;
  bool _isCheckingVersion = false;

  @override
  void initState() {
    super.initState();
    // _showCurrentVersionDialog();
    // _checkAppVersion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAppVersion();
    });
  }


  Future<void> _showCurrentVersionDialog() async {

    final info = await PackageInfo.fromPlatform();
    final currentVersion = info.buildNumber;


    final globalContext = navigatorKey.currentContext;
    if (globalContext == null || !mounted) {
      print('❌ Global context is null or widget unmounted, cannot show version dialog.');
      return;
    }

    // if (context.mounted) {
      showDialog(
        context: globalContext,
        builder: (_) => AlertDialog(
          title: const Text('Phiên bản hiện tại'),
          content: Text('🔢 Build version: $currentVersion'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(globalContext).pop(),
              child: const Text('OK'),
            )
          ],
        ),
      );
    // }
  }

  // Future<bool> _requestStoragePermission() async {
  //   final status = await Permission.storage.request();
  //   return status.isGranted;
  // }
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid && (await DeviceInfoPlugin().androidInfo).version.sdkInt >= 30) {
      final status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    } else {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }

  Future<void> _checkAppVersion() async {
    if (_versionChecked || _isCheckingVersion) return;

    _isCheckingVersion = true;

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) {
      _isCheckingVersion = false;
      return;
    }

    _versionChecked = true;

    try {
      final appInfo = await PackageInfo.fromPlatform();
      final currentVersion = int.parse(appInfo.buildNumber);

      final response = await Dio().get(
        'https://innerchilddownload.netlify.app/version.json',
        options: Options(responseType: ResponseType.json),
      );

      if (!mounted) {
        _isCheckingVersion = false;
        return;
      }

      final json = response.data;
      final latestVersion = json['versionCode'] ?? 0;
      final apkUrl =
          json['apkUrl'] ??
          'https://innerchilddownload.netlify.app/app-release.apk';

      if (latestVersion > currentVersion) {
        await Future.delayed(const Duration(milliseconds: 1000));

        if (mounted) {
          _showUpdateDialog(apkUrl);
        }
        // _showUpdateDialog(apkUrl);
      }
    } catch (e) {
      print('❌ Version check failed: $e');
    } finally {
      _isCheckingVersion = false;
    }
  }

  void _showUpdateDialog(String apkUrl) {
    final globalContext = navigatorKey.currentContext;
    if (globalContext == null || !mounted) {
      print('❌ Cannot show update dialog: context is null or widget unmounted.');
      return;
    }

    showDialog(
      context: globalContext,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false, // Prevent back button dismissal
        child: AlertDialog(
          backgroundColor: const Color(0xFFFFF5F7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titleTextStyle: const TextStyle(
            fontFamily: 'LeagueSpartan',
            fontSize: 22,
            color: Color(0xFFE37083),
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: Colors.black87,
          ),
          title: const Text('Update Available'),
          content: const Text(
            'A new version of the app is available.\nPlease update to continue.',
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF89B7C2),
              ),
              onPressed: () {
                if (Navigator.canPop(globalContext)) {
                  Navigator.of(globalContext).pop();
                }
              },
              child: const Text('Later', style: TextStyle(fontFamily: 'Inter')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE37083),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                if (Navigator.canPop(globalContext)) {
                  Navigator.of(globalContext).pop();
                }
                _downloadAndInstallApk(apkUrl);
              },
              child: const Text(
                'Update Now',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadAndInstallApk(String url) async {
    final globalContext = navigatorKey.currentContext;
    if (globalContext == null || !mounted) return;

    if (!await _requestStoragePermission()) {
      print('❌ Storage permission denied');
      _showErrorDialog('Storage permission is required to download updates. Please enable it in app settings.');
      return;
    }

    try {
      _showLoadingDialog();

      final downloadDir = Directory('/storage/emulated/0/Download/update');

      if (await downloadDir.exists()) {
        final existingApk = File('${downloadDir.path}/app-release.apk');
        if (await existingApk.exists()) {
          await existingApk.delete();
          print('🧹 Old APK deleted');
        }
      } else {
        await downloadDir.create(recursive: true);
        print('📁 Created update folder');
      }

      final filePath = '${downloadDir.path}/app-release.apk';

      print('url : $url');
      final response = await Dio().download(
        url,
        filePath,
        options: Options(
          followRedirects: true,
          responseType: ResponseType.bytes,
          headers: {
            'User-Agent': 'Mozilla/5.0',
          },
        ),
        deleteOnError: true,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print('⬇️ Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      // Close loading dialog
      if (mounted && Navigator.canPop(globalContext)) {
        Navigator.of(globalContext, rootNavigator: true).pop();
      }

      if (response.statusCode == 200) {
        print('✅ APK downloaded to: $filePath');

        final apkFile = File(filePath);
        if (!await apkFile.exists()) {
          throw Exception('Downloaded file does not exist');
        }

        final fileSize = await apkFile.length();
        print('📦 File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

        // Check if file size is reasonable (should be at least 1MB)
        if (fileSize < 1024 * 1024) {
          throw Exception('Downloaded file is too small ($fileSize bytes). Download may be corrupted.');
        }

        final result = await OpenFilex.open(filePath);
        print('📂 Open result: ${result.message}');

        // Check if installation was successful
        if (result.type != ResultType.done) {
          String errorMessage = 'Failed to open installer.';
          switch (result.type) {
            case ResultType.noAppToOpen:
              errorMessage = 'No app available to install APK files. Please install a file manager.';
              break;
            case ResultType.fileNotFound:
              errorMessage = 'Installation file not found. Please try downloading again.';
              break;
            case ResultType.permissionDenied:
              errorMessage = 'Permission denied. Please enable "Install from unknown sources" in settings.';
              break;
            case ResultType.error:
              errorMessage = 'Installation error: ${result.message}';
              break;
            default:
              errorMessage = 'Installation failed: ${result.message}';
          }
          _showErrorDialog(errorMessage);
        }
      } else {
        throw Exception('Download failed with HTTP status ${response.statusCode}');
      }
    } catch (e) {
      // Ensure loading dialog is closed
      if (mounted && Navigator.canPop(globalContext)) {
        Navigator.of(globalContext, rootNavigator: true).pop();
      }

      print('❌ Download/install failed: $e');

      String errorMessage = 'Download failed. Please try again.';
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            errorMessage = 'Connection timeout. Please check your internet connection and try again.';
            break;
          case DioExceptionType.receiveTimeout:
            errorMessage = 'Download timeout. Please check your internet connection and try again.';
            break;
          case DioExceptionType.connectionError:
            errorMessage = 'Network error. Please check your internet connection.';
            break;
          case DioExceptionType.badResponse:
            errorMessage = 'Server error. Please try again later.';
            break;
          default:
            errorMessage = 'Download failed: ${e.message}';
        }
      } else if (e.toString().contains('No space left')) {
        errorMessage = 'Not enough storage space. Please free up some space and try again.';
      } else if (e.toString().contains('Permission denied')) {
        errorMessage = 'Storage permission denied. Please enable storage permission in app settings.';
      }

      _showErrorDialog(errorMessage);
    }
  }

  void _showLoadingDialog() {
    final globalContext = navigatorKey.currentContext;
    if (globalContext == null || !mounted) return;

    showDialog(
      context: globalContext,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false, // Prevent back navigation
        child: AlertDialog(
          backgroundColor: const Color(0xFFFFF5F7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Row(
            children: const [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE37083)),
              ),
              SizedBox(width: 16),
              Flexible(
                child: Text(
                  'Downloading and installing the update...',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  void _showErrorDialog(String message) {
    final globalContext = navigatorKey.currentContext;
    if (globalContext == null || !mounted) return;

    showDialog(
      context: globalContext,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFFF5F7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: const TextStyle(
          fontFamily: 'LeagueSpartan',
          fontSize: 20,
          color: Color(0xFFE37083),
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          color: Colors.black87,
        ),
        title: const Text('Update Failed'),
        content: Text(message),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF89B7C2),
            ),
            onPressed: () {
              if (Navigator.canPop(globalContext)) {
                Navigator.of(globalContext).pop();
              }
            },
            child: const Text('OK', style: TextStyle(fontFamily: 'Inter')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE37083),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              if (Navigator.canPop(globalContext)) {
                Navigator.of(globalContext).pop();
              }
              // Retry the version check which will show update dialog again
              _versionChecked = false;
              _checkAppVersion();
            },
            child: const Text(
              'Retry',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Future<void> _downloadAndInstallApk(String url) async {
  //   final globalContext = navigatorKey.currentContext;
  //   if (globalContext == null || !mounted) return;
  //
  //   if (!await _requestStoragePermission()) {
  //     print('❌ Storage permission denied');
  //     return;
  //   }
  //
  //   try {
  //     _showLoadingDialog(); // ✅ Hiện loading
  //
  //     // 📁 Tạo thư mục con trong Download: /storage/emulated/0/Download/update
  //     final downloadDir = Directory('/storage/emulated/0/Download/update');
  //
  //     if (await downloadDir.exists()) {
  //       // 🧹 Xóa file APK cũ nếu tồn tại
  //       final existingApk = File('${downloadDir.path}/app-release.apk');
  //       if (await existingApk.exists()) {
  //         await existingApk.delete();
  //         print('🧹 Old APK deleted');
  //       }
  //     } else {
  //       await downloadDir.create(recursive: true);
  //       print('📁 Created update folder');
  //     }
  //
  //     final filePath = '${downloadDir.path}/app-release.apk';
  //
  //     print('url : $url');
  //     final response = await Dio().download(
  //       url,
  //       filePath,
  //       options: Options(
  //         followRedirects: true,
  //         responseType: ResponseType.bytes,
  //         headers: {
  //           'User-Agent': 'Mozilla/5.0', // Một số server cần UA
  //         },
  //       ),
  //       deleteOnError: true,
  //       onReceiveProgress: (received, total) {
  //         if (total != -1) {
  //           print('⬇️ Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
  //         }
  //       },
  //     );
  //
  //     // final response = await Dio().download(
  //     //   url,
  //     //   filePath,
  //     //   onReceiveProgress: (received, total) {
  //     //     if (total != -1) {
  //     //       print('⬇️ Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
  //     //     }
  //     //   },
  //     // );
  //
  //     Navigator.of(globalContext, rootNavigator: true).pop(); // ✅ Ẩn loading dialog
  //
  //     if (response.statusCode == 200) {
  //       print('✅ APK downloaded to: $filePath');
  //
  //       // 🧾 Kiểm tra kích thước file
  //       final apkFile = File(filePath);
  //       final fileSize = apkFile.lengthSync();
  //       print('📦 File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
  //
  //       // 🚀 Mở file APK
  //       final result = await OpenFilex.open(filePath);
  //       // const platform = MethodChannel('apkInstaller');
  //       // await platform.invokeMethod('installApk', {'path': filePath});
  //       print('📂 Open result: ${result.message}');
  //     } else {
  //       print('❌ APK download failed with status ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     Navigator.of(globalContext, rootNavigator: true).pop(); // ✅ Đảm bảo dialog luôn đóng
  //     print('❌ Download/install failed: $e');
  //   }
  // }

  // Future<void> _downloadAndInstallApk(String url) async {
  //   final globalContext = navigatorKey.currentContext;
  //   if (globalContext == null) return;
  //
  //   if (!await _requestStoragePermission()) {
  //     print('❌ Storage permission denied');
  //     return;
  //   }
  //
  //   try {
  //     _showLoadingDialog(); // ✅ Hiện loading
  //
  //     final dir = await getExternalStorageDirectory();
  //     final filePath = '${dir!.path}/update.apk';
  //
  //     final response = await Dio().download(
  //       url,
  //       filePath,
  //       onReceiveProgress: (received, total) {
  //         if (total != -1) {
  //           print('⬇️ Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
  //         }
  //       },
  //     );
  //
  //     Navigator.of(globalContext, rootNavigator: true).pop(); // ✅ Ẩn loading dialog
  //
  //     if (response.statusCode == 200) {
  //       print('✅ APK downloaded to: $filePath');
  //
  //       final result = await OpenFilex.open(filePath);
  //       print('📂 Open result: ${result.message}');
  //     } else {
  //       print('❌ APK download failed with status ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     Navigator.of(globalContext, rootNavigator: true).pop(); // ✅ Đảm bảo dialog luôn đóng
  //     print('❌ Download/install failed: $e');
  //   }
  // }

  // Future<void> _downloadAndInstallApk(String url) async {
  //   if (!await _requestStoragePermission()) {
  //     print('❌ Storage permission denied');
  //     return;
  //   }
  //
  //   try {
  //     final dir = await getExternalStorageDirectory();
  //     final filePath = '${dir!.path}/update.apk';
  //
  //     final response = await Dio().download(
  //       url,
  //       filePath,
  //       onReceiveProgress: (received, total) {
  //         if (total != -1) {
  //           print(
  //               '⬇️ Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
  //         }
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       print('✅ APK downloaded to: $filePath');
  //       InstallPlugin.installApk(filePath);
  //     } else {
  //       print('❌ APK download failed with status ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('❌ Download/install failed: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// class AppWrapper extends ConsumerWidget {
//   final Widget child;
//
//   const AppWrapper({super.key, required this.child});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authNotifierProvider);
//
//     // Show loading page when auth status is loading
//     if (authState.status == AuthStatus.loading) {
//       return const LoadingPage();
//     }
//
//     return child;
//   }
// }
//
// class GlobalAuthWrapper extends ConsumerStatefulWidget {
//   final Widget child;
//
//   const GlobalAuthWrapper({super.key, required this.child});
//
//   @override
//   ConsumerState<GlobalAuthWrapper> createState() => _GlobalAuthWrapperState();
// }
//
// class _GlobalAuthWrapperState extends ConsumerState<GlobalAuthWrapper> {
//   Timer? _tokenCheckTimer;
//   Timer? _sessionCountdownTimer;
//   bool _dialogShown = false;
//   Duration _remainingTime = Duration.zero;
//
//   @override
//   void initState() {
//     super.initState();
//     _startTokenCheckTimer();
//   }
//
//   @override
//   void dispose() {
//     _tokenCheckTimer?.cancel();
//     _sessionCountdownTimer?.cancel();
//     super.dispose();
//   }
//
//   void _startTokenCheckTimer() {
//     // Check token every 5 minutes
//     _tokenCheckTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
//       _checkTokenExpiry();
//     });
//   }
//
//   void _startSessionCountdown() {
//     _sessionCountdownTimer?.cancel();
//
//     final authState = ref.watch(authNotifierProvider);
//     if (authState.status != AuthStatus.authenticated ||
//         authState.userInfo == null) {
//       return;
//     }
//
//     final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//     final expirationTime = authState.userInfo!.expiration;
//     final remainingSeconds = expirationTime - now;
//
//     print('cl $remainingSeconds');
//
//     if (remainingSeconds <= 0) {
//       // Token already expired
//       _checkTokenExpiry();
//       return;
//     }
//
//     _remainingTime = Duration(seconds: remainingSeconds);
//
//     _sessionCountdownTimer = Timer.periodic(const Duration(seconds: 1), (
//       timer,
//     ) {
//       // if(_remainingTime.inSeconds <= 120) {
//       //   // _checkTokenExpiry();
//       // }else{
//       //   setState(() {
//       //         _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
//       //       });
//       // }
//       if (_remainingTime.inSeconds <= 0) {
//         timer.cancel();
//         // Token expired, check auth status
//         _checkTokenExpiry();
//       } else {
//         setState(() {
//           _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
//           print('cc$_remainingTime');
//         });
//
//         // Check if we should show refresh dialog when 5 minutes remaining
//         if (_remainingTime.inSeconds == 300 && !_dialogShown) {
//           _checkTokenExpiry();
//         }
//       }
//     });
//   }
//
//   void _stopSessionCountdown() {
//     _sessionCountdownTimer?.cancel();
//     _remainingTime = Duration.zero;
//   }
//
//   void _checkTokenExpiry() {
//     final authNotifier = ref.read(authNotifierProvider.notifier);
//     final authState = ref.read(authNotifierProvider);
//
//     print('=== Token Expiry Check ===');
//     print('Auth status: ${authState.status}');
//     print('Dialog shown: $_dialogShown');
//     print('Should refresh token: ${authNotifier.shouldRefreshToken}');
//     print('_remainingTime: $_remainingTime');
//     print('_remainingTime: $_remainingTime');
//     print('Widget mounted: $mounted');
//
//     // Only check if user is authenticated and dialog is not already shown
//     if (authState.status == AuthStatus.authenticated &&
//         !_dialogShown &&
//         authNotifier.shouldRefreshToken) {
//       _showTokenExpiryDialog();
//     }
//   }
//
//   Future<void> _showTokenExpiryDialog() async {
//     print('Showing token expiry dialog'); //
//
//     // if (_dialogShown || !mounted) {
//     //   print('Dialog blocked: shown=$_dialogShown, mounted=$mounted');
//     //   return;
//     // }
//
//     print('Showing token expiry dialog 2');
//     // if (_dialogShown || !mounted) return;
//
//     // setState(() {
//       _dialogShown = true;
//     // });
//
//     print('du mâmy qua');
//     final globalContext = navigatorKey.currentContext;
//     if(globalContext == null) return;
//
//     print('context qua');
//     try {
//       await showDialog(
//             context: globalContext,
//             barrierDismissible: false,
//             // useRootNavigator: true,
//             builder: (globalContext) {
//               print('Dialog builder called');
//               return AlertDialog(
//                 title: const Text('Session Expiring'),
//                 content: const Text(
//                   'Your session is about to expire. Would you like to refresh your session?',
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () {
//                       Navigator.of(globalContext).pop();
//                       _handleLogout();
//                     },
//                     child: const Text('Logout'),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.of(globalContext).pop();
//                       _handleRefresh();
//                     },
//                     child: const Text('Refresh Session'),
//                   ),
//                 ],
//               );
//             },
//           )
//           .then((_) {
//             _dialogShown = false;
//           })
//           .catchError((error) {
//             print('Dialog error: $error');
//             if (mounted) {
//               setState(() {
//                 _dialogShown = false;
//               });
//             }
//           });
//     } catch (e) {
//       print('Exception showing dialog: $e');
//       setState(() {
//         _dialogShown = false;
//       });
//     }
//   }
//
//   void _handleRefresh() async {
//     try {
//       // Show loading
//       if (mounted) {
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder:
//               (context) => const AlertDialog(
//                 content: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     CircularProgressIndicator(),
//                     SizedBox(width: 16),
//                     Text('Refreshing session...'),
//                   ],
//                 ),
//               ),
//         );
//       }
//
//       final authNotifier = ref.read(authNotifierProvider.notifier);
//       final refreshed = await authNotifier.refreshTokenIfNeeded();
//
//       if (mounted) {
//         Navigator.of(context).pop(); // Close loading dialog
//
//         if (refreshed) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Session refreshed successfully'),
//               backgroundColor: Colors.green,
//             ),
//           );
//           // Restart countdown with new token
//           _startSessionCountdown();
//         } else {
//           _showRefreshFailedDialog();
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         Navigator.of(context).pop(); // Close loading dialog
//         _showRefreshFailedDialog();
//       }
//     }
//   }
//
//   void _showRefreshFailedDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Session Refresh Failed'),
//             content: const Text(
//               'Unable to refresh your session. Please login again.',
//             ),
//             actions: [
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   _handleLogout();
//                 },
//                 child: const Text('Login Again'),
//               ),
//             ],
//           ),
//     );
//   }
//
//   void _handleLogout() async {
//     final authNotifier = ref.read(authNotifierProvider.notifier);
//     await authNotifier.logout();
//
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('You have been logged out'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//     }
//   }
//
//   String _formatDuration(Duration duration) {
//     final hours = duration.inHours;
//     final minutes = duration.inMinutes.remainder(60);
//     final seconds = duration.inSeconds.remainder(60);
//
//     if (hours > 0) {
//       return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
//     } else {
//       return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Listen to auth state changes
//     ref.listen<AuthState>(authNotifierProvider, (previous, next) {
//       // Reset dialog flag when user logs out or becomes unauthenticated
//       if (next.status == AuthStatus.unauthenticated) {
//         _dialogShown = false;
//         _stopSessionCountdown();
//       }
//
//       // Start countdown when user becomes authenticated
//       if (next.status == AuthStatus.authenticated &&
//           previous?.status != AuthStatus.authenticated) {
//         _startSessionCountdown();
//       }
//
//       // Restart countdown if token was refreshed
//       if (next.status == AuthStatus.authenticated &&
//           previous?.status == AuthStatus.authenticated &&
//           next.token != previous?.token) {
//         _startSessionCountdown();
//       }
//
//       // Check if token needs refresh when state changes
//       if (next.status == AuthStatus.authenticated &&
//           !_dialogShown &&
//           ref.read(authNotifierProvider.notifier).shouldRefreshToken) {
//         // Delay to avoid showing dialog immediately on state change
//         Future.delayed(const Duration(milliseconds: 500), () {
//           if (mounted) {
//             _checkTokenExpiry();
//           }
//         });
//       }
//     });
//
//     final authState = ref.watch(authNotifierProvider);
//
//     return SafeArea(child:  Scaffold(
//       floatingActionButton: ElevatedButton(
//         onPressed: () => _showTokenExpiryDialog(),
//         //     setState(() {
//         //   _dialogShown = true
//         //       ;
//         // })
//         child: Icon(Icons.add),
//       ),
//       body: Column(
//         children: [
//           // Session countdown bar (only show when authenticated)
//           if (authState.status == AuthStatus.authenticated &&
//               _remainingTime.inSeconds > 0)
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 color:
//                     _remainingTime.inMinutes <= 5
//                         ? Colors.red.withOpacity(0.1)
//                         : Colors.blue.withOpacity(0.1),
//                 border: Border(
//                   bottom: BorderSide(
//                     color:
//                         _remainingTime.inMinutes <= 5
//                             ? Colors.red.withOpacity(0.3)
//                             : Colors.blue.withOpacity(0.3),
//                     width: 1,
//                   ),
//                 ),
//               ),
//               // child: SafeArea(
//               //   bottom: false,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Session expires in:',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color:
//                             _remainingTime.inMinutes <= 5
//                                 ? Colors.red[700]
//                                 : Colors.blue[700],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.timer_outlined,
//                           size: 16,
//                           color:
//                               _remainingTime.inMinutes <= 5
//                                   ? Colors.red[700]
//                                   : Colors.blue[700],
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           _formatDuration(_remainingTime),
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color:
//                                 _remainingTime.inMinutes <= 5
//                                     ? Colors.red[700]
//                                     : Colors.blue[700],
//                             fontFamily: 'monospace',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 // ),
//               ),
//             ),
//           // Main app content
//           Expanded(child: widget.child),
//         ],
//       ),
//     ));
//   }
// }
