import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/domain/entities/auth/auth_status_enum.dart';
import 'package:inner_child_app/presentation/pages/admin/admin_home_page.dart';
import 'package:inner_child_app/presentation/pages/authentication_pages/forgot_password_1.dart';
import 'package:inner_child_app/presentation/pages/authentication_pages/forgot_password_2.dart';
import 'package:inner_child_app/presentation/pages/authentication_pages/login.dart';
import 'package:inner_child_app/presentation/pages/authentication_pages/register.dart';
import 'package:inner_child_app/presentation/pages/function_pages/user_information/password_change_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/user_information/profile_edit_page.dart';
import 'package:inner_child_app/presentation/pages/main_pages/main_screen.dart';

/// Routes names for app navigation
class AppRoute {
  //====== Auth Routes =====
  static const mainScreen = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword1 = '/forgot-password-1';
  static const forgotPassword2 = '/forgot-password-2';

  //====== User Function Routes =====
  static const changePassword = '/change-password';
  static const profileEdit = '/profile-edit';

  //====== Base Routes =====
  static const userBase = '/user';
  static const adminBase = '/admin';

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
      final authState = ref.read(authNotifierProvider);
      final isLoggingIn = state.matchedLocation == AppRoute.login ||
          state.matchedLocation == AppRoute.register;

      // Don't redirect while authentication state is being determined
      if (authState.status == AuthStatus.loading) return null;

      // Redirect to login if user is not authenticated and not already on auth page
      if (authState.status == AuthStatus.unauthenticated && !isLoggingIn) {
        return AppRoute.login;
      }

      // Redirect to home if user is authenticated and trying to access auth pages
      if (authState.status == AuthStatus.authenticated && isLoggingIn) {
        return AppRoute.mainScreen;
      }

      // No redirect needed
      return null;
    },
      routes: [
        GoRoute(
          path: AppRoute.mainScreen,
          name: 'mainScreen',
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
        GoRoute(
          path: AppRoute.forgotPassword1,
          name: 'forgotPassword1',
          builder: (context, state) => const ForgotPassword1(),
        ),
        GoRoute(
          path: AppRoute.forgotPassword2,
          name: 'forgotPassword2',
          builder: (context, state) => const ForgotPassword2(),
        ),

        // === /user/* Routes ===
        GoRoute(
          path: AppRoute.userBase,
          name: 'userBase',
          // redirect: (context, state) => '/user/chat', // optional default redirect
          routes: [
            GoRoute(
              path: 'chat',
              name: 'userChat',
              builder: (context, state) => const RegisterPage(),
            ),
            GoRoute(
              path: AppRoute.profileEdit,
              name: 'profileEdit',
              builder: (context, state) => const ProfileEditPage(),
            ),
            GoRoute(
              path: AppRoute.changePassword,
              name: 'changePassword',
              builder: (context, state) => const PasswordChangePage(),
            ),
          ],
        ),

        // === /admin/* Routes ===
        GoRoute(
          path: AppRoute.adminBase,
          name: 'adminBase',
          // redirect: (context, state) => '/admin/user', // optional
          routes: [
            GoRoute(
              path: 'user', // becomes /admin/user
              name: 'adminUserManagement',
              builder: (context, state) => const AdminHomePage(),
            ),
            GoRoute(
              path: 'settings', // becomes /admin/settings
              name: 'adminSettings',
              builder: (context, state) => const AdminHomePage(),
            ),
          ],
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