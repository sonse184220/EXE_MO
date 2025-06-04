class AudioModel {
  final String? audioId;
  final String? audioTitle;
  final String? audioUrl;
  final String? audioThumbnail;
  final DateTime? audioCreatedAt;
  final bool? audioIsPremium;
  final String? audioStatus;
  final String? subAudioCategoryId;
  final String? subAudioCategoryName;

  AudioModel({
    this.audioId,
    this.audioTitle,
    this.audioUrl,
    this.audioThumbnail,
    this.audioCreatedAt,
    this.audioIsPremium,
    this.audioStatus,
    this.subAudioCategoryId,
    this.subAudioCategoryName,
  });

  factory AudioModel.fromJson(Map<String, dynamic> json) {
    return AudioModel(
      audioId: json['audioId'] as String?,
      audioTitle: json['audioTitle'] as String?,
      audioUrl: json['audioUrl'] as String?,
      audioThumbnail: json['audioThumbnail'] as String?,
      audioCreatedAt: json['audioCreatedAt'] != null
          ? DateTime.tryParse(json['audioCreatedAt'])
          : null,
      audioIsPremium: json['audioIsPremium'] as bool?,
      audioStatus: json['audioStatus'] as String?,
      subAudioCategoryId: json['subAudioCategoryId'] as String?,
      subAudioCategoryName: json['subAudioCategoryName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audioId': audioId,
      'audioTitle': audioTitle,
      'audioUrl': audioUrl,
      'audioThumbnail': audioThumbnail,
      'audioCreatedAt': audioCreatedAt?.toIso8601String(),
      'audioIsPremium': audioIsPremium,
      'audioStatus': audioStatus,
      'subAudioCategoryId': subAudioCategoryId,
    };
  }
}
