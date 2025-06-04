import 'package:inner_child_app/domain/entities/help/help_category_model.dart';

import '../../core/utils/result_model.dart';

abstract class IHelpCategoryRepository{
  Future<Result<List<HelpCategoryModel>>> getAllHelpCategory();
}