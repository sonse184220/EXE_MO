import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/community/community_group_model.dart';
import 'package:inner_child_app/domain/entities/community/create_community_post_model.dart';
import 'package:inner_child_app/domain/usecases/community_usecase.dart';

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

  late TabController _tabController;

  String? get currentUserId => ref.watch(authNotifierProvider).userInfo?.userId;

  String? get currentProfileId =>
      ref.watch(authNotifierProvider).userInfo?.profileId;

  late final List<Widget> communityPosts;

  // Color scheme
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color secondaryBrown = Color(0xFF8B4513);
  static const Color darkBrown = Color(0xFF654321);
  static const Color lightOrange = Color(0xFFFFE5D9);
  static const Color textBlack = Color(0xFF1A1A1A);
  static const Color lightGray = Color(0xFFF5F5F5);

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
    if (currentProfileId == null ||
        communityGroup?.communityPostsDetail == null) {
      return [];
    }
    return communityGroup!.communityPostsDetail!
        .where((post) => post.profileId == currentProfileId)
        .toList();
  }

  Future<void> _createCommunityPost({
    required String title,
    required String content,
    File? imageFile,
    VoidCallback? onCloseDialog,
    dynamic editingPost,
  }) async {
    try {
      final createCommunityPostModel = CreateCommunityPostModel(
        communityPostTitle: title,
        communityPostContent: content,
        communityPostImageFile: imageFile,
        communityGroupId: widget.communityGroupId,
      );

      final result =
          editingPost != null
              ? await _communityUsecase.updateCommunityPost(editingPost.communityPostId,
                createCommunityPostModel,
              )
              : await _communityUsecase.createCommunityPost(
                createCommunityPostModel,
              );

      if (result.isSuccess) {
        Notify.showFlushbar(
          editingPost != null
              ? 'Post updated successfully!'
              : 'Post created successfully!',
        );
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
    final result = await _communityUsecase.getCommunityGroupById(
      widget.communityGroupId,
    );

    setState(() {
      communityGroup = result.data;
      isLoading = false;
    });
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
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
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
          ),
        ),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(Icons.search, color: textBlack),
        //   ),
        // ],
      ),
      body:
      isLoading
          ? const Center(
        child: CircularProgressIndicator(color: primaryOrange),
      )
          : Column(
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
                      Text(
                        communityGroup?.communityName ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${communityGroup?.communityMembersDetail?.length ?? 0} participants',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Join/Leave Button
                if (currentUserId != null)
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
                    onPressed:
                    isUserJoined
                        ? _leaveCommunity
                        : _joinCommunity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isUserJoined ? Colors.red : primaryOrange,
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
                      style: const TextStyle(fontSize: 12),
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
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search Posts and comments',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
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
              // indicatorWeight: 3,
              // onTap: (index) {
              //   setState(() {});
              // },
              tabs: const [
                Tab(text: 'Posts'),
                Tab(text: 'My Posts'),
                Tab(text: 'Trending'),
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
                // Trending Tab
                _buildTrendingTab(),
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
    ));
      // SafeArea(child: );
  }

  Widget _buildMyPostsTab() {
    final myPosts = userPosts;

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
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first post',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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

        return CommunityPostCard(
          post: post,
          communityName: communityGroup?.communityName ?? '',
          isUserPost: true,
          // Always true for my posts tab
          onEdit: () => _editPost(post),
          onDelete: () => _showDeleteConfirmation(post),
        );
      },
    );
  }

  Widget _buildTrendingTab() {
    // You can implement trending logic here
    // For now, showing posts sorted by engagement or recent activity
    final posts = communityGroup?.communityPostsDetail ?? [];
    final trendingPosts = posts.take(5).toList(); // Simple implementation

    if (trendingPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No trending posts yet',
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trendingPosts.length,
      itemBuilder: (context, index) {
        final post = trendingPosts[index];
        final isUserPost = post.profileId == currentProfileId;

        return CommunityPostCard(
          post: post,
          communityName: communityGroup?.communityName ?? '',
          isUserPost: isUserPost,
          onEdit: isUserPost ? () => _editPost(post) : null,
          onDelete: isUserPost ? () => _showDeleteConfirmation(post) : null,
        );
      },
    );
  }

  Widget _buildPostsTab() {
    final posts = communityGroup?.communityPostsDetail ?? [];

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
        final isUserPost = post.profileId == currentProfileId;

        return CommunityPostCard(
          post: post,
          communityName: communityGroup?.communityName ?? '',
          isUserPost: isUserPost,
          onEdit: () => _editPost(post),
          onDelete: () => _showDeleteConfirmation(post),
        );
      },
    );
  }

  void _showDeleteConfirmation(dynamic post) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Post'),
            content: const Text('Are you sure you want to delete this post?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deletePost(post.id ?? '');
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
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
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
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
