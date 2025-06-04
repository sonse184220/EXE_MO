import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/data/datasources/remote/help_category_api_service.dart';
import 'package:inner_child_app/domain/entities/help/help_category_model.dart';
import 'package:inner_child_app/domain/repositories/i_help_category_repository.dart';

class HelpCategoryRepository implements IHelpCategoryRepository{
  final HelpCategoryApiService _helpCategoryApiService;
  HelpCategoryRepository(this._helpCategoryApiService);
  @override
  Future<Result<List<HelpCategoryModel>>> getAllHelpCategory() async {
   try{
    final response = await _helpCategoryApiService.getAllHelpCategory();
    if (response.statusCode==200){
    final List<dynamic> data = response.data;
    final List<HelpCategoryModel> categories = data.map((json)=> HelpCategoryModel.fromJson(json)).toList();
    return Result.success(categories);
    }else{
      return Result.failure('Error: ${response.statusCode}');
    }
   }catch(e){
    return Result.failure(e.toString());
    }
  }

}