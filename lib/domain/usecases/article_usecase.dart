import 'package:inner_child_app/domain/repositories/i_article_repository.dart';

class ArticleUseCase {
 final IArticleRepository iArticleRepository;

 ArticleUseCase(this.iArticleRepository);
}