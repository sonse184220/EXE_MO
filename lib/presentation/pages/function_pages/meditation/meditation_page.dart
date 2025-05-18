import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/notify_another_flushbar.dart';
import 'package:inner_child_app/domain/entities/audio/audio_model.dart';
import 'package:inner_child_app/domain/usecases/audio_usecase.dart';
import 'package:inner_child_app/presentation/pages/function_pages/audio_pages/daily_mindfulness_page.dart';

class MeditationPage extends ConsumerStatefulWidget {
  const MeditationPage({super.key});

  @override
  ConsumerState<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends ConsumerState<MeditationPage> {
  late final AudioUseCase _audioUseCase;
  List<AudioModel> audioListApi = [];
  bool isLoading = true;

  late final List<Widget> audioList;

  Future<void> _fetchAudios() async {
    try {
      final result = await _audioUseCase.getAllAudios();
      if(result.isSuccess) {
        NotifyAnotherFlushBar.showFlushbar( 'ok', isError: true);

        setState(() {
          audioListApi = result.data!;
          isLoading = false;
        });
      } else {
        NotifyAnotherFlushBar.showFlushbar( result.error ?? 'An unknown error occurred', isError: true);
      }
    } catch (e) {
      NotifyAnotherFlushBar.showFlushbar('Error fetching audios list: $e', isError: true);
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _audioUseCase = ref.read(audioUseCaseProvider);

    audioList = [
      _buildSessionOption('Quick session - 5 minutes', false, Icons.play_arrow),

      _buildSessionOption(
        'Default relaxation - 10 minutes',
        false,
        Icons.play_arrow,
      ),

      _buildSessionOption('Long session - 15 minutes', true, Icons.play_arrow),

      _buildSessionOption('Sleep music - 45 minutes', false, Icons.play_arrow),

      _buildSessionOption('Sleep music - 45 minutes', false, Icons.play_arrow),
      _buildSessionOption('Sleep music - 45 minutes', false, Icons.play_arrow),
      _buildSessionOption('Sleep music - 45 minutes', false, Icons.play_arrow),
      _buildSessionOption('Sleep music - 45 minutes', false, Icons.play_arrow),
      _buildSessionOption('Sleep music - 45 minutes', false, Icons.play_arrow),
      _buildSessionOption('Sleep music - 45 minutes', false, Icons.play_arrow),
    ];

    _fetchAudios();
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Header text
                    const Text(
                      'Meditation',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    // Meditation image with sunset scene
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: AssetImage(
                            'assets/images/meditation_page_image.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Sunset scene and text overlay
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              child: const Text(
                                'Meditation',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Main content
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Toggle between Visual and Audio only
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(
                                            (0.1 * 255).round(),
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Visual',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Audio only',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Meditation session options
                          Expanded(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: audioListApi.length,
                              itemBuilder: (context, index) {
                                final audio = audioListApi[index];
                                return _buildSessionOption(
                                  audio.audioTitle ?? "Unknown",
                                  index == 0,
                                  // mark first one active as example
                                  Icons.play_arrow,
                                );
                                // final item = audioList[index];
                                // return item;
                              },
                              separatorBuilder:
                                  (context, index) => SizedBox(height: 15),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Get started button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Get started',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DailyMindfulnessPage(),
                              ),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(
                                    (0.1 * 255).round(),
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildSessionOption(String title, bool isActive, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? Colors.green.shade300 : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isActive ? Colors.green.shade100 : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: isActive ? Colors.green : Colors.black54,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.green.shade700 : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.more_horiz, color: Colors.grey),
        ],
      ),
    );
  }
}
