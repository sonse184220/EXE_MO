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
  String? get currentProfileId => ref.watch(authNotifierProvider).userInfo?.profileId;

  late final List<Widget> communityPosts;

  Future<void> _joinCommunity() async {
    if (currentUserId == null) return;

    setState(() {
      isJoinLoading = true;
    });

    try {
      // Replace with your actual join community method
      final result = await _communityUsecase.joinCommunity(
        widget.communityGroupId,
      );

      if (result.isSuccess) {
        Notify.showFlushbar('Successfully joined the community!');
        await fetchCommunityGroupById(); // Refresh to update join status
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
      // Replace with your actual leave community method
      final result = await _communityUsecase.leaveCommunity(
        widget.communityGroupId,
      );

      if (result.isSuccess) {
        Notify.showFlushbar('Successfully left the community!');
        await fetchCommunityGroupById(); // Refresh to update join status
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
    if (currentProfileId == null || communityGroup?.communityPostsDetail == null) {
      return [];
    }
    return communityGroup!.communityPostsDetail!
        .where((post) => post.profileId == currentProfileId)
        .toList();
    // if (currentUserId == null || communityGroup?.communityPostsDetail == null) {
    //   return [];
    // }
    // return communityGroup!.communityPostsDetail!
    //     .where((post) => post.userId == currentUserId)
    //     .toList();
  }

  Future<void> _createCommunityPost({
    required String title,
    required String content,
    File? imageFile,
    VoidCallback? onCloseDialog,
  }) async {
    try {
      final createCommunityPostModel = CreateCommunityPostModel(
        communityPostTitle: title,
        communityPostContent: content,
        communityPostImageFile: imageFile,
        communityGroupId: widget.communityGroupId,
      );
      final result = await _communityUsecase.createCommunityPost(
        createCommunityPostModel,
      );

      if (result.isSuccess) {
        Notify.showFlushbar('Post created successfully!');
        onCloseDialog?.call();
        await fetchCommunityGroupById(); // Refresh post list
      } else {
        Notify.showFlushbar(
          result.error ?? 'Failed to create post',
          isError: true,
        );
      }

      if (result.isSuccess) {
        Notify.showFlushbar('Post created successfully!');
        await fetchCommunityGroupById(); // Refresh post list
      } else {
        Notify.showFlushbar('Failed to create post', isError: true);
      }
    } catch (e) {
      Notify.showFlushbar('Error: ${e.toString()}', isError: true);
    }
  }

  Future<void> fetchCommunityGroupById() async {
    // Replace with your real API call
    final result = await _communityUsecase.getCommunityGroupById(
      widget.communityGroupId,
    ); // Your method

    setState(() {
      communityGroup = result.data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _communityUsecase = ref.read(communityUseCaseProvider);

    communityPosts = [
      CommunityPost(
        authorName: 'Laura',
        communityName: 'Santa Fe Community',
        postTitle: 'The Power of Healing 🌿',
        postImage: 'assets/forest.jpg',
        category: 'Natural Energy',
        subcategory: 'Healing ritual',
      ),
      CommunityPost(
        authorName: 'Laura',
        communityName: 'Santa Fe Community',
        postTitle: 'The Power of Healing 🌿',
        postImage: 'assets/forest.jpg',
        category: 'Natural Energy',
        subcategory: 'Healing ritual',
      ),
      CommunityPost(
        authorName: 'Laura',
        communityName: 'Santa Fe Community',
        postTitle: 'The Power of Healing 🌿',
        postImage: 'assets/forest.jpg',
        category: 'Natural Energy',
        subcategory: 'Healing ritual',
      ),
      CommunityPost(
        authorName: 'Laura',
        communityName: 'Santa Fe Community',
        postTitle: 'The Power of Healing 🌿',
        postImage: 'assets/forest.jpg',
        category: 'Natural Energy',
        subcategory: 'Healing ritual',
      ),
      CommunityPost(
        authorName: 'Laura',
        communityName: 'Santa Fe Community',
        postTitle: 'The Power of Healing 🌿',
        postImage: 'assets/forest.jpg',
        category: 'Natural Energy',
        subcategory: 'Healing ritual',
      ),
    ];

    fetchCommunityGroupById();
  }

  @override
  void dispose() {
    _tabController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Building with currentUserId: $currentUserId');
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : LayoutBuilder(
                  builder: (context, constraints) {
                    final posts = communityGroup?.communityPostsDetail ?? [];

                    final allPosts = communityGroup?.communityPostsDetail ?? [];
                    final myPosts = userPosts;

                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Community header image
                            Stack(
                              children: [
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                        'assets/images/meditation_page_image.png',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 20,
                                  left: 20,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withAlpha(
                                        (0.7 * 255).toInt(),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: IconButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      icon: Icon(
                                        Icons.arrow_back,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Community title and info
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                communityGroup?.communityName ??
                                                    '',
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                '${communityGroup?.communityMembersDetail?.length ?? 0} participants',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Join/Leave Button
                                        if (currentUserId != null)
                                          isJoinLoading
                                              ? const CircularProgressIndicator()
                                              : ElevatedButton(
                                                onPressed:
                                                    isUserJoined
                                                        ? _leaveCommunity
                                                        : _joinCommunity,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      isUserJoined
                                                          ? Colors.red
                                                          : Colors.blue,
                                                  foregroundColor: Colors.white,
                                                ),
                                                child: Text(
                                                  isUserJoined
                                                      ? 'Leave'
                                                      : 'Join',
                                                ),
                                              ),
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    // Tab Bar
                                    // TabBar(
                                    //   controller: _tabController,
                                    //   labelColor: Colors.blue,
                                    //   unselectedLabelColor: Colors.grey,
                                    //   indicatorColor: Colors.blue,
                                    //   tabs: const [
                                    //     Tab(text: 'All Posts'),
                                    //     Tab(text: 'My Posts'),
                                    //   ],
                                    // ),
                                    const SizedBox(height: 15),

                                    // Tab Bar
                                    TabBar(
                                      controller: _tabController,
                                      labelColor: Colors.blue,
                                      unselectedLabelColor: Colors.grey,
                                      indicatorColor: Colors.blue,
                                      tabs: const [
                                        Tab(text: 'All Posts'),
                                        Tab(text: 'My Posts'),
                                      ],
                                    ),

                                    const SizedBox(height: 15),

                                    // Tab Bar View
                                    Expanded(
                                      child: TabBarView(
                                        controller: _tabController,
                                        children: [
                                          // All Posts Tab
                                          _buildPostsList(allPosts),

                                          // My Posts Tab
                                          _buildPostsList(myPosts),
                                        ],
                                      ),
                                    ),

                                    // Expanded(
                                    //   child: ListView.separated(
                                    //     itemCount: posts.length,
                                    //     itemBuilder: (context, index) {
                                    //       // return communityPosts[index];
                                    //
                                    //       final post = posts[index];
                                    //       return CommunityPost(
                                    //         authorName:
                                    //             post.userName ?? 'Unknown',
                                    //         communityName:
                                    //             communityGroup?.communityName ??
                                    //             '',
                                    //         postTitle:
                                    //             post.communityPostTitle ?? '',
                                    //         postImage:
                                    //             'assets/images/meditation_page_image.png',
                                    //         // fallback asset
                                    //         category:
                                    //             post.communityPostStatus ??
                                    //             'General',
                                    //         subcategory:
                                    //             post.communityPostCreatedAt
                                    //                 ?.toIso8601String() ??
                                    //             '',
                                    //       );
                                    //     },
                                    //     separatorBuilder:
                                    //         (context, index) => const Divider(),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }

  void _showCreatePostDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    File? selectedImage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Community Post'),
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
                          // 'Selected: ${selectedImage!.name}',
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

                    // Navigator.pop(context); // close dialog
                    await _createCommunityPost(
                      title: titleController.text.trim(),
                      content: contentController.text.trim(),
                      imageFile: selectedImage,
                      onCloseDialog: () {
                        Navigator.pop(context); // Close dialog only on success
                      },
                    );
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPostsList(List<dynamic> posts) {
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

    return ListView.separated(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return CommunityPost(
          authorName: post.userName ?? 'Unknown',
          communityName: communityGroup?.communityName ?? '',
          postTitle: post.communityPostTitle ?? '',
          postImage: 'assets/images/meditation_page_image.png',
          category: post.communityPostStatus ?? 'General',
          subcategory: post.communityPostCreatedAt?.toIso8601String() ?? '',
        );
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}

class CommunityPost extends StatelessWidget {
  final String authorName;
  final String communityName;
  final String postTitle;
  final String postImage;
  final String category;
  final String subcategory;

  const CommunityPost({
    super.key,
    required this.authorName,
    required this.communityName,
    required this.postTitle,
    required this.postImage,
    required this.category,
    required this.subcategory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Author avatar
                const CircleAvatar(
                  radius: 15,
                  backgroundImage: AssetImage('assets/avatar.jpg'),
                ),
                const SizedBox(width: 8),
                // Author name and community
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    children: [
                      TextSpan(
                        text: authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' shared to '),
                      TextSpan(
                        text: communityName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Post title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              postTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 10),

          // Post image
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(postImage),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Post footer
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subcategory,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
