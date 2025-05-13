import 'package:inner_child_app/core/utils/result_model.dart';

abstract class IArticleRepository {
  Future<Result<void>> getAllArticle();
}