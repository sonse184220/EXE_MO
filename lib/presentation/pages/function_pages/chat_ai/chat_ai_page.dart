import 'package:flutter/material.dart';
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

  List<ChatMessageModel> _messages = [];
  String _chatTitle = 'Inner Child AI';
  bool _isLoading = true;
  bool _isError = false;

  // void _retryMessage(LocalChatMessage failedMessage) {
  //   setState(() {
  //     _localMessages.remove(failedMessage);
  //   });
  //   _sendMessage(failedMessage.content);
  // }

  // Future<void> _sendMessage(String text) async {
  //   final message = LocalChatMessage(
  //     content: text,
  //     senderType: "User",
  //     sentAt: DateTime.now(),
  //     status: MessageStatus.sending,
  //   );
  //
  //   setState(() {
  //     _localMessages.add(message);
  //   });
  //
  //   final result = await _chatAIUseCase.sendChatMessage(
  //     message: text,
  //     sessionId: widget.chatSessionId,
  //   );
  //
  //   if (result.isSuccess) {
  //     await _loadChatMessages(); // Refresh from server
  //   } else {
  //     setState(() {
  //       message.status = MessageStatus.failed;
  //     });
  //   }
  // }

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
        _chatTitle = result.data!.aichatSessionTitle;
        _isLoading = false;
        _isError = false;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
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
                              ? const Center(child: CircularProgressIndicator())
                              : _isError
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                  final combinedMessages = [
                                    ..._messages.map(
                                      (msg) => LocalChatMessageModel(
                                        content: msg.content,
                                        senderType: msg.senderType,
                                        sentAt: msg.sentAt,
                                        status: MessageStatus.sent,
                                      ),
                                    ),
                                    ..._localMessages,
                                  ];

                                  combinedMessages.sort(
                                    (a, b) => a.sentAt.compareTo(b.sentAt),
                                  );

                                  return ListView.builder(
                                    itemCount: combinedMessages.length,
                                    itemBuilder: (context, index) {
                                      // final msg = _messages[index];
                                      final msg = combinedMessages[index];
                                      final time = TimeOfDay.fromDateTime(
                                        msg.sentAt,
                                      ).format(context);

                                      if (msg.senderType == "User") {
                                        return UserMessageBubble(
                                          message: msg.content,
                                          timeStamp: time,
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
                            color: Colors.grey,
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            color: Colors.grey,
                            onPressed: () {},
                          ),
                          Expanded(
                            child: TextField(
                              onTap: (){
                                // final text = _textController.text.trim();
                                // if (text.isNotEmpty) {
                                //   _textController.clear();
                                //   _sendMessage(text);
                                // }
                              },
                              decoration: const InputDecoration(
                                hintText: "Enter your text here",
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.brown,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              color: Colors.white,
                              onPressed: () {},
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
      ),
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
    required this.timeStamp,this.isFailed = false, this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: isFailed ? 0.4 : 1, child: Padding(
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
              ),if (isFailed && onRetry != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onRetry,
                  child: const Icon(Icons.refresh, size: 16, color: Colors.red),
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
    ),);
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
