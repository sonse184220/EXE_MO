import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/chat_ai/chat_message_model.dart';
import 'package:inner_child_app/domain/entities/chat_ai/local_chat_message_model.dart';
import 'package:inner_child_app/domain/usecases/chat_ai_usecase.dart';

class ChatAiPage extends ConsumerStatefulWidget {
  final String chatSessionId;

  const ChatAiPage({super.key, required this.chatSessionId});

  @override
  ConsumerState<ChatAiPage> createState() => _ChatAiPageState();
}

class _ChatAiPageState extends ConsumerState<ChatAiPage> {
  late final ChatAIUseCase _chatAIUseCase;

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

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final offsetFromBottom =
        _scrollController.position.maxScrollExtent - _scrollController.position.pixels;

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

      // Wait a bit for list to render new items and update scroll extent
      await Future.delayed(const Duration(milliseconds: 100));

      currentMax = _scrollController.position.maxScrollExtent;
    }
  }

  // void _scrollToBottom({bool animate = true}) {
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     await Future.delayed(const Duration(milliseconds: 150));
  //
  //     if (!_scrollController.hasClients) return;
  //
  //     final maxScroll = _scrollController.position.maxScrollExtent;
  //     final currentPos = _scrollController.position.pixels;
  //
  //     if ((maxScroll - currentPos).abs() < 10) {
  //       // Already near bottom, no need to scroll
  //       return;
  //     }
  //
  //     if (animate) {
  //       _scrollController.animateTo(
  //         maxScroll,
  //         duration: const Duration(milliseconds: 300),
  //         curve: Curves.easeOut,
  //       );
  //     } else {
  //       _scrollController.jumpTo(maxScroll);
  //     }
  //
  //     print('Current: ${_scrollController.position.pixels}');
  //     print('Max: ${_scrollController.position.maxScrollExtent}');
  //   });
  // }

  // Future<void> _scrollToBottomAfterBuild({bool animate = true}) async {
  //   await SchedulerBinding.instance.endOfFrame;
  //   if (!_scrollController.hasClients) return;
  //   final position = _scrollController.position.maxScrollExtent;
  //
  //   if (animate) {
  //     _scrollController.animateTo(
  //       position,
  //       duration: const Duration(milliseconds: 300),
  //       curve: Curves.easeOut,
  //     );
  //   } else {
  //     _scrollController.jumpTo(position);
  //   }
  // }

  // void _scrollToBottom({bool animate = true}) {
  //   if (!_scrollController.hasClients) return;
  //
  //   final target = _scrollController.position.maxScrollExtent;
  //
  //   if (animate) {
  //     _scrollController.animateTo(
  //       target,
  //       duration: const Duration(milliseconds: 300),
  //       curve: Curves.easeOut,
  //     );
  //   } else {
  //     _scrollController.jumpTo(target);
  //   }
  // }


  // void _onScroll() {
  //   final shouldShow = !_scrollController.position.atEdge &&
  //       _scrollController.position.pixels <
  //           _scrollController.position.maxScrollExtent - 100;
  //
  //   if (_showScrollToBottomButton != shouldShow) {
  //     setState(() {
  //       _showScrollToBottomButton = shouldShow;
  //     });
  //   }
  //   // final isAtBottom =
  //   //     _scrollController.position.pixels >=
  //   //     _scrollController.position.maxScrollExtent - 100;
  //   //
  //   // if (_showScrollToBottomButton == isAtBottom) {
  //   //   setState(() {
  //   //     _showScrollToBottomButton = !isAtBottom;
  //   //   });
  //   // }
  // }
  //
  // void _scrollToBottom({bool animate = true}) {
  //   if (animate) {
  //     _scrollController.animateTo(
  //       _scrollController.position.maxScrollExtent,
  //       duration: const Duration(milliseconds: 300),
  //       curve: Curves.easeOut,
  //     );
  //   } else {
  //     _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  //   }
  // }

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

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Future.delayed(Duration.zero, () {
    //     _scrollToBottom();
    //   });
    // });

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _scrollToBottom();
    // });

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
      // await _loadChatMessages(); // Refresh from server

      _scrollToBottom();

      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   Future.delayed(Duration.zero, () {
      //     if (!_showScrollToBottomButton) {
      //       _scrollToBottom();
      //     }
      //   });
      // });

      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   if (!_showScrollToBottomButton) {
      //     _scrollToBottom();
      //   }
      // });
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

       // _scrollToBottom();

      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   Future.delayed(Duration.zero, () {
      //     if (_scrollController.hasClients) {
      //       _scrollToBottom(animate: false);
      //     }
      //   });
      // });


      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollToBottom(animate: false);
        }
      });
    } else {
      // Handle failure UI here
      setState(() {
        _isLoading = false;
        _isError = true;
      });
      Notify.showFlushbar(result.error!, isError: true);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _chatAIUseCase = ref.read(chatAiUseCaseProvider);
    _loadChatMessages();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Container(
                    width: double.infinity,
                    // height: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Header with back button and title
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            const SizedBox(width: 8),
                            Text(
                              // "Inner Child AI",
                              _chatTitle,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        // Chat messages list
                        Expanded(
                          child:
                              _isLoading
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : _isError
                                  ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Load chat session fail',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        ElevatedButton(
                                          onPressed: _loadChatMessages,
                                          child: const Text("Retry"),
                                        ),
                                      ],
                                    ),
                                  )
                                  : _messages.isEmpty && _localMessages.isEmpty
                                  ? const Center(
                                    child: Text(
                                      "No messages yet.\nStart the conversation below.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                  : Builder(
                                    builder: (context) {
                                      // final combinedMessages = [
                                      //   ..._messages.map(
                                      //     (msg) => LocalChatMessageModel(
                                      //       content: msg.content,
                                      //       senderType: msg.senderType,
                                      //       sentAt: msg.sentAt,
                                      //       status: MessageStatus.sent,
                                      //     ),
                                      //   ),
                                      //   ..._localMessages,
                                      // ];

                                      final combinedMap =
                                          <String, LocalChatMessageModel>{};

                                      for (final msg in _messages) {
                                        final key =
                                            '${msg.content}_${msg.sentAt.toIso8601String()}';
                                        combinedMap[key] =
                                            LocalChatMessageModel(
                                              content: msg.content,
                                              senderType: msg.senderType,
                                              sentAt: msg.sentAt,
                                              status: MessageStatus.sent,
                                            );
                                      }

                                      for (final localMsg in _localMessages) {
                                        final key =
                                            '${localMsg.content}_${localMsg.sentAt.toIso8601String()}';
                                        combinedMap[key] =
                                            localMsg; // local messages can overwrite duplicates if needed
                                      }

                                      final combinedMessages =
                                          combinedMap.values.toList()..sort(
                                            (a, b) =>
                                                a.sentAt.compareTo(b.sentAt),
                                          );

                                      // combinedMessages.sort(
                                      //   (a, b) => a.sentAt.compareTo(b.sentAt),
                                      // );

                                      return ListView.builder(
                                        controller: _scrollController,
                                        itemCount: combinedMessages.length + (_isWaitingForResponse ? 1 : 0),
                                        itemBuilder: (context, index) {
                                          // Show loading bubble if waiting for AI response
                                          if (
                                              _isWaitingForResponse&& index == combinedMessages.length) {
                                            return const AILoadingBubble();
                                          }

                                          // final msg = _messages[index];
                                          final msg = combinedMessages[index];
                                          final time = TimeOfDay.fromDateTime(
                                            msg.sentAt,
                                          ).format(context);

                                          if (msg.senderType == "User") {
                                            return UserMessageBubble(
                                              message: msg.content,
                                              timeStamp: time,
                                              isFailed:
                                                  msg.status ==
                                                  MessageStatus.failed,
                                              onRetry: () {
                                                final text =
                                                    _textController.text.trim();
                                                // _sendMessage(text);
                                                _retryMessage(msg);
                                              },
                                            );
                                          } else {
                                            return AIResponseBubble(
                                              message: msg.content,
                                              timeStamp: time,
                                            );
                                          }
                                        },
                                      );
                                    },
                                  ),
                        ),
                        // Expanded(
                        //   child: ListView(
                        //     children: [
                        //       // Time indicator
                        //       const Center(
                        //         child: Padding(
                        //           padding: EdgeInsets.symmetric(vertical: 12),
                        //           child: Text(
                        //             "9:41",
                        //             style: TextStyle(
                        //               fontSize: 12,
                        //               color: Colors.grey,
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //
                        //       // User message 1
                        //       const UserMessageBubble(
                        //         message: "How can I reduce stress?",
                        //         timeStamp: "12:45 PM",
                        //       ),
                        //
                        //       // AI response 1
                        //       const AIResponseBubble(
                        //         message:
                        //             "Try deep breathing, meditation, or light exercise. Would you like some guided breathing tips?",
                        //         timeStamp: "12:46 PM",
                        //       ),
                        //
                        //       // User message 2
                        //       const UserMessageBubble(
                        //         message: "What foods boost immunity?",
                        //         timeStamp: "12:51 PM",
                        //       ),
                        //
                        //       // AI response 2
                        //       const AIResponseBubble(
                        //         message: "Foods rich in vitamin C",
                        //         timeStamp: "12:53 PM",
                        //       ),
                        //
                        //       const UserMessageBubble(
                        //         message: "What foods boost immunity?",
                        //         timeStamp: "12:51 PM",
                        //       ),
                        //
                        //       // AI response 2
                        //       const AIResponseBubble(
                        //         message: "Foods rich in vitamin C",
                        //         timeStamp: "12:53 PM",
                        //       ),
                        //       const UserMessageBubble(
                        //         message: "What foods boost immunity?",
                        //         timeStamp: "12:51 PM",
                        //       ),
                        //
                        //       // AI response 2
                        //       const AIResponseBubble(
                        //         message: "Foods rich in vitamin C",
                        //         timeStamp: "12:53 PM",
                        //       ),
                        //       const UserMessageBubble(
                        //         message: "What foods boost immunity?",
                        //         timeStamp: "12:51 PM",
                        //       ),
                        //
                        //       // AI response 2
                        //       const AIResponseBubble(
                        //         message: "Foods rich in vitamin C",
                        //         timeStamp: "12:53 PM",
                        //       ),
                        //     ],
                        //   ),
                        // ),

                        // Message input field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.link),
                                // color: Colors.grey,
                                color:
                                    _isSending
                                        ? Colors.grey.shade400
                                        : Colors.grey,
                                onPressed: _isSending ? null : () {},
                                // onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                color:
                                    _isSending
                                        ? Colors.grey.shade400
                                        : Colors.grey,
                                onPressed: _isSending ? null : () {},
                                // color: Colors.grey,
                                // onPressed: () {},
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _textController,
                                  enabled: !_isSending,
                                  // onTap: (){
                                  //   final text = _textController.text.trim();
                                  //   if (text.isNotEmpty) {
                                  //     _textController.clear();
                                  //     // _sendMessage(text);
                                  //   }
                                  // },
                                  decoration: InputDecoration(
                                    // hintText: "Enter your text here",
                                    hintText:
                                        _isSending
                                            ? "Sending..."
                                            : "Enter your text here",
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                      color:
                                          _isSending
                                              ? Colors.grey.shade400
                                              : Colors.grey,
                                    ),
                                    // hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                  style: TextStyle(
                                    color:
                                        _isSending
                                            ? Colors.grey.shade600
                                            : Colors.black,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      _isSending
                                          ? Colors.grey.shade400
                                          : Colors.brown,
                                  // color: Colors.brown,
                                ),
                                child: IconButton(
                                  icon:
                                      _isSending
                                          ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                          : const Icon(Icons.arrow_forward),
                                  // const Icon(Icons.arrow_forward),
                                  color: Colors.white,
                                  onPressed:
                                      _isSending
                                          ? null
                                          : () {
                                            final text =
                                                _textController.text.trim();
                                            if (text.isNotEmpty) {
                                              // _textController.clear();
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
                  ),
                );
              },
            ),
            // Scroll to bottom button
            if (_showScrollToBottomButton)
    Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100, right: 30),
        child: FloatingActionButton.small(
          onPressed: _scrollToBottom,
          // onPressed: _scrollToBottomAfterBuild,
          backgroundColor: Colors.brown,
          child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ),
      ),
    ),
              // Positioned(
              //   bottom: 100,
              //   right: 0,
              //   child: FloatingActionButton.small(
              //     onPressed: _scrollToBottom,
              //     backgroundColor: Colors.brown,
              //     child: const Icon(
              //       Icons.keyboard_arrow_down,
              //       color: Colors.white,
              //     ),
              //   ),
              // ),
          ],
        ),
      ),
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
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Opacity(
                opacity: _animation.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(18),
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
              color: Colors.grey.shade600,
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
    return Opacity(
      opacity: isFailed ? 0.4 : 1,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade200,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStamp,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (isFailed && onRetry != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onRetry,
                    child: const Icon(
                      Icons.refresh,
                      size: 16,
                      color: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: AssetImage('assets/user_avatar.png'),
                  // Replace with your asset
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: Colors.white, width: 2),
              ),
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
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timeStamp,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
