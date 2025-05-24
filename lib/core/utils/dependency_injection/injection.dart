import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/auth_utils/auth_notifier.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';
import 'package:inner_child_app/core/utils/secure_storage_utils.dart';
import 'package:inner_child_app/data/datasources/remote/article_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/audio_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/audio_category_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/audio_subcategory_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/chat_ai_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/community_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/notification_api_service.dart';
import 'package:inner_child_app/data/repositories/audio_category_repository.dart';
import 'package:inner_child_app/data/repositories/audio_repository.dart';
import 'package:inner_child_app/data/repositories/article_repository.dart';
import 'package:inner_child_app/data/repositories/audio_subcategory_repository.dart';
import 'package:inner_child_app/data/repositories/auth_repository.dart';
import 'package:inner_child_app/data/repositories/chat_ai_repository.dart';
import 'package:inner_child_app/data/repositories/community_repository.dart';
import 'package:inner_child_app/data/repositories/notification_repository.dart';
import 'package:inner_child_app/domain/entities/auth/auth_status_enum.dart';
import 'package:inner_child_app/domain/repositories/i_article_repository.dart';
import 'package:inner_child_app/domain/repositories/i_audio_category_repository.dart';
import 'package:inner_child_app/domain/repositories/i_audio_repository.dart';
import 'package:inner_child_app/domain/repositories/i_audio_subcategory_repository.dart';
import 'package:inner_child_app/domain/repositories/i_auth_repository.dart';
import 'package:inner_child_app/domain/repositories/i_chat_ai_repository.dart';
import 'package:inner_child_app/domain/repositories/i_community_repository.dart';
import 'package:inner_child_app/domain/repositories/i_notification_repository.dart';
import 'package:inner_child_app/domain/usecases/article_usecase.dart';
import 'package:inner_child_app/domain/usecases/audio_category_usecase.dart';
import 'package:inner_child_app/domain/usecases/audio_subcategory_usecase.dart';
import 'package:inner_child_app/domain/usecases/audio_usecase.dart';
import 'package:inner_child_app/domain/usecases/auth_usecase.dart';
import 'package:inner_child_app/domain/usecases/chat_ai_usecase.dart';
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

final audioApiServiceProvider = Provider(
      (ref) => AudioApiService(ref.read(dioClientProvider)),
);

final chatAiApiServiceProvider = Provider(
      (ref) => ChatAiApiService(ref.read(dioClientProvider)),
);

final audioCategoryAiApiServiceProvider = Provider(
      (ref) => AudioCategoryApiService(ref.read(dioClientProvider)),
);

final audioSubcategoryAiApiServiceProvider = Provider(
      (ref) => AudioSubcategoryApiService(ref.read(dioClientProvider)),
);

// ─────────────────────────────────────────────────────────────
// 🧱 Repositories
// ─────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<IAuthRepository>(
      (ref) => AuthRepository(ref.read(authApiServiceProvider), ref.read(storageProvider), ref.read(authNotifierProvider.notifier)),
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

final audioRepositoryProvider = Provider<IAudioRepository>(
      (ref) => AudioRepository(ref.read(audioApiServiceProvider)),
);

final chatAiRepositoryProvider = Provider<IChatAiRepository>(
      (ref) => ChatAiRepository(ref.read(chatAiApiServiceProvider)),
);

final audioCategoryRepositoryProvider = Provider<IAudioCategoryRepository>(
      (ref) => AudioCategoryRepository(ref.read(audioCategoryAiApiServiceProvider)),
);

final audioSubcategoryRepositoryProvider = Provider<IAudioSubcategoryRepository>(
      (ref) => AudioSubcategoryRepository(ref.read(audioSubcategoryAiApiServiceProvider)),
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

final audioUseCaseProvider = Provider(
      (ref) => AudioUseCase(ref.read(audioRepositoryProvider)),
);

final chatAiUseCaseProvider = Provider(
      (ref) => ChatAIUseCase(ref.read(chatAiRepositoryProvider)),
);

final audioCategoryUseCaseProvider = Provider(
      (ref) => AudioCategoryUsecase(ref.read(audioCategoryRepositoryProvider)),
);

final audioSubcategoryUseCaseProvider = Provider(
      (ref) => AudioSubcategoryUsecase(ref.read(audioSubcategoryRepositoryProvider)),
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
