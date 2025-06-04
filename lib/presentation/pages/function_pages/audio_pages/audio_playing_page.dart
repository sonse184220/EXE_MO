import 'dart:math';
import 'dart:ui';

import 'package:audio_session/audio_session.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_child_app/core/utils/dependency_injection/injection.dart';
import 'package:inner_child_app/core/utils/result_model.dart';
import 'package:inner_child_app/domain/entities/audio/audio_model.dart';
import 'package:inner_child_app/domain/usecases/audio_usecase.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayingPage extends ConsumerStatefulWidget {
  final String audioId;
  const AudioPlayingPage({super.key, required this.audioId});

  @override
  ConsumerState<AudioPlayingPage> createState() => _AudioPlayingPageState();
}

class _AudioPlayingPageState extends ConsumerState<AudioPlayingPage>
    with SingleTickerProviderStateMixin {
  late final AudioUseCase _audioUseCase;
  late final AudioPlayer _player;
  AnimationController? _diskController;

  AudioModel? _audio;
  List<AudioModel> _audioList = [];

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  bool _isLoading = true;
  bool _isSeeking = false;

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // final audioDetailResult = await _audioUseCase.getAudioDetail(widget.audioId);
      final audioDetailResult = Result.success('data');
      final allAudiosResult = await _audioUseCase.getAllAudios();

      if (audioDetailResult.isFailure || allAudiosResult.isFailure) {
        return _handleError(audioDetailResult.error ?? allAudiosResult.error);
      }

      setState(() {
        _audio = AudioModel(audioId: 'Id', audioCreatedAt: DateTime.now(), audioStatus: 'Active', audioIsPremium: false, audioThumbnail: '', audioTitle: 'Son', audioUrl: 'Url', subAudioCategoryId: 'SubAuId');
        // _audio = audioDetailResult.data!;
        _audioList = allAudiosResult.data!;
      });

      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration.music());

      // final url = 'https://thantrieu.com/resources/music/${_audio!.audioUrl}';
      // final url = 'https://thantrieu.com/resources/music/1130295695.mp3';
      final url = 'https://res.cloudinary.com/daxex7msa/video/upload/v1749047149/Audio/wobxsfuhkrymybtnlyqs.mp4';
      await _player.setUrl(url);

      _duration = _player.duration ?? Duration.zero;
      _listenToPlayer();
    } catch (e) {
      _handleError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleError(String? message) {
    debugPrint('Error loading audio: $message');
    // Optionally show Snackbar/toast/dialog here
  }

  void _listenToPlayer() {
    _player.positionStream.listen((pos) {
      if (!_isSeeking) setState(() => _position = pos);
    });

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
        _diskController?.stop();
      } else if (state.playing) {
        _diskController?.repeat();
      } else {
        _diskController?.stop();
      }
    });
  }

  void _togglePlayPause() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void _seekRelative(int seconds) {
    final newPosition = _player.position + Duration(seconds: seconds);
    final clampedPosition = newPosition < Duration.zero
        ? Duration.zero
        : (newPosition > _duration ? _duration : newPosition);

    _player.seek(clampedPosition);
  }

  String _formatDuration(Duration d) {
    return d.toString().split('.').first.padLeft(8, "0").substring(3);
  }

  @override
  void initState() {
    super.initState();
    _audioUseCase = ref.read(audioUseCaseProvider);
    _player = AudioPlayer();
    _diskController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    // WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    // });
  }

  @override
  void dispose() {
    _player.dispose();
    _diskController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // final imgUrl = _audio?.audioThumbnail != null
    //     ? 'https://thantrieu.com/resources/thumbnails/${_audio!.audioThumbnail}'
    //     : null;
    final imgUrl = 'https://thantrieu.com/resources/arts/1130295695.webp';

    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // Blurred background
          Positioned.fill(
            child: ClipRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: imgUrl != null
                    ? CachedNetworkImage(
                  imageUrl: imgUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Image.asset(
                    'assets/images/default_bg_blur.png',
                    fit: BoxFit.cover,
                  ),
                )
                    : Image.asset('assets/images/default_bg_blur.png'),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Back and menu
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _circleIcon(Icons.arrow_back_ios_new),
                      _circleIcon(Icons.more_vert),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Spinning Disk
                RotationTransition(
                  turns: _diskController!,
                  child: Container(
                    width: screenWidth * 0.7,
                    height: screenWidth * 0.7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imgUrl != null
                            ? CachedNetworkImageProvider(imgUrl)
                            : AssetImage(
                            'assets/images/audio_not_found_icon.png')
                        as ImageProvider,
                        fit: BoxFit.cover,
                        onError: (_, __) => {},
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  _audio?.audioTitle ?? "Unknown",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  _audio?.subAudioCategoryName ??
                      "Unknown category type",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),

                // Progress Slider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      Slider(
                        value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
                        max: _duration.inSeconds.toDouble(),
                        onChanged: (value) {
                          setState(() => _isSeeking = true);
                          _player.seek(Duration(seconds: value.toInt()));
                        },
                        onChangeEnd: (_) => setState(() => _isSeeking = false),
                        activeColor: Colors.white,
                        inactiveColor: Colors.white30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(_position), style: TextStyle(color: Colors.white70)),
                          Text(_formatDuration(_duration), style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Controls
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _circleIcon(Icons.fast_rewind, onTap: () => _seekRelative(-10)),
                      _circleIcon(
                        _player.playing ? Icons.pause : Icons.play_arrow,
                        size: 40,
                        color: Colors.brown.shade800,
                        bgColor: Colors.white,
                        onTap: _togglePlayPause,
                      ),
                      _circleIcon(Icons.fast_forward, onTap: () => _seekRelative(10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleIcon(IconData icon, {double size = 24, Color? color, Color? bgColor, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor ?? Colors.black38,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color ?? Colors.white, size: size),
      ),
    );
  }
}
