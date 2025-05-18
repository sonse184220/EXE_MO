import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/domain/entities/auth/auth_status_enum.dart';
import 'package:inner_child_app/presentation/pages/authentication_pages/login.dart';
import 'package:inner_child_app/presentation/pages/authentication_pages/register.dart';
import 'package:inner_child_app/presentation/pages/main_pages/main_screen.dart';

/// Routes names for app navigation
class AppRoute {
  static const home = '/';
  static const login = '/login';
  static const register = '/register';

  // Prevent instantiation
  const AppRoute._();
}

/// Router provider that handles navigation and authentication redirects
final routerProvider = Provider<GoRouter>((ref) {
  final authChangeNotifier = ref.watch(authStateChangeProvider);

  return GoRouter(
    initialLocation: AppRoute.login,
    refreshListenable: authChangeNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final authStatus = ref.read(authNotifierProvider);
      final isLoggingIn = state.matchedLocation == AppRoute.login ||
          state.matchedLocation == AppRoute.register;

      // Don't redirect while authentication state is being determined
      if (authStatus == AuthStatus.loading) return null;

      // Redirect to login if user is not authenticated and not already on auth page
      if (authStatus == AuthStatus.unauthenticated && !isLoggingIn) {
        return AppRoute.login;
      }

      // Redirect to home if user is authenticated and trying to access auth pages
      if (authStatus == AuthStatus.authenticated && isLoggingIn) {
        return AppRoute.home;
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoute.home,
        name: 'home',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: AppRoute.login,
        name: 'login',
        builder: (context, state) => const Login(),
      ),
      GoRoute(
        path: AppRoute.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
    ],
    // Add error handling for routes
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.matchedLocation}'),
      ),
    ),
  );
});