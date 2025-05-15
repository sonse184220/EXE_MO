import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/article/article_model.dart';

abstract class IArticleRepository {
  Future<Result<List<ArticleModel>>> getAllArticles();

  Future<Result<ArticleModel>> getArticleById(String id);
}
