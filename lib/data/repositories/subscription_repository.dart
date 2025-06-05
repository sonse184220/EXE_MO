import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/subscription_api_service.dart';
import 'package:inner_child_app/domain/entities/subscription/subscription_model.dart';
import 'package:inner_child_app/domain/repositories/i_subscription_repository.dart';

class SubscriptionRepository implements ISubscriptionRepository {
  final SubscriptionApiService _subscriptionApiService;

  SubscriptionRepository(this._subscriptionApiService);

  @override
  Future<Result<List<SubscriptionModel>>> getAllSubscriptions() async {
    try {
          final response = await _subscriptionApiService.getAllSubscriptions();

          if (response.statusCode == 200) {
            final data = response.data;

            final subscriptions =
            (data as List<dynamic>)
                .map((e) => SubscriptionModel.fromJson(e))
                .toList();
            return Result.success(subscriptions);
          }
          return Result.failure('Fail to get all subscriptions. Please try again');
        } catch (e) {
          return Result.failure('Get all subscriptions error: $e');
        }
  }

  // @override
  // Future<Result<List<QuizModel>>> getAllQuizzes() async {
  //   try {
  //     final response = await _quizApiService.getAllQuizzes();
  //
  //     if (response.statusCode == 200) {
  //       final data = response.data;
  //
  //       final quizzes =
  //       (data as List<dynamic>)
  //           .map((e) => QuizModel.fromJson(e))
  //           .toList();
  //       return Result.success(quizzes);
  //     }
  //     return Result.failure('Fail to get all quizzes. Please try again');
  //   } catch (e) {
  //     return Result.failure('Get all quizzes error: $e');
  //   }
  // }
  //
  // @override
  // Future<Result<QuizModel>> getQuizDetail(String quizId) async {
  //   try {
  //     final response = await _quizApiService.getQuizDetail(quizId);
  //
  //     if (response.statusCode == 200) {
  //       final data = response.data;
  //
  //       final quiz = QuizModel.fromJson(data);
  //       return Result.success(quiz);
  //     }
  //     return Result.failure('Fail to get quiz detail. Please try again');
  //   } catch (e) {
  //     return Result.failure('Get quiz detail error: $e');
  //   }
  // }
  //
  // @override
  // Future<Result<String>> submitQuiz(String quizId, List<QuizUserAnswerModel> data) async {
  //   try {
  //     final response = await _quizApiService.submitQuiz(quizId, data);
  //
  //     if (response.statusCode == 201) {
  //       final data = response.data;
  //
  //       // final quiz = QuizModel.fromJson(data);
  //       return Result.success('Quiz submited successfully');
  //     }
  //     return Result.failure('Fail to submit quiz. Please try again');
  //   } catch (e) {
  //     return Result.failure('Submit quiz error: $e');
  //   }
  // }
}