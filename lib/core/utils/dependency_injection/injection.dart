import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/auth_utils/auth_notifier.dart';
import 'package:inner_child_app/core/utils/dio_instance.dart';
import 'package:inner_child_app/core/utils/global_signalR_ui_handler.dart';
import 'package:inner_child_app/core/utils/secure_storage_utils.dart';
import 'package:inner_child_app/core/utils/signalr_service.dart';
import 'package:inner_child_app/data/datasources/remote/article_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/audio_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/audio_category_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/audio_subcategory_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/chat_ai_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/community_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/goal_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/help_category_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/mood_journal_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/mood_journal_type_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/notification_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/payment_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/quiz_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/quiz_attempt_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/quiz_category_api_service.dart';
import 'package:inner_child_app/data/datasources/remote/subscription_api_service.dart';
import 'package:inner_child_app/data/repositories/audio_category_repository.dart';
import 'package:inner_child_app/data/repositories/audio_repository.dart';
import 'package:inner_child_app/data/repositories/article_repository.dart';
import 'package:inner_child_app/data/repositories/audio_subcategory_repository.dart';
import 'package:inner_child_app/data/repositories/auth_repository.dart';
import 'package:inner_child_app/data/repositories/chat_ai_repository.dart';
import 'package:inner_child_app/data/repositories/community_repository.dart';
import 'package:inner_child_app/data/repositories/goal_repository.dart';
import 'package:inner_child_app/data/repositories/help_category_repository.dart';
import 'package:inner_child_app/data/repositories/mood_journal_repository.dart';
import 'package:inner_child_app/data/repositories/mood_journal_type_repository.dart';
import 'package:inner_child_app/data/repositories/notification_repository.dart';
import 'package:inner_child_app/data/repositories/payment_repository.dart';
import 'package:inner_child_app/data/repositories/quiz_attempt_repository.dart';
import 'package:inner_child_app/data/repositories/quiz_category_repository.dart';
import 'package:inner_child_app/data/repositories/quiz_repository.dart';
import 'package:inner_child_app/data/repositories/subscription_repository.dart';
import 'package:inner_child_app/domain/entities/auth/auth_state.dart';
import 'package:inner_child_app/domain/repositories/i_article_repository.dart';
import 'package:inner_child_app/domain/repositories/i_audio_category_repository.dart';
import 'package:inner_child_app/domain/repositories/i_audio_repository.dart';
import 'package:inner_child_app/domain/repositories/i_audio_subcategory_repository.dart';
import 'package:inner_child_app/domain/repositories/i_auth_repository.dart';
import 'package:inner_child_app/domain/repositories/i_chat_ai_repository.dart';
import 'package:inner_child_app/domain/repositories/i_community_repository.dart';
import 'package:inner_child_app/domain/repositories/i_goal_repository.dart';
import 'package:inner_child_app/domain/repositories/i_help_category_repository.dart';
import 'package:inner_child_app/domain/repositories/i_mood_journal_repository.dart';
import 'package:inner_child_app/domain/repositories/i_mood_journal_type_repository.dart';
import 'package:inner_child_app/domain/repositories/i_notification_repository.dart';
import 'package:inner_child_app/domain/repositories/i_payment_repository.dart';
import 'package:inner_child_app/domain/repositories/i_quiz_attempt_repository.dart';
import 'package:inner_child_app/domain/repositories/i_quiz_category_repository.dart';
import 'package:inner_child_app/domain/repositories/i_quiz_repository.dart';
import 'package:inner_child_app/domain/repositories/i_subscription_repository.dart';
import 'package:inner_child_app/domain/usecases/article_usecase.dart';
import 'package:inner_child_app/domain/usecases/audio_category_usecase.dart';
import 'package:inner_child_app/domain/usecases/audio_subcategory_usecase.dart';
import 'package:inner_child_app/domain/usecases/audio_usecase.dart';
import 'package:inner_child_app/domain/usecases/auth_usecase.dart';
import 'package:inner_child_app/domain/usecases/chat_ai_usecase.dart';
import 'package:inner_child_app/domain/usecases/community_usecase.dart';
import 'package:inner_child_app/domain/usecases/goal_usecase.dart';
import 'package:inner_child_app/domain/usecases/help_category_usecase.dart';
import 'package:inner_child_app/domain/usecases/mood_journal_type_usecase.dart';
import 'package:inner_child_app/domain/usecases/mood_journal_usecase.dart';
import 'package:inner_child_app/domain/usecases/notification_usecase.dart';
import 'package:inner_child_app/domain/usecases/payment_usecase.dart';
import 'package:inner_child_app/domain/usecases/quiz_attempt_usecase.dart';
import 'package:inner_child_app/domain/usecases/quiz_category_usecase.dart';
import 'package:inner_child_app/domain/usecases/quiz_usecase.dart';
import 'package:inner_child_app/domain/usecases/subscription_usecase.dart';
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

final quizApiServiceProvider = Provider(
  (ref) => QuizApiService(ref.read(dioClientProvider)),
);

final goalApiServiceProvider = Provider(
  (ref) => GoalApiService(ref.read(dioClientProvider)),
);

final moodJournalApiServiceProvider = Provider(
  (ref) => MoodJournalApiService(ref.read(dioClientProvider)),
);

final moodJournalTypeApiServiceProvider = Provider(
  (ref) => MoodJournalTypeApiService(ref.read(dioClientProvider)),
);

final quizCategoryApiServiceProvider = Provider(
  (ref) => QuizCategoryApiService(ref.read(dioClientProvider)),
);

final quizAttemptApiServiceProvider = Provider(
  (ref) => QuizAttemptApiService(ref.read(dioClientProvider)),
);

final helpCategoryApiServiceProvider = Provider(
  (ref) => HelpCategoryApiService(ref.read(dioClientProvider)),
);

final subscriptionApiServiceProvider = Provider(
      (ref) => SubscriptionApiService(ref.read(dioClientProvider)),
);

final paymentApiServiceProvider = Provider(
      (ref) => PaymentApiService(ref.read(dioClientProvider)),
);

// ─────────────────────────────────────────────────────────────
// 🧱 Repositories
// ─────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<IAuthRepository>(
  (ref) => AuthRepository(
    ref.read(authApiServiceProvider),
    ref.read(storageProvider),
    ref.read(authNotifierProvider.notifier),
  ),
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

final audioSubcategoryRepositoryProvider =
    Provider<IAudioSubcategoryRepository>(
      (ref) => AudioSubcategoryRepository(
        ref.read(audioSubcategoryAiApiServiceProvider),
      ),
    );

final quizRepositoryProvider = Provider<IQuizRepository>(
  (ref) => QuizRepository(ref.read(quizApiServiceProvider)),
);

final goalRepositoryProvider = Provider<IGoalRepository>(
  (ref) => GoalRepository(ref.read(goalApiServiceProvider)),
);

final moodJournalRepositoryProvider = Provider<IMoodJournalRepository>(
  (ref) => MoodJournalRepository(ref.read(moodJournalApiServiceProvider)),
);

final moodJournalTypeRepositoryProvider = Provider<IMoodJournalTypeRepository>(
  (ref) =>
      MoodJournalTypeRepository(ref.read(moodJournalTypeApiServiceProvider)),
);

final quizCategoryRepositoryProvider = Provider<IQuizCategoryRepository>(
  (ref) => QuizCategoryRepository(ref.read(quizCategoryApiServiceProvider)),
);

final quizAttemptRepositoryProvider = Provider<IQuizAttemptRepository>(
  (ref) => QuizAttemptRepository(ref.read(quizAttemptApiServiceProvider)),
);

final helpCategoryRepositoryProvider = Provider<IHelpCategoryRepository>(
    (ref)=> HelpCategoryRepository(ref.read(helpCategoryApiServiceProvider)),
);

final subscriptionRepositoryProvider = Provider<ISubscriptionRepository>(
      (ref)=> SubscriptionRepository(ref.read(subscriptionApiServiceProvider)),
);

final paymentRepositoryProvider = Provider<IPaymentRepository>(
      (ref)=> PaymentRepository(ref.read(paymentApiServiceProvider)),
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
  (ref) =>
      AudioSubcategoryUsecase(ref.read(audioSubcategoryRepositoryProvider)),
);

final quizUseCaseProvider = Provider(
  (ref) => QuizUsecase(ref.read(quizRepositoryProvider)),
);

final goalUseCaseProvider = Provider(
  (ref) => GoalUsecase(ref.read(goalRepositoryProvider)),
);

final moodJournalUseCaseProvider = Provider(
  (ref) => MoodJournalUsecase(ref.read(moodJournalRepositoryProvider)),
);

final moodJournalTypeUseCaseProvider = Provider(
  (ref) => MoodJournalTypeUsecase(ref.read(moodJournalTypeRepositoryProvider)),
);

final quizCategoryUseCaseProvider = Provider(
  (ref) => QuizCategoryUsecase(ref.read(quizCategoryRepositoryProvider)),
);

final quizAttemptUseCaseProvider = Provider(
  (ref) => QuizAttemptUsecase(ref.read(quizAttemptRepositoryProvider)),
);

final helpCategoryUseCaseProvider = Provider(
    (ref)=>HelpCategoryUseCase(ref.read(helpCategoryRepositoryProvider))
);

final subscriptionUseCaseProvider = Provider(
        (ref)=>SubscriptionUsecase(ref.read(subscriptionRepositoryProvider))
);

final paymentUseCaseProvider = Provider(
        (ref)=>PaymentUsecase(ref.read(paymentRepositoryProvider))
);

// ─────────────────────────────────────────────────────────────
// 📍 State Notifiers
// ─────────────────────────────────────────────────────────────

// final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
//   (ref) => AuthNotifier(ref.read(storageProvider)),
// );

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.read(storageProvider);
  final signalRService = ref.read(signalRServiceProvider);
  final messagesNotifier = ref.read(signalRMessagesProvider.notifier);

  return AuthNotifier(storage, signalRService, messagesNotifier);
});

// ─────────────────────────────────────────────────────────────
// 🔁 Auth State Change Listener
// ─────────────────────────────────────────────────────────────

final authStateChangeProvider = Provider<AuthStateChangeNotifier>(
  (ref) => AuthStateChangeNotifier(authNotifierProvider, ref),
);

// ─────────────────────────────────────────────────────────────
// 📍 SignalR Providers
// ─────────────────────────────────────────────────────────────
final signalRServiceProvider = Provider<SignalRService>((ref) =>
  SignalRService()
);

final signalRMessagesProvider = StateNotifierProvider<SignalRMessagesNotifier, List<SignalRMessage>>((ref) {
  return SignalRMessagesNotifier();
});