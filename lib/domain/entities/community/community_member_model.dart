class CommunityMemberModel {
  final String? communityMemberId;
  final String? communityMemberStatus;
  final String? communityGroupId;
  final String? profileId;

  CommunityMemberModel({
    this.communityMemberId,
    this.communityMemberStatus,
    this.communityGroupId,
    this.profileId,
  });

  factory CommunityMemberModel.fromJson(Map<String, dynamic> json) {
    return CommunityMemberModel(
      communityMemberId: json['communityMemberId'],
      communityMemberStatus: json['communityMemberStatus'],
      communityGroupId: json['communityGroupId'],
      profileId: json['profileId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'communityMemberId': communityMemberId,
      'communityMemberStatus': communityMemberStatus,
      'communityGroupId': communityGroupId,
      'profileId': profileId,
    };
  }
}
