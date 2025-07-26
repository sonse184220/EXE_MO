import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/chat_ai/chat_session_model.dart';
import 'package:inner_child_app/domain/usecases/chat_ai_usecase.dart';
import 'package:inner_child_app/presentation/pages/function_pages/chat_ai/chat_ai_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/subscription_pages/subscription_page.dart';

class ChatAiSessionListPage extends ConsumerStatefulWidget {
  const ChatAiSessionListPage({super.key});

  @override
  ConsumerState<ChatAiSessionListPage> createState() =>
      _ChatAiSessionListPageState();
}

class _ChatAiSessionListPageState extends ConsumerState<ChatAiSessionListPage>
    with TickerProviderStateMixin {
  late final ChatAIUseCase _chatAIUseCase;
  late AnimationController _animationController;
  late AnimationController _dialogAnimationController;

  Timer? _animationTimer;

  List<ChatSessionModel> _chatSessions = [];
  List<ChatSessionModel> _filteredSessions = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortBy = 'newest';
  String? _selectedSessionId; // Track selected session for delete mode

  final TextEditingController _searchController = TextEditingController();

  late final String? currentPlan;

  @override
  void initState() {
    super.initState();
    _chatAIUseCase = ref.read(chatAiUseCaseProvider);
    currentPlan = ref.read(authNotifierProvider).userInfo?.purchasePlan;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _dialogAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    fetchChatSessions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dialogAnimationController.dispose();
    _searchController.dispose();
    _animationTimer?.cancel();
    super.dispose();
  }

  bool get isPremiumUser => currentPlan == 'PremiumPlan';

  // Future<void> _createNewSession(String title) async {
  //   try {
  //     final result = await _chatAIUseCase.createNewChatSession(title);
  //     if (result.isSuccess) {
  //       Notify.showFlushbar('Session created!');
  //       if (mounted) {
  //         await fetchChatSessions();
  //       }
  //     } else {
  //       Notify.showFlushbar('Failed to create session', isError: true);
  //     }
  //   } catch (e) {
  //     Notify.showFlushbar('Error creating session', isError: true);
  //   }
  // }
  // Future<Result<void>> _createNewSession(String title) async {
  //   try {
  //     final result = await _chatAIUseCase.createNewChatSession(title);
  //     if (result.isSuccess) {
  //       // Notify.showFlushbar('Session created!');
  //       if (mounted) {
  //         await fetchChatSessions();
  //       }
  //       return Result.success(null);
  //     } else {
  //       final error = result.error ?? 'Failed to create session';
  //       Notify.showFlushbar(error, isError: true);
  //       return Result.failure(error);
  //     }
  //   } catch (e) {
  //     Notify.showFlushbar('Error creating session', isError: true);
  //     return Result.failure(e.toString());
  //   }
  // }

  Future<Result<String>> _createNewSession(String title) async {
    try {
      final result = await _chatAIUseCase.createNewChatSession(title);
      if (result.isSuccess) {
        await fetchChatSessions();
        return Result.success('Session created successfully');
      } else {
        final error = result.error ?? 'Failed to create session';
        return Result.failure(error);
      }
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<String>> _deleteSession(String sessionId) async {
    try {
      final result = await _chatAIUseCase.deleteChatSession(sessionId);
      if (result.isSuccess) {
        if (mounted) {
          setState(() {
            _selectedSessionId = null;
          });
          await fetchChatSessions();
        }
        return Result.success('Session deleted!');
      } else {
        final error = result.error ?? 'Failed to delete session';
        return Result.failure(error);
      }
    } catch (e) {
      return Result.failure('Error while deleting chat session');
    }
  }

  // Future<void> _deleteSession(String sessionId) async {
  //   try {
  //     final result = await _chatAIUseCase.deleteChatSession(sessionId);
  //     if (result.isSuccess) {
  //       Notify.showFlushbar('Session deleted!');
  //       if (mounted) {
  //         setState(() {
  //           _selectedSessionId = null; // Reset selection
  //         });
  //         await fetchChatSessions();
  //       }
  //     } else {
  //       Notify.showFlushbar('Failed to delete session', isError: true);
  //     }
  //   } catch (e) {
  //     Notify.showFlushbar('Error deleting session', isError: true);
  //   }
  // }

  void _showDeleteConfirmation(ChatSessionModel session) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Delete Session',
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'Are you sure you want to delete "${session.aiChatSessionTitle}"? This action cannot be undone.',
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            setState(() {
                              isLoading = true;
                            });

                            final result = await _deleteSession(
                              session.aiChatSessionId,
                            );

                            if (result.isSuccess) {
                              Notify.showFlushbar(result.data!);
                            } else {
                              Notify.showFlushbar(
                                result.error ?? "Failed to delete session.",
                                isError: true,
                              );
                            }
                            Navigator.pop(context);
                          },
                  child:
                      isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // void _showDeleteConfirmation(ChatSessionModel session) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16),
  //         ),
  //         title: const Text(
  //           'Delete Session',
  //           style: TextStyle(
  //             color: Color(0xFF1F2937),
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         content: Text(
  //           'Are you sure you want to delete "${session.aiChatSessionTitle}"? This action cannot be undone.',
  //           style: const TextStyle(color: Color(0xFF6B7280)),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text(
  //               'Cancel',
  //               style: TextStyle(color: Color(0xFF6B7280)),
  //             ),
  //           ),
  //           ElevatedButton(
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.red,
  //               foregroundColor: Colors.white,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //             ),
  //             onPressed: () {
  //               Navigator.pop(context);
  //               _deleteSession(session.aiChatSessionId);
  //             },
  //             child: const Text('Delete'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<void> fetchChatSessions() async {
    try {
      final result = await _chatAIUseCase.getAllChatSessions();

      if (result.isSuccess) {
        setState(() {
          _chatSessions = result.data!;
          _filteredSessions = _chatSessions;
          _isLoading = false;
        });
        _animationController.forward();
        _filterAndSortSessions();
      } else {
        throw Exception("Failed to load chat sessions");
      }
    } catch (e) {
      Notify.showFlushbar('error fetch sessions', isError: true);
      setState(() {
        _isLoading = false;
      });
    }
  }

  // void _filterAndSortSessions() {
  //   List<ChatSessionModel> filtered =
  //       _chatSessions.where((session) {
  //         return session.aiChatSessionTitle.toLowerCase().contains(
  //           _searchQuery.toLowerCase(),
  //         );
  //       }).toList();
  //
  //   filtered.sort((a, b) {
  //     if (_sortBy == 'newest') {
  //       return b.aiChatSessionCreatedAt.compareTo(a.aiChatSessionCreatedAt);
  //     } else {
  //       return a.aiChatSessionCreatedAt.compareTo(b.aiChatSessionCreatedAt);
  //     }
  //   });
  //
  //   setState(() {
  //     _filteredSessions = filtered;
  //   });
  // }

  void _filterAndSortSessions() {
    List<ChatSessionModel> filtered =
        _chatSessions.where((session) {
          return session.aiChatSessionTitle.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
        }).toList();

    filtered.sort((a, b) {
      if (_sortBy == 'newest') {
        return b.aiChatSessionCreatedAt.compareTo(a.aiChatSessionCreatedAt);
      } else {
        return a.aiChatSessionCreatedAt.compareTo(b.aiChatSessionCreatedAt);
      }
    });

    setState(() {
      _filteredSessions = filtered;
    });

    // Cancel previous timer if it exists
    _animationTimer?.cancel();

    // Reset and restart animation with a small delay
    _animationTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.reset();
        _animationController.forward();
      }
    });
  }

  Map<String, List<ChatSessionModel>> _groupSessionsByTime() {
    final Map<String, List<ChatSessionModel>> groups = {
      'This Week': [],
      'This Month': [],
      'Earlier': [],
    };

    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    final oneMonthAgo = now.subtract(const Duration(days: 30));

    for (final session in _filteredSessions) {
      if (session.aiChatSessionCreatedAt.isAfter(oneWeekAgo)) {
        groups['This Week']!.add(session);
      } else if (session.aiChatSessionCreatedAt.isAfter(oneMonthAgo)) {
        groups['This Month']!.add(session);
      } else {
        groups['Earlier']!.add(session);
      }
    }

    // Remove empty groups
    groups.removeWhere((key, value) => value.isEmpty);
    return groups;
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 30) {
      return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedSessions = _groupSessionsByTime();

    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: const Color(0xFFF5F7F0),
            appBar: AppBar(
              backgroundColor: Colors.white,
              shape: const Border(
                bottom: BorderSide(
                  color: Color(0xFFE5E7EB), // light gray border
                  width: 1,
                ),
              ),
              elevation: 2,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFFA8BF8A),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              centerTitle: true,
              title: const Text(
                'Chat Session History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              actions: [
                if (_selectedSessionId != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFFA8BF8A)),
                    onPressed: () {
                      setState(() {
                        _selectedSessionId = null;
                      });
                    },
                  ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Search and Sort Row
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search sessions...',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Color(0xFFA8BF8A),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                                _filterAndSortSessions();
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButton<String>(
                            value: _sortBy,
                            underline: const SizedBox(),
                            icon: const Icon(
                              Icons.sort,
                              color: Color(0xFFA8BF8A),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'newest',
                                child: Text('Newest'),
                              ),
                              DropdownMenuItem(
                                value: 'oldest',
                                child: Text('Oldest'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _sortBy = value!;
                              });
                              _filterAndSortSessions();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // List Content
                  Expanded(
                    child:
                        _isLoading
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFA8BF8A),
                              ),
                            )
                            : _filteredSessions.isEmpty
                            ? const Center(
                              child: Text(
                                'No sessions found.',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 16,
                                ),
                              ),
                            )
                            : AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: _calculateTotalItems(
                                    groupedSessions,
                                  ),
                                  itemBuilder: (context, index) {
                                    return _buildGroupedItem(
                                      groupedSessions,
                                      index,
                                    );
                                  },
                                );
                              },
                            ),
                  ),

                  // Fixed Bottom Button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _showCreateSessionDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA8BF8A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Create New Session',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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
          ),
          if (!isPremiumUser)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 360),
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFF49AA2), // ICE CREAM
                              Color(0xFFF49AA2).withOpacity(0.95),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Color(0xFFFFB876), // PAPAYA
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFE37083).withOpacity(0.3), // RASPBERRY
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Premium Icon
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFFCB7C), // SUNSHINE
                                    Color(0xFFFFB876), // PAPAYA
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFE37083).withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.diamond,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Title
                            const Text(
                              'Premium Feature',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Changed to white for better contrast
                                decoration: TextDecoration.none,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    color: Color(0xFFE37083), // RASPBERRY shadow
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),

                            // Subtitle
                            const Text(
                              'This feature is locked',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white, // Changed to white for better contrast
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(
                                    color: Color(0xFF89B7C2), // SPRING SKY shadow
                                    offset: Offset(0, 1),
                                    blurRadius: 1,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),

                            // Description
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9), // More opaque background
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(0xFFFFB876).withOpacity(0.5), // PAPAYA border
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Upgrade to Premium to unlock chat session history and advanced features!',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFE37083), // RASPBERRY for better contrast
                                  decoration: TextDecoration.none,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Action Buttons - Fixed overflow by using Column
                            Column(
                              children: [
                                // Primary Button
                                Container(
                                  width: double.infinity,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    // color: Color(0xFFE37083).withOpacity(0.3),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFFFCB7C), // SUNSHINE
                                        Color(0xFFFFB876), // PAPAYA
                                      ],
                                    ),
                                    // gradient: LinearGradient(
                                    //   begin: Alignment.topLeft,
                                    //   end: Alignment.bottomRight,
                                    //   // colors: [
                                    //   //   Color(0xFFA8BF8A), // MEADOW
                                    //   //   Color(0xFFA8BF8A).withOpacity(0.9),
                                    //   // ],
                                    // ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFFA8BF8A).withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                    ),
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=> SubscriptionPage()));
                                      // Notify.showFlushbar("Upgrade feature coming soon!");
                                    },
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min, // Fix overflow
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Flexible( // Prevent text overflow
                                          child: Text(
                                            'Unlock Premium',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.none,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Secondary Button
                                Container(
                                  width: double.infinity,
                                  height: 44,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(0.9), // More opaque
                                      foregroundColor: Color(0xFFE37083), // RASPBERRY for better contrast
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: Color(0xFFFFB876).withOpacity(0.6), // PAPAYA border
                                          width: 1,
                                        ),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'Maybe Later',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Feature Pills - Fixed overflow with Wrap
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              alignment: WrapAlignment.center,
                              children: [
                                _buildFeaturePill('Chat History', Icons.history),
                                _buildFeaturePill('Advanced AI', Icons.smart_toy),
                                _buildFeaturePill('Priority Support', Icons.support),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

// Helper method for feature pills - Fixed overflow
  Widget _buildFeaturePill(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9), // More opaque background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFFFFB876).withOpacity(0.6), // PAPAYA border
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Color(0xFFA8BF8A), // MEADOW for better contrast
            size: 14,
          ),
          const SizedBox(width: 4),
          Flexible( // Prevent text overflow
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFFE37083), // RASPBERRY for better contrast
                decoration: TextDecoration.none,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateTotalItems(Map<String, List<ChatSessionModel>> groups) {
    int total = 0;
    for (final entry in groups.entries) {
      total += 1 + entry.value.length; // Header + items
    }
    return total;
  }

  Widget _buildGroupedItem(
    Map<String, List<ChatSessionModel>> groups,
    int index,
  ) {
    int currentIndex = 0;

    for (final entry in groups.entries) {
      final groupTitle = entry.key;
      final sessions = entry.value;

      if (currentIndex == index) {
        // Group header
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            groupTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
        );
      }
      currentIndex++;

      if (index < currentIndex + sessions.length) {
        // Session item
        final sessionIndex = index - currentIndex;
        final session = sessions[sessionIndex];

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                (sessionIndex * 0.1).clamp(0.0, 1.0),
                ((sessionIndex + 1) * 0.1).clamp(0.0, 1.0),
                curve: Curves.easeOutBack,
              ),
            ),
          ),
          child: FadeTransition(
            opacity: _animationController,
            child: _buildSessionCard(session),
          ),
        );
      }
      currentIndex += sessions.length;
    }

    return const SizedBox.shrink();
  }

  Widget _buildSessionCard(ChatSessionModel session) {
    final isSelected = _selectedSessionId == session.aiChatSessionId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        // onTap: () async {
        //   if (isSelected) {
        //     // If already selected, deselect
        //     setState(() {
        //       _selectedSessionId = null;
        //     });
        //   } else if (_selectedSessionId == null) {
        //     // If no selection, navigate to chat
        //     final result = await Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder:
        //             (_) => ChatAiPage(chatSessionId: session.aiChatSessionId),
        //       ),
        //     );
        //
        //     if (result == true) {
        //       await fetchChatSessions();
        //     }
        //   } else {
        //     // If another session is selected, select this one
        //     setState(() {
        //       _selectedSessionId = session.aiChatSessionId;
        //     });
        //   }
        // },
        // onLongPress: () {
        //   // Long press to select
        //   setState(() {
        //     _selectedSessionId = session.aiChatSessionId;
        //   });
        // },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border:
                isSelected
                    ? Border.all(color: const Color(0xFFA8BF8A), width: 2)
                    : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                if (isSelected) {
                  // If already selected, deselect
                  setState(() {
                    _selectedSessionId = null;
                  });
                } else if (_selectedSessionId == null) {
                  // If no selection, navigate to chat
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ChatAiPage(
                            chatSessionId: session.aiChatSessionId,
                          ),
                    ),
                  );
                  if (result == true) {
                    await fetchChatSessions();
                  }
                } else {
                  // If another session is selected, select this one
                  setState(() {
                    _selectedSessionId = session.aiChatSessionId;
                  });
                }
              },
              onLongPress: () {
                // Long press to select
                setState(() {
                  _selectedSessionId = session.aiChatSessionId;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFFA8BF8A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.aiChatSessionTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTimeAgo(session.aiChatSessionCreatedAt),
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      GestureDetector(
                        onTap: () {
                          _showDeleteConfirmation(session);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete,
                            size: 20,
                            color: Colors.red,
                          ),
                        ),
                      )
                    else
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Color(0xFFA8BF8A),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // void _showCreateSessionDialog() {
  //   final TextEditingController titleController = TextEditingController();
  //   _dialogAnimationController.reset();
  //
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) {
  //       _dialogAnimationController.forward();
  //       return ScaleTransition(
  //         scale: CurvedAnimation(
  //           parent: _dialogAnimationController,
  //           curve: Curves.easeOutBack,
  //         ),
  //         child: FadeTransition(
  //           opacity: _dialogAnimationController,
  //           child: AlertDialog(
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(16),
  //             ),
  //             title: const Text(
  //               'Create New Session',
  //               style: TextStyle(
  //                 color: Color(0xFF1F2937),
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             content: TextField(
  //               controller: titleController,
  //               decoration: InputDecoration(
  //                 hintText: 'Enter session title',
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                   borderSide: const BorderSide(color: Color(0xFFA8BF8A)),
  //                 ),
  //                 focusedBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                   borderSide: const BorderSide(color: Color(0xFFA8BF8A), width: 2),
  //                 ),
  //               ),
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(context),
  //                 child: const Text(
  //                   'Cancel',
  //                   style: TextStyle(color: Color(0xFF6B7280)),
  //                 ),
  //               ),
  //               ElevatedButton(
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: const Color(0xFFA8BF8A),
  //                   foregroundColor: Colors.white,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                 ),
  //                 onPressed: () async {
  //                   final title = titleController.text.trim();
  //                   if (title.isNotEmpty) {
  //                     Navigator.pop(context);
  //                     await _createNewSession(title);
  //                   } else {
  //                     Notify.showFlushbar("Title can't be empty", isError: true);
  //                   }
  //                 },
  //                 child: const Text('Create'),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  void _showCreateSessionDialog() {
    final TextEditingController titleController = TextEditingController();
    _dialogAnimationController.reset();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isLoading = false;

        _dialogAnimationController.forward();

        return StatefulBuilder(
          builder: (context, setState) {
            return ScaleTransition(
              scale: CurvedAnimation(
                parent: _dialogAnimationController,
                curve: Curves.easeOutBack,
              ),
              child: FadeTransition(
                opacity: _dialogAnimationController,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    'Create New Session',
                    style: TextStyle(
                      color: Color(0xFF1F2937),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: TextField(
                    controller: titleController,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'Enter session title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFA8BF8A)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFA8BF8A),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          isLoading ? null : () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA8BF8A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                final title = titleController.text.trim();

                                if (title.isEmpty) {
                                  Notify.showFlushbar(
                                    "Title can't be empty",
                                    isError: true,
                                  );
                                  return;
                                }

                                setState(() {
                                  isLoading = true;
                                });

                                final result = await _createNewSession(title);

                                if (result.isSuccess) {
                                  Notify.showFlushbar(result.data!);
                                } else {
                                  Notify.showFlushbar(
                                    result.error ?? "Failed to create session.",
                                    isError: true,
                                  );
                                }
                                Navigator.pop(context);
                              },
                      child:
                          isLoading
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Create'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // void _showCreateSessionDialog() {
  //   final TextEditingController titleController = TextEditingController();
  //   _dialogAnimationController.reset();
  //
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (dialogContext) {
  //       bool isLoading = false;
  //
  //       _dialogAnimationController.forward();
  //
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           Future<void> handleSubmit() async {
  //             final title = titleController.text.trim();
  //
  //             if (title.isEmpty) {
  //               Notify.showFlushbar(
  //                 "Title can't be empty",
  //                 isError: true,
  //               );
  //               return;
  //             }
  //
  //             setState(() {
  //               isLoading = true;
  //             });
  //
  //             final result = await _createNewSession(title);
  //
  //             if (result.isSuccess) {
  //               Navigator.of(dialogContext, rootNavigator: true).pop(title);
  //             } else {
  //               setState(() {
  //                 isLoading = false;
  //               });
  //               Notify.showFlushbar(
  //                 result.error ?? "Failed to create session.",
  //                 isError: true,
  //               );
  //             }
  //           }
  //
  //           return ScaleTransition(
  //             scale: CurvedAnimation(
  //               parent: _dialogAnimationController,
  //               curve: Curves.easeOutBack,
  //             ),
  //             child: FadeTransition(
  //               opacity: _dialogAnimationController,
  //               child: AlertDialog(
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(16),
  //                 ),
  //                 title: const Text(
  //                   'Create New Session',
  //                   style: TextStyle(
  //                     color: Color(0xFF1F2937),
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 content: TextField(
  //                   controller: titleController,
  //                   enabled: !isLoading,
  //                   decoration: InputDecoration(
  //                     hintText: 'Enter session title',
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                       borderSide: const BorderSide(color: Color(0xFFA8BF8A)),
  //                     ),
  //                     focusedBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                       borderSide: const BorderSide(
  //                         color: Color(0xFFA8BF8A),
  //                         width: 2,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 actions: [
  //                   TextButton(
  //                     onPressed: isLoading
  //                         ? null
  //                         : () => Navigator.of(dialogContext, rootNavigator: true).pop(null),
  //                     child: const Text(
  //                       'Cancel',
  //                       style: TextStyle(color: Color(0xFF6B7280)),
  //                     ),
  //                   ),
  //                   ElevatedButton(
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: const Color(0xFFA8BF8A),
  //                       foregroundColor: Colors.white,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                     ),
  //                     onPressed: isLoading ? null : handleSubmit,
  //                     child: isLoading
  //                         ? const SizedBox(
  //                       width: 20,
  //                       height: 20,
  //                       child: CircularProgressIndicator(
  //                         color: Colors.white,
  //                         strokeWidth: 2,
  //                       ),
  //                     )
  //                         : const Text('Create'),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   ).then((title) async {
  //     // handle dialog result outside
  //     if (title is String && title.isNotEmpty) {
  //       Notify.showFlushbar("Session created!", isError: false);
  //       if (context.mounted) {
  //         await fetchChatSessions();
  //       }
  //     }
  //   });
  // }
}
