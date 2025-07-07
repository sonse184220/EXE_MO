import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/community/community_post_model.dart';
import 'package:inner_child_app/domain/usecases/community_usecase.dart';
import 'package:inner_child_app/presentation/pages/function_pages/community_pages/community_detail_page.dart';

class CommunityPostDetailPage extends ConsumerStatefulWidget {
  final String postId;

  const CommunityPostDetailPage({super.key, required this.postId});

  @override
  ConsumerState<CommunityPostDetailPage> createState() =>
      _CommunityPostDetailPageState();
}

class _CommunityPostDetailPageState
    extends ConsumerState<CommunityPostDetailPage> {
  late final CommunityUsecase _communityUsecase;
  CommunityPostModel? postDetail;
  List<CommunityPostModel> otherPosts = [];
  bool isLoading = true;
  bool isLoadingOtherPosts = false;
  bool hasErrorOtherPosts = false;

  // Color scheme for light theme
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color secondaryBrown = Color(0xFF8B4513);
  static const Color darkBrown = Color(0xFF654321);
  static const Color lightOrange = Color(0xFFFFE5D9);
  static const Color textBlack = Color(0xFF1A1A1A);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color backgroundColor = Color(0xFFFAFAFA);

  String? get currentUserId => ref.watch(authNotifierProvider).userInfo?.userId;

  String? get currentProfileId =>
      ref.watch(authNotifierProvider).userInfo?.profileId;

  @override
  void initState() {
    super.initState();
    _communityUsecase = ref.read(communityUseCaseProvider);
    _fetchPostDetail();
    // _fetchOtherPosts();
  }

  Future<void> _fetchPostDetail() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await _communityUsecase.getCommunityPostDetail(
        widget.postId,
      );
      // final result = Result.success(new CommunityPostDetailModel(communityPostId: 'communityPostId', communityPostTitle: 'communityPostTitle', communityPostContent: 'communityPostContent', communityPostCreatedAt: DateTime.now().toString(), communityGroupId: 'communityGroupId', userId: 'userId', profileId: 'profileId', userName: 'userName'));
      if (result.isSuccess) {
        setState(() {
          postDetail = result.data;
          _fetchOtherPosts();
        });
      } else {
        Notify.showFlushbar(
          result.error ?? 'Failed to load post details',
          isError: true,
        );
      }
    } catch (e) {
      Notify.showFlushbar('Error: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchOtherPosts() async {
    if (postDetail?.communityGroupId == null) return;

    setState(() {
      isLoadingOtherPosts = true;
    });

    try {
      // final result = await _communityUsecase.getCommunityPosts(
      //   postDetail!.communityGroupId,
      //   excludePostId: widget.postId,
      // );
      final result = await _communityUsecase.getCommunityGroupById(
        postDetail!.communityGroupId!,
      );
      if (result.isSuccess) {
        if (result.data?.communityPostsDetail == null) {
          throw Exception();
        }
        setState(() {
          otherPosts = (result.data?.communityPostsDetail)!;
        });
      }
    } catch (e) {
      // Handle error silently for other posts
      setState(() {
        // isLoadingOtherPosts = false;
        hasErrorOtherPosts = true;
      });
    } finally {
      setState(() {
        isLoadingOtherPosts = false;
        // hasErrorOtherPosts = true;
      });
    }
  }

  // Future<void> _deletePost() async {
  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: cardBackground,
  //       title: const Text('Delete Post', style: TextStyle(color: textBlack)),
  //       content: const Text(
  //         'Are you sure you want to delete this post?',
  //         style: TextStyle(color: textBlack),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(false),
  //           child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(true),
  //           child: const Text('Delete', style: TextStyle(color: Colors.red)),
  //         ),
  //       ],
  //     ),
  //   );
  //
  //   if (confirmed == true) {
  //     try {
  //       final result = await _communityUsecase.deleteCommunityPost(widget.postId);
  //       if (result.isSuccess) {
  //         Notify.showFlushbar('Post deleted successfully!');
  //         Navigator.of(context).pop();
  //       } else {
  //         Notify.showFlushbar(
  //           result.error ?? 'Failed to delete post',
  //           isError: true,
  //         );
  //       }
  //     } catch (e) {
  //       Notify.showFlushbar('Error: ${e.toString()}', isError: true);
  //     }
  //   }
  // }

  bool get canEditOrDelete {
    return currentProfileId == postDetail?.userId;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SafeArea(child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: cardBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: textBlack),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Post Details',
            style: TextStyle(
              color: textBlack,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: primaryOrange),
        ),
      ));
    }

    if (postDetail == null) {
      return SafeArea(child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: cardBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: textBlack),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text(
            'Post not found',
            style: TextStyle(color: textBlack, fontSize: 16),
          ),
        ),
      ));
    }

    return SafeArea(child: Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Post Details',
          style: TextStyle(
            color: textBlack,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(padding: EdgeInsets.symmetric(vertical: 8.0),
            child: IconButton(
              icon: const Icon(Icons.home, color: textBlack),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CommunityDetailPage(
                          communityGroupId: postDetail!.communityGroupId!,
                        ),
                  ),
                );
              },
            ),)
          // if (canEditOrDelete)
          //   PopupMenuButton<String>(
          //     icon: const Icon(Icons.home, color: textBlack),
          //     color: cardBackground,
          //     onSelected: (value) {
          //       Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityDetailPage(communityGroupId: postDetail!.communityGroupId!)));
          //       // if (value == 'delete') {
          //       //   // _deletePost();
          //       // }
          //     },
          //     itemBuilder:
          //         (context) => [
          //           const PopupMenuItem(
          //             value: 'delete',
          //             child: Row(
          //               children: [
          //                 Icon(Icons.delete, color: Colors.red, size: 20),
          //                 SizedBox(width: 8),
          //                 Text('Delete', style: TextStyle(color: Colors.red)),
          //               ],
          //             ),
          //           ),
          //         ],
          //   ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostContent(),
            const SizedBox(height: 24),
            _buildOtherPosts(),
          ],
        ),
      ),
    ));
  }

  Widget _buildPostContent() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: lightOrange,
                backgroundImage:
                    postDetail!.profilePicture != null
                        ? NetworkImage(postDetail!.profilePicture!)
                        : AssetImage('assets/images/user_avt.png')
                            as ImageProvider,
                child:
                    postDetail!.profilePicture == null
                        ? null // If you're using an image fallback, no need for text here
                        : null,
                //   ? Text(
                // // postDetail!.userName.isNotEmpty
                // //     ? postDetail!.userName[0].toUpperCase()
                // //     : 'U',
                // postDetail!.userName ?? 'Unknown user',
                // style: const TextStyle(
                //   color: primaryOrange,
                //   fontWeight: FontWeight.bold,
                // ),
                // )
                // : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      postDetail!.userName ?? 'Unknown user',
                      style: const TextStyle(
                        color: textBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      postDetail!.communityPostCreatedAt != null
                          ? _formatDate(
                            postDetail!.communityPostCreatedAt.toString(),
                          )
                          : '-',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Post title
          Text(
            postDetail!.communityPostTitle ?? 'Unknown title',
            style: const TextStyle(
              color: textBlack,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Post content
          Text(
            postDetail!.communityPostContent ?? 'Unknown content',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
              height: 1.5,
            ),
          ),

          // Post image if exists
          if (postDetail!.communityPostImageUrl != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                postDetail!.communityPostImageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: lightGray,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 48,
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: lightGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No image available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOtherPosts() {
    if (isLoadingOtherPosts) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: primaryOrange),
        ),
      );
    }

    if (hasErrorOtherPosts) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'Something went wrong while loading posts.',
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _fetchOtherPosts,
                style: ElevatedButton.styleFrom(backgroundColor: primaryOrange),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (otherPosts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Sorry, no posts found.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Other Posts',
            style: TextStyle(
              color: textBlack,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: otherPosts.length,
            itemBuilder: (context, index) {
              final post = otherPosts[index];
              return _buildOtherPostCard(post);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOtherPostCard(CommunityPostModel post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    CommunityPostDetailPage(postId: post.communityPostId!),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background image or placeholder
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                color: lightOrange,
                image:
                    post.communityPostImageUrl != null
                        ? DecorationImage(
                          image: NetworkImage(post.communityPostImageUrl!),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  post.communityPostImageUrl == null
                      ? const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: primaryOrange,
                          size: 48,
                        ),
                      )
                      : null,
            ),

            // Content overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.communityPostTitle ?? 'Unknown title',
                      style: const TextStyle(
                        color: textBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.communityPostContent ?? 'Unknown content',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
