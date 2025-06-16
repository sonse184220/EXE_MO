import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/domain/entities/auth/auth_status_enum.dart';
import 'package:inner_child_app/main.dart';
import 'package:inner_child_app/presentation/pages/admin/admin_main_screen.dart';
import 'package:inner_child_app/presentation/pages/authentication_pages/forgot_password_1.dart';
import 'package:inner_child_app/presentation/pages/authentication_pages/forgot_password_2.dart';
import 'package:inner_child_app/presentation/pages/authentication_pages/login.dart';
import 'package:inner_child_app/presentation/pages/authentication_pages/profile_choosing_page.dart';
import 'package:inner_child_app/presentation/pages/authentication_pages/register.dart';
import 'package:inner_child_app/presentation/pages/main_pages/main_screen.dart';
import 'package:inner_child_app/presentation/widgets/loading_page.dart';

/// Routes names for app navigation
class AppRoute {
  static const loading = "/loading";

  //====== Auth Routes ======
  static const mainScreen = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword1 = '/forgot-password-1';
  static const forgotPassword2 = '/forgot-password-2';

  //====== User Function Routes ======
  static const profileChoosing = '/profile-choosing';

  static const profileEdit = '/profile-edit';
  static const changePassword = '/change-password';

  static const moodJournalWrite = '/mood-journal-write';
  static const moodJournalhistory = '/mood-journal-history';

  static const audioHome = '/audio-home';
  static const audioList = '/audio-list';
  static const audioPlaying = '/audio-playing';

  static const communityList = '/community-list';
  static const communityGroupDetail = '/community-group-detail';
  static const communityPostDetail = '/community-post-detail';
  static const communityMembers = '/community-members';

  static const quizList = '/quiz-list';
  static const quizTaking = '/quiz-taking';
  static const quizAttempts = '/quiz-attempts';

  static const aiSessions = '/ai-sessions';
  static const aiChat = '/ai-chat';

  static const goalManage = '/goal-manage';
  static const goalProgress = '/goal-progress';
  static const goalList = '/goal-list';
  static const goalDetail = '/goal-detail';

  static const subscription = '/subscription';
  static const paymentTransactionHistory = '/payment-transaction-history';
  static const help = '/help';

  //====== Admin Function Routes ======
  static const adminMainScreen = '/admin-main-screen';


  //====== Base Routes ======
  static const userBase = '/user';
  static const adminBase = '/admin';

  // Prevent instantiation
  const AppRoute._();
}

// class _AuthenticatedPageWrapper extends ConsumerWidget {
//   final Widget child;
//
//   const _AuthenticatedPageWrapper({required this.child});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return GlobalAuthWrapper(child: child);
//   }
// }


/// Router provider that handles navigation and authentication redirects
final routerProvider = Provider<GoRouter>((ref) {
  final authChangeNotifier = ref.watch(authStateChangeProvider);

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoute.login,
    refreshListenable: authChangeNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authNotifierProvider);
      final currentLocation = state.matchedLocation;

      // Don't redirect while authentication state is being determined
      if (authState.status == AuthStatus.loading) {
        // You can either return null to stay on current page or redirect to a loading route
        return AppRoute.loading; // Add this route below
      }

      final isOnAuthPage = currentLocation == AppRoute.login ||
          currentLocation == AppRoute.register ||
          currentLocation == AppRoute.forgotPassword1 ||
          currentLocation == AppRoute.forgotPassword2;

      final isOnProfileChoosing = currentLocation == '/user${AppRoute.profileChoosing}';
      final isOnLoadingPage = currentLocation == '/loading';

      switch (authState.status) {
        case AuthStatus.unauthenticated:
        // Redirect to login if not on auth pages
          if (!isOnAuthPage) {
            if (kDebugMode) {
              print(' Redirect to login if not on auth pages');
            }
            return AppRoute.login;

          }
          break;

        case AuthStatus.profileSelection:
        // Allow access to profile choosing page, redirect from auth pages
          if (isOnAuthPage || isOnLoadingPage) {
            if (kDebugMode) {
              print(' Allow access to profile choosing page, redirect from auth pages /user${AppRoute.profileChoosing}');
            }
            return '/user${AppRoute.profileChoosing}';
          }
          // If trying to access other pages, redirect to profile choosing
          if (!isOnProfileChoosing) {
            if (kDebugMode) {
              print('If trying to access other pages, redirect to profile choosing');
            }
            // return AppRoute.profileChoosing;
            return '/user${AppRoute.profileChoosing}';
          }
          break;

        case AuthStatus.authenticated:
        // Redirect away from auth pages and profile choosing
          if (isOnProfileChoosing || isOnLoadingPage) {
            if (kDebugMode) {
              print(' Redirect away from auth pages and profile choosing');
            }
            final role = authChangeNotifier.userInfo?.role;
            if (kDebugMode) {
              print(role);
            }

            if (role == 'User') {
              return AppRoute.mainScreen;
            } else if (role == 'Admin') {
              return '/admin${AppRoute.adminMainScreen}';
            } else {
              // Role is invalid → force logout
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(authNotifierProvider.notifier).logout();
              });
              return AppRoute.login;
            }
          }

          if (isOnAuthPage) {
            if (kDebugMode) {
              print(' Allow access to main screen page, redirect from auth pages after refresh token');
            }
            final role = authChangeNotifier.userInfo?.role;

            if (role == 'User') {
              return AppRoute.mainScreen;
            } else if (role == 'Admin') {
              return '/admin${AppRoute.adminMainScreen}';
            } else {
              // Role is invalid → force logout
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(authNotifierProvider.notifier).logout();
              });
              return AppRoute.login;
            }
            // return AppRoute.mainScreen;
          }
          // else{
          //   return AppRoute.login;
          // }
          break;

        case AuthStatus.loading:
        // Already handled above
          break;
      }

      return null; //
      // final isLoggingIn = state.matchedLocation == AppRoute.login ||
      //     state.matchedLocation == AppRoute.register;
      //
      // // Don't redirect while authentication state is being determined
      // if (authState.status == AuthStatus.loading) return null;
      //
      // // Redirect to login if user is not authenticated and not already on auth page
      // if (authState.status == AuthStatus.unauthenticated && !isLoggingIn) {
      //   return AppRoute.login;
      // }
      //
      // // Redirect to home if user is authenticated and trying to access auth pages
      // if (authState.status == AuthStatus.authenticated && isLoggingIn) {
      //   return AppRoute.mainScreen;
      // }
      //
      // // No redirect needed
      // return null;
    },
      routes: [
        GoRoute(
          path: AppRoute.loading,
          name: 'loading',
          builder: (context, state) => const LoadingPage(),
        ),
        GoRoute(
          path: AppRoute.mainScreen,
          name: 'mainScreen',
          builder: (context, state) => MainScreen(key: mainScreenKey,),
          // )
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
          // builder: (context, state) => const Scaffold(
          //   body: Center(child: Text("Select a user function")),
          // ), //
          // builder: (context, state) => const Scaffold(body: Center(child: Text("User Base"))),
          redirect: (context, state) => '/user/profile-choosing', // optional default redirect
          routes: [
            GoRoute(
              path: AppRoute.profileChoosing,
              name: 'profileChoosing',
              builder: (context, state) => const ProfileChoosingPage(),
            ),
            GoRoute(
              path: AppRoute.profileEdit,
              name: 'profileEdit',
              builder: (context, state) => const Placeholder(), // Replace with actual widget
            ),
            GoRoute(
              path: AppRoute.changePassword,
              name: 'changePassword',
              builder: (context, state) => const Placeholder(), // Replace with actual widget
            ),
            GoRoute(
              path: AppRoute.audioHome,
              name: 'audioHome',
              builder: (context, state) => const Placeholder(), // Replace with actual widget
            ),
            GoRoute(
              path: AppRoute.audioList,
              name: 'audioList',
              builder: (context, state) => const Placeholder(),
            ),
            GoRoute(
              path: AppRoute.audioPlaying,
              name: 'audioPlaying',
              builder: (context, state) => const Placeholder(),
            ),
            GoRoute(
              path: AppRoute.moodJournalWrite,
              name: 'moodJournalWrite',
              builder: (context, state) => const Placeholder(),
            ),
            GoRoute(
              path: AppRoute.moodJournalhistory,
              name: 'moodJournalhistory',
              builder: (context, state) => const Placeholder(),
            ),
            GoRoute(
              path: AppRoute.communityList,
              name: 'communityList',
              builder: (context, state) => const Placeholder(),
            ),
            GoRoute(
              path: AppRoute.communityGroupDetail,
              name: 'communityGroupDetail',
              builder: (context, state) => const Placeholder(),
            ),
            GoRoute(
              path: AppRoute.communityPostDetail,
              name: 'communityPostDetail',
              builder: (context, state) => const Placeholder(),
            ),
            GoRoute(
              path: AppRoute.communityMembers,
              name: 'communityMembers',
              builder: (context, state) => const Placeholder(),
            ),
            GoRoute(
              path: AppRoute.quizList,
              name: 'quizList',
              builder: (context, state) => const Placeholder(),
            ),
            GoRoute(
              path: AppRoute.quizTaking,
              name: 'quizTaking',
              builder: (context, state) => const Placeholder(),
            ),
            GoRoute(
              path: AppRoute.quizAttempts,
              name: 'quizAttempts',
              builder: (context, state) => const Placeholder(),
            ),
            GoRoute(
              path: AppRoute.aiSessions,
              name: 'aiSessions',
              builder: (context, state) => const Placeholder(),
            ),
            GoRoute(
              path: AppRoute.aiChat,
              name: 'aiChat',
              builder: (context, state) => const Placeholder(),
            ),
            GoRoute(
              path: AppRoute.goalManage,
              name: 'goalManage',
              builder: (context, state) => const Placeholder(),
            ),
            GoRoute(
              path: AppRoute.goalProgress,
              name: 'goalProgress',
              builder: (context, state) => const Placeholder(),
            ),
            GoRoute(
              path: AppRoute.goalList,
              name: 'goalList',
              builder: (context, state) => const Placeholder(),
            ),
            GoRoute(
              path: AppRoute.goalDetail,
              name: 'goalDetail',
              builder: (context, state) => const Placeholder(),
            ),
            GoRoute(
              path: AppRoute.subscription,
              name: 'subscription',
              builder: (context, state) => const Placeholder(),
            ),
            GoRoute(
              path: AppRoute.paymentTransactionHistory,
              name: 'paymentTransactionHistory',
              builder: (context, state) => const Placeholder(),
            ),
            GoRoute(
              path: AppRoute.help,
              name: 'help',
              builder: (context, state) => const Placeholder(),
            ),
          ],
        ),

        // === /admin/* Routes ===
        GoRoute(
          path: AppRoute.adminBase,
          name: 'adminBase',
          // builder: (context, state) => const Scaffold(
          //   body: Center(child: Text("Select a admin function")),
          // ),
          redirect: (context, state) => '/admin${AppRoute.adminMainScreen}', // optional
          routes: [
            GoRoute(
              path: AppRoute.adminMainScreen, //
              name: 'adminMainScreen',
              builder: (context, state) => const AdminMainScreen(),
            ),
            // GoRoute(
            //   path: 'settings', // becomes /admin/settings
            //   name: 'adminSettings',
            //   builder: (context, state) => const AdminHomePage(),
            // ),
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