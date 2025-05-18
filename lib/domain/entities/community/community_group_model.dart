import 'package:inner_child_app/domain/entities/community/community_member_model.dart';
import 'package:inner_child_app/domain/entities/community/community_post_model.dart';

class CommunityGroupModel {
  final String? communityGroupId;
  final String? communityName;
  final String? communityDescription;
  final DateTime? communityCreatedAt;
  final String? communityStatus;
  final List<CommunityMemberModel>? communityMembersDetail;
  final List<CommunityPostModel>? communityPostsDetail;

  CommunityGroupModel({
    this.communityGroupId,
    this.communityName,
    this.communityDescription,
    this.communityCreatedAt,
    this.communityStatus,
    this.communityMembersDetail,
    this.communityPostsDetail,
  });

  factory CommunityGroupModel.fromJson(Map<String, dynamic> json) {
    return CommunityGroupModel(
      communityGroupId: json['communityGroupId'],
      communityName: json['communityName'],
      communityDescription: json['communityDescription'],
      communityCreatedAt: json['communityCreatedAt'] != null
          ? DateTime.parse(json['communityCreatedAt'])
          : null,
      communityStatus: json['communityStatus'],
      communityMembersDetail: (json['communityMembersDetail'] as List?)
          ?.map((e) => CommunityMemberModel.fromJson(e))
          .toList(),
      communityPostsDetail: (json['communityPostsDetail'] as List?)
          ?.map((e) => CommunityPostModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'communityGroupId': communityGroupId,
      'communityName': communityName,
      'communityDescription': communityDescription,
      'communityCreatedAt': communityCreatedAt?.toIso8601String(),
      'communityStatus': communityStatus,
      'communityMembersDetail':
      communityMembersDetail?.map((e) => e.toJson()).toList(),
      'communityPostsDetail':
      communityPostsDetail?.map((e) => e.toJson()).toList(),
    };
  }
}
