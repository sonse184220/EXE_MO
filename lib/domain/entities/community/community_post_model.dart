import 'package:inner_child_app/domain/entities/community/community_post_comment_model.dart';

class CommunityPostModel {
  final String? communityPostId;
  final String? communityPostTitle;
  final String? communityPostContent;
  final List<String>? communityPostImageUrls;
  final String? communityPostStatus;
  final DateTime? communityPostCreatedAt;
  final String? communityGroupId;
  final String? userId;
  final String? userName;
  final String? profilePicture;
  final int? likeCount;
  final bool? isLikedByCurrentUser;
  final List<CommunityPostCommentModel>? comments;

  CommunityPostModel({
    this.communityPostId,
    this.communityPostTitle,
    this.communityPostContent,
    this.communityPostImageUrls,
    this.communityPostStatus,
    this.communityPostCreatedAt,
    this.communityGroupId,
    this.userId,
    this.userName,
    this.profilePicture,
    this.likeCount,
    this.isLikedByCurrentUser,
    this.comments,
  });

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    return CommunityPostModel(
      communityPostId: json['communityPostId'],
      communityPostTitle: json['communityPostTitle'],
      communityPostContent: json['communityPostContent'],
      communityPostImageUrls: json['communityPostImageUrls'] != null
          ? List<String>.from(json['communityPostImageUrls'])
          : [],
      communityPostStatus: json['communityPostStatus'],
      communityPostCreatedAt: json['communityPostCreatedAt'] != null
          ? DateTime.parse(json['communityPostCreatedAt'])
          : null,
      communityGroupId: json['communityGroupId'],
      userId: json['userId'],
      userName: json['userName'],
      profilePicture: json['profilePicture'],
      likeCount: json['likeCount'],
      isLikedByCurrentUser: json['isLikedByCurrentUser'],
      comments: json['comments'] != null
          ? (json['comments'] as List<dynamic>)
          .map((e) => CommunityPostCommentModel.fromJson(e))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'communityPostId': communityPostId,
      'communityPostTitle': communityPostTitle,
      'communityPostContent': communityPostContent,
      'communityPostImageUrls': communityPostImageUrls,
      'communityPostStatus': communityPostStatus,
      'communityPostCreatedAt': communityPostCreatedAt?.toIso8601String(),
      'communityGroupId': communityGroupId,
      'userId': userId,
      'userName': userName,
      'profilePicture': profilePicture,
      'likeCount': likeCount,
      'isLikedByCurrentUser': isLikedByCurrentUser,
      'comments': comments?.map((e) => e.toJson()).toList(),
    };
  }

  CommunityPostModel copyWith({
    String? communityPostId,
    String? communityPostTitle,
    String? communityPostContent,
    List<String>? communityPostImageUrls,
    String? communityPostStatus,
    DateTime? communityPostCreatedAt,
    String? communityGroupId,
    String? userId,
    String? userName,
    String? profilePicture,
    int? likeCount,
    bool? isLikedByCurrentUser,
    List<CommunityPostCommentModel>? comments,
  }) {
    return CommunityPostModel(
      communityPostId: communityPostId ?? this.communityPostId,
      communityPostTitle: communityPostTitle ?? this.communityPostTitle,
      communityPostContent: communityPostContent ?? this.communityPostContent,
      communityPostImageUrls: communityPostImageUrls ?? this.communityPostImageUrls,
      communityPostStatus: communityPostStatus ?? this.communityPostStatus,
      communityPostCreatedAt:
      communityPostCreatedAt ?? this.communityPostCreatedAt,
      communityGroupId: communityGroupId ?? this.communityGroupId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      profilePicture: profilePicture ?? this.profilePicture,
      likeCount: likeCount ?? this.likeCount,
      isLikedByCurrentUser:
      isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      comments: comments ?? this.comments,
    );
  }
}