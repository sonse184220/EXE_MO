import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/community/community_group_model.dart';
import 'package:inner_child_app/domain/entities/community/create_community_post_model.dart';
import 'package:inner_child_app/domain/usecases/community_usecase.dart';
import 'package:inner_child_app/presentation/pages/function_pages/community_pages/community_members_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/community_pages/community_post_detail_page.dart';

class CommunityDetailPage extends ConsumerStatefulWidget {
  final String communityGroupId;

  const CommunityDetailPage({super.key, required this.communityGroupId});

  @override
  ConsumerState<CommunityDetailPage> createState() =>
      _CommunityDetailPageState();
}

class _CommunityDetailPageState extends ConsumerState<CommunityDetailPage>
    with SingleTickerProviderStateMixin {
  late final CommunityUsecase _communityUsecase;

  CommunityGroupModel? communityGroup;
  bool isLoading = true;
  bool isJoinLoading = false;
  bool isUpdatingPost = false;
  String? errorMessage;

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  late TabController _tabController;

  String? get currentUserId =>
      ref
          .watch(authNotifierProvider)
          .userInfo
          ?.userId;

  String? get currentProfileId =>
      ref
          .watch(authNotifierProvider)
          .userInfo
          ?.profileId;

  late final List<Widget> communityPosts;

  // Color scheme
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color secondaryBrown = Color(0xFF8B4513);
  static const Color darkBrown = Color(0xFF654321);
  static const Color lightOrange = Color(0xFFFFE5D9);
  static const Color textBlack = Color(0xFF1A1A1A);
  static const Color lightGray = Color(0xFFF5F5F5);

  // Check if current user is the community admin/owner
  bool get isCurrentUserAdmin {
    return currentUserId != null &&
        communityGroup?.createdBy == currentUserId;
  }

  List<dynamic> _filterPosts(List<dynamic> posts) {
    if (_searchQuery.isEmpty) {
      return posts;
    }

    return posts.where((post) {
      final title = post.communityPostTitle?.toLowerCase() ?? '';
      return title.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _updateCommunityGroup() async {
    final nameController = TextEditingController(
        text: communityGroup?.communityName ?? '');
    final descriptionController = TextEditingController(
        text: communityGroup?.communityDescription ?? '');
    String selectedStatus = communityGroup?.communityStatus ?? 'Active';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text(
              'Update Community Group',
              style: TextStyle(
                fontFamily: 'League Spartan',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Community Name',
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: 'Inter'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: 'Inter'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  items: const [
                    DropdownMenuItem(value: 'Active', child: Text('Active')),
                    DropdownMenuItem(
                        value: 'Inactive', child: Text('Inactive')),
                  ],
                  onChanged: (value) {
                    selectedStatus = value!;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                    'Cancel', style: TextStyle(fontFamily: 'Inter')),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text
                      .trim()
                      .isEmpty ||
                      descriptionController.text
                          .trim()
                          .isEmpty) {
                    Notify.showFlushbar(
                        'Please fill all fields', isError: true);
                    return;
                  }

                  try {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                    );

                    final result = await _communityUsecase.updateCommunityGroup(
                      widget.communityGroupId,
                      nameController.text.trim(),
                      descriptionController.text.trim(),
                      selectedStatus,
                    );

                    if (result.isSuccess) {
                      Navigator.of(context).pop(); // Close loading dialog
                      Navigator.of(context).pop(true); // Close update dialog
                      Notify.showFlushbar(
                          'Community group updated successfully!');
                      await fetchCommunityGroupById();
                    } else {
                      throw Exception('Failed to update community group');
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.of(context).pop(); // Close loading dialog
                      Notify.showFlushbar(
                          'Error updating group: $e', isError: true);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                    'Update', style: TextStyle(fontFamily: 'Inter')),
              ),
            ],
          ),
    );
  }

  Future<void> _approvePost(dynamic post) async {
    if (isUpdatingPost) return;

    setState(() {
      isUpdatingPost = true;
    });

    try {
      final createPostModel = CreateCommunityPostModel(
        communityPostImageFile: null,
        communityPostTitle: post.communityPostTitle ?? '',
        communityPostContent: post.communityPostContent ?? '',
        communityGroupId: widget.communityGroupId,
        communityPostStatus: 'Active'
      );

      final result = await _communityUsecase.updateCommunityPost(
        post.communityPostId,
        createPostModel,
      );

      if (result.isSuccess) {
        Notify.showFlushbar('Post approved successfully!');
        await fetchCommunityGroupById();
      } else {
        Notify.showFlushbar('Failed to approve post', isError: true);
      }
    } catch (e) {
      Notify.showFlushbar('Error approving post: $e', isError: true);
    } finally {
      setState(() {
        isUpdatingPost = false;
      });
    }
  }

  void _showPostApprovalDialog(dynamic post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          Container(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Post Approval',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'League Spartan',
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Post content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Author info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: primaryOrange.withOpacity(0.2),
                              child: Text(
                                (post.userName ?? 'U')[0].toUpperCase(),
                                style: const TextStyle(
                                  color: primaryOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.userName ?? 'Unknown User',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                Text(
                                  _formatDate(post.communityPostCreatedAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Post title
                        Text(
                          post.communityPostTitle ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'League Spartan',
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Post content
                        Text(
                          post.communityPostContent ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            fontFamily: 'Inter',
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Post image if available
                        if (post.communityPostImageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              post.communityPostImageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Action buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text(
                            'Reject',
                            style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isUpdatingPost
                              ? null
                              : () async {
                            await _approvePost(post);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: isUpdatingPost
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                              : const Text(
                            'Approve',
                            style: TextStyle(fontFamily: 'Inter'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _joinCommunity() async {
    if (currentUserId == null) return;

    setState(() {
      isJoinLoading = true;
    });

    try {
      final result = await _communityUsecase.joinCommunity(
        widget.communityGroupId,
      );

      if (result.isSuccess) {
        Notify.showFlushbar('Successfully joined the community!');
        await fetchCommunityGroupById();
      } else {
        Notify.showFlushbar(
          result.error ?? 'Failed to join community',
          isError: true,
        );
      }
    } catch (e) {
      Notify.showFlushbar('Error: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        isJoinLoading = false;
      });
    }
  }

  Future<void> _leaveCommunity() async {
    if (currentUserId == null) return;

    setState(() {
      isJoinLoading = true;
    });

    try {
      final result = await _communityUsecase.leaveCommunity(
        widget.communityGroupId,
      );

      if (result.isSuccess) {
        Notify.showFlushbar('Successfully left the community!');
        await fetchCommunityGroupById();
      } else {
        Notify.showFlushbar(
          result.error ?? 'Failed to leave community',
          isError: true,
        );
      }
    } catch (e) {
      Notify.showFlushbar('Error: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        isJoinLoading = false;
      });
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      // Add your delete post logic here
      Notify.showFlushbar('Post deleted successfully!');
      await fetchCommunityGroupById();
    } catch (e) {
      Notify.showFlushbar(
        'Error deleting post: ${e.toString()}',
        isError: true,
      );
    }
  }

  Future<void> _editPost(dynamic post) async {
    // Add your edit post logic here
    _showCreatePostDialog(editingPost: post);
  }

  bool get isUserJoined {
    if (currentUserId == null ||
        communityGroup?.communityMembersDetail == null) {
      return false;
    }
    return communityGroup!.communityMembersDetail!.any(
          (member) => member.userId == currentUserId,
    );
  }

  List<dynamic> get userPosts {
    if (currentUserId == null ||
        communityGroup?.communityPostsDetail == null) {
      return [];
    }
    return communityGroup!.communityPostsDetail!
        .where((post) =>
    post.userId == currentUserId &&
        (post.communityPostStatus?.toLowerCase() == 'active' ||
            post.communityPostStatus?.toLowerCase() != 'inactive'))
        .toList();
  }

  List<dynamic> get activePosts {
    if (communityGroup?.communityPostsDetail == null) {
      return [];
    }
    return communityGroup!.communityPostsDetail!
        .where((post) =>
    post.communityPostStatus?.toLowerCase() == 'active' ||
        post.communityPostStatus?.toLowerCase() != 'inactive')
        .toList();
  }

  List<dynamic> get pendingPosts {
    if (communityGroup?.communityPostsDetail == null) {
      return [];
    }
    return communityGroup!.communityPostsDetail!
        .where((post) => post.communityPostStatus?.toLowerCase() == 'inactive')
        .toList();
  }

  List<dynamic> get filteredActivePosts => _filterPosts(activePosts);
  List<dynamic> get filteredUserPosts => _filterPosts(userPosts);
  List<dynamic> get filteredPendingPosts => _filterPosts(pendingPosts);

  Future<void> _createCommunityPost({
    required String title,
    required String content,
    File? imageFile,
    VoidCallback? onCloseDialog,
    dynamic editingPost,
  }) async {
    try {
      // Determine post status based on user role
      String postStatus = 'Active';
      if (!isCurrentUserAdmin && editingPost == null) {
        // New posts from non-admin users are inactive (pending approval)
        postStatus = 'Inactive';
      }

      final createCommunityPostModel = CreateCommunityPostModel(
        communityPostTitle: title,
        communityPostContent: content,
        communityPostImageFile: imageFile,
        communityGroupId: widget.communityGroupId,
        communityPostStatus: postStatus
      );
      
      // print('title ${createCommunityPostModel.communityPostTitle}, groupId ${createCommunityPostModel.communityGroupId}, image ${createCommunityPostModel.communityPostImageFile}');

      final result = editingPost != null
          ? await _communityUsecase.updateCommunityPost(
        editingPost.communityPostId,
        createCommunityPostModel,
      )
          : await _communityUsecase.createCommunityPost(
        createCommunityPostModel,
      );

      if (result.isSuccess) {
        String message = editingPost != null
            ? 'Post updated successfully!'
            : isCurrentUserAdmin
            ? 'Post created successfully!'
            : 'Post submitted for approval!';

        Notify.showFlushbar(message);
        onCloseDialog?.call();
        await fetchCommunityGroupById();
      } else {
        Notify.showFlushbar(
          result.error ??
              (editingPost != null
                  ? 'Failed to update post'
                  : 'Failed to create post'),
          isError: true,
        );
      }
    } catch (e) {
      Notify.showFlushbar('Error: ${e.toString()}', isError: true);
    }
  }

  Future<void> fetchCommunityGroupById() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _communityUsecase.getCommunityGroupById(
        widget.communityGroupId,
      );

      setState(() {
        communityGroup = result.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              fontFamily: 'League Spartan',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Unknown error occurred',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: fetchCommunityGroupById,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Retry',
              style: TextStyle(fontFamily: 'Inter'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _communityUsecase = ref.read(communityUseCaseProvider);

    fetchCommunityGroupById();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: lightGray,
          body: const Center(
            child: CircularProgressIndicator(color: primaryOrange),
          ),
        ),
      );
    }

    if (errorMessage != null) {
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
            title: const Text(
              'Community',
              style: TextStyle(
                color: textBlack,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'League Spartan',
              ),
            ),
            centerTitle: true,
          ),
          body: _buildErrorWidget(),
        ),
      );
    }

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
          title: const Text(
            'Community',
            style: TextStyle(
              color: textBlack,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'League Spartan',
            ),
          ),
          centerTitle: true,
          actions: [
            if (isCurrentUserAdmin)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: textBlack),
                onSelected: (value) {
                  if (value == 'edit') {
                    _updateCommunityGroup();
                  }
                },
                itemBuilder: (context) =>
                [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: primaryOrange),
                        SizedBox(width: 8),
                        Text(
                          'Edit Community',
                          style: TextStyle(fontFamily: 'Inter'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: Column(
          children: [
            // Community Info Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                communityGroup?.communityName ?? '',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textBlack,
                                  fontFamily: 'League Spartan',
                                ),
                              ),
                            ),
                            if (isCurrentUserAdmin)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryOrange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: primaryOrange.withOpacity(0.3),
                                  ),
                                ),
                                child: const Text(
                                  'ADMIN',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: primaryOrange,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () =>
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CommunityMembersPage(
                                        communityId: widget.communityGroupId,
                                        communityName:
                                        communityGroup?.communityName ??
                                            'Community Group',
                                      ),
                                ),
                              ),
                          child: Text(
                            '${communityGroup?.communityMembersDetail?.length ??
                                0} participants',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Join/Leave Button (hidden for admin)
                  if (currentUserId != null && !isCurrentUserAdmin)
                    isJoinLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: primaryOrange,
                        strokeWidth: 2,
                      ),
                    )
                        : ElevatedButton(
                      onPressed: isUserJoined
                          ? _leaveCommunity
                          : _joinCommunity,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isUserJoined
                            ? Colors.red
                            : primaryOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        isUserJoined ? 'Leave' : 'Join',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Search Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: lightGray,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search Posts',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Inter',
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                  style: const TextStyle(fontFamily: 'Inter'),
                ),
              ),
            ),

            // Tab Bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: primaryOrange,
                unselectedLabelColor: Colors.grey,
                indicatorColor: primaryOrange,
                labelStyle: const TextStyle(fontFamily: 'Inter'),
                unselectedLabelStyle: const TextStyle(fontFamily: 'Inter'),
                tabs: [
                  const Tab(text: 'Posts'),
                  const Tab(text: 'My Posts'),
                  if (isCurrentUserAdmin) const Tab(text: 'Approve'),
                  // if (!isCurrentUserAdmin) const Tab(text: 'Trending'),
                ],
              ),
            ),

            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // All Posts Tab
                  _buildPostsTab(),
                  // My Posts Tab
                  _buildMyPostsTab(),
                  // Admin Approve Tab or Trending Tab
                  if (isCurrentUserAdmin)
                    _buildApproveTab()
                  // else
                  //   _buildTrendingTab(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreatePostDialog(),
          backgroundColor: primaryOrange,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPostsTab() {
    // final posts = activePosts;
    final posts = filteredActivePosts;

    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.post_add, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No posts found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontFamily: 'League Spartan',
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final isUserPost = post.userId == currentUserId;

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommunityPostDetailPage(
                postId: post.communityPostId!,
              ),
            ),
          ),
          child: CommunityPostCard(
            post: post,
            communityName: communityGroup?.communityName ?? '',
            isUserPost: isUserPost,
            onEdit: isUserPost ? () => _editPost(post) : null,
            // onDelete: isUserPost ? () => _showDeleteConfirmation(post) : null,
          ),
        );
      },
    );
  }

  Widget _buildMyPostsTab() {
    // final myPosts = userPosts;
    final myPosts = filteredUserPosts;

    if (myPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.post_add, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'You haven\'t posted anything yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontFamily: 'League Spartan',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first post',
              style: TextStyle(fontSize: 14, color: Colors.grey[500], fontFamily: 'Inter'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myPosts.length,
      itemBuilder: (context, index) {
        final post = myPosts[index];

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommunityPostDetailPage(
                postId: post.communityPostId!,
              ),
            ),
          ),
          child: CommunityPostCard(
            post: post,
            communityName: communityGroup?.communityName ?? '',
            isUserPost: true,
            onEdit: () => _editPost(post),
            // onDelete: () => _showDeleteConfirmation(post),
          ),
        );
      },
    );
  }


  Widget _buildApproveTab() {
    // final pendingPostsList = pendingPosts;
    final pendingPostsList = filteredPendingPosts;

    if (pendingPostsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No posts pending approval',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontFamily: 'League Spartan',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All posts have been reviewed',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingPostsList.length,
      itemBuilder: (context, index) {
        final post = pendingPostsList[index];

        return GestureDetector(
          onTap: () => _showPostApprovalDialog(post),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post header: author & date
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: primaryOrange.withOpacity(0.2),
                      child: Text(
                        (post.userName ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: primaryOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName ?? 'Unknown User',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                        Text(
                          _formatDate(post.communityPostCreatedAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Post title
                Text(
                  post.communityPostTitle ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'League Spartan',
                  ),
                ),
                const SizedBox(height: 8),

                // Post content preview
                Text(
                  (post.communityPostContent ?? '').length > 100
                      ? '${post.communityPostContent.substring(0, 100)}...'
                      : post.communityPostContent ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),

                // Optional thumbnail
                if (post.communityPostImageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      post.communityPostImageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.broken_image),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreatePostDialog({dynamic editingPost}) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    File? selectedImage;

    if (editingPost != null) {
      titleController.text = editingPost.communityPostTitle ?? '';
      contentController.text = editingPost.communityPostContent ?? '';
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(editingPost != null ? 'Edit Post' : 'Create Post'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: contentController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Content'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text('Choose Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile != null) {
                          setState(() {
                            selectedImage = File(pickedFile.path);
                          });
                        }
                      },
                    ),
                    if (selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Selected: ${selectedImage!.path.split('/').last}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty ||
                        contentController.text.trim().isEmpty) {
                      Notify.showFlushbar(
                        "All fields are required.",
                        isError: true,
                      );
                      return;
                    }

                    await _createCommunityPost(
                      title: titleController.text.trim(),
                      content: contentController.text.trim(),
                      imageFile: selectedImage,
                      editingPost: editingPost,
                      onCloseDialog: () {
                        Navigator.pop(context);
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(editingPost != null ? 'Update' : 'Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
// Widget _buildApproveTab() {
//   final pendingPostsList = pendingPosts;
//
//   if (pendingPostsList.isEmpty) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(
//             'No posts pending approval',
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//               fontFamily: 'League Spartan',
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'All posts have been reviewed',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[500],
//               fontFamily: 'Inter',
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   return ListView.builder(
//       padding: const EdgeInsets.all(16),
//   itemCount: pendingPostsList.length,
//   itemBuilder: (context, index) {
//   final post = pendingPostsList[index];
//
//   return GestureDetector(
//   onTap: () => _showPostApprovalDialog(post),
//   child: Container(
//   margin: const EdgeInsets.only(bottom: 16),
//   decoration: BoxDecoration(
//   color: Colors.white,
//   borderRadius: BorderRadius.circular(12),
//   border: Border.all(color: Colors.orange.withOpacity(0.3)),
//   boxShadow: [
//   BoxShadow(
//   color: Colors.black.withOpacity(0.05),
//   blurRadius: 10,
//   offset

}

class CommunityPostCard extends StatelessWidget {
  final dynamic post;
  final String communityName;
  final bool isUserPost;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CommunityPostCard({
    super.key,
    required this.post,
    required this.communityName,
    required this.isUserPost,
    this.onEdit,
    this.onDelete,
  });

  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color secondaryBrown = Color(0xFF8B4513);
  static const Color textBlack = Color(0xFF1A1A1A);
  static const String fallbackImage =
      'https://media.istockphoto.com/id/1409329028/vector/no-picture-available-placeholder-thumbnail-icon-illustration-design.jpg?s=612x612&w=0&k=20&c=_zOuJu755g2eEUioiOUdz_mHKJQJn-tDgIAhQzyeKUQ=';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header
            Row(
              children: [
                // Author avatar
               GestureDetector(onTap: (){}, child:  CircleAvatar(
                 radius: 24,
                 backgroundColor: post.profilePicture != null
                     ? Colors.transparent
                     : primaryOrange.withOpacity(0.2),
                 backgroundImage: post.profilePicture != null
                     ? NetworkImage(post.profilePicture!)
                     : null,
                 child: post.profilePicture == null
                     ? Text(
                   (post.userName ?? 'U')[0].toUpperCase(),
                   style: const TextStyle(
                     color: primaryOrange,
                     fontWeight: FontWeight.bold,
                     fontSize: 18,
                   ),
                 )
                     : null,
               ),),
                // CircleAvatar(
                //   radius: 20,
                //   backgroundColor: primaryOrange.withOpacity(0.2),
                //   child:
                //
                //   Text(
                //     (post.userName ?? 'U')[0].toUpperCase(),
                //     style: const TextStyle(
                //       color: primaryOrange,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
                const SizedBox(width: 12),
                // Author info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName ?? 'Unknown User',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textBlack,
                        ),
                      ),
                      Text(
                        _formatDate(post.communityPostCreatedAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Three dots menu for user posts
                if (isUserPost)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz, color: Colors.grey),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit?.call();
                      } else if (value == 'delete') {
                        onDelete?.call();
                      }
                    },
                    itemBuilder:
                        (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: primaryOrange),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      // const PopupMenuItem(
                      //   value: 'delete',
                      //   child: Row(
                      //     children: [
                      //       Icon(Icons.delete, color: Colors.red),
                      //       SizedBox(width: 8),
                      //       Text('Delete'),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Post content
            Text(
              post.communityPostTitle ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: textBlack,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 15),

            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                post.communityPostImageUrl ?? fallbackImage,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    fallbackImage,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),

            // // Post image
            // Container(
            //   height: 150,
            //   width: double.infinity,
            //   decoration: BoxDecoration(
            //     image: DecorationImage(
            //       image: AssetImage(post.communityPostImageUrl),
            //       fit: BoxFit.cover,
            //     ),
            //   ),
            // ),
            const SizedBox(height: 12),

            // Hashtags or category
            if (post.communityPostStatus != null)
              Text(
                '#${post.communityPostStatus}',
                style: const TextStyle(
                  fontSize: 14,
                  color: primaryOrange,
                  fontWeight: FontWeight.w500,
                ),
              ),

            const SizedBox(height: 12),

            // Post actions
            Row(
              children: [
                _buildActionButton(Icons.favorite_border, '12'),
                const SizedBox(width: 24),
                _buildActionButton(Icons.chat_bubble_outline, '5'),
                const SizedBox(width: 24),
                _buildActionButton(Icons.share_outlined, ''),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        if (count.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(count, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
