import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inner_child_app/core/utils/auth_utils/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/presentation/pages/authentication_pages/login.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  const storage = FlutterSecureStorage();
  await storage.deleteAll();
  runApp(
    ProviderScope(
      child:
          // InnerChildApp(),
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Login(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

class InnerChildApp extends ConsumerWidget {
  const InnerChildApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      // navigatorKey: navigatorKey,
      // home: const Login(),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}