import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
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

  // Color scheme
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color secondaryBrown = Color(0xFF8B4513);
  static const Color darkBrown = Color(0xFF654321);
  static const Color lightOrange = Color(0xFFFFE5D9);
  static const Color textBlack = Color(0xFF1A1A1A);
  static const Color lightGray = Color(0xFFF5F5F5);

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
    return SafeArea(
      child: Scaffold(
        backgroundColor: lightGray,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: textBlack),
          ),
          title: Text(
            '${widget.communityName} Members',
            style: const TextStyle(
              color: textBlack,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryOrange),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Failed to load members',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error ?? 'Unknown error occurred',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchMembers,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No members found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This community doesn\'t have any members yet',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList() {
    return Column(
      children: [
        // Members count header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.people, color: primaryOrange, size: 24),
              const SizedBox(width: 12),
              Text(
                '${members.length} Members',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textBlack,
                ),
              ),
            ],
          ),
        ),

        // Members list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: member.profilePicture != null
              ? Colors.transparent
              : primaryOrange.withOpacity(0.2),
          backgroundImage: member.profilePicture != null
              ? NetworkImage(member.profilePicture!)
              : null,
          child: member.profilePicture == null
              ? Text(
            (member.userName ?? 'U')[0].toUpperCase(),
            style: const TextStyle(
              color: primaryOrange,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          )
              : null,
        ),
        title: Text(
          member.userName ?? 'Unknown User',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textBlack,
          ),
        ),
        subtitle: Text(
          _getMemberStatusText(member.communityMemberStatus),
          style: TextStyle(
            fontSize: 14,
            color: _getMemberStatusColor(member.communityMemberStatus),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {
          if (member.userId != null) {
            _showMemberDetails(member.userId!);
          }
        },
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
        return Colors.red;
      case 'moderator':
        return primaryOrange;
      case 'active':
        return Colors.green;
      default:
        return Colors.grey;
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

  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color textBlack = Color(0xFF1A1A1A);

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
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  'Member Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textBlack,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

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
      return const Center(
        child: CircularProgressIndicator(color: primaryOrange),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Failed to load user details',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error ?? 'Unknown error occurred',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchUserDetail,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No user details found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 50,
            backgroundColor: userDetail!.profilePicture != null
                ? Colors.transparent
                : primaryOrange.withOpacity(0.2),
            backgroundImage: userDetail!.profilePicture != null
                ? NetworkImage(userDetail!.profilePicture!)
                : null,
            child: userDetail!.profilePicture == null
                ? Text(
              (userDetail!.fullName ?? 'U')[0].toUpperCase(),
              style: const TextStyle(
                color: primaryOrange,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            )
                : null,
          ),

          const SizedBox(height: 20),

          // User Details
          _buildDetailCard('Full Name', userDetail!.fullName ?? 'N/A'),
          _buildDetailCard('Email', userDetail!.email ?? 'N/A'),
          _buildDetailCard('Phone Number', userDetail!.phoneNumber ?? 'N/A'),
          _buildDetailCard('Gender', userDetail!.gender ?? 'N/A'),
          _buildDetailCard('Date of Birth', _formatDate(userDetail!.dateOfBirth)),
          _buildDetailCard('User ID', userDetail!.userId ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textBlack,
              ),
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