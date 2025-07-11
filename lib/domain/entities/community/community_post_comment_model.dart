class CommunityPostCommentModel {
  final String? commentId;
  final String? content;
  final DateTime? createdAt;
  final String? replyToCommentId;
  final String? userId;
  final String? userName;
  final String? profilePicture;
  final int? likeCount;
  final bool? isLikedByCurrentUser;
  final List<String>? commentImages;
  final List<CommunityPostCommentModel>? comments;

  CommunityPostCommentModel({
    this.commentId,
    this.content,
    this.createdAt,
    this.replyToCommentId,
    this.userId,
    this.userName,
    this.profilePicture,
    this.likeCount,
    this.isLikedByCurrentUser,
    this.commentImages,
    this.comments,
  });

  factory CommunityPostCommentModel.fromJson(Map<String, dynamic> json) {
    return CommunityPostCommentModel(
      commentId: json['commentId'],
      content: json['content'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      replyToCommentId: json['replyToCommentId'],
      userId: json['userId'],
      userName: json['userName'],
      profilePicture: json['profilePicture'],
      likeCount: json['likeCount'],
      isLikedByCurrentUser: json['isLikedByCurrentUser'],
      commentImages: json['commentImages'] != null
          ? List<String>.from(json['commentImages'])
          : [],
      comments: json['comments'] != null
          ? (json['comments'] as List<dynamic>)
          .map((e) => CommunityPostCommentModel.fromJson(e))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'content': content,
      'createdAt': createdAt?.toIso8601String(),
      'replyToCommentId': replyToCommentId,
      'userId': userId,
      'userName': userName,
      'profilePicture': profilePicture,
      'likeCount': likeCount,
      'isLikedByCurrentUser': isLikedByCurrentUser,
      'commentImageUrls': commentImages,
      'comments': comments?.map((e) => e.toJson()).toList(),
    };
  }

  CommunityPostCommentModel copyWith({
    String? commentId,
    String? content,
    DateTime? createdAt,
    String? replyToCommentId,
    String? userId,
    String? userName,
    String? profilePicture,
    int? likeCount,
    bool? isLikedByCurrentUser,
    List<String>? commentImages,
    List<CommunityPostCommentModel>? comments,
  }) {
    return CommunityPostCommentModel(
      commentId: commentId ?? this.commentId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      replyToCommentId: replyToCommentId ?? this.replyToCommentId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      profilePicture: profilePicture ?? this.profilePicture,
      likeCount: likeCount ?? this.likeCount,
      isLikedByCurrentUser:
      isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      commentImages: commentImages ?? this.commentImages,
      comments: comments ?? this.comments,
    );
  }
}