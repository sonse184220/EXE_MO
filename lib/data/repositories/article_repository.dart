import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/article_api_service.dart';
import 'package:inner_child_app/domain/repositories/i_article_repository.dart';

class ArticleRepository implements IArticleRepository {
  final ArticleApiService apiService;

  ArticleRepository(this.apiService);

  @override
  Future<Result<void>> getAllArticle() {
    // TODO: implement getAllArticle
    throw UnimplementedError();
  }


}