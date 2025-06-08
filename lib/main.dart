import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inner_child_app/core/utils/auth_utils/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/domain/entities/auth/auth_state.dart';
import 'package:inner_child_app/domain/entities/auth/auth_status_enum.dart';
import 'package:inner_child_app/presentation/widgets/loading_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

class AppWrapper extends ConsumerWidget {
  final Widget child;

  const AppWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    // Show loading page when auth status is loading
    if (authState.status == AuthStatus.loading) {
      return const LoadingPage();
    }

    return child;
  }
}

class GlobalAuthWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalAuthWrapper({super.key, required this.child});

  @override
  ConsumerState<GlobalAuthWrapper> createState() => _GlobalAuthWrapperState();
}

class _GlobalAuthWrapperState extends ConsumerState<GlobalAuthWrapper> {
  Timer? _tokenCheckTimer;
  Timer? _sessionCountdownTimer;
  bool _dialogShown = false;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTokenCheckTimer();
  }

  @override
  void dispose() {
    _tokenCheckTimer?.cancel();
    _sessionCountdownTimer?.cancel();
    super.dispose();
  }

  void _startTokenCheckTimer() {
    // Check token every 5 minutes
    _tokenCheckTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkTokenExpiry();
    });
  }

  void _startSessionCountdown() {
    _sessionCountdownTimer?.cancel();

    final authState = ref.watch(authNotifierProvider);
    if (authState.status != AuthStatus.authenticated ||
        authState.userInfo == null) {
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expirationTime = authState.userInfo!.expiration;
    final remainingSeconds = expirationTime - now;

    print('cl $remainingSeconds');

    if (remainingSeconds <= 0) {
      // Token already expired
      _checkTokenExpiry();
      return;
    }

    _remainingTime = Duration(seconds: remainingSeconds);

    _sessionCountdownTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) {
      // if(_remainingTime.inSeconds <= 120) {
      //   // _checkTokenExpiry();
      // }else{
      //   setState(() {
      //         _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
      //       });
      // }
      if (_remainingTime.inSeconds <= 0) {
        timer.cancel();
        // Token expired, check auth status
        _checkTokenExpiry();
      } else {
        setState(() {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
          print('cc$_remainingTime');
        });

        // Check if we should show refresh dialog when 5 minutes remaining
        if (_remainingTime.inSeconds == 300 && !_dialogShown) {
          _checkTokenExpiry();
        }
      }
    });
  }

  void _stopSessionCountdown() {
    _sessionCountdownTimer?.cancel();
    _remainingTime = Duration.zero;
  }

  void _checkTokenExpiry() {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final authState = ref.read(authNotifierProvider);

    print('=== Token Expiry Check ===');
    print('Auth status: ${authState.status}');
    print('Dialog shown: $_dialogShown');
    print('Should refresh token: ${authNotifier.shouldRefreshToken}');
    print('_remainingTime: $_remainingTime');
    print('_remainingTime: $_remainingTime');
    print('Widget mounted: $mounted');

    // Only check if user is authenticated and dialog is not already shown
    if (authState.status == AuthStatus.authenticated &&
        !_dialogShown &&
        authNotifier.shouldRefreshToken) {
      _showTokenExpiryDialog();
    }
  }

  Future<void> _showTokenExpiryDialog() async {
    print('Showing token expiry dialog'); //

    // if (_dialogShown || !mounted) {
    //   print('Dialog blocked: shown=$_dialogShown, mounted=$mounted');
    //   return;
    // }

    print('Showing token expiry dialog 2');
    // if (_dialogShown || !mounted) return;

    // setState(() {
      _dialogShown = true;
    // });

    print('du mâmy qua');
    final globalContext = navigatorKey.currentContext;
    if(globalContext == null) return;

    print('context qua');
    try {
      await showDialog(
            context: globalContext,
            barrierDismissible: false,
            // useRootNavigator: true,
            builder: (globalContext) {
              print('Dialog builder called');
              return AlertDialog(
                title: const Text('Session Expiring'),
                content: const Text(
                  'Your session is about to expire. Would you like to refresh your session?',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(globalContext).pop();
                      _handleLogout();
                    },
                    child: const Text('Logout'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(globalContext).pop();
                      _handleRefresh();
                    },
                    child: const Text('Refresh Session'),
                  ),
                ],
              );
            },
          )
          .then((_) {
            _dialogShown = false;
          })
          .catchError((error) {
            print('Dialog error: $error');
            if (mounted) {
              setState(() {
                _dialogShown = false;
              });
            }
          });
    } catch (e) {
      print('Exception showing dialog: $e');
      setState(() {
        _dialogShown = false;
      });
    }
  }

  void _handleRefresh() async {
    try {
      // Show loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const AlertDialog(
                content: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('Refreshing session...'),
                  ],
                ),
              ),
        );
      }

      final authNotifier = ref.read(authNotifierProvider.notifier);
      final refreshed = await authNotifier.refreshTokenIfNeeded();

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (refreshed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session refreshed successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Restart countdown with new token
          _startSessionCountdown();
        } else {
          _showRefreshFailedDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showRefreshFailedDialog();
      }
    }
  }

  void _showRefreshFailedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Session Refresh Failed'),
            content: const Text(
              'Unable to refresh your session. Please login again.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleLogout();
                },
                child: const Text('Login Again'),
              ),
            ],
          ),
    );
  }

  void _handleLogout() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.logout();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have been logged out'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      // Reset dialog flag when user logs out or becomes unauthenticated
      if (next.status == AuthStatus.unauthenticated) {
        _dialogShown = false;
        _stopSessionCountdown();
      }

      // Start countdown when user becomes authenticated
      if (next.status == AuthStatus.authenticated &&
          previous?.status != AuthStatus.authenticated) {
        _startSessionCountdown();
      }

      // Restart countdown if token was refreshed
      if (next.status == AuthStatus.authenticated &&
          previous?.status == AuthStatus.authenticated &&
          next.token != previous?.token) {
        _startSessionCountdown();
      }

      // Check if token needs refresh when state changes
      if (next.status == AuthStatus.authenticated &&
          !_dialogShown &&
          ref.read(authNotifierProvider.notifier).shouldRefreshToken) {
        // Delay to avoid showing dialog immediately on state change
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _checkTokenExpiry();
          }
        });
      }
    });

    final authState = ref.watch(authNotifierProvider);

    return SafeArea(child:  Scaffold(
      floatingActionButton: ElevatedButton(
        onPressed: () => _showTokenExpiryDialog(),
        //     setState(() {
        //   _dialogShown = true
        //       ;
        // })
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Session countdown bar (only show when authenticated)
          if (authState.status == AuthStatus.authenticated &&
              _remainingTime.inSeconds > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:
                    _remainingTime.inMinutes <= 5
                        ? Colors.red.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color:
                        _remainingTime.inMinutes <= 5
                            ? Colors.red.withOpacity(0.3)
                            : Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              // child: SafeArea(
              //   bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Session expires in:',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            _remainingTime.inMinutes <= 5
                                ? Colors.red[700]
                                : Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color:
                              _remainingTime.inMinutes <= 5
                                  ? Colors.red[700]
                                  : Colors.blue[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(_remainingTime),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color:
                                _remainingTime.inMinutes <= 5
                                    ? Colors.red[700]
                                    : Colors.blue[700],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                // ),
              ),
            ),
          // Main app content
          Expanded(child: widget.child),
        ],
      ),
    ));
  }
}