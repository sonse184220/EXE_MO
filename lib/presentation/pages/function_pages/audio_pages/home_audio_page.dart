import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/domain/entities/audio/audio_model.dart';
import 'package:inner_child_app/domain/usecases/audio_usecase.dart';
import 'package:inner_child_app/presentation/pages/function_pages/audio_pages/all_audio_page.dart';
import 'package:inner_child_app/presentation/pages/function_pages/audio_pages/audio_playing_page.dart';

class HomeAudioPage extends ConsumerStatefulWidget {
  const HomeAudioPage({super.key});

  @override
  ConsumerState<HomeAudioPage> createState() => _HomeAudioPageState();
}

class _HomeAudioPageState extends ConsumerState<HomeAudioPage> {
  late final AudioUseCase _audioUseCase;

  TextEditingController searchController = TextEditingController();

  List<AudioModel> audioList = [];
  List<AudioModel> featuredAudios = [];
  late final List<Widget> featureList;

  String searchQuery = '';

  bool isLoading = true;

  // You may extract duration from metadata in the future; for now it's a placeholder
  String _formatDuration(String? url) {
    return '10 min';
  }

  Future<void> _loadAudioList() async {
    try {
      final result =
          await _audioUseCase
              .getAllAudios(); // assuming this returns List<AudioModel>
      setState(() {
        audioList = result.data!;
        featuredAudios = _getRandomFeaturedAudios(result.data!);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching audios: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<AudioModel> _getRandomFeaturedAudios(List<AudioModel> source) {
    final random = source.toList()..shuffle();
    return random.take(2).toList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _audioUseCase = ref.read(audioUseCaseProvider);

    _loadAudioList();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                color: Color(0xFF4B3621),
                child: Stack(
                  children: [
                    // Image takes only part of the container
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: (screenHeight * 1 / 2) * 0.6,
                      // 60% of container height
                      child: Image.asset(
                        'assets/images/daily_mindfulness_background.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        // color: Color(0xFF4B3621),
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
                          // Top section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Back button and user profile
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(
                                        (0.1 * 255).round(),
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      icon: Icon(
                                        Icons.arrow_back_ios_new,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundImage: AssetImage(
                                      'assets/profile.jpg',
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),

                              // Welcome text
                              Text(
                                'Hi, Nhi!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              // Search bar
                              SizedBox(height: 16),
                              TextField(
                                controller: searchController,
                                style: TextStyle(color: Colors.white),
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withAlpha((0.2 * 255).round()),
                                  prefixIcon: Icon(Icons.search, color: Colors.white.withAlpha(180)),
                                  hintText: 'Search',
                                  hintStyle: TextStyle(color: Colors.white.withAlpha(180)),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),

                              // Container(
                              //   padding: EdgeInsets.symmetric(
                              //     horizontal: 12,
                              //     vertical: 8,
                              //   ),
                              //   decoration: BoxDecoration(
                              //     color: Colors.white.withAlpha(
                              //       (0.2 * 255).round(),
                              //     ),
                              //     borderRadius: BorderRadius.circular(20),
                              //   ),
                              //   child: Row(
                              //     children: [
                              //       Icon(
                              //         Icons.search,
                              //         color: Colors.white.withAlpha(
                              //           (0.7 * 255).round(),
                              //         ),
                              //         size: 20,
                              //       ),
                              //       SizedBox(width: 8),
                              //       Text(
                              //         'Search',
                              //         style: TextStyle(
                              //           color: Colors.white.withAlpha(
                              //             (0.7 * 255).round(),
                              //           ),
                              //           fontSize: 16,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),

                              // Featured meditations
                              SizedBox(height: 24),
                              SizedBox(
                                height: 120,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: featuredAudios.length,
                                  separatorBuilder: (_, __) => SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    final audio = featuredAudios[index];
                                    return Container(
                                      width: 180,
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(255, 171, 64, 0.8),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            audio.audioTitle ?? 'Untitled',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const Spacer(),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _formatDuration(audio.audioUrl),
                                                style: TextStyle(
                                                  color: Colors.white.withAlpha(200),
                                                  fontSize: 12,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(context, MaterialPageRoute(
                                                    builder: (_) => AudioPlayingPage(audioId: audio.audioId!,),
                                                  ));
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(Icons.play_arrow, size: 16, color: Colors.orangeAccent),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // Row(
                              //   children: [
                              //     Expanded(
                              //       child: Container(
                              //         padding: EdgeInsets.all(12),
                              //         decoration: BoxDecoration(
                              //           color: Colors.orange,
                              //           borderRadius: BorderRadius.circular(10),
                              //         ),
                              //         child: Column(
                              //           crossAxisAlignment:
                              //               CrossAxisAlignment.start,
                              //           children: [
                              //             Text(
                              //               'Evening Meditation',
                              //               style: TextStyle(
                              //                 color: Colors.white,
                              //                 fontSize: 14,
                              //                 fontWeight: FontWeight.w500,
                              //               ),
                              //             ),
                              //             Text(
                              //               'to Relax',
                              //               style: TextStyle(
                              //                 color: Colors.white,
                              //                 fontSize: 14,
                              //                 fontWeight: FontWeight.w500,
                              //               ),
                              //             ),
                              //             SizedBox(height: 8),
                              //             Row(
                              //               mainAxisAlignment:
                              //                   MainAxisAlignment.spaceBetween,
                              //               children: [
                              //                 Text(
                              //                   '5 min',
                              //                   style: TextStyle(
                              //                     color: Colors.white.withAlpha(
                              //                       (0.8 * 255).round(),
                              //                     ),
                              //                     fontSize: 12,
                              //                   ),
                              //                 ),
                              //                 Container(
                              //                   padding: EdgeInsets.all(4),
                              //                   decoration: BoxDecoration(
                              //                     color: Colors.white,
                              //                     shape: BoxShape.circle,
                              //                   ),
                              //                   child: Icon(
                              //                     Icons.play_arrow,
                              //                     color: Colors.orange,
                              //                     size: 18,
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //           ],
                              //         ),
                              //       ),
                              //     ),
                              //     SizedBox(width: 12),
                              //     Expanded(
                              //       child: Container(
                              //         padding: EdgeInsets.all(12),
                              //         decoration: BoxDecoration(
                              //           color: Colors.deepPurple.withAlpha(
                              //             (0.8 * 255).round(),
                              //           ),
                              //           borderRadius: BorderRadius.circular(10),
                              //         ),
                              //         child: Column(
                              //           crossAxisAlignment:
                              //               CrossAxisAlignment.start,
                              //           children: [
                              //             Text(
                              //               'Get Back',
                              //               style: TextStyle(
                              //                 color: Colors.white,
                              //                 fontSize: 14,
                              //                 fontWeight: FontWeight.w500,
                              //               ),
                              //             ),
                              //             Text(
                              //               'to Sleep',
                              //               style: TextStyle(
                              //                 color: Colors.white,
                              //                 fontSize: 14,
                              //                 fontWeight: FontWeight.w500,
                              //               ),
                              //             ),
                              //             SizedBox(height: 8),
                              //             Row(
                              //               mainAxisAlignment:
                              //                   MainAxisAlignment.spaceBetween,
                              //               children: [
                              //                 Text(
                              //                   '8 min',
                              //                   style: TextStyle(
                              //                     color: Colors.white.withAlpha(
                              //                       (0.8 * 255).round(),
                              //                     ),
                              //                     fontSize: 12,
                              //                   ),
                              //                 ),
                              //                 Container(
                              //                   padding: EdgeInsets.all(6),
                              //                   decoration: BoxDecoration(
                              //                     color: Colors.white,
                              //                     shape: BoxShape.circle,
                              //                   ),
                              //                   child: Icon(
                              //                     Icons.play_arrow,
                              //                     color: Colors.deepPurple,
                              //                     size: 16,
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //           ],
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              // ),

                              // Featured for you section
                              SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Featured for you',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  AllAudioPage(), // <-- Your target page
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'See all',
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(
                                          (0.7 * 255).round(),
                                        ),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Bottom lists
                          isLoading
                              ? const Expanded(
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                              : Expanded(
                                child: Builder(builder: (_) {
                                  final filteredList = audioList.where((audio) =>
                                      (audio.audioTitle ?? '')
                                          .toLowerCase()
                                          .contains(searchQuery.toLowerCase())).toList();
                                  return ListView.separated(
                                    // itemCount: audioList.length,
                                    // itemBuilder: (context, index) {
                                    //   final audio = audioList[index];
                                    itemCount: filteredList.length,
                                    itemBuilder: (context, index) {
                                      final audio = filteredList[index];
                                      return _buildSessionCard(audio: audio);
                                    },
                                    separatorBuilder:
                                        (context, index) =>
                                    const SizedBox(height: 16),
                                  );
                                }),
                              ),

                          // Expanded(
                          //   child: ListView.separated(
                          //     // padding: const EdgeInsets.symmetric(vertical: 16),
                          //     shrinkWrap: true,
                          //     itemCount: featureList.length,
                          //     itemBuilder: (context, index) {
                          //       final item = featureList[index];
                          //       return item;
                          //     },
                          //     separatorBuilder:
                          //         (context, index) => SizedBox(height: 16),
                          //   ),
                          // ),
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

  Widget _buildSessionCard({
    // required String title,
    // required String duration,
    // required List<String> tags,
    // required Function? play,
    required AudioModel audio,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.1 * 255).round()),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // title,
                    audio.audioTitle ?? 'Untitled Audio',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    // duration,
                    _formatDuration(audio.audioUrl), // Placeholder
                    style: TextStyle(
                      color: Colors.white.withAlpha((0.8 * 255).round()),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (audio.audioIsPremium == true) _buildTag('Premium'),
                      if (audio.subAudioCategoryId != null)
                        _buildTag(audio.audioStatus!),
                    ],
                    // tags
                    //     .map(
                    //       (tag) => Container(
                    //         margin: const EdgeInsets.only(right: 6),
                    //         padding: const EdgeInsets.symmetric(
                    //           horizontal: 10,
                    //           vertical: 4,
                    //         ),
                    //         decoration: BoxDecoration(
                    //           color: Colors.white.withOpacity(0.2),
                    //           borderRadius: BorderRadius.circular(20),
                    //         ),
                    //         child: Text(
                    //           tag,
                    //           style: const TextStyle(
                    //             color: Colors.white,
                    //             fontSize: 11,
                    //           ),
                    //         ),
                    //       ),
                    //     )
                    //     .toList(),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AudioPlayingPage(audioId: audio.audioId!,)),
                  );
                },
                // onTap: () {
                //   play?.call();
                // },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.brown,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}
