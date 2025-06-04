import 'package:inner_child_app/domain/entities/help/help_category_model.dart';
import 'package:inner_child_app/domain/repositories/i_help_category_repository.dart';

import '../../core/utils/result_model.dart';

class HelpCategoryUseCase{
  final IHelpCategoryRepository _iHelpCategoryRepository;
  HelpCategoryUseCase(this._iHelpCategoryRepository);
  Future<Result<List<HelpCategoryModel>>> getAllHelpCategory() {
    return _iHelpCategoryRepository.getAllHelpCategory();
  }
}