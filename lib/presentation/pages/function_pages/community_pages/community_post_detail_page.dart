import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/core/utils/signalr_service.dart';
import 'package:inner_child_app/domain/entities/community/community_post_comment_model.dart';
import 'package:inner_child_app/domain/entities/community/community_post_model.dart';
import 'package:inner_child_app/domain/entities/community/create_comment_model.dart';
import 'package:inner_child_app/domain/entities/community/create_community_post_model.dart';
import 'dart:io';

import 'package:inner_child_app/domain/usecases/community_usecase.dart';

class CommunityPostDetailPage extends ConsumerStatefulWidget {
  final String postId;

  const CommunityPostDetailPage({super.key, required this.postId});

  @override
  ConsumerState<CommunityPostDetailPage> createState() =>
      _CommunityPostDetailPageState();
}

class _CommunityPostDetailPageState
    extends ConsumerState<CommunityPostDetailPage>
    with TickerProviderStateMixin {
  late final CommunityUsecase _communityUsecase;
  late final SignalRService _signalRService;

  // final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  late CommunityPostModel postDetail;
  List<CommunityPostModel> otherPosts = [];
  bool isLoading = true;
  bool isLoadingOtherPosts = false;
  bool hasErrorOtherPosts = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Ice cream color theme
  static const Color primaryIceCream = Color(0xFFF49AA2);
  static const Color lightIceCream = Color(0xFFFDF2F3);
  static const Color darkIceCream = Color(0xFFE88A95);
  static const Color veryLightIceCream = Color(0xFFFEF9FA);
  static const Color cardBackground = Colors.white;
  static const Color textDark = Color(0xFF2D2D2D);
  static const Color textGray = Color(0xFF666666);
  static const Color borderColor = Color(0xFFF0F0F0);

  String? get currentUserId => ref.watch(authNotifierProvider).userInfo?.userId;

  String? get currentProfileId =>
      ref.watch(authNotifierProvider).userInfo?.profileId;

  String? replyingToCommentId;
  String? replyingToUserName;
  bool showCommentInput = false;
  final TextEditingController _commentController = TextEditingController();
  List<File> _selectedImages = [];
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _communityUsecase = ref.read(communityUseCaseProvider);
    _signalRService = ref.read(signalRServiceProvider);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fetchPostDetail();
    _setupSignalRConnection();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _commentController.dispose();

    _signalRService.unregisterPostConnection();
    super.dispose();
  }

  Future<void> _setupSignalRConnection() async {
    try {
      // Register this post for real-time updates
      await _signalRService.registerPostConnection(widget.postId);

      // Listen for post updates (including new comments)
      _signalRService.onPostUpdate((args) {
        print('invoke');
        if (args != null && args.isNotEmpty) {
          // final data = args[0] as Map<String, dynamic>?;
          final data = args[0] as String? ?? 'ReceiveMessage';
          if (data != null) {
            // _handlePostUpdate(data);
            refreshComment();
          }
        }
      });

      debugPrint(
        "✅ SignalR post connection established for post: ${widget.postId}",
      );
    } catch (e) {
      debugPrint("❌ Failed to setup SignalR connection: $e");
    }
  }

  // void _handlePostUpdate(Map<String, dynamic> data) {
  //   final updateType = data['type'] as String?;
  //
  //   switch (updateType) {
  //     case 'new_comment':
  //       _handleNewComment(data['comment']);
  //       break;
  //     // case 'comment_liked':
  //     //   _handleCommentLiked(data);
  //     //   break;
  //     // case 'comment_deleted':
  //     //   _handleCommentDeleted(data['commentId']);
  //     //   break;
  //     // case 'post_updated':
  //     //   _handlePostUpdated(data);
  //     //   break;
  //     default:
  //       debugPrint("Unknown post update type: $updateType");
  //   }
  // }

  Future<void> _fetchPostDetail() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await _communityUsecase.getCommunityPostDetail(
        widget.postId,
      );
      if (result.isSuccess) {
        setState(() {
          postDetail = result.data!;
        });
        _animationController.forward();
      } else {
        Notify.showFlushbar(
          result.error ?? 'Failed to load post details',
          isError: true,
        );
      }
    } catch (e) {
      Notify.showFlushbar('Error while getting post detail', isError: true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> refreshComment() async {
    try {
      final result = await _communityUsecase.getCommunityPostDetail(
        widget.postId,
      );
      if (result.isSuccess) {
        if (mounted) {  // Thêm kiểm tra này
          setState(() {
            postDetail = result.data!;
          });
          _animationController.forward();
        }
      } else {
        Notify.showFlushbar(
          result.error ?? 'Failed to refresh comment',
          isError: true,
        );
      }
    } catch (e) {
      print('error ne: $e.toString()');
      Notify.showFlushbar('Error while refresh comment', isError: true);
    } finally {
      if (mounted) {  // Thêm kiểm tra này
        setState(() {
          isLoading = false;
        });
      }
    }
  }

//Ban refreshcomment nay bi loi: flutter ( 3981): error ne: setState() called after dispose():
  // Future<void> refreshComment() async {
  //   // setState(() {
  //   //   isLoading = true;
  //   // });
  //   try {
  //     final result = await _communityUsecase.getCommunityPostDetail(
  //       widget.postId,
  //     );
  //     if (result.isSuccess) {
  //       setState(() {
  //         postDetail = result.data!;
  //       });
  //       _animationController.forward();
  //     } else {
  //       Notify.showFlushbar(
  //         result.error ?? 'Failed to refresh comment',
  //         isError: true,
  //       );
  //     }
  //   } catch (e) {
  //     print('error ne: $e.toString()');
  //     Notify.showFlushbar('Error while refresh comment', isError: true);
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  // Future<void> _likePost() async {
  //   try {
  //     final result = await _communityUsecase.likePost(
  //       postDetail.communityPostId!,
  //     );
  //     if (result.isSuccess) {
  //       setState(() {
  //         postDetail = postDetail.copyWith(
  //           isLikedByCurrentUser: !postDetail.isLikedByCurrentUser!,
  //           likeCount:
  //               postDetail.isLikedByCurrentUser!
  //                   ? postDetail.likeCount! - 1
  //                   : postDetail.likeCount! + 1,
  //         );
  //       });
  //     }
  //   } catch (e) {
  //     Notify.showFlushbar('Error while like the post.Please try again later', isError: true);
  //   }
  // }

  // Future<void> _toggleLikePost() async {
  //   try {
  //     final isLiked = postDetail.isLikedByCurrentUser ?? false;
  //
  //     final result = isLiked
  //         ? await _communityUsecase.unlikePost(postDetail.communityPostId!)
  //         : await _communityUsecase.likePost(postDetail.communityPostId!);
  //
  //     if (result.isSuccess) {
  //       setState(() {
  //         postDetail = postDetail.copyWith(
  //           isLikedByCurrentUser: !isLiked,
  //           likeCount: isLiked
  //               ? (postDetail.likeCount ?? 1) - 1
  //               : (postDetail.likeCount ?? 0) + 1,
  //         );
  //       });
  //     } else {
  //       Notify.showFlushbar(result.error ?? 'Failed to update like', isError: true);
  //     }
  //   } catch (e) {
  //     Notify.showFlushbar(
  //       'Error while updating like for the post. Please try again later.',
  //       isError: true,
  //     );
  //   }
  // }

  Future<void> _toggleLikePost() async {
    final oldIsLiked = postDetail.isLikedByCurrentUser ?? false;
    final oldLikeCount = postDetail.likeCount ?? 0;

    // Optimistic update
    setState(() {
      postDetail = postDetail.copyWith(
        isLikedByCurrentUser: !oldIsLiked,
        likeCount: oldIsLiked ? oldLikeCount - 1 : oldLikeCount + 1,
      );
    });

    try {
      final result =
          oldIsLiked
              ? await _communityUsecase.unlikePost(postDetail.communityPostId!)
              : await _communityUsecase.likePost(postDetail.communityPostId!);

      if (!result.isSuccess) {
        // Revert UI if API fails
        setState(() {
          postDetail = postDetail.copyWith(
            isLikedByCurrentUser: oldIsLiked,
            likeCount: oldLikeCount,
          );
        });
        Notify.showFlushbar(
          result.error ?? 'Failed to update post like.',
          isError: true,
        );
      }
    } catch (e) {
      // Revert UI if API throws
      setState(() {
        postDetail = postDetail.copyWith(
          isLikedByCurrentUser: oldIsLiked,
          likeCount: oldLikeCount,
        );
      });
      print('[ERROR] _toggleLikePost: $e');
      Notify.showFlushbar(
        'Error while updating post like. Please try again later.',
        isError: true,
      );
    }
  }

  // Future<void> _likeComment(String commentId, bool isLiked) async {
  //   try {
  //     final result = await _communityUsecase.likeComment(commentId);
  //     if (result.isSuccess) {
  //       setState(() {
  //         _updateCommentLikeStatus(postDetail!.comments!, commentId, isLiked);
  //       });
  //     }
  //   } catch (e) {
  //     Notify.showFlushbar('Error while like comment.Please try again later', isError: true);
  //   }
  // }

  // Future<void> _toggleLikeComment(String commentId, bool isLiked) async {
  //   try {
  //     final result = isLiked
  //         ? await _communityUsecase.unlikeComment(commentId)
  //         : await _communityUsecase.likeComment(commentId);
  //
  //     if (result.isSuccess) {
  //       setState(() {
  //         _updateCommentLikeStatus(postDetail.comments!, commentId, isLiked);
  //       });
  //     } else {
  //       Notify.showFlushbar(result.error ?? 'Failed to update comment like', isError: true);
  //     }
  //   } catch (e) {
  //     Notify.showFlushbar(
  //       'Error while updating comment like. Please try again later.',
  //       isError: true,
  //     );
  //   }
  // }

  Future<void> _toggleLikeComment(String commentId, bool isLiked) async {
    // Save old state
    final comment = _findCommentById(postDetail.comments!, commentId);
    if (comment == null) return;

    final oldIsLiked = comment.isLikedByCurrentUser ?? false;
    final oldLikeCount = comment.likeCount ?? 0;

    // Optimistic update
    setState(() {
      _updateCommentLikeStatus(postDetail.comments!, commentId, oldIsLiked);
    });

    try {
      final result =
          oldIsLiked
              ? await _communityUsecase.unlikeComment(commentId)
              : await _communityUsecase.likeComment(commentId);

      if (!result.isSuccess) {
        // Revert on failure
        setState(() {
          _updateCommentLikeStatus(
            postDetail.comments!,
            commentId,
            !oldIsLiked,
          );
        });
        Notify.showFlushbar(
          result.error ?? 'Failed to update comment like.',
          isError: true,
        );
      }
    } catch (e) {
      setState(() {
        _updateCommentLikeStatus(postDetail.comments!, commentId, !oldIsLiked);
      });
      print('[ERROR] _toggleLikeComment: $e');
      Notify.showFlushbar(
        'Error while updating comment like. Please try again later.',
        isError: true,
      );
    }
  }

  CommunityPostCommentModel? _findCommentById(
    List<CommunityPostCommentModel> comments,
    String commentId,
  ) {
    for (final comment in comments) {
      if (comment.commentId == commentId) {
        return comment;
      }
      if (comment.comments != null && comment.comments!.isNotEmpty) {
        final found = _findCommentById(comment.comments!, commentId);
        if (found != null) return found;
      }
    }
    return null;
  }

  void _updateCommentLikeStatus(
    List<CommunityPostCommentModel> comments,
    String commentId,
    bool isLiked,
  ) {
    for (int i = 0; i < comments.length; i++) {
      if (comments[i].commentId == commentId) {
        comments[i] = comments[i].copyWith(
          isLikedByCurrentUser: !isLiked,
          likeCount:
              isLiked ? comments[i].likeCount! - 1 : comments[i].likeCount! + 1,
        );
        return;
      }
      if (comments[i].comments != null && comments[i].comments!.isNotEmpty) {
        _updateCommentLikeStatus(comments[i].comments!, commentId, isLiked);
      }
    }
  }

  Future<void> _addComment(
    String content, {
    String? replyToCommentId,
    List<File>? images,
  }) async {
    if (content.trim().isEmpty) return;

    try {
      final commentCreateModel = CreateCommentModel(
        postId: widget.postId,
        content: content,
        replyToCommentId: replyToCommentId,
        images: images,
      );
      final result = await _communityUsecase.createComment(
        commentCreateModel,
        // postId: widget.postId,
        // content: content,
        // replyToCommentId: replyToCommentId,
        // images: images,
      );
      if (result.isSuccess) {
        // refreshComment();
        // _fetchPostDetail(); // Refresh to get updated comments
      }
    } catch (e) {
      Notify.showFlushbar('Error: ${e.toString()}', isError: true);
    }
  }

  // void _handleNewComment() async {
  //   List<CommunityPostCommentModel> newCommentList = [];
  //   try {
  //     final result = await _communityUsecase.getCommunityPostDetail(
  //       widget.postId,
  //     );
  //     if (result.isSuccess) {
  //       newCommentList = result.data!.comments ?? [];
  //     } else {
  //       Notify.showFlushbar(
  //         result.error ?? 'Failed to load new comment details',
  //         isError: true,
  //       );
  //     }
  //
  //     // final newComment = CommunityPostCommentModel.fromJson(commentData);
  //
  //     setState(() {
  //       if (newComment.replyToCommentId != null) {
  //         // It's a reply, add it to the parent comment
  //         _addReplyToComment(newComment.replyToCommentId!, newComment);
  //       } else {
  //         // It's a new top-level comment
  //         if (postDetail.comments == null) {
  //           postDetail.comments = [];
  //         }
  //         postDetail.comments!.insert(0, newComment);
  //       }
  //
  //       // Update comment count if your model has it
  //       // postDetail.commentCount = (postDetail.commentCount ?? 0) + 1;
  //     });
  //
  //     // Show a subtle notification if it's not the current user's comment
  //     if (newComment.userId != currentUserId) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('${newComment.userName} added a comment'),
  //           duration: const Duration(seconds: 2),
  //           backgroundColor: primaryIceCream,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint("Error handling new comment: $e");
  //   }
  // }

  //   Future<void> _addComment(
  //       String content, {
  //         String? replyToCommentId,
  //         List<File>? images,
  //       }) async {
  //     if (content.trim().isEmpty) return;
  //
  //     try {
  //       final commentCreateModel = CreateCommentModel(
  //         postId: widget.postId,
  //         content: content,
  //         replyToCommentId: replyToCommentId,
  //         images: images,
  //       );
  //
  //       final result = await _communityUsecase.createComment(commentCreateModel);
  //
  //       if (result.isSuccess && result.data != null) {
  //         // Get the newly created comment from the API response
  //         final newComment = result.data!; // This should be CommunityPostCommentModel
  //
  //         setState(() {
  //           if (replyToCommentId != null) {
  //             // Add reply to existing comment
  //             _addReplyToComment(replyToCommentId, newComment);
  //           } else {
  //             // Add new comment to post
  //             if (postDetail.comments == null) {
  //               postDetail.comments = [];
  //             }
  //             postDetail.comments!.insert(0, newComment); // Insert at beginning for newest first
  //           }
  //
  //           // Update comment count
  //           if (postDetail.comments != null) {
  //             // You might need to update this based on your model structure
  //             // postDetail.commentCount = postDetail.comments!.length;
  //           }
  //         });
  //       } else {
  //         // Fallback to refresh if API doesn't return the comment
  //         _fetchPostDetail();
  //       }
  //     } catch (e) {
  //       Notify.showFlushbar('Error: ${e.toString()}', isError: true);
  //     }
  //   }
  //
  // // Helper method to add reply to nested comment structure
  //   void _addReplyToComment(String parentCommentId, CommunityPostCommentModel newReply) {
  //     bool addReplyRecursively(List<CommunityPostCommentModel> comments) {
  //       for (var comment in comments) {
  //         if (comment.commentId == parentCommentId) {
  //           // Found the parent comment, add reply
  //           if (comment.comments == null) {
  //             comment.comments = [];
  //           }
  //           comment.comments!.insert(0, newReply); // Insert at beginning
  //           return true;
  //         }
  //
  //         // Search in nested comments
  //         if (comment.comments != null && comment.comments!.isNotEmpty) {
  //           if (addReplyRecursively(comment.comments!)) {
  //             return true;
  //           }
  //         }
  //       }
  //       return false;
  //     }
  //
  //     if (postDetail.comments != null) {
  //       addReplyRecursively(postDetail.comments!);
  //     }
  //   }

  Future<void> _deleteComment(String commentId) async {
    try {
      // final result = await _communityUsecase.deleteComment(commentId);
      final result = Result.success('');
      if (result.isSuccess) {
        _fetchPostDetail(); // Refresh to get updated comments
      }
    } catch (e) {
      Notify.showFlushbar('Error: ${e.toString()}', isError: true);
    }
  }

  void _showImageOverlay(List<String> imageUrls, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder:
          (context) => ImageOverlayViewer(
            imageUrls: imageUrls,
            initialIndex: initialIndex,
          ),
    );
  }

  // void _showCommentDialog({String? replyToCommentId, String? replyToUserName}) {
  //   final TextEditingController contentController = TextEditingController();
  //   List<File> selectedImages = [];
  //   bool isSubmitting = false;
  //
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return Dialog(
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(16),
  //             ),
  //             child: Container(
  //               width: MediaQuery.of(context).size.width * 0.9,
  //               padding: const EdgeInsets.all(20),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: Text(
  //                           replyToCommentId != null
  //                               ? 'Reply to $replyToUserName'
  //                               : 'Add Comment',
  //                           style: const TextStyle(
  //                             fontSize: 18,
  //                             fontWeight: FontWeight.bold,
  //                             color: primaryIceCream,
  //                           ),
  //                         ),
  //                       ),
  //                       IconButton(
  //                         onPressed:
  //                             isSubmitting
  //                                 ? null
  //                                 : () => Navigator.pop(context),
  //                         icon: Icon(Icons.close, color: Colors.grey[600]),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 16),
  //                   TextField(
  //                     controller: contentController,
  //                     enabled: !isSubmitting,
  //                     maxLines: 4,
  //                     decoration: InputDecoration(
  //                       hintText: 'Write your comment...',
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(8),
  //                         borderSide: const BorderSide(color: borderColor),
  //                       ),
  //                       focusedBorder: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(8),
  //                         borderSide: const BorderSide(color: primaryIceCream),
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(height: 16),
  //                   Row(
  //                     children: [
  //                       ElevatedButton.icon(
  //                         onPressed:
  //                             isSubmitting
  //                                 ? null
  //                                 : () async {
  //                                   final picker = ImagePicker();
  //                                   final pickedFiles =
  //                                       await picker.pickMultiImage();
  //                                   if (pickedFiles.isNotEmpty) {
  //                                     setState(() {
  //                                       selectedImages.addAll(
  //                                         pickedFiles.map((e) => File(e.path)),
  //                                       );
  //                                     });
  //                                   }
  //                                 },
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: lightIceCream,
  //                           foregroundColor: primaryIceCream,
  //                         ),
  //                         icon: const Icon(Icons.image, size: 20),
  //                         label: const Text('Add Images'),
  //                       ),
  //                       const SizedBox(width: 8),
  //                       Text(
  //                         '${selectedImages.length} selected',
  //                         style: const TextStyle(color: textGray),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 16),
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: OutlinedButton(
  //                           onPressed:
  //                               isSubmitting
  //                                   ? null
  //                                   : () => Navigator.pop(context),
  //                           style: OutlinedButton.styleFrom(
  //                             side: const BorderSide(color: primaryIceCream),
  //                             foregroundColor: primaryIceCream,
  //                           ),
  //                           child: const Text('Cancel'),
  //                         ),
  //                       ),
  //                       const SizedBox(width: 16),
  //                       Expanded(
  //                         child: ElevatedButton(
  //                           onPressed:
  //                               isSubmitting
  //                                   ? null
  //                                   : () async {
  //                                     setState(() => isSubmitting = true);
  //                                     await _addComment(
  //                                       contentController.text,
  //                                       replyToCommentId: replyToCommentId,
  //                                       images: selectedImages,
  //                                     );
  //                                     setState(() => isSubmitting = false);
  //                                     Navigator.pop(context);
  //                                   },
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: primaryIceCream,
  //                             foregroundColor: Colors.white,
  //                           ),
  //                           child:
  //                               isSubmitting
  //                                   ? const SizedBox(
  //                                     width: 20,
  //                                     height: 20,
  //                                     child: CircularProgressIndicator(
  //                                       strokeWidth: 2,
  //                                       color: Colors.white,
  //                                     ),
  //                                   )
  //                                   : const Text('Post'),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  void _showCommentDialog({String? replyToCommentId, String? replyToUserName}) {
    setState(() {
      if (replyToCommentId != null) {
        // Reply to specific comment
        replyingToCommentId = replyToCommentId;
        replyingToUserName = replyToUserName;
      } else {
        // New comment on post
        replyingToCommentId = null;
        replyingToUserName = null;
      }
      showCommentInput = true;
      _commentController.clear();
      _selectedImages.clear();
    });
  }

  void _cancelComment() {
    setState(() {
      showCommentInput = false;
      replyingToCommentId = null;
      replyingToUserName = null;
      _commentController.clear();
      _selectedImages.clear();
    });
  }

  void _showPostOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: primaryIceCream),
                title: const Text('Edit Post'),
                onTap: () {
                  Navigator.pop(context);
                  _showUpdatePostDialog(editingPost: postDetail);
                  // _showCreatePostDialog(editingPost: postDetail);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.grey),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  void _showCommentOptions(CommunityPostCommentModel comment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Comment'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteComment(comment.commentId!);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.grey),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  String _formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: veryLightIceCream,
      appBar: AppBar(
        backgroundColor: cardBackground,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: textDark),
        ),
        title: const Text(
          'Post Details',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body:
      isLoading
          ? const Center(
        child: CircularProgressIndicator(color: primaryIceCream),
      )
          : postDetail == null
          ? const Center(child: Text('Post not found'))
          : FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPostCard(),
                const SizedBox(height: 24),
                _buildCommentsSection(),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightIceCream.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (replyingToCommentId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Replying to $replyingToUserName',
                style: const TextStyle(
                  color: primaryIceCream,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          TextField(
            controller: _commentController,
            enabled: !_isSubmittingComment,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  replyingToCommentId != null
                      ? 'Write your reply...'
                      : 'Write your comment...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: primaryIceCream),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed:
                    _isSubmittingComment
                        ? null
                        : () async {
                          final picker = ImagePicker();
                          final pickedFiles = await picker.pickMultiImage();
                          if (pickedFiles.isNotEmpty) {
                            setState(() {
                              _selectedImages.addAll(
                                pickedFiles.map((e) => File(e.path)),
                              );
                            });
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: lightIceCream,
                  foregroundColor: primaryIceCream,
                ),
                icon: const Icon(Icons.image, size: 16),
                label: const Text('Images'),
              ),
              const SizedBox(width: 8),
              if (_selectedImages.isNotEmpty)
                Text(
                  '${_selectedImages.length} selected',
                  style: const TextStyle(color: textGray, fontSize: 12),
                ),
              const Spacer(),
              TextButton(
                onPressed: _isSubmittingComment ? null : _cancelComment,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed:
                    _isSubmittingComment
                        ? null
                        : () async {
                          if (_commentController.text.trim().isEmpty) return;

                          setState(() => _isSubmittingComment = true);
                          await _addComment(
                            _commentController.text,
                            replyToCommentId: replyingToCommentId,
                            images: _selectedImages,
                          );
                          setState(() => _isSubmittingComment = false);
                          _cancelComment();
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryIceCream,
                  foregroundColor: Colors.white,
                ),
                child:
                    _isSubmittingComment
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Post'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard() {
    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: lightIceCream,
                backgroundImage:
                    postDetail?.profilePicture != null
                        ? NetworkImage(postDetail!.profilePicture!)
                        : null,
                child:
                    postDetail?.profilePicture == null
                        ? const Icon(Icons.person, color: primaryIceCream)
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      postDetail?.userName ?? 'Unknown User',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textDark,
                      ),
                    ),
                    Text(
                      _formatTimeAgo(postDetail?.communityPostCreatedAt),
                      style: const TextStyle(color: textGray, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (currentUserId == postDetail?.userId)
                IconButton(
                  onPressed: _showPostOptions,
                  icon: const Icon(Icons.more_vert, color: textGray),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (postDetail?.communityPostTitle != null)
            Text(
              postDetail!.communityPostTitle!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            postDetail?.communityPostContent ?? '',
            style: const TextStyle(fontSize: 16, color: textDark, height: 1.4),
          ),

          buildPostDetailImageSection(postDetail),
          // if (postDetail?.communityPostImageUrl != null) ...[
          //   const SizedBox(height: 16),
          //   GestureDetector(
          //     onTap:
          //         () => _showImageOverlay([
          //           postDetail!.communityPostImageUrl!,
          //         ], 0),
          //     child: ClipRRect(
          //       borderRadius: BorderRadius.circular(12),
          //       child: Image.network(
          //         postDetail!.communityPostImageUrl!,
          //         width: double.infinity,
          //         height: 200,
          //         fit: BoxFit.cover,
          //       ),
          //     ),
          //   ),
          // ],
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: _toggleLikePost,
                child: Row(
                  children: [
                    Icon(
                      postDetail?.isLikedByCurrentUser == true
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          postDetail?.isLikedByCurrentUser == true
                              ? Colors.red
                              : textGray,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${postDetail?.likeCount ?? 0}',
                      style: const TextStyle(color: textGray),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: () => _showCommentDialog(),
                child: Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      color: textGray,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${postDetail?.comments?.length ?? 0}',
                      style: const TextStyle(color: textGray),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildCommentsSection() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: cardBackground,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 10,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     padding: const EdgeInsets.all(20),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             const Text(
  //               'Comments',
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //                 color: textDark,
  //               ),
  //             ),
  //             const Spacer(),
  //             TextButton.icon(
  //               onPressed: () => _showCommentDialog(),
  //               icon: const Icon(Icons.add, color: primaryIceCream, size: 20),
  //               label: const Text(
  //                 'Add Comment',
  //                 style: TextStyle(color: primaryIceCream),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         if (postDetail?.comments?.isEmpty == true)
  //           const Center(
  //             child: Text(
  //               'No comments yet. Be the first to comment!',
  //               style: TextStyle(color: textGray),
  //             ),
  //           )
  //         else
  //           ListView.builder(
  //             shrinkWrap: true,
  //             physics: const NeverScrollableScrollPhysics(),
  //             itemCount: postDetail?.comments?.length ?? 0,
  //             itemBuilder: (context, index) {
  //               final comment = postDetail!.comments![index];
  //               return _buildCommentCard(comment, 0);
  //             },
  //           ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCommentsSection() {
    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Comments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showCommentDialog(),
                icon: const Icon(Icons.add, color: primaryIceCream, size: 20),
                label: const Text(
                  'Add Comment',
                  style: TextStyle(color: primaryIceCream),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Show comment input at top when commenting on post
          if (showCommentInput && replyingToCommentId == null) ...[
            _buildCommentInput(),
            const SizedBox(height: 16),
          ],
          if (postDetail.comments?.isEmpty == true)
            const Center(
              child: Text(
                'No comments yet. Be the first to comment!',
                style: TextStyle(color: textGray),
              ),
            )
          else
            // ImplicitlyAnimatedList<CommunityPostCommentModel>(
            //   items: postDetail.comments ?? [],
            //   areItemsTheSame: (a, b) => a.commentId == b.commentId,
            //   itemBuilder: (context, animation, item, index) {
            //     return SizeFadeTransition(
            //       animation: animation,
            //       child: _buildCommentCard(item, 0),
            //     );
            //   },
            // )
            // AnimatedList(
            //   key: _listKey,
            //   initialItemCount: postDetail.comments!.length,
            //   itemBuilder: (context, index, animation) {
            //     final comment = postDetail.comments![index];
            //     return SizeTransition(
            //       sizeFactor: animation,
            //       child: _buildCommentCard(comment, 0),
            //     );
            //   },
            // )
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: postDetail.comments?.length ?? 0,
              itemBuilder: (context, index) {
                final comment = postDetail.comments![index];
                return _buildCommentCard(comment, 0);
              },
            ),
        ],
      ),
    );
  }

  // Widget _buildCommentCard(CommunityPostCommentModel comment, int depth) {
  //   final isOwnComment = currentUserId == comment.userId;
  //
  //   return Container(
  //     margin: EdgeInsets.only(left: depth * 24.0, bottom: 12),
  //     decoration: BoxDecoration(
  //       color: depth == 0 ? veryLightIceCream : lightIceCream.withOpacity(0.3),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: borderColor),
  //     ),
  //     padding: const EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             CircleAvatar(
  //               radius: 16,
  //               backgroundColor: lightIceCream,
  //               backgroundImage:
  //                   comment.profilePicture != null
  //                       ? NetworkImage(comment.profilePicture!)
  //                       : null,
  //               child:
  //                   comment.profilePicture == null
  //                       ? const Icon(
  //                         Icons.person,
  //                         color: primaryIceCream,
  //                         size: 16,
  //                       )
  //                       : null,
  //             ),
  //             const SizedBox(width: 8),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     comment.userName ?? 'Unknown User',
  //                     style: const TextStyle(
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 14,
  //                       color: textDark,
  //                     ),
  //                   ),
  //                   Text(
  //                     _formatTimeAgo(comment.createdAt),
  //                     style: const TextStyle(color: textGray, fontSize: 11),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             if (isOwnComment)
  //               IconButton(
  //                 onPressed: () => _showCommentOptions(comment),
  //                 icon: const Icon(Icons.more_vert, color: textGray, size: 16),
  //               ),
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           comment.content ?? '',
  //           style: const TextStyle(fontSize: 14, color: textDark, height: 1.3),
  //         ),
  //         const SizedBox(height: 12),
  //         Row(
  //           children: [
  //             GestureDetector(
  //               onTap:
  //                   () => _toggleLikeComment(
  //                     comment.commentId!,
  //                     comment.isLikedByCurrentUser!,
  //                   ),
  //               child: Row(
  //                 children: [
  //                   Icon(
  //                     comment.isLikedByCurrentUser == true
  //                         ? Icons.favorite
  //                         : Icons.favorite_border,
  //                     color:
  //                         comment.isLikedByCurrentUser == true
  //                             ? Colors.red
  //                             : textGray,
  //                     size: 16,
  //                   ),
  //                   const SizedBox(width: 4),
  //                   Text(
  //                     '${comment.likeCount ?? 0}',
  //                     style: const TextStyle(color: textGray, fontSize: 12),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             const SizedBox(width: 16),
  //             GestureDetector(
  //               onTap:
  //                   () => _showCommentDialog(
  //                     replyToCommentId: comment.commentId,
  //                     replyToUserName: comment.userName,
  //                   ),
  //               child: const Text(
  //                 'Reply',
  //                 style: TextStyle(
  //                   color: primaryIceCream,
  //                   fontSize: 12,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         if (comment.comments?.isNotEmpty == true) ...[
  //           const SizedBox(height: 16),
  //           ListView.builder(
  //             shrinkWrap: true,
  //             physics: const NeverScrollableScrollPhysics(),
  //             itemCount: comment.comments!.length,
  //             itemBuilder: (context, index) {
  //               return _buildCommentCard(comment.comments![index], depth + 1);
  //             },
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildCommentCard(CommunityPostCommentModel comment, int depth) {
  //   final isOwnComment = currentUserId == comment.userId;
  //   final isReplyingToThis = replyingToCommentId == comment.commentId;
  //
  //   return Column(
  //     children: [
  //       Container(
  //         margin: EdgeInsets.only(left: depth * 24.0, bottom: 12),
  //         decoration: BoxDecoration(
  //           color: depth == 0 ? veryLightIceCream : lightIceCream.withOpacity(0.3),
  //           borderRadius: BorderRadius.circular(12),
  //           border: Border.all(color: borderColor),
  //         ),
  //         padding: const EdgeInsets.all(16),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             // ... existing comment content code stays the same ...
  //             Row(
  //               children: [
  //                 CircleAvatar(
  //                   radius: 16,
  //                   backgroundColor: lightIceCream,
  //                   backgroundImage: comment.profilePicture != null
  //                       ? NetworkImage(comment.profilePicture!)
  //                       : null,
  //                   child: comment.profilePicture == null
  //                       ? const Icon(Icons.person, color: primaryIceCream, size: 16)
  //                       : null,
  //                 ),
  //                 const SizedBox(width: 8),
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         comment.userName ?? 'Unknown User',
  //                         style: const TextStyle(
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: 14,
  //                           color: textDark,
  //                         ),
  //                       ),
  //                       Text(
  //                         _formatTimeAgo(comment.createdAt),
  //                         style: const TextStyle(color: textGray, fontSize: 11),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 if (isOwnComment)
  //                   IconButton(
  //                     onPressed: () => _showCommentOptions(comment),
  //                     icon: const Icon(Icons.more_vert, color: textGray, size: 16),
  //                   ),
  //               ],
  //             ),
  //             const SizedBox(height: 8),
  //             Text(
  //               comment.content ?? '',
  //               style: const TextStyle(fontSize: 14, color: textDark, height: 1.3),
  //             ),
  //             const SizedBox(height: 12),
  //             Row(
  //               children: [
  //                 GestureDetector(
  //                   onTap: () => _toggleLikeComment(
  //                     comment.commentId!,
  //                     comment.isLikedByCurrentUser!,
  //                   ),
  //                   child: Row(
  //                     children: [
  //                       Icon(
  //                         comment.isLikedByCurrentUser == true
  //                             ? Icons.favorite
  //                             : Icons.favorite_border,
  //                         color: comment.isLikedByCurrentUser == true
  //                             ? Colors.red
  //                             : textGray,
  //                         size: 16,
  //                       ),
  //                       const SizedBox(width: 4),
  //                       Text(
  //                         '${comment.likeCount ?? 0}',
  //                         style: const TextStyle(color: textGray, fontSize: 12),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 const SizedBox(width: 16),
  //                 GestureDetector(
  //                   onTap: () => _showCommentDialog(
  //                     replyToCommentId: comment.commentId,
  //                     replyToUserName: comment.userName,
  //                   ),
  //                   child: const Text(
  //                     'Reply',
  //                     style: TextStyle(
  //                       color: primaryIceCream,
  //                       fontSize: 12,
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //       // Show reply input right after this comment if replying to it
  //       if (isReplyingToThis && showCommentInput) ...[
  //         Container(
  //           margin: EdgeInsets.only(left: (depth + 1) * 24.0, bottom: 12),
  //           child: _buildCommentInput(),
  //         ),
  //       ],
  //       // Show nested comments
  //       if (comment.comments?.isNotEmpty == true) ...[
  //         ListView.builder(
  //           shrinkWrap: true,
  //           physics: const NeverScrollableScrollPhysics(),
  //           itemCount: comment.comments!.length,
  //           itemBuilder: (context, index) {
  //             return _buildCommentCard(comment.comments![index], depth + 1);
  //           },
  //         ),
  //       ],
  //     ],
  //   );
  // }

  Widget _buildCommentCard(CommunityPostCommentModel comment, int depth) {
    final isOwnComment = currentUserId == comment.userId;
    final isReplyingToThis = replyingToCommentId == comment.commentId;

    // Limit the maximum depth to prevent overflow
    final maxDepth = 3;
    final actualDepth = depth > maxDepth ? maxDepth : depth;
    final leftMargin = actualDepth * 16.0; // Reduced margin per level

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: leftMargin, bottom: 12),
          decoration: BoxDecoration(
            color:
                depth == 0 ? veryLightIceCream : lightIceCream.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: lightIceCream,
                    backgroundImage:
                        comment.profilePicture != null
                            ? NetworkImage(comment.profilePicture!)
                            : null,
                    child:
                        comment.profilePicture == null
                            ? const Icon(
                              Icons.person,
                              color: primaryIceCream,
                              size: 16,
                            )
                            : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.userName ?? 'Unknown User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: textDark,
                          ),
                        ),
                        Text(
                          _formatTimeAgo(comment.createdAt),
                          style: const TextStyle(color: textGray, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  if (isOwnComment)
                    IconButton(
                      onPressed: () => _showCommentOptions(comment),
                      icon: const Icon(
                        Icons.more_vert,
                        color: textGray,
                        size: 16,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                comment.content ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  color: textDark,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  GestureDetector(
                    onTap:
                        () => _toggleLikeComment(
                          comment.commentId!,
                          comment.isLikedByCurrentUser!,
                        ),
                    child: Row(
                      children: [
                        Icon(
                          comment.isLikedByCurrentUser == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              comment.isLikedByCurrentUser == true
                                  ? Colors.red
                                  : textGray,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${comment.likeCount ?? 0}',
                          style: const TextStyle(color: textGray, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap:
                        () => _showCommentDialog(
                          replyToCommentId: comment.commentId,
                          replyToUserName: comment.userName,
                        ),
                    child: const Text(
                      'Reply',
                      style: TextStyle(
                        color: primaryIceCream,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Show reply input right after this comment if replying to it
        if (isReplyingToThis && showCommentInput) ...[
          Container(
            margin: EdgeInsets.only(left: leftMargin + 16, bottom: 12),
            child: _buildCommentInput(),
          ),
        ],
        // Show nested comments with proper overflow handling
        if (comment.comments?.isNotEmpty == true) ...[
          // Use a constrained container to prevent overflow
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - (leftMargin + 32),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comment.comments!.length,
              itemBuilder: (context, index) {
                return _buildCommentCard(comment.comments![index], depth + 1);
              },
            ),
          ),
        ],
      ],
    );
  }

  void _showUpdatePostDialog({required CommunityPostModel editingPost}) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    List<File> selectedImages = [];

    titleController.text = editingPost.communityPostTitle ?? '';
    contentController.text = editingPost.communityPostContent ?? '';
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

              await _updateCommunityPost(
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
                            onPressed:
                                isUpdating
                                    ? null
                                    : () {
                                      Navigator.pop(context);
                                    },
                            icon: Icon(Icons.close, color: Colors.grey[600]),
                          ),
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
                        onPressed:
                            isUpdating
                                ? null
                                : () async {
                                  final picker = ImagePicker();
                                  final pickedFiles =
                                      await picker.pickMultiImage();

                                  if (pickedFiles.isNotEmpty) {
                                    setState(() {
                                      selectedImages =
                                          pickedFiles
                                              .map((file) => File(file.path))
                                              .toList();
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
                          'Choose Image',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      if (selectedImages.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                selectedImages
                                    .map(
                                      (file) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Color(0xFFE37083),
                                              size: 18,
                                            ),
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
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),

                      const SizedBox(height: 24),

                      /// Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  isUpdating
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
                              child:
                                  isUpdating
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
                          ),
                        ],
                      ),
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

  Future<void> _updateCommunityPost({
    required String title,
    required String content,
    List<File>? imageFiles,
    required CommunityPostModel editingPost,
    required VoidCallback onCloseDialog,
  }) async {
    try {
      final createCommunityPostModel = CreateCommunityPostModel(
        communityPostTitle: title,
        communityPostContent: content,
        communityPostImageFiles: imageFiles,
        communityGroupId: editingPost.communityGroupId!,
        communityPostStatus: editingPost.communityPostStatus!,
      );

      final result = await _communityUsecase.updateCommunityPost(
        editingPost.communityPostId!,
        createCommunityPostModel,
      );

      if (result.isSuccess) {
        Notify.showFlushbar(
          editingPost != null
              ? 'Post updated successfully!'
              : 'Post created successfully!',
        );
        onCloseDialog();
        _fetchPostDetail(); // Refresh the post detail
      } else {
        Notify.showFlushbar(
          result.error ??
              'Failed to ${editingPost != null ? 'update' : 'create'} post',
          isError: true,
        );
      }
    } catch (e) {
      Notify.showFlushbar('Error: ${e.toString()}', isError: true);
    }
  }

  Widget buildPostDetailImageSection(CommunityPostModel postDetail) {
    // Convert single image URL to list for consistency
    List<String> imageUrls = [];
    if (postDetail?.communityPostImageUrls != null &&
        postDetail!.communityPostImageUrls!.isNotEmpty) {
      // If it's a single string, convert to list
      if (postDetail.communityPostImageUrls is String) {
        imageUrls = [postDetail.communityPostImageUrls as String];
      } else if (postDetail.communityPostImageUrls is List<String>) {
        imageUrls = postDetail.communityPostImageUrls as List<String>;
      }
    }

    if (imageUrls.isEmpty) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: _buildImageGrid(imageUrls),
    );
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

  Widget _buildImageGrid(List<String> imageUrls) {
    if (imageUrls.isEmpty) return SizedBox.shrink();

    const double singleHeight = 120;
    const double twoImageHeight = 120;
    const double overlayHeight = 100;

    Widget buildStyledImage(String url, {double? height, VoidCallback? onTap}) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE37083).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Image.network(
            url,
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: height,
                color: const Color(0xFFF49AA2).withOpacity(0.1),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: Color(0xFFE37083),
                    size: 32,
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: height,
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFE37083),
                    strokeWidth: 2,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    if (imageUrls.length == 1) {
      return buildStyledImage(
        imageUrls[0],
        height: singleHeight,
        onTap: () => _openImageOverlay(imageUrls, 0),
      );
    } else if (imageUrls.length == 2) {
      return Row(
        children: [
          Expanded(
            child: buildStyledImage(
              imageUrls[0],
              height: twoImageHeight,
              onTap: () => _openImageOverlay(imageUrls, 0),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: buildStyledImage(
              imageUrls[1],
              height: twoImageHeight,
              onTap: () => _openImageOverlay(imageUrls, 1),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: buildStyledImage(
                  imageUrls[0],
                  height: twoImageHeight,
                  onTap: () => _openImageOverlay(imageUrls, 0),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: buildStyledImage(
                  imageUrls[1],
                  height: twoImageHeight,
                  onTap: () => _openImageOverlay(imageUrls, 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => _openImageOverlay(imageUrls, 2),
            child: Container(
              height: overlayHeight,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE37083).withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  Image.network(
                    imageUrls[2],
                    width: double.infinity,
                    height: overlayHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: overlayHeight,
                        color: const Color(0xFFF49AA2).withOpacity(0.1),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Color(0xFFE37083),
                            size: 32,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: overlayHeight,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFE37083),
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    width: double.infinity,
                    height: overlayHeight,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, color: Colors.white, size: 30),
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

  void _openImageOverlay(List<String> imageUrls, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => ImageOverlayViewer(
              imageUrls: imageUrls,
              initialIndex: initialIndex,
            ),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
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
    return SafeArea(child: Scaffold(
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
    ));
  }
}
