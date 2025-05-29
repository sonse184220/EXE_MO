import 'package:flutter/material.dart';
import 'package:inner_child_app/presentation/pages/function_pages/chat_ai/chat_ai_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/chat_ai/chat_ai_session_list_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/community_pages/community_groups_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/meditation/meditation_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/mood_journal_page/mood_journal_writing.dart';
import 'package:inner_child_app/presentation/pages/function_pages/quiz/all_quiz_page.dart';

class TherapyToolsPage extends StatefulWidget {
  const TherapyToolsPage({super.key});

  @override
  State<TherapyToolsPage> createState() => _TherapyToolsPageState();
}

class _TherapyToolsPageState extends State<TherapyToolsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return
            // SingleChildScrollView(
            // child:
            ConstrainedBox(
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
                // child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Back button and centered title row
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Back button on the left
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.blue,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        // Centered title
                        Align(
                          alignment: Alignment.center,
                          child: const Text(
                            'Therapy-Toolkits',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Expanded(
                      child: SingleChildScrollView(
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    MediaQuery.of(context).size.width > 600
                                        ? 3
                                        : 2,
                                mainAxisSpacing: 16.0,
                                crossAxisSpacing: 16.0,
                                childAspectRatio: 1.0,
                              ),
                          itemCount: 5,
                          // Update this with your actual item count
                          itemBuilder: (context, index) {
                            // Define your toolkit items
                            final toolkits = [
                              {
                                'title': 'Emotional Diary',
                                'imageAsset':
                                    'assets/images/emotionalDiary.png',
                                'navigate': () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MoodJournalWriting(),
                                    ),
                                  );
                                },
                              },
                              {
                                'title': 'Meditation',
                                'imageAsset': 'assets/images/meditation.png',
                                'navigate': () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MeditationPage(),
                                    ),
                                  );
                                },
                              },
                              {
                                'title': 'Community',
                                'imageAsset': 'assets/images/community.png',
                                'navigate': () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CommunityGroupsPage(),
                                    ),
                                  );
                                },
                              },
                              {
                                'title': 'Mental Health Quiz',
                                'imageAsset': 'assets/images/frequency.png',
                                'navigate': () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AllQuizPage(),
                                    ),
                                  );
                                },
                              },
                              {
                                'title': 'AI Chat',
                                'imageAsset': 'assets/images/aiChat.png',
                                'navigate': () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatAiSessionListPage(),
                                    ),
                                  );
                                },
                              },
                            ];

                            final toolkit = toolkits[index];
                            return _buildToolkitCard(
                              title: toolkit['title'] as String,
                              imageAsset: toolkit['imageAsset'] as String,
                              navigate: toolkit['navigate'] as Function?,
                            );
                          },
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
}

Widget _buildToolkitCard({
  required String title,
  required String imageAsset,
  required Function? navigate,
}) {
  return GestureDetector(
    onTap: () {
      // Navigate to the specific toolkit page
      navigate?.call();
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(imageAsset, fit: BoxFit.cover),
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
