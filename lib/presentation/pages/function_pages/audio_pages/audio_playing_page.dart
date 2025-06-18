import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/domain/entities/audio/audio_model.dart';
import 'package:inner_child_app/domain/usecases/audio_usecase.dart';

class AudioPlayingPage extends ConsumerStatefulWidget {
  final String audioId;
  const AudioPlayingPage({super.key, required this.audioId});

  @override
  ConsumerState<AudioPlayingPage> createState() => _AudioPlayingPageState();
}

class _AudioPlayingPageState extends ConsumerState<AudioPlayingPage>
    with TickerProviderStateMixin {
  late final AudioUseCase _audioUseCase;

  late AnimationController _rotationController;
  late AudioPlayer _audioPlayer;

  // State variables
  AudioModel? currentAudio;
  List<AudioModel> audioList = [];

  bool isPlaying = false;
  bool isLoading = false;
  bool isInitialLoading = true;

  bool isSetSourceError = false;

  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  int currentAudioIndex = 0;

  @override
  void initState() {
    super.initState();
    _audioUseCase = ref.read(audioUseCaseProvider);
    _audioPlayer = AudioPlayer();
    _rotationController = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    );

    _setupAudioPlayer();
    _loadAudioDetails();
    _loadAudioList();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });

      if (isPlaying) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        currentPosition = position;
      });
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        totalDuration = duration;
      });
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _onAudioComplete();
    });
  }

  Future<void> _loadAudioDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      // throw Exception();
      // Replace with your actual API endpoint
      final result = await _audioUseCase.getAudioDetail(widget.audioId);

      if (result.isSuccess) {
        final data = result.data;
        setState(() {
          currentAudio = data;
        });
        await _loadAndPlayAudio();
      }
    } catch (e) {
      print('Error loading audio details: $e');
      // Fallback audio for demo
      setState(() {
        currentAudio = AudioModel(
          audioId: widget.audioId,
          audioTitle: "Evening Meditation to Relax",
          audioUrl: "https://thantrieu.com/resources/music/1130295695.mp3",
          audioThumbnail: "",
          audioCreatedAt: DateTime.now(),
          audioIsPremium: false,
          audioStatus: "Active",
          subAudioCategoryId: "SAC001",
          subAudioCategoryName: "Guided Meditation",
        );
      });
      await _loadAndPlayAudio();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadAudioList() async {
    try {
      // throw Exception();
      // Replace with your actual API endpoint
      final result = await _audioUseCase.getAllAudios();

      if (result.isSuccess) {
        final data = result.data!;
        setState(() {
          audioList = data;
          currentAudioIndex = audioList.indexWhere((audio) => audio.audioId == widget.audioId);
          if (currentAudioIndex == -1) currentAudioIndex = 0;
        });
      }
    } catch (e) {
      print('Error loading audio list: $e');
      // Fallback list for demo
      setState(() {
        audioList = [];
        // audioList = [
        //   AudioModel(
        //     audioId: "A001",
        //     audioTitle: "Morning Meditation",
        //     audioUrl: "https://thantrieu.com/resources/music/1130295695.mp3",
        //     audioThumbnail: "",
        //     audioCreatedAt: DateTime.now(),
        //     audioIsPremium: false,
        //     audioStatus: "Active",
        //     subAudioCategoryId: "SAC001",
        //     subAudioCategoryName: "Guided Meditation",
        //   ),
        //   AudioModel(
        //     audioId: "A002",
        //     audioTitle: "Evening Relaxation",
        //     audioUrl: "https://thantrieu.com/resources/music/1130295695.mp3",
        //     audioThumbnail: "",
        //     audioCreatedAt: DateTime.now(),
        //     audioIsPremium: false,
        //     audioStatus: "Active",
        //     subAudioCategoryId: "SAC002",
        //     subAudioCategoryName: "Relaxation",
        //   ),
        // ];
        currentAudioIndex = 0;
      });
    }
  }

  Future<void> _loadAndPlayAudio() async {
    if (currentAudio?.audioUrl != null) {
      setState(() {
        isLoading = true;
        isSetSourceError = false;
        currentPosition = Duration.zero;
        totalDuration = Duration.zero;
      });

      try {
        print('url ne: $currentAudio?.audioUrl');
        await _audioPlayer.stop();
        await _audioPlayer.setSourceUrl(currentAudio!.audioUrl!);
        await _audioPlayer.resume();
        // setState(() {
        //   isPlaying = true;
        // });
      } catch (e) {
        print('Error loading audio: $e');
        setState(() {
          isSetSourceError = true;
        });
      } finally {
        setState(() {
          isLoading = false;
          isInitialLoading = false;
        });
      }
    }
  }

  // Fixed retry function that maintains correct state
  Future<void> _retryLoadAudio() async {
    if (currentAudio != null) {
      await _loadAndPlayAudio();
    } else {
      await _loadAudioDetails();
    }
  }

  void _playPause() async {
    if (isSetSourceError || isLoading) return;

    if (isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      try {
        await _audioPlayer.resume();
        setState(() {
          isPlaying = true;
        });
      } catch (e) {
        print('Error resuming audio: $e');
      }
    }
  }

  // void _playPause() async {
  //   if (isLoading || isInitialLoading) return;
  //
  //   if (isPlaying) {
  //     await _audioPlayer.pause();
  //   } else {
  //     await _audioPlayer.resume();
  //   }
  // }

  void _seekTo(Duration position) {
    if (isLoading || isInitialLoading) return;

    _audioPlayer.seek(position);
  }

  void _skipForward() {
    if (isLoading || isInitialLoading) return;

    final newPosition = currentPosition + Duration(seconds: 10);
    if (newPosition < totalDuration) {
      _seekTo(newPosition);
    }
  }

  void _skipBackward() {
    if (isLoading || isInitialLoading) return;

    final newPosition = currentPosition - Duration(seconds: 10);
    if (newPosition > Duration.zero) {
      _seekTo(newPosition);
    } else {
      _seekTo(Duration.zero);
    }
  }

  void _previousTrack() {
    if (isLoading || isInitialLoading) return;

    if (audioList.isNotEmpty && currentAudioIndex > 0) {
      setState(() {
        currentAudioIndex--;
        currentAudio = audioList[currentAudioIndex];
      });
      _loadAndPlayAudio();
    }
  }

  void _nextTrack() {
    if (isLoading || isInitialLoading) return;

    if (audioList.isNotEmpty && currentAudioIndex < audioList.length - 1) {
      setState(() {
        currentAudioIndex++;
        currentAudio = audioList[currentAudioIndex];
      });
      _loadAndPlayAudio();
    }
  }

  void _onAudioComplete() {
    setState(() {
      currentPosition = Duration.zero;
      isPlaying = false;
    });
    _rotationController.reset();

    // Auto play next track
    if (currentAudioIndex < audioList.length - 1) {
      _nextTrack();
    }
  }

  void _showPlaylist() {
    if (isLoading || isInitialLoading) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF4B3621),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Playlist',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: audioList.length,
                  itemBuilder: (context, index) {
                    final audio = audioList[index];
                    final isCurrentTrack = index == currentAudioIndex;

                    return ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: audio.audioThumbnail!.isNotEmpty
                            ? ClipOval(
                          child: Image.network(
                            audio.audioThumbnail!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.music_note, color: Colors.grey);
                            },
                          ),
                        )
                            : Icon(Icons.music_note, color: Colors.grey),
                      ),
                      title: Text(
                        audio.audioTitle ?? 'Unknown title',
                        style: TextStyle(
                          color: isCurrentTrack ? Colors.amber : Colors.white,
                          fontWeight: isCurrentTrack ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        audio.subAudioCategoryName ?? 'Unknown category',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      trailing: isCurrentTrack
                          ? Icon(Icons.play_arrow, color: Colors.amber)
                          : null,
                      onTap: () {
                        setState(() {
                          currentAudioIndex = index;
                          currentAudio = audio;
                        });
                        _loadAndPlayAudio();
                        Navigator.pop(context);
                        // Navigator.push(context, MaterialPageRoute(builder: (context)=> AudioPlayingPage(audioId: audio.audioId!)));
                        // setState(() {
                        //   currentAudioIndex = index;
                        //   currentAudio = audio;
                        // });
                        // _loadAndPlayAudio();
                        // Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imgSize = MediaQuery.of(context).size.width - 20;

    return SafeArea(
      child:  Scaffold(
      body: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  SizedBox(
                    height: screenHeight * 0.75,
                    child: Stack(
                      children: [
                        // Background Image with Blur
                        Positioned.fill(
                          child: ClipRect(
                            child: ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: 8,
                                sigmaY: 8,
                              ),
                              child: Transform.scale(
                                scale: 1.2,
                                child: currentAudio?.audioThumbnail != null &&
                                    currentAudio!.audioThumbnail!.isNotEmpty
                                    ? Image.network(
                                  currentAudio!.audioThumbnail!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/audio_playing.png',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                                    : Image.asset(
                                  'assets/images/audio_playing.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Main Content with padding
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.arrow_back_ios_new,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap:(isLoading || isInitialLoading) ? null : _showPlaylist,
                                      child: Opacity(opacity:   (isLoading || isInitialLoading) ? 0.5 : 1.0,child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
            ),
            child: Icon(
            Icons.playlist_play,
            color: Colors.white,
            size: 18,
            ),
            ),),
                                    ),
                                  ],
                                ),

                                // Meditation image and title
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AnimatedBuilder(
                                        animation: _rotationController,
                                        builder: (context, child) {
                                          return Transform.rotate(
                                            angle: _rotationController.value * 2 * 3.14159,
                                            child: Container(
                                              width: imgSize,
                                              height: imgSize,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey[300],
                                              ),
                                              child: isLoading
                                                  ? Center(
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                ),
                                              )
                                                  : currentAudio?.audioThumbnail != null &&
                                                  currentAudio!.audioThumbnail!.isNotEmpty
                                                  ? ClipOval(
                                                child: Image.network(
                                                  currentAudio!.audioThumbnail!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Icon(
                                                      Icons.music_note,
                                                      color: Colors.grey,
                                                      size: 100,
                                                    );
                                                  },
                                                ),
                                              )
                                                  : Icon(
                                                Icons.music_note,
                                                color: Colors.grey,
                                                size: 100,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        currentAudio?.audioTitle ?? 'Loading...',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        currentAudio?.subAudioCategoryName ?? '',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _formatDuration(currentPosition),
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.7),
                                              fontSize: 14,
                                            ),
                                          ),
                                          Expanded(
                                            child: Slider(
                                              value: totalDuration.inMilliseconds > 0
                                                  ? currentPosition.inMilliseconds /
                                                  totalDuration.inMilliseconds
                                                  : 0.0,
                                              onChanged: (value) {
                                                final position = Duration(
                                                  milliseconds: (value * totalDuration.inMilliseconds).round(),
                                                );
                                                _seekTo(position);
                                              },
                                              activeColor: Colors.white,
                                              inactiveColor: Colors.white.withOpacity(0.3),
                                            ),
                                          ),
                                          Text(
                                            _formatDuration(totalDuration),
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.7),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom controls
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: Color(0xFF89B7C2)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: (isLoading || isInitialLoading) ? null : _previousTrack,
                            child: Opacity( opacity: (isLoading || isInitialLoading) ? 0.5 : 1.0, child: Icon(
                              Icons.skip_previous,
                              color: Colors.white,
                              size: 30,
                            ),)
                          ),
                          GestureDetector(
                            onTap: (isLoading || isInitialLoading) ? null : _skipBackward,
                            child: Opacity(  opacity: (isLoading || isInitialLoading) ? 0.5 : 1.0,child:  Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.replay_10,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),)
                          ),
                          GestureDetector(
                            onTap:  (isLoading || isInitialLoading) ? null :  isSetSourceError
                                ? () => _retryLoadAudio() // Retry loading
                                : _playPause,
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: (isLoading || isInitialLoading)
                                  ? SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  color: Colors.brown.shade700,
                                  strokeWidth: 3,
                                ),
                              )
                                  : isSetSourceError
                                  ? Icon(
                                Icons.refresh,
                                color: Colors.redAccent,
                                size: 30,
                              )
                                  : Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.brown.shade700,
                                size: 30,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (isLoading || isInitialLoading) ? null :  _skipForward,
                            child: Opacity( opacity: (isLoading || isInitialLoading) ? 0.5 : 1.0, child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.forward_10,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),),
                          ),
                          GestureDetector(
                            onTap: (isLoading || isInitialLoading) ? null : _nextTrack,
                            child: Opacity( opacity: (isLoading || isInitialLoading) ? 0.5 : 1.0, child: Icon(
                              Icons.skip_next,
                              color: Colors.white,
                              size: 30,
                            ),),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}