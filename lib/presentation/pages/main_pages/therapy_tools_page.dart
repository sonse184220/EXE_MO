import 'package:flutter/material.dart';
import 'package:inner_child_app/presentation/pages/function_pages/chat_ai/chat_ai_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/meditation/meditation_page.dart';

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
        child: Container(
          width: double.infinity,
          height: double.infinity,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button and centered title row
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Back button on the left
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
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
              const SizedBox(height: 20),

              // Emotional Diary rectangle at the top
              GestureDetector(
                onTap: () {
                  // Navigate to Emotional Diary
                },
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/emotionalDiary.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
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
                          child: const Text(
                            'Emotional Diary',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Toolkit grid section
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  children: [
                    _buildToolkitCard(
                      title: 'Meditation',
                      imageAsset: 'assets/images/meditation.png',
                      navigate: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MeditationPage()),
                        );
                      },
                    ),
                    _buildToolkitCard(
                      title: 'Community',
                      imageAsset: 'assets/images/community.png',
                        navigate: null
                    ),
                    _buildToolkitCard(
                      title: 'Frequency Sounds',
                      imageAsset: 'assets/images/frequency.png',
                        navigate: null
                    ),
                    _buildToolkitCard(
                      title: 'AI Chat',
                      imageAsset: 'assets/images/aiChat.png',
                        navigate: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ChatAiPage()),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildToolkitCard({required String title, required String imageAsset, required Function? navigate}) {
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
