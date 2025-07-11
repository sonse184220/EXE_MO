import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/domain/entities/community/community_member_model.dart';
import 'package:inner_child_app/domain/entities/auth/user_detail_model.dart';
import 'package:inner_child_app/domain/usecases/auth_usecase.dart';
import 'package:inner_child_app/domain/usecases/community_usecase.dart';

class CommunityMembersPage extends ConsumerStatefulWidget {
  final String communityId;
  final String communityName;

  const CommunityMembersPage({
    super.key,
    required this.communityId,
    required this.communityName,
  });

  @override
  ConsumerState<CommunityMembersPage> createState() =>
      _CommunityMembersPageState();
}

class _CommunityMembersPageState extends ConsumerState<CommunityMembersPage> {
  late final CommunityUsecase _communityUsecase;
  late final AuthUsecase _authUsecase;

  List<CommunityMemberModel> members = [];
  bool isLoading = true;
  String? error;

  // Beautiful color scheme based on ICE CREAM harmony
  static const Color primaryIceCream = Color(0xFFF49AA2);
  static const Color primaryIceCreamDark = Color(0xFFE37083);
  static const Color primaryIceCreamLight = Color(0xFFFCE4E6);
  static const Color accentPapaya = Color(0xFFFFB876);
  static const Color accentMeadow = Color(0xFFA8BF8A);
  static const Color accentSpringSky = Color(0xFF89B7C2);
  static const Color accentSunshine = Color(0xFFFFCB7C);
  static const Color textDark = Color(0xFF2C2C2C);
  static const Color textMedium = Color(0xFF5A5A5A);
  static const Color textLight = Color(0xFF8A8A8A);
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color shadowColor = Color(0x1A000000);

  @override
  void initState() {
    super.initState();
    _communityUsecase = ref.read(communityUseCaseProvider);
    _authUsecase = ref.read(authUseCaseProvider);
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await _communityUsecase.getCommunityGroupById(
        widget.communityId,
      );

      if (result.isSuccess) {
        if(result.data?.communityMembersDetail == null) {throw Exception('Fail to fetch community member!');}
        setState(() {
          members = result.data?.communityMembersDetail ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          error = result.error ?? 'Failed to fetch members';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _showMemberDetails(String userId) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MemberDetailModal(
        userId: userId,
        authUsecase: _authUsecase,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double toolbarHeight = 80;
    final double iconBoxSize = toolbarHeight * 0.5; // e.g. 40 if toolbar is 80

    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundLight,
        appBar: AppBar(
          toolbarHeight: toolbarHeight,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryIceCream,
                  primaryIceCreamDark,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryIceCream.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
          leadingWidth: iconBoxSize + 24, // padding left + box size
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Material(
                  color: Colors.white.withOpacity(0.2),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: SizedBox(
                      width: iconBoxSize,
                      height: iconBoxSize,
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: iconBoxSize * 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.communityName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: toolbarHeight * 0.25,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Members',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: toolbarHeight * 0.175,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            SizedBox(width: iconBoxSize + 24),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }




  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                color: primaryIceCream,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading members...',
              style: TextStyle(
                color: textMedium,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return _buildErrorState();
    }

    if (members.isEmpty) {
      return _buildEmptyState();
    }

    return _buildMembersList();
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryIceCreamLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: primaryIceCreamDark,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                color: textDark,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error ?? 'Unknown error occurred',
              style: TextStyle(
                fontSize: 14,
                color: textMedium,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchMembers,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryIceCream,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: primaryIceCream.withOpacity(0.3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh_rounded, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Try Again',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accentMeadow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 64,
                color: accentMeadow,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No members yet',
              style: TextStyle(
                fontSize: 20,
                color: textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This community is waiting for its first members to join',
              style: TextStyle(
                fontSize: 14,
                color: textMedium,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersList() {
    return Column(
      children: [
        // Members count header
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentSpringSky.withOpacity(0.1),
                accentMeadow.withOpacity(0.1),
              ],
            ),
            // borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: accentSpringSky.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentSpringSky,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${members.length} Members',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                  Text(
                    'Active community members',
                    style: TextStyle(
                      fontSize: 14,
                      color: textMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Members list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return _buildMemberCard(member);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(CommunityMemberModel member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (member.userId != null) {
              _showMemberDetails(member.userId!);
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Profile picture with gradient border
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryIceCream, primaryIceCreamDark],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: member.profilePicture != null
                        ? Colors.transparent
                        : primaryIceCreamLight,
                    backgroundImage: member.profilePicture != null
                        ? NetworkImage(member.profilePicture!)
                        : null,
                    child: member.profilePicture == null
                        ? Text(
                      (member.userName ?? 'U')[0].toUpperCase(),
                      style: TextStyle(
                        color: primaryIceCreamDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                // Member info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.userName ?? 'Unknown User',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getMemberStatusColor(member.communityMemberStatus).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getMemberStatusText(member.communityMemberStatus),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getMemberStatusColor(member.communityMemberStatus),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow with subtle background
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: textLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMemberStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'admin':
        return 'Admin';
      case 'moderator':
        return 'Moderator';
      case 'active':
        return 'Active Member';
      default:
        return 'Member';
    }
  }

  Color _getMemberStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'admin':
        return primaryIceCreamDark;
      case 'moderator':
        return accentPapaya;
      case 'active':
        return accentMeadow;
      default:
        return textMedium;
    }
  }
}

class MemberDetailModal extends StatefulWidget {
  final String userId;
  final AuthUsecase authUsecase;

  const MemberDetailModal({
    super.key,
    required this.userId,
    required this.authUsecase,
  });

  @override
  State<MemberDetailModal> createState() => _MemberDetailModalState();
}

class _MemberDetailModalState extends State<MemberDetailModal> {
  UserDetailModel? userDetail;
  bool isLoading = true;
  String? error;

  // Beautiful color scheme
  static const Color primaryIceCream = Color(0xFFF49AA2);
  static const Color primaryIceCreamDark = Color(0xFFE37083);
  static const Color primaryIceCreamLight = Color(0xFFFCE4E6);
  static const Color accentPapaya = Color(0xFFFFB876);
  static const Color accentMeadow = Color(0xFFA8BF8A);
  static const Color accentSpringSky = Color(0xFF89B7C2);
  static const Color textDark = Color(0xFF2C2C2C);
  static const Color textMedium = Color(0xFF5A5A5A);
  static const Color textLight = Color(0xFF8A8A8A);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color shadowColor = Color(0x1A000000);
  static const Color primaryIceCreamLightest = Color(0xFFFCEEEF);

  @override
  void initState() {
    super.initState();
    _fetchUserDetail();
  }

  Future<void> _fetchUserDetail() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await widget.authUsecase.getUserDetail(widget.userId);

      if (result.isSuccess) {
        setState(() {
          userDetail = result.data;
          isLoading = false;
        });
      } else {
        setState(() {
          error = result.error ?? 'Failed to fetch user details';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery
          .of(context)
          .size
          .height * 0.8,
      decoration: BoxDecoration(
        color: primaryIceCreamLightest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 16),
            height: 4,
            width: 50,
            decoration: BoxDecoration(
              color: textLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with gradient
          Container(
            // margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            // decoration: BoxDecoration(
            //   gradient: LinearGradient(
            //     begin: Alignment.topLeft,
            //     end: Alignment.bottomRight,
            //     colors: [
            //       primaryIceCream.withOpacity(0.1),
            //       primaryIceCreamDark.withOpacity(0.1),
            //     ],
            //   ),
            //   borderRadius: BorderRadius.circular(20),
            //   border: Border.all(
            //     color: primaryIceCream.withOpacity(0.3),
            //     width: 1,
            //   ),
            // ),
            child: Row(
              children: [
                Icon(
                  Icons.person_rounded,
                  color: primaryIceCream,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Member Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: textLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: textMedium),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryIceCreamLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: CircularProgressIndicator(
                color: primaryIceCream,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading user details...',
              style: TextStyle(
                color: textMedium,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return _buildErrorContent();
    }

    if (userDetail == null) {
      return _buildEmptyContent();
    }

    return _buildUserDetails();
  }

  Widget _buildErrorContent() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: primaryIceCreamDark.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryIceCreamLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: primaryIceCreamDark,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load details',
              style: TextStyle(
                fontSize: 18,
                color: textDark,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error ?? 'Unknown error occurred',
              style: TextStyle(
                fontSize: 14,
                color: textMedium,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchUserDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryIceCream,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh_rounded, size: 20),
                  const SizedBox(width: 8),
                  const Text('Retry'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContent() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: accentMeadow.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accentMeadow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.person_outline_rounded,
                size: 64,
                color: accentMeadow,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No user details found',
              style: TextStyle(
                fontSize: 18,
                color: textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Picture with enhanced design
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryIceCream, primaryIceCreamDark],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: CircleAvatar(
              radius: 56,
              backgroundColor: userDetail!.profilePicture != null
                  ? Colors.transparent
                  : primaryIceCreamLight,
              backgroundImage: userDetail!.profilePicture != null
                  ? NetworkImage(userDetail!.profilePicture!)
                  : null,
              child: userDetail!.profilePicture == null
                  ? Text(
                (userDetail!.fullName ?? 'U')[0].toUpperCase(),
                style: TextStyle(
                  color: primaryIceCreamDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 36,
                ),
              )
                  : null,
            ),
          ),

          const SizedBox(height: 24),

          // User name with enhanced styling
          Text(
            userDetail!.fullName ?? 'Unknown User',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // User Details with beautiful cards
          _buildDetailCard(
              'Email', userDetail!.email ?? 'N/A', Icons.email_rounded,
              accentSpringSky),
          _buildDetailCard(
              'Phone', userDetail!.phoneNumber ?? 'N/A', Icons.phone_rounded,
              accentPapaya),
          _buildDetailCard(
              'Gender', userDetail!.gender ?? 'N/A', Icons.person_rounded,
              accentMeadow),
          _buildDetailCard('Birthday', _formatDate(userDetail!.dateOfBirth),
              Icons.cake_rounded, primaryIceCream),
          // _buildDetailCard(
          //     'User ID', userDetail!.userId ?? 'N/A', Icons.fingerprint_rounded,
          //     primaryIceCreamDark),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String label,
      String value,
      IconData icon,
      Color accentColor,) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textLight,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';

    try {
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

}