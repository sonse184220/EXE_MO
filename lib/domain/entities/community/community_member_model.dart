class CommunityMemberModel {
  final String? communityMemberId;
  final String? communityMemberStatus;
  final String? communityGroupId;
  final String? profileId;
  final String? userId;
  final String? userName;
  final String? profilePicture;

  CommunityMemberModel({
    this.communityMemberId,
    this.communityMemberStatus,
    this.communityGroupId,
    this.profileId,
    this.userId,
    this.userName,
    this.profilePicture,
  });

  factory CommunityMemberModel.fromJson(Map<String, dynamic> json) {
    return CommunityMemberModel(
      communityMemberId: json['communityMemberId'],
      communityMemberStatus: json['communityMemberStatus'],
      communityGroupId: json['communityGroupId'],
      profileId: json['profileId'],
      userId: json['userId'],
      userName: json['userName'],
      profilePicture: json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'communityMemberId': communityMemberId,
      'communityMemberStatus': communityMemberStatus,
      'communityGroupId': communityGroupId,
      'profileId': profileId,
      'userId': userId,
      'userName': userName,
      'profilePicture': profilePicture,
    };
  }
}