class CommunityPostModel {
  final String? communityPostId;
  final String? communityPostTitle;
  final String? communityPostContent;
  final String? communityPostImageUrl;
  final String? communityPostStatus;
  final DateTime? communityPostCreatedAt;
  final String? communityGroupId;
  final String? profileId;

  CommunityPostModel({
    this.communityPostId,
    this.communityPostTitle,
    this.communityPostContent,
    this.communityPostImageUrl,
    this.communityPostStatus,
    this.communityPostCreatedAt,
    this.communityGroupId,
    this.profileId,
  });

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    return CommunityPostModel(
      communityPostId: json['communityPostId'],
      communityPostTitle: json['communityPostTitle'],
      communityPostContent: json['communityPostContent'],
      communityPostImageUrl: json['communityPostImageUrl'],
      communityPostStatus: json['communityPostStatus'],
      communityPostCreatedAt: json['communityPostCreatedAt'] != null
          ? DateTime.parse(json['communityPostCreatedAt'])
          : null,
      communityGroupId: json['communityGroupId'],
      profileId: json['profileId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'communityPostId': communityPostId,
      'communityPostTitle': communityPostTitle,
      'communityPostContent': communityPostContent,
      'communityPostImageUrl': communityPostImageUrl,
      'communityPostStatus': communityPostStatus,
      'communityPostCreatedAt': communityPostCreatedAt?.toIso8601String(),
      'communityGroupId': communityGroupId,
      'profileId': profileId,
    };
  }
}
