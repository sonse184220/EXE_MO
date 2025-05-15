import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/article_api_service.dart';
import 'package:inner_child_app/domain/entities/article/article_model.dart';
import 'package:inner_child_app/domain/repositories/i_article_repository.dart';

class ArticleRepository implements IArticleRepository {
  final ArticleApiService apiService;

  ArticleRepository(this.apiService);

  @override
  Future<Result<List<ArticleModel>>> getAllArticles() async {
    try {
      final response = await apiService.getAllArticles();

      if (response.statusCode == 200) {
        final data = response.data;

        final articles =
            (data as List<dynamic>)
                .map((e) => ArticleModel.fromJson(e))
                .toList();

        return Result.success(articles);
        // final articleList = jsonEncode(
        //   articles.map((p) => p.toJson()).toList(),
        // );
      } else {
        throw Exception(
          'Fetch all article list failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      return Result.failure('Fetch all article error: $e');
    }
  }

  @override
  Future<Result<ArticleModel>> getArticleById(String id) async {
    try {
      final response = await apiService.getArticleById(id);

      if (response.statusCode == 200) {
        final data = response.data;

        final article = ArticleModel.fromJson(data);

        return Result.success(article);
        // final articleList = jsonEncode(
        //   articles.map((p) => p.toJson()).toList(),
        // );
      } else {
        throw Exception('Fetch article by id failed: ${response.statusCode}');
      }
    } catch (e) {
      return Result.failure('Fetch article by id error: $e');
    }
  }
}
