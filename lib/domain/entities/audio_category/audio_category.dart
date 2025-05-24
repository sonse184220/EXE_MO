class AudioCategory {
  final String audioCategoryId;
  final String audioCategoryName;
  final List<SubAudioCategory> subAudioCategories;

  AudioCategory({
    required this.audioCategoryId,
    required this.audioCategoryName,
    required this.subAudioCategories,
  });

  factory AudioCategory.fromJson(Map<String, dynamic> json) {
    return AudioCategory(
      audioCategoryId: json['audioCategoryId'] as String,
      audioCategoryName: json['audioCategoryName'] as String,
      subAudioCategories: (json['subAudioCategories'] as List)
          .map((e) => SubAudioCategory.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audioCategoryId': audioCategoryId,
      'audioCategoryName': audioCategoryName,
      'subAudioCategories': subAudioCategories.map((e) => e.toJson()).toList(),
    };
  }
}

class SubAudioCategory {
  // Add fields here as needed

  SubAudioCategory();

  factory SubAudioCategory.fromJson(Map<String, dynamic> json) {
    // Parse subcategory fields here
    return SubAudioCategory();
  }

  Map<String, dynamic> toJson() {
    // Return subcategory fields here
    return {};
  }
}
