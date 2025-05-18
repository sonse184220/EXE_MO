import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/article/article_model.dart';
import 'package:inner_child_app/domain/repositories/i_article_repository.dart';

class ArticleUseCase {
 final IArticleRepository iArticleRepository;

 ArticleUseCase(this.iArticleRepository);

 Future<Result<List<ArticleModel>>> getAllArticles() {
  return iArticleRepository.getAllArticles();
 }

 Future<Result<ArticleModel>> getArticleById(String id) {
  return iArticleRepository.getArticleById(id);
 }
}