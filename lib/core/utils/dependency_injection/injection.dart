import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/auth_utils/auth_notifier.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';
import 'package:inner_child_app/core/utils/secure_storage_utils.dart';
import 'package:inner_child_app/data/datasources/remote/article_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/community_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/notification_api_service.dart';
import 'package:inner_child_app/data/repositories/article_repository.dart';
import 'package:inner_child_app/data/repositories/auth_repository.dart';
import 'package:inner_child_app/data/repositories/community_repository.dart';
import 'package:inner_child_app/data/repositories/notification_repository.dart';
import 'package:inner_child_app/domain/entities/auth/auth_status_enum.dart';
import 'package:inner_child_app/domain/repositories/i_article_repository.dart';
import 'package:inner_child_app/domain/repositories/i_auth_repository.dart';
import 'package:inner_child_app/domain/repositories/i_community_repository.dart';
import 'package:inner_child_app/domain/repositories/i_notification_repository.dart';
import 'package:inner_child_app/domain/usecases/article_usecase.dart';
import 'package:inner_child_app/domain/usecases/auth_usecase.dart';
import 'package:inner_child_app/domain/usecases/community_usecase.dart';
import 'package:inner_child_app/domain/usecases/notification_usecase.dart';
import '../../../data/datasources/remote/authentication_api_service.dart';
// ─────────────────────────────────────────────────────────────
// 🔐 Secure Storage
// ─────────────────────────────────────────────────────────────

final storageProvider = Provider((_) => SecureStorageUtils());


// ─────────────────────────────────────────────────────────────
// 🌐 Network & Dio
// ─────────────────────────────────────────────────────────────

final dioClientProvider = Provider<DioClient>(
      (ref) => DioClient(ref.read(storageProvider)),
);


// ─────────────────────────────────────────────────────────────
// 📡 API Services
// ─────────────────────────────────────────────────────────────

final authApiServiceProvider = Provider(
      (ref) => AuthApiService(ref.read(dioClientProvider)),
);

final articleApiServiceProvider = Provider(
      (ref) => ArticleApiService(ref.read(dioClientProvider)),
);

final notificationApiServiceProvider = Provider(
      (ref) => NotificationApiService(ref.read(dioClientProvider)),
);

final communityApiServiceProvider = Provider(
      (ref) => CommunityApiService(ref.read(dioClientProvider)),
);

// ─────────────────────────────────────────────────────────────
// 🧱 Repositories
// ─────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<IAuthRepository>(
      (ref) => AuthRepository(ref.read(authApiServiceProvider), ref.read(storageProvider)),
);

final articleRepositoryProvider = Provider<IArticleRepository>(
      (ref) => ArticleRepository(ref.read(articleApiServiceProvider)),
);

final notificationRepositoryProvider = Provider<INotificationRepository>(
      (ref) => NotificationRepository(ref.read(notificationApiServiceProvider)),
);

final communityRepositoryProvider = Provider<ICommunityRepository>(
      (ref) => CommunityRepository(ref.read(communityApiServiceProvider)),
);

// ─────────────────────────────────────────────────────────────
// ⚙️ Use Cases
// ─────────────────────────────────────────────────────────────

final authUseCaseProvider = Provider(
      (ref) => AuthUsecase(ref.read(authRepositoryProvider)),
);

final articleUseCaseProvider = Provider(
      (ref) => ArticleUseCase(ref.read(articleRepositoryProvider)),
);

final notificationUseCaseProvider = Provider(
      (ref) => NotificationUseCase(ref.read(notificationRepositoryProvider)),
);

final communityUseCaseProvider = Provider(
      (ref) => CommunityUsecase(ref.read(communityRepositoryProvider)),
);


// ─────────────────────────────────────────────────────────────
// 📍 State Notifiers
// ─────────────────────────────────────────────────────────────

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthStatus>(
      (ref) => AuthNotifier(ref.read(storageProvider)),
);


// ─────────────────────────────────────────────────────────────
// 🔁 Auth State Change Listener
// ─────────────────────────────────────────────────────────────

final authStateChangeProvider = Provider<AuthStateChangeNotifier>(
      (ref) => AuthStateChangeNotifier(authNotifierProvider, ref),
);
