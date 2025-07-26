import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/community/community_group_model.dart';
import 'package:inner_child_app/domain/entities/community/community_post_model.dart';
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
    with TickerProviderStateMixin {
  late final CommunityUsecase _communityUsecase;

  late CommunityGroupModel communityGroup;
  bool isLoading = true;
  bool isJoinLoading = false;
  bool isCreatingPost = false;
  bool isUpdatingPost = false;
  bool _showSearchOverlay = false;

  String? errorMessage;

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  late TabController _tabController;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final GlobalKey<AnimatedListState> _activePostListKey =
      GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _pendingPostListKey =
      GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _userPostListKey =
      GlobalKey<AnimatedListState>();

  List<CommunityPostModel> _animatedActivePosts = [];
  List<CommunityPostModel> _animatedPendingPosts = [];
  List<CommunityPostModel> _animatedUserPosts = [];

  String? get currentUserId => ref.watch(authNotifierProvider).userInfo?.userId;

  String? get currentProfileId =>
      ref.watch(authNotifierProvider).userInfo?.profileId;

  String? get cl => ref.watch(authNotifierProvider).userInfo?.purchasePlan;

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
    return currentUserId != null && communityGroup?.createdBy == currentUserId;
  }

  List<CommunityPostModel> _filterPosts(List<CommunityPostModel> posts) {
    if (_searchQuery.isEmpty) {
      return posts;
    }

    return posts.where((post) {
      final title = post.communityPostTitle?.toLowerCase() ?? '';
      return title.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _animateListChanges({
    required List<CommunityPostModel> newList,
    required List<CommunityPostModel> animatedList,
    required GlobalKey<AnimatedListState> listKey,
  }) {
    final listState = listKey.currentState;
    if (listState == null) {
      // Probably first build – just replace the list
      animatedList.clear();
      animatedList.addAll(newList);
      return;
    }

    // Remove all old items
    for (int i = animatedList.length - 1; i >= 0; i--) {
      final removedItem = animatedList.removeAt(i);
      listState.removeItem(
        i,
            (context, animation) => SizeTransition(
          sizeFactor: animation,
          child: _buildStyledPostCard(
            post: removedItem,
            communityName: communityGroup?.communityName ?? '',
            isUserPost: removedItem.userId == currentUserId,
          ),
        ),
        duration: const Duration(milliseconds: 300),
      );
    }

    // Add all new items
    for (int i = 0; i < newList.length; i++) {
      animatedList.insert(i, newList[i]);
      listState.insertItem(
        i,
        duration: const Duration(milliseconds: 300),
      );
    }
  }


  void _refreshAnimatedLists() {
    _animateListChanges(
      // oldList: List.of(_animatedActivePosts),
      newList: filteredActivePosts,
      animatedList: _animatedActivePosts,
      listKey: _activePostListKey,
    );

    _animateListChanges(
      // oldList: List.of(_animatedUserPosts),
      newList: filteredUserPosts,
      animatedList: _animatedUserPosts,
      listKey: _userPostListKey,
    );

    _animateListChanges(
      // oldList: List.of(_animatedPendingPosts),
      newList: filteredPendingPosts,
      animatedList: _animatedPendingPosts,
      listKey: _pendingPostListKey,
    );
  }


  Future<void> _updateCommunityGroup() async {
    final nameController = TextEditingController(
      text: communityGroup?.communityName ?? '',
    );
    final descriptionController = TextEditingController(
      text: communityGroup?.communityDescription ?? '',
    );
    String selectedStatus = communityGroup?.communityStatus ?? 'Active';

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
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
                      value: 'Inactive',
                      child: Text('Inactive'),
                    ),
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
                  'Cancel',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty ||
                      descriptionController.text.trim().isEmpty) {
                    Notify.showFlushbar(
                      'Please fill all fields',
                      isError: true,
                    );
                    return;
                  }

                  try {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (context) =>
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
                        'Community group updated successfully!',
                      );
                      await fetchCommunityGroupById();
                    } else {
                      throw Exception('Failed to update community group');
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.of(context).pop(); // Close loading dialog
                      Notify.showFlushbar(
                        'Error updating group: $e',
                        isError: true,
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE37083),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _approvePost(CommunityPostModel post) async {
    if (isUpdatingPost) return;

    setState(() {
      isUpdatingPost = true;
    });

    try {
      final createPostModel = CreateCommunityPostModel(
        communityPostImageFiles: null,
        communityPostTitle: post.communityPostTitle ?? '',
        communityPostContent: post.communityPostContent ?? '',
        communityGroupId: widget.communityGroupId,
        communityPostStatus: 'Active',
      );

      final result = await _communityUsecase.updateCommunityPost(
        post.communityPostId!,
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

  // void _showPostApprovalDialog(CommunityPostModel post) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder:
  //         (context) => Container(
  //           height: MediaQuery.of(context).size.height * 0.8,
  //           decoration: const BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //           ),
  //           child: Column(
  //             children: [
  //               // Handle bar
  //               Container(
  //                 margin: const EdgeInsets.only(top: 8),
  //                 width: 40,
  //                 height: 4,
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey[300],
  //                   borderRadius: BorderRadius.circular(2),
  //                 ),
  //               ),
  //
  //               // Header
  //               Padding(
  //                 padding: const EdgeInsets.all(16),
  //                 child: Row(
  //                   children: [
  //                     const Expanded(
  //                       child: Text(
  //                         'Post Approval',
  //                         style: TextStyle(
  //                           fontSize: 20,
  //                           fontWeight: FontWeight.bold,
  //                           fontFamily: 'League Spartan',
  //                         ),
  //                       ),
  //                     ),
  //                     IconButton(
  //                       onPressed: () => Navigator.pop(context),
  //                       icon: const Icon(Icons.close),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //
  //               const Divider(height: 1),
  //
  //               // Post content
  //               Expanded(
  //                 child: SingleChildScrollView(
  //                   padding: const EdgeInsets.all(16),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       // Author info
  //                       Row(
  //                         children: [
  //                           CircleAvatar(
  //                             radius: 20,
  //                             backgroundColor: primaryOrange.withOpacity(0.2),
  //                             child: Text(
  //                               (post.userName ?? 'U')[0].toUpperCase(),
  //                               style: const TextStyle(
  //                                 color: primaryOrange,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                           ),
  //                           const SizedBox(width: 12),
  //                           Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                 post.userName ?? 'Unknown User',
  //                                 style: const TextStyle(
  //                                   fontSize: 16,
  //                                   fontWeight: FontWeight.w600,
  //                                   fontFamily: 'Inter',
  //                                 ),
  //                               ),
  //                               Text(
  //                                 _formatDate(post.communityPostCreatedAt),
  //                                 style: const TextStyle(
  //                                   fontSize: 12,
  //                                   color: Colors.grey,
  //                                   fontFamily: 'Inter',
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //
  //                       const SizedBox(height: 16),
  //
  //                       // Post title
  //                       Text(
  //                         post.communityPostTitle ?? '',
  //                         style: const TextStyle(
  //                           fontSize: 18,
  //                           fontWeight: FontWeight.bold,
  //                           fontFamily: 'League Spartan',
  //                         ),
  //                       ),
  //
  //                       const SizedBox(height: 12),
  //
  //                       // Post content
  //                       Text(
  //                         post.communityPostContent ?? '',
  //                         style: const TextStyle(
  //                           fontSize: 14,
  //                           height: 1.4,
  //                           fontFamily: 'Inter',
  //                         ),
  //                       ),
  //
  //                       const SizedBox(height: 16),
  //
  //                       // Post image if available
  //                       buildImageSection(post),
  //                       // if (post.communityPostImageUrl != null)
  //                       //   ClipRRect(
  //                       //     borderRadius: BorderRadius.circular(12),
  //                       //     child: Image.network(
  //                       //       post.communityPostImageUrl ?? '',
  //                       //       width: double.infinity,
  //                       //       fit: BoxFit.cover,
  //                       //       errorBuilder: (context, error, stackTrace) {
  //                       //         return Container(
  //                       //           height: 200,
  //                       //           color: Colors.grey[200],
  //                       //           child: const Center(
  //                       //             child: Icon(Icons.image_not_supported),
  //                       //           ),
  //                       //         );
  //                       //       },
  //                       //     ),
  //                       //   ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //
  //               // Action buttons
  //               Container(
  //                 padding: const EdgeInsets.all(16),
  //                 decoration: BoxDecoration(
  //                   border: Border(top: BorderSide(color: Colors.grey[200]!)),
  //                 ),
  //                 child: Row(
  //                   children: [
  //                     Expanded(
  //                       child: OutlinedButton(
  //                         onPressed: () => Navigator.pop(context),
  //                         style: OutlinedButton.styleFrom(
  //                           padding: const EdgeInsets.symmetric(vertical: 12),
  //                           side: const BorderSide(color: Colors.red),
  //                         ),
  //                         child: const Text(
  //                           'Reject',
  //                           style: TextStyle(
  //                             color: Colors.red,
  //                             fontFamily: 'Inter',
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 16),
  //                     Expanded(
  //                       child: ElevatedButton(
  //                         onPressed:
  //                             isUpdatingPost
  //                                 ? null
  //                                 : () async {
  //                                   await _approvePost(post);
  //                                   Navigator.pop(context);
  //                                 },
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: primaryOrange,
  //                           foregroundColor: Colors.white,
  //                           padding: const EdgeInsets.symmetric(vertical: 12),
  //                         ),
  //                         child:
  //                             isUpdatingPost
  //                                 ? const SizedBox(
  //                                   width: 20,
  //                                   height: 20,
  //                                   child: CircularProgressIndicator(
  //                                     strokeWidth: 2,
  //                                     valueColor: AlwaysStoppedAnimation<Color>(
  //                                       Colors.white,
  //                                     ),
  //                                   ),
  //                                 )
  //                                 : const Text(
  //                                   'Approve',
  //                                   style: TextStyle(fontFamily: 'Inter'),
  //                                 ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //   );
  // }

  void _showPostApprovalDialog(CommunityPostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Modern handle bar with gradient background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE37083).withOpacity(0.1),
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE37083).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Modern header with gradient accent
            Container(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFE37083).withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Gradient accent bar
                  Container(
                    width: 4,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE37083), Color(0xFFF49AA2)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Post Approval',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'League Spartan',
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        Text(
                          'Review and approve community content',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF718096),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE37083).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFFE37083),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Post content with modern card design
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE37083).withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE37083).withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author info with modern design
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFE37083).withOpacity(0.05),
                              Colors.white,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFE37083).withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFFE37083).withOpacity(0.15),
                                child: Text(
                                  (post.userName ?? 'U')[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFFE37083),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.userName ?? 'Unknown User',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter',
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule_rounded,
                                        size: 14,
                                        color: Colors.grey[500],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(post.communityPostCreatedAt),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Post content with better spacing
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Post title with modern styling
                            Container(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                post.communityPostTitle ?? '',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'League Spartan',
                                  color: Color(0xFF2D3748),
                                  height: 1.3,
                                ),
                              ),
                            ),

                            // Post content with improved readability
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE37083).withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                post.communityPostContent ?? '',
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.6,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF4A5568),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Post image with modern styling
                            buildImageSection(post),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Modern action buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFE37083).withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Reject button with modern styling
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: Colors.red.withOpacity(0.3),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.red.withOpacity(0.02),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.close_rounded,
                              color: Colors.red[600],
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Reject',
                              style: TextStyle(
                                color: Colors.red[600],
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Approve button with gradient
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE37083), Color(0xFFF49AA2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE37083).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isUpdatingPost
                            ? null
                            : () async {
                          await _approvePost(post);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isUpdatingPost
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                            : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Approve',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
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

  Future<void> _editPost(CommunityPostModel post) async {
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

  List<CommunityPostModel> get userPosts {
    if (currentUserId == null || communityGroup?.communityPostsDetail == null) {
      return [];
    }
    return communityGroup!.communityPostsDetail!
        .where(
          (post) =>
              post.userId == currentUserId &&
              (post.communityPostStatus?.toLowerCase() == 'active' ||
                  post.communityPostStatus?.toLowerCase() != 'inactive'),
        )
        .toList();
  }

  List<CommunityPostModel> get activePosts {
    if (communityGroup?.communityPostsDetail == null) {
      return [];
    }
    return communityGroup!.communityPostsDetail!
        .where(
          (post) =>
              post.communityPostStatus?.toLowerCase() == 'active' ||
              post.communityPostStatus?.toLowerCase() != 'inactive',
        )
        .toList();
  }

  List<CommunityPostModel> get pendingPosts {
    if (communityGroup?.communityPostsDetail == null) {
      return [];
    }
    return communityGroup!.communityPostsDetail!
        .where((post) => post.communityPostStatus?.toLowerCase() == 'inactive')
        .toList();
  }

  List<CommunityPostModel> get filteredActivePosts => _filterPosts(activePosts);

  List<CommunityPostModel> get filteredUserPosts => _filterPosts(userPosts);

  List<CommunityPostModel> get filteredPendingPosts => _filterPosts(pendingPosts);

  Future<void> _createCommunityPost({
    required String title,
    required String content,
    List<File>? imageFiles,
    VoidCallback? onCloseDialog,
    CommunityPostModel? editingPost,
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
        communityPostImageFiles: imageFiles,
        communityGroupId: widget.communityGroupId,
        communityPostStatus: postStatus,
      );

      // print('title ${createCommunityPostModel.communityPostTitle}, groupId ${createCommunityPostModel.communityGroupId}, image ${createCommunityPostModel.communityPostImageFile}');

      final result =
          editingPost != null
              ? await _communityUsecase.updateCommunityPost(
                editingPost.communityPostId!,
                createCommunityPostModel,
              )
              : await _communityUsecase.createCommunityPost(
                createCommunityPostModel,
              );

      if (result.isSuccess) {
        String message =
            editingPost != null
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
        communityGroup = result.data!;
        isLoading = false;
      });
      _refreshAnimatedLists();
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Fail to load group data. Please check your network and try again later';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging || _tabController.index != _tabController.previousIndex) {
        setState(() {});
      }
    });
    _communityUsecase = ref.read(communityUseCaseProvider);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();

    fetchCommunityGroupById();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _showCreatePostDialog({CommunityPostModel? editingPost}) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    List<File> selectedImages =[];

    if (editingPost != null) {
      titleController.text = editingPost.communityPostTitle ?? '';
      contentController.text = editingPost.communityPostContent ?? '';
    }
    bool isUpdating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> handleSubmit() async {
              if (titleController.text.trim().isEmpty ||
                  contentController.text.trim().isEmpty) {
                Notify.showFlushbar("All fields are required.", isError: true);
                return;
              }

              setState(() => isUpdating = true);

              await _createCommunityPost(
                title: titleController.text.trim(),
                content: contentController.text.trim(),
                imageFiles: selectedImages.isEmpty ? null : selectedImages,
                editingPost: editingPost,
                onCloseDialog: () {
                  Navigator.pop(context);
                },
              );

              setState(() => isUpdating = false);
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Title
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              editingPost != null ? 'Edit Post' : 'Create Post',
                              style: TextStyle(
                                fontFamily: 'League Spartan',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFFE37083),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: isUpdating ? null : () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.close, color: Colors.grey[600]),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),

                      /// Title field
                      TextField(
                        controller: titleController,
                        enabled: !isUpdating,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[500]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFE37083)),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// Content field
                      TextField(
                        controller: contentController,
                        enabled: !isUpdating,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Content',
                          labelStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[500]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFE37083)),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// Image picker
                      ElevatedButton.icon(
                        onPressed: isUpdating
                            ? null
                            : () async {
                          final picker = ImagePicker();
                          final pickedFiles = await picker.pickMultiImage();
                          if (pickedFiles.isNotEmpty) {
                            setState(() {
                              selectedImages!.addAll(pickedFiles.map((x) => File(x.path)));
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE37083),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.image),
                        label: const Text(
                          'Choose Images',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // ElevatedButton.icon(
                      //   onPressed: isUpdating
                      //       ? null
                      //       : () async {
                      //     final picker = ImagePicker();
                      //     final pickedFile = await picker.pickImage(
                      //         source: ImageSource.gallery);
                      //     if (pickedFile != null) {
                      //       setState(() {
                      //         selectedImages = File(pickedFile.path);
                      //       });
                      //     }
                      //   },
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Color(0xFFE37083),
                      //     foregroundColor: Colors.white,
                      //     minimumSize: const Size.fromHeight(50),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //   ),
                      //   icon: const Icon(Icons.image),
                      //   label: const Text(
                      //     'Choose Image',
                      //     style: TextStyle(
                      //       fontFamily: 'Inter',
                      //       fontWeight: FontWeight.w600,
                      //     ),
                      //   ),
                      // ),

                      // if (selectedImage != null)
                      //   Padding(
                      //     padding: const EdgeInsets.only(top: 12),
                      //     child: Row(
                      //       children: [
                      //         Icon(Icons.check_circle,
                      //             color: Color(0xFFE37083), size: 18),
                      //         const SizedBox(width: 8),
                      //         Expanded(
                      //           child: Text(
                      //             selectedImage!.path.split('/').last,
                      //             style: const TextStyle(
                      //               fontSize: 13,
                      //               fontFamily: 'Inter',
                      //               color: Colors.grey,
                      //             ),
                      //             overflow: TextOverflow.ellipsis,
                      //           ),
                      //         )
                      //       ],
                      //     ),
                      //   ),

                      if (selectedImages.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Column(
                            children: selectedImages.map((file) {
                              return Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Color(0xFFE37083), size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      file.path.split('/').last,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontFamily: 'Inter',
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                                    onPressed: isUpdating
                                        ? null
                                        : () {
                                      setState(() {
                                        selectedImages.remove(file);
                                      });
                                    },
                                  )
                                ],
                              );
                            }).toList(),
                          ),
                        ),


                      const SizedBox(height: 24),

                      /// Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isUpdating
                                  ? null
                                  : () {
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFE37083),
                                  width: 1.5,
                                ),
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                backgroundColor: Colors.transparent,
                                foregroundColor: Color(0xFFE37083),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isUpdating ? null : handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFE37083),
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: isUpdating
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : Text(
                                editingPost != null
                                    ? 'Update'
                                    : 'Create',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SafeArea(
        child: Scaffold(
          // backgroundColor: const Color(0xFFF49AA2).withOpacity(0.05),
          body: const Center(
            child: CircularProgressIndicator(color: Color(0xFFE37083)),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFF49AA2).withOpacity(0.05),
          body: Stack(
            children: [
              // Background image behind AppBar
              Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/community.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Spacer(),
                        const Text(
                          'Community',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'League Spartan',
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: _buildErrorWidget(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: const Color(0xFFF49AA2).withOpacity(0.05),
            body: Stack(
              children: [
                // Background image behind AppBar
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/community.png'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    // Custom AppBar
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                          const Text(
                            'Community',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'League Spartan',
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _showSearchOverlay = true;
                              });
                            },
                          ),
                          if (isCurrentUserAdmin)
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _updateCommunityGroup();
                                }
                              },
                              itemBuilder:
                                  (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            color: Color(0xFFE37083),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Edit Community',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                            ),
                          // else
                          //   const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    // Main container with rounded corners
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Community Info Header
                            Container(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                communityGroup?.communityName ??
                                                    '',
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFE37083),
                                                  fontFamily: 'League Spartan',
                                                ),
                                              ),
                                            ),
                                            if (isCurrentUserAdmin)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFE37083,
                                                  ).withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFFE37083,
                                                    ).withOpacity(0.3),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'ADMIN',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFE37083),
                                                    fontFamily: 'Inter',
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        const SizedBox(height: 8),

                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => CommunityMembersPage(
                                                        communityId: widget.communityGroupId,
                                                        communityName: communityGroup?.communityName ?? 'Community Group',
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Row(
                                                  children: [
                                                    // Up to 3 avatars
                                                    ...List.generate(
                                                      (communityGroup?.communityMembersDetail?.length ?? 0).clamp(0, 3),
                                                          (index) {
                                                        final member = communityGroup!.communityMembersDetail![index];
                                                        return Container(
                                                          margin: const EdgeInsets.only(right: 4),
                                                          width: 28,
                                                          height: 28,
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            border: Border.all(color: Colors.white, width: 1.5),
                                                            image: DecorationImage(
                                                              image: NetworkImage(
                                                                member.profilePicture ??
                                                                    'https://i.pravatar.cc/150?img=${index + 1}',
                                                              ),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),

                                                    // If more members exist, show +N circle
                                                    if ((communityGroup?.communityMembersDetail?.length ?? 0) > 3)
                                                      Container(
                                                        margin: const EdgeInsets.only(right: 8),
                                                        width: 28,
                                                        height: 28,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: const Color(0xFFE37083).withOpacity(0.2),
                                                          border: Border.all(
                                                            color: const Color(0xFFE37083).withOpacity(0.5),
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            '+${(communityGroup?.communityMembersDetail?.length ?? 0) - 3}',
                                                            style: const TextStyle(
                                                              color: Color(0xFFE37083),
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.bold,
                                                              fontFamily: 'Inter',
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                    // Participants text
                                                    Text(
                                                      '${communityGroup?.communityMembersDetail?.length ?? 0} participants',
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 14,
                                                        decoration: TextDecoration.underline,
                                                        fontFamily: 'Inter',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            if (currentUserId != null && !isCurrentUserAdmin)
                                              ElevatedButton(
                                                onPressed: isJoinLoading
                                                    ? null // disables button
                                                    : (isUserJoined ? _leaveCommunity : _joinCommunity),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isJoinLoading
                                                      ? Colors.grey.shade400
                                                      : const Color(0xFFE37083),
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  elevation: 2,
                                                ),
                                                child: isJoinLoading
                                                    ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                                    : Text(
                                                  isUserJoined ? 'Leave' : 'Join',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'Inter',
                                                  ),
                                                ),
                                              ),

                                          ],
                                        ),

                                        // InkWell(
                                        //   onTap:
                                        //       () => Navigator.push(
                                        //         context,
                                        //         MaterialPageRoute(
                                        //           builder:
                                        //               (
                                        //                 context,
                                        //               ) => CommunityMembersPage(
                                        //                 communityId:
                                        //                     widget
                                        //                         .communityGroupId,
                                        //                 communityName:
                                        //                     communityGroup
                                        //                         ?.communityName ??
                                        //                     'Community Group',
                                        //               ),
                                        //         ),
                                        //       ),
                                        //   child: Text(
                                        //     '${communityGroup?.communityMembersDetail?.length ?? 0} participants',
                                        //     style: const TextStyle(
                                        //       color: Colors.grey,
                                        //       fontSize: 14,
                                        //       decoration:
                                        //           TextDecoration.underline,
                                        //       fontFamily: 'Inter',
                                        //     ),
                                        //   ),
                                        // ),
                                        // const SizedBox(height: 16),
                                        // // Join/Leave Button (positioned under title)
                                        // if (currentUserId != null &&
                                        //     !isCurrentUserAdmin)
                                        //   isJoinLoading
                                        //       ? const SizedBox(
                                        //         width: 24,
                                        //         height: 24,
                                        //         child:
                                        //             CircularProgressIndicator(
                                        //               color: Color(0xFFE37083),
                                        //               strokeWidth: 2,
                                        //             ),
                                        //       )
                                        //       : SizedBox(
                                        //         width: double.infinity,
                                        //         child: ElevatedButton(
                                        //           onPressed:
                                        //               isUserJoined
                                        //                   ? _leaveCommunity
                                        //                   : _joinCommunity,
                                        //           style: ElevatedButton.styleFrom(
                                        //             backgroundColor:
                                        //                 isUserJoined
                                        //                     ? Colors.red
                                        //                     : const Color(
                                        //                       0xFFE37083,
                                        //                     ),
                                        //             foregroundColor:
                                        //                 Colors.white,
                                        //             padding:
                                        //                 const EdgeInsets.symmetric(
                                        //                   vertical: 16,
                                        //                 ),
                                        //             shape: RoundedRectangleBorder(
                                        //               borderRadius:
                                        //                   BorderRadius.circular(
                                        //                     12,
                                        //                   ),
                                        //             ),
                                        //             elevation: 2,
                                        //           ),
                                        //           child: Text(
                                        //             isUserJoined
                                        //                 ? 'Leave Community'
                                        //                 : 'Join Community',
                                        //             style: const TextStyle(
                                        //               fontSize: 16,
                                        //               fontWeight:
                                        //                   FontWeight.w600,
                                        //               fontFamily: 'Inter',
                                        //             ),
                                        //           ),
                                        //         ),
                                        //       ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Tab switch
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFF49AA2,
                                    ).withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  _buildTabButton(
                                    'Posts',
                                    _tabController.index == 0,
                                    () => _tabController.animateTo(0),
                                  ),
                                  const SizedBox(width: 4),
                                  _buildTabButton(
                                    'My Posts',
                                    _tabController.index == 1,
                                    () => _tabController.animateTo(1),
                                  ),
                                  if (isCurrentUserAdmin) ...[
                                    const SizedBox(width: 4),
                                    _buildTabButton(
                                      'Approve',
                                      _tabController.index == 2,
                                      () => _tabController.animateTo(2),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Tab Bar View
                            Expanded(
                              child: Container(
                                color: const Color(0xFFFFEBEE),
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildPostsTab(),
                                    _buildMyPostsTab(),
                                    if (isCurrentUserAdmin) _buildApproveTab(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_showSearchOverlay) _buildSearchOverlay(),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE37083) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color:
                  isSelected
                      ? const Color(0xFFE37083)
                      : const Color(0xFFF49AA2).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isSelected ? Colors.white : const Color(0xFFE37083),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostsTab() {
    final posts = filteredActivePosts;

    if (posts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.post_add,
        message: 'No posts found',
      );
    }

    return AnimatedList(
      key: _activePostListKey,
      initialItemCount: _animatedActivePosts.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index, animation) {
        final post = _animatedActivePosts[index];
        final isUserPost = post.userId == currentUserId;

        return SizeTransition(
          sizeFactor: animation,
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommunityPostDetailPage(
                  postId: post.communityPostId!,
                ),
              ),
            ),
            child: _buildStyledPostCard(
              post: post,
              communityName: communityGroup?.communityName ?? '',
              isUserPost: isUserPost,
              onEdit: isUserPost ? () => _editPost(post) : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyPostsTab() {
    final myPosts = filteredUserPosts;

    return Column(
      children: [
        if (isUserJoined)
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showCreatePostDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE37083),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Create New Post',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        Expanded(
          child: myPosts.isEmpty
              ? _buildEmptyState(
            icon: Icons.post_add,
            message: 'You haven\'t posted anything yet',
            subMessage: 'Tap "Create New Post" to share your thoughts',
          )
              : AnimatedList(
            key: _userPostListKey,
            initialItemCount: _animatedUserPosts.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index, animation) {
              final post = _animatedUserPosts[index];

              return SizeTransition(
                sizeFactor: animation,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommunityPostDetailPage(
                        postId: post.communityPostId!,
                      ),
                    ),
                  ),
                  child: _buildStyledPostCard(
                    post: post,
                    communityName: communityGroup?.communityName ?? '',
                    isUserPost: true,
                    onEdit: () => _editPost(post),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildApproveTab() {
    final pendingPostsList = filteredPendingPosts;

    if (pendingPostsList.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        message: 'No posts pending approval',
        subMessage: 'All posts have been reviewed',
      );
    }

    return AnimatedList(
      key: _pendingPostListKey,
      initialItemCount: _animatedPendingPosts.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index, animation) {
        final post = _animatedPendingPosts[index];

        return SizeTransition(
          sizeFactor: animation,
          child: GestureDetector(
            onTap: () => _showPostApprovalDialog(post),
            child: _buildStyledPostCard(
              post: post,
              communityName: communityGroup?.communityName ?? '',
              isUserPost: false,
              isPendingApproval: true,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStyledPostCard({
    required CommunityPostModel post,
    required String communityName,
    required bool isUserPost,
    VoidCallback? onEdit,
    bool isPendingApproval = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            isPendingApproval
                ? Border.all(color: const Color(0xFFE37083).withOpacity(0.3))
                : null,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE37083).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFE37083).withOpacity(0.2),
                  child: ClipOval(
                    child: Image.network(
                      post.profilePicture ?? '',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            (post.userName ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFFE37083),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFE37083),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
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
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFFE37083)),
                    onPressed: onEdit,
                  ),
              ],
            ),
          ),

          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.communityPostTitle ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'League Spartan',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.communityPostContent ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),

          // Post image
          buildImageSection(post),
          // if (post.communityPostImageUrl != null)
          //   Container(
          //     margin: const EdgeInsets.all(16),
          //     child: ClipRRect(
          //       borderRadius: BorderRadius.circular(12),
          //       child: Image.network(
          //         post.communityPostImageUrl ?? '',
          //         height: 200,
          //         width: double.infinity,
          //         fit: BoxFit.cover,
          //         errorBuilder: (context, error, stackTrace) {
          //           return Container(
          //             height: 200,
          //             color: const Color(0xFFF49AA2).withOpacity(0.1),
          //             child: const Center(
          //               child: Icon(
          //                 Icons.broken_image,
          //                 color: Color(0xFFE37083),
          //               ),
          //             ),
          //           );
          //         },
          //       ),
          //     ),
          //   ),

          // Post actions/stats
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.favorite_border, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '0',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.comment_outlined, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '0',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.share_outlined, size: 20, color: Colors.grey[600]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF49AA2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 48,
                    color: const Color(0xFFE37083),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE37083),
                    fontFamily: 'League Spartan',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage ?? 'Unknown error occurred',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: fetchCommunityGroupById,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE37083),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget _buildSearchOverlay() {
  //   return AnimatedOpacity(
  //     opacity: _showSearchOverlay ? 1.0 : 0.0,
  //     duration: const Duration(milliseconds: 300),
  //     child: GestureDetector(
  //       onTap: () {
  //         setState(() {
  //           _showSearchOverlay = false;
  //         });
  //       },
  //       child: Material(
  //         color: Colors.black.withOpacity(0.2),
  //         child: BackdropFilter(
  //           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
  //           child: Center(
  //             child: Container(
  //               margin: const EdgeInsets.symmetric(horizontal: 20),
  //               padding: const EdgeInsets.symmetric(
  //                 horizontal: 20,
  //                 vertical: 4,
  //               ),
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFFFFEBEE),
  //                 borderRadius: BorderRadius.circular(25),
  //                 border: Border.all(
  //                   color: const Color(0xFFE37083).withOpacity(0.5),
  //                   width: 1,
  //                 ),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: const Color(0xFFE37083).withOpacity(0.2),
  //                     blurRadius: 12,
  //                     offset: const Offset(0, 4),
  //                   ),
  //                 ],
  //               ),
  //               child: Row(
  //                 children: [
  //                   Icon(
  //                     Icons.search,
  //                     color: const Color(0xFFE37083).withOpacity(0.7),
  //                   ),
  //                   const SizedBox(width: 12),
  //                   Expanded(
  //                     child: TextField(
  //                       controller: _searchController,
  //                       autofocus: true,
  //                       onChanged: (value) {
  //                         setState(() {
  //                           _searchQuery = value;
  //                         });
  //                         _refreshAnimatedLists();
  //                       },
  //                       decoration: const InputDecoration(
  //                         hintText: 'Search Posts...',
  //                         border: InputBorder.none,
  //                         hintStyle: TextStyle(
  //                           fontFamily: 'Inter',
  //                           color: Colors.grey,
  //                         ),
  //                       ),
  //                       style: const TextStyle(fontFamily: 'Inter'),
  //                     ),
  //                   ),
  //                   if (_searchQuery.isNotEmpty)
  //                     IconButton(
  //                       icon: Icon(
  //                         Icons.clear,
  //                         color: const Color(0xFFE37083).withOpacity(0.7),
  //                       ),
  //                       onPressed: () {
  //                         _searchController.clear();
  //                         setState(() {
  //                           _searchQuery = '';
  //                         });
  //                       },
  //                     ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSearchOverlay() {
    return AnimatedOpacity(
      opacity: _showSearchOverlay ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showSearchOverlay = false;
          });
        },
        child: Material(
          color: Colors.black.withOpacity(0.2),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 60, // adjust as needed
                  left: 20,
                  right: 20,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFFE37083).withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE37083).withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: const Color(0xFFE37083).withOpacity(0.7),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                            _refreshAnimatedLists();
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search Posts...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.grey,
                            ),
                          ),
                          style: const TextStyle(fontFamily: 'Inter'),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: const Color(0xFFE37083).withOpacity(0.7),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    String? subMessage,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFF49AA2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              icon,
              size: 64,
              color: const Color(0xFFE37083).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontFamily: 'League Spartan',
            ),
            textAlign: TextAlign.center,
          ),
          if (subMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              subMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget buildImageSection(CommunityPostModel post) {
    // Convert single image URL to list for consistency
    List<String> imageUrls = [];
    if (post.communityPostImageUrls != null && post.communityPostImageUrls!.isNotEmpty) {
      // If it's a single string, convert to list
      if (post.communityPostImageUrls is String) {
        imageUrls = [post.communityPostImageUrls as String];
      } else if (post.communityPostImageUrls is List<String>) {
        imageUrls = post.communityPostImageUrls as List<String>;
      }
    }

    if (imageUrls.isEmpty) return SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: _buildImageGrid(imageUrls),
    );
  }

  Widget _buildImageGrid(List<String> imageUrls) {
    if (imageUrls.isEmpty) return SizedBox.shrink();

    if (imageUrls.length == 1) {
      // Single image
      return GestureDetector(
        onTap: () => _openImageOverlay(imageUrls, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrls[0],
            width: double.infinity,
            height: 120, // ⬅️ reduced from 200
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 120,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.image_not_supported),
                ),
              );
            },
          ),
        ),
      );
    } else if (imageUrls.length == 2) {
      // Two images side by side
      return Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _openImageOverlay(imageUrls, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrls[0],
                  height: 120, // ⬅️ reduced from 200
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => _openImageOverlay(imageUrls, 1),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrls[1],
                  height: 120, // ⬅️ reduced from 200
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // More than 2 images
      return Column(
        children: [
          // First row with 2 images
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _openImageOverlay(imageUrls, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrls[0],
                      height: 120, // ⬅️ reduced from 200
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.image_not_supported),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: GestureDetector(
                  onTap: () => _openImageOverlay(imageUrls, 1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrls[1],
                      height: 120, // ⬅️ reduced from 200
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.image_not_supported),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Second row with third image (blurred) and remaining count
          GestureDetector(
            onTap: () => _openImageOverlay(imageUrls, 2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.network(
                    imageUrls[2],
                    width: double.infinity,
                    height: 100, // ⬅️ reduced from 150
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.image_not_supported),
                        ),
                      );
                    },
                  ),
                  // Blur overlay
                  Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black.withOpacity(0.4),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 30,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '+${imageUrls.length - 2}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }


  // Widget _buildImageGrid(List<String> imageUrls) {
  //   if (imageUrls.isEmpty) return SizedBox.shrink();
  //
  //   if (imageUrls.length == 1) {
  //     // Single image
  //     return GestureDetector(
  //       onTap: () => _openImageOverlay(imageUrls, 0),
  //       child: ClipRRect(
  //         borderRadius: BorderRadius.circular(12),
  //         child: Image.network(
  //           imageUrls[0],
  //           width: double.infinity,
  //           height: 200,
  //           fit: BoxFit.cover,
  //           errorBuilder: (context, error, stackTrace) {
  //             return Container(
  //               height: 200,
  //               color: Colors.grey[200],
  //               child: const Center(
  //                 child: Icon(Icons.image_not_supported),
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     );
  //   } else if (imageUrls.length == 2) {
  //     // Two images side by side
  //     return Row(
  //       children: [
  //         Expanded(
  //           child: GestureDetector(
  //             onTap: () => _openImageOverlay(imageUrls, 0),
  //             child: ClipRRect(
  //               borderRadius: BorderRadius.circular(12),
  //               child: Image.network(
  //                 imageUrls[0],
  //                 height: 200,
  //                 fit: BoxFit.cover,
  //                 errorBuilder: (context, error, stackTrace) {
  //                   return Container(
  //                     height: 200,
  //                     color: Colors.grey[200],
  //                     child: const Center(
  //                       child: Icon(Icons.image_not_supported),
  //                     ),
  //                   );
  //                 },
  //               ),
  //             ),
  //           ),
  //         ),
  //         const SizedBox(width: 4),
  //         Expanded(
  //           child: GestureDetector(
  //             onTap: () => _openImageOverlay(imageUrls, 1),
  //             child: ClipRRect(
  //               borderRadius: BorderRadius.circular(12),
  //               child: Image.network(
  //                 imageUrls[1],
  //                 height: 200,
  //                 fit: BoxFit.cover,
  //                 errorBuilder: (context, error, stackTrace) {
  //                   return Container(
  //                     height: 200,
  //                     color: Colors.grey[200],
  //                     child: const Center(
  //                       child: Icon(Icons.image_not_supported),
  //                     ),
  //                   );
  //                 },
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     );
  //   } else {
  //     // More than 2 images - show first 2 and third with blur + count
  //     return Column(
  //       children: [
  //         // First row with 2 images
  //         Row(
  //           children: [
  //             Expanded(
  //               child: GestureDetector(
  //                 onTap: () => _openImageOverlay(imageUrls, 0),
  //                 child: ClipRRect(
  //                   borderRadius: BorderRadius.circular(12),
  //                   child: Image.network(
  //                     imageUrls[0],
  //                     height: 200,
  //                     fit: BoxFit.cover,
  //                     errorBuilder: (context, error, stackTrace) {
  //                       return Container(
  //                         height: 200,
  //                         color: Colors.grey[200],
  //                         child: const Center(
  //                           child: Icon(Icons.image_not_supported),
  //                         ),
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(width: 4),
  //             Expanded(
  //               child: GestureDetector(
  //                 onTap: () => _openImageOverlay(imageUrls, 1),
  //                 child: ClipRRect(
  //                   borderRadius: BorderRadius.circular(12),
  //                   child: Image.network(
  //                     imageUrls[1],
  //                     height: 200,
  //                     fit: BoxFit.cover,
  //                     errorBuilder: (context, error, stackTrace) {
  //                       return Container(
  //                         height: 200,
  //                         color: Colors.grey[200],
  //                         child: const Center(
  //                           child: Icon(Icons.image_not_supported),
  //                         ),
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 4),
  //         // Second row with third image (blurred) and remaining count
  //         GestureDetector(
  //           onTap: () => _openImageOverlay(imageUrls, 2),
  //           child: ClipRRect(
  //             borderRadius: BorderRadius.circular(12),
  //             child: Stack(
  //               children: [
  //                 Image.network(
  //                   imageUrls[2],
  //                   width: double.infinity,
  //                   height: 150,
  //                   fit: BoxFit.cover,
  //                   errorBuilder: (context, error, stackTrace) {
  //                     return Container(
  //                       height: 150,
  //                       color: Colors.grey[200],
  //                       child: const Center(
  //                         child: Icon(Icons.image_not_supported),
  //                       ),
  //                     );
  //                   },
  //                 ),
  //                 // Blur overlay
  //                 Container(
  //                   width: double.infinity,
  //                   height: 150,
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(12),
  //                     color: Colors.black.withOpacity(0.4),
  //                   ),
  //                   child: Center(
  //                     child: Column(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         const Icon(
  //                           Icons.add,
  //                           color: Colors.white,
  //                           size: 30,
  //                         ),
  //                         const SizedBox(height: 8),
  //                         Text(
  //                           '+${imageUrls.length - 2}',
  //                           style: const TextStyle(
  //                             color: Colors.white,
  //                             fontSize: 18,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     );
  //   }
  // }

  void _openImageOverlay(List<String> imageUrls, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ImageOverlayViewer(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        ),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        opaque: false,
      ),
    );
  }
}

class ImageOverlayViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageOverlayViewer({
    Key? key,
    required this.imageUrls,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<ImageOverlayViewer> createState() => _ImageOverlayViewerState();
}

class _ImageOverlayViewerState extends State<ImageOverlayViewer>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: Colors.black.withOpacity(0.9),
              child: Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              currentIndex = index;
                            });
                          },
                          itemCount: widget.imageUrls.length,
                          itemBuilder: (context, index) {
                            return InteractiveViewer(
                              child: Image.network(
                                widget.imageUrls[index],
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${currentIndex + 1} / ${widget.imageUrls.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}