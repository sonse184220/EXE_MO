class SubAudioCategoryModel {
  final String subAudioCategoryId;
  final String subAudioCategoryName;
  final String audioCategoryId;
  final String audioCategoryName;

  SubAudioCategoryModel({
    required this.subAudioCategoryId,
    required this.subAudioCategoryName,
    required this.audioCategoryId,
    required this.audioCategoryName,
  });

  factory SubAudioCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubAudioCategoryModel(
      subAudioCategoryId: json['subAudioCategoryId'] as String,
      subAudioCategoryName: json['subAudioCategoryName'] as String,
      audioCategoryId: json['audioCategoryId'] as String,
      audioCategoryName: json['audioCategoryName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subAudioCategoryId': subAudioCategoryId,
      'subAudioCategoryName': subAudioCategoryName,
      'audioCategoryId': audioCategoryId,
      'audioCategoryName': audioCategoryName,
    };
  }
}
