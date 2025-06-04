import 'help_model.dart';

class HelpCategoryModel {
  final String helpCategoryId;
  final String helpCategoryName;
  final List<HelpModel> helps;

  HelpCategoryModel({
    required this.helpCategoryId,
    required this.helpCategoryName,
    required this.helps,
  });
  factory HelpCategoryModel.fromJson(Map<String,dynamic> json){
    return HelpCategoryModel(
      helpCategoryId: json['helpCategoryId'] as String,
      helpCategoryName: json['helpCategoryName'] as String,
      helps: (json['helps'] as List<dynamic>)
          .map((e) => HelpModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'helpCategoryId': helpCategoryId,
      'helpCategoryName': helpCategoryName,
      'helps': helps.map((e) => e.toJson()).toList(),
    };
  }
}
