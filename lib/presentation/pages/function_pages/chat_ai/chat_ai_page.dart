import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/chat_ai/chat_message_model.dart';
import 'package:inner_child_app/domain/entities/chat_ai/local_chat_message_model.dart';
import 'package:inner_child_app/domain/usecases/chat_ai_usecase.dart';

class ChatAiPage extends ConsumerStatefulWidget {
  final String chatSessionId;

  const ChatAiPage({super.key, required this.chatSessionId});

  @override
  ConsumerState<ChatAiPage> createState() => _ChatAiPageState();
}

class _ChatAiPageState extends ConsumerState<ChatAiPage>
    with TickerProviderStateMixin {
  late final ChatAIUseCase _chatAIUseCase;
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<LocalChatMessageModel> _localMessages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessageModel> _messages = [];
  String _chatTitle = 'Inner Child AI';
  bool _isLoading = true;
  bool _isError = false;

  bool _isSending = false;
  bool _isWaitingForResponse = false;
  bool _showScrollToBottomButton = false;
  bool _showLoadingSpinner = false;
  bool _isLoadingMore = false;

  bool _showDeleteDropdown = false;

  @override
  void initState() {
    super.initState();

    _chatAIUseCase = ref.read(chatAiUseCaseProvider);

    // Initialize animations
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _loadChatMessages();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final offsetFromBottom =
        _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;

    final shouldShow = offsetFromBottom > 300;

    if (_showScrollToBottomButton != shouldShow) {
      setState(() {
        _showScrollToBottomButton = shouldShow;
      });
    }
  }

  Future<void> _scrollToBottom({bool animate = true}) async {
    if (!_scrollController.hasClients) return;

    double previousMax = 0;
    double currentMax = _scrollController.position.maxScrollExtent;

    while ((currentMax - previousMax).abs() > 1) {
      previousMax = currentMax;

      if (animate) {
        await _scrollController.animateTo(
          currentMax,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(currentMax);
      }

      await Future.delayed(const Duration(milliseconds: 100));
      currentMax = _scrollController.position.maxScrollExtent;
    }
  }

  void _retryMessage(LocalChatMessageModel failedMessage) {
    setState(() {
      _localMessages.remove(failedMessage);
    });
    _sendMessage(failedMessage.content);
  }

  Future<void> _sendMessage(String text) async {
    if (_isSending) return;

    setState(() {
      _isSending = true;
      _isWaitingForResponse = true;
    });

    final message = LocalChatMessageModel(
      content: text,
      senderType: "User",
      sentAt: DateTime.now(),
      status: MessageStatus.sending,
    );

    setState(() {
      _localMessages.add(message);
    });

    _scrollToBottom();

    final result = await _chatAIUseCase.sendChatMessage(
      text,
      widget.chatSessionId,
    );

    setState(() {
      _isSending = false;
      _isWaitingForResponse = false;
    });

    if (result.isSuccess) {
      final response = result.data!;

      setState(() {
        message.status = MessageStatus.sent;
      });

      final aiMessage = LocalChatMessageModel(
        content: response,
        senderType: "System",
        sentAt: DateTime.now(),
        status: MessageStatus.sent,
      );

      _textController.clear();

      setState(() {
        _localMessages.add(aiMessage);
      });

      _scrollToBottom();
    } else {
      setState(() {
        message.status = MessageStatus.failed;
      });
    }
  }

  Future<void> _loadChatMessages() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    final result = await _chatAIUseCase.getChatSessionById(
      widget.chatSessionId,
    );

    if (result.isSuccess) {
      setState(() {
        _messages = result.data!.aiChatMessages;
        _chatTitle = result.data!.aiChatSessionTitle;
        _isLoading = false;
        _isError = false;
      });

      // Start animations
      _fadeAnimationController.forward();
      _slideAnimationController.forward();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollToBottom(animate: false);
        }
      });
    } else {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
      Notify.showFlushbar(result.error!, isError: true);
    }
  }

  Future<Result<String>> _deleteSession(String sessionId) async {
    try {
      final result = await _chatAIUseCase.deleteChatSession(sessionId);
      if (result.isSuccess) {
        return Result.success('Session deleted successfully!');
      } else {
        final error = result.error ?? 'Failed to delete session';
        return Result.failure(error);
      }
    } catch (e) {
      return Result.failure('Error while deleting chat session');
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              // ... existing dialog code ...
              content: Text(
                'Are you sure you want to delete "$_chatTitle"? This action cannot be undone.',
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
                  // ... existing button styling ...
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            setState(() {
                              isLoading = true;
                            });

                            final result = await _deleteSession(
                              widget.chatSessionId,
                            );

                            if (result.isSuccess) {
                              Notify.showFlushbar(result.data!);
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context, true); // Go back to previous page
                            } else {
                              Notify.showFlushbar(
                                result.error ?? "Failed to delete session.",
                                isError: true,
                              );
                              Navigator.pop(
                                context,
                              ); // Close dialog even on error
                            }
                          },
                  child:
                      isLoading
                          ? const SizedBox(
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

  // Future<void> _deleteSession() async {
  //   try {
  //     final result = await _chatAIUseCase.deleteChatSession(widget.chatSessionId);
  //     if (result.isSuccess) {
  //       Notify.showFlushbar('Session deleted!');
  //       if (mounted) {
  //         Navigator.pop(context); // Go back to previous page
  //       }
  //     } else {
  //       Notify.showFlushbar('Failed to delete session', isError: true);
  //     }
  //   } catch (e) {
  //     Notify.showFlushbar('Error deleting session', isError: true);
  //   }
  // }
  //
  // void _showDeleteConfirmation() {
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
  //           'Are you sure you want to delete "$_chatTitle"? This action cannot be undone.',
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
  //               _deleteSession();
  //             },
  //             child: const Text('Delete'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F0),
        // Meadow background
        appBar: AppBar(
          backgroundColor: Colors.white,
          shape: const Border(
            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFA8BF8A)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            _chatTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFFA8BF8A)),
              onSelected: (String value) {
                if (value == 'delete') {
                  _showDeleteConfirmation();
                }
              },
              itemBuilder:
                  (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Delete Session',
                            style: TextStyle(color: Colors.red),
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
            // Chat messages list
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child:
                      _isLoading
                          ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFA8BF8A),
                            ),
                          )
                          : _isError
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Color(0xFFEF4444),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Failed to load chat session',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadChatMessages,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFA8BF8A),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text("Retry"),
                                ),
                              ],
                            ),
                          )
                          : _messages.isEmpty && _localMessages.isEmpty
                          ? FadeTransition(
                            opacity: _fadeAnimation,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 64,
                                    color: Color(0xFFA8BF8A),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "No messages yet.\nStart the conversation below.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          : FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: _buildMessagesList(),
                            ),
                          ),
                ),
              ),
            ),

            // Message input field
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _textController,
                        enabled: !_isSending,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText:
                              _isSending
                                  ? "Sending..."
                                  : "Type your message here...",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color:
                                _isSending
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF6B7280),
                          ),
                        ),
                        style: TextStyle(
                          color:
                              _isSending
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF1F2937),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _isSending
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFFA8BF8A),
                    ),
                    child: IconButton(
                      icon:
                          _isSending
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
                              : const Icon(Icons.send, color: Colors.white),
                      onPressed:
                          _isSending
                              ? null
                              : () {
                                final text = _textController.text.trim();
                                if (text.isNotEmpty) {
                                  _sendMessage(text);
                                }
                              },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton:
            _showScrollToBottomButton
                ? Padding(
                  padding: const EdgeInsets.only(bottom: 70),
                  child: FloatingActionButton.small(
                    onPressed: _scrollToBottom,
                    backgroundColor: const Color(0xFFA8BF8A),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                  ),
                )
                : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildMessagesList() {
    final combinedMap = <String, LocalChatMessageModel>{};

    for (final msg in _messages) {
      final key = '${msg.content}_${msg.sentAt.toIso8601String()}';
      combinedMap[key] = LocalChatMessageModel(
        content: msg.content,
        senderType: msg.senderType,
        sentAt: msg.sentAt,
        status: MessageStatus.sent,
      );
    }

    for (final localMsg in _localMessages) {
      final key = '${localMsg.content}_${localMsg.sentAt.toIso8601String()}';
      combinedMap[key] = localMsg;
    }

    final combinedMessages =
        combinedMap.values.toList()
          ..sort((a, b) => a.sentAt.compareTo(b.sentAt));

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: combinedMessages.length + (_isWaitingForResponse ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isWaitingForResponse && index == combinedMessages.length) {
          return const AILoadingBubble();
        }

        final msg = combinedMessages[index];
        final time = TimeOfDay.fromDateTime(msg.sentAt).format(context);

        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutBack,
          child:
              msg.senderType == "User"
                  ? UserMessageBubble(
                    message: msg.content,
                    timeStamp: time,
                    isFailed: msg.status == MessageStatus.failed,
                    onRetry: () => _retryMessage(msg),
                  )
                  : AIResponseBubble(message: msg.content, timeStamp: time),
        );
      },
    );
  }
}

class AILoadingBubble extends StatefulWidget {
  const AILoadingBubble({super.key});

  @override
  State<AILoadingBubble> createState() => _AILoadingBubbleState();
}

class _AILoadingBubbleState extends State<AILoadingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFA8BF8A),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Opacity(
                opacity: _animation.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 18,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDot(0),
                      const SizedBox(width: 4),
                      _buildDot(1),
                      const SizedBox(width: 4),
                      _buildDot(2),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delay = index * 0.2;
        final progress = (_animationController.value - delay).clamp(0.0, 1.0);
        final opacity = (progress < 0.5) ? progress * 2 : (1 - progress) * 2;

        return Opacity(
          opacity: opacity.clamp(0.3, 1.0),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFA8BF8A),
            ),
          ),
        );
      },
    );
  }
}

class UserMessageBubble extends StatelessWidget {
  final String message;
  final String timeStamp;
  final bool isFailed;
  final VoidCallback? onRetry;

  const UserMessageBubble({
    super.key,
    required this.message,
    required this.timeStamp,
    this.isFailed = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isFailed ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 18,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFA8BF8A),
                          const Color(0xFF9FB380),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isFailed && onRetry != null) ...[
                        GestureDetector(
                          onTap: onRetry,
                          child: const Icon(
                            Icons.refresh,
                            size: 16,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        timeStamp,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFA8BF8A),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class AIResponseBubble extends StatelessWidget {
  final String message;
  final String timeStamp;

  const AIResponseBubble({
    super.key,
    required this.message,
    required this.timeStamp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFA8BF8A),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 18,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  timeStamp,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
