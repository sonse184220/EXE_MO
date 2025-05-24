import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/chat_ai/chat_session_model.dart';
import 'package:inner_child_app/domain/usecases/chat_ai_usecase.dart';
import 'package:inner_child_app/presentation/pages/function_pages/chat_ai/chat_ai_page.dart';

class ChatAiSessionListPage extends ConsumerStatefulWidget {
  const ChatAiSessionListPage({super.key});

  @override
  ConsumerState<ChatAiSessionListPage> createState() => _ChatAiSessionListPageState();
}

class _ChatAiSessionListPageState extends ConsumerState<ChatAiSessionListPage> {
  late final ChatAIUseCase _chatAIUseCase;

  List<ChatSessionModel> _chatSessions = [];
  bool _isLoading = true;

  Future<void> _createNewSession(String title) async {
    try {
      final result = await _chatAIUseCase.createNewChatSession(title);
      if (result.isSuccess) {
        Notify.showFlushbar('Session created!');
        await fetchChatSessions(); // Refresh the list
      } else {
        Notify.showFlushbar('Failed to create session', isError: true);
      }
    } catch (e) {
      Notify.showFlushbar('Error creating session', isError: true);
    }
  }

  Future<void> fetchChatSessions() async {
    try {
      // Replace this with your real API URL
      final result = await _chatAIUseCase.getAllChatSessions();

      if (result.isSuccess) {
        setState(() {
          _chatSessions = result.data!;
          _isLoading = false;
        });
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


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _chatAIUseCase = ref.read(chatAiUseCaseProvider);
    fetchChatSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSessionDialog(),
        backgroundColor: Colors.orangeAccent,
        child: const Icon(Icons.add, color: Colors.brown,),
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Custom styled header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Chat Session History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // List content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _chatSessions.isEmpty
                  ? const Center(child: Text('No sessions found.'))
                  : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _chatSessions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final session = _chatSessions[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to chat detail page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatAiPage(
                            chatSessionId: session.aiChatSessionId,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.chat, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.aichatSessionTitle,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Started: ${session.aichatSessionCreatedAt.toLocal()}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateSessionDialog() {
    final TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Session'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: 'Enter session title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isNotEmpty) {
                  Navigator.pop(context); // Close the dialog
                  await _createNewSession(title);
                } else {
                  Notify.showFlushbar("Title can't be empty", isError: true);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
