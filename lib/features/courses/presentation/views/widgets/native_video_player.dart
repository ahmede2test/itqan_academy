import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

class NativeVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final Duration? startAt;
  final String? thumbnailUrl;
  final Function(Duration position)? onProgress;
  final Function(bool isFullScreen)? onFullScreenChanged;

  const NativeVideoPlayer({
    super.key,
    required this.videoUrl,
    this.autoPlay = true,
    this.startAt,
    this.thumbnailUrl,
    this.onProgress,
    this.onFullScreenChanged,
  });

  @override
  State<NativeVideoPlayer> createState() => _NativeVideoPlayerState();
}

class _NativeVideoPlayerState extends State<NativeVideoPlayer> {
  // Common
  bool _isLoading = true;
  String? _errorMessage;
  bool _isYouTube = false;
  bool _showControls = true;
  Timer? _controlsTimer;

  // Native Player
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  // YouTube Player
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _checkVideoType();
    if (_isYouTube) {
      // 🚀 Lazy Loading: Wait for page transition to finish before initializing YouTube
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _initializeYouTubePlayer();
        }
      });
    } else {
      _initializeNativePlayer();
    }
  }

  void _checkVideoType() {
    final url = widget.videoUrl.toLowerCase();
    _isYouTube = url.contains('youtube.com') ||
        url.contains('youtu.be') ||
        url.contains('shorts');
  }

  void _initializeYouTubePlayer() {
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid YouTube URL';
        });
      }
      return;
    }

    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: widget.autoPlay,
        mute: false,
        startAt: widget.startAt?.inSeconds ?? 0,
        enableCaption: true,
        forceHD: false, // Shorts don't always need HD
        useHybridComposition: true, // 🚀 Stable performance for Android
      ),
    );

    _youtubeController!.addListener(() {
      final value = _youtubeController!.value;
      // 🚀 Fix: Ensure metadata is not null before processing
      if (value.isReady) {
        if (value.isPlaying) {
          widget.onProgress?.call(value.position);
        }
        // 🚀 Sync orientation with YouTube's internal fullscreen state
        if (value.isFullScreen) {
          _onYoutubeEnterFullScreen();
        }
      }
    });

    if (mounted) {
      setState(() {
        _isLoading = false;
        _startHideTimer();
      });
    }
  }

  void _onYoutubeEnterFullScreen() {
    _enterFullScreen();
  }

  void _startHideTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    if (mounted) {
      setState(() {
        _showControls = !_showControls;
      });
    }
    if (_showControls) {
      _startHideTimer();
    }
  }

  void _seekForward() {
    if (_isYouTube) {
      final current = _youtubeController!.value.position;
      _youtubeController!.seekTo(current + const Duration(seconds: 10));
    } else {
      final current = _videoPlayerController!.value.position;
      _videoPlayerController!.seekTo(current + const Duration(seconds: 10));
    }
    _startHideTimer();
  }

  void _seekBackward() {
    if (_isYouTube) {
      final current = _youtubeController!.value.position;
      _youtubeController!.seekTo(current - const Duration(seconds: 10));
    } else {
      final current = _videoPlayerController!.value.position;
      _videoPlayerController!.seekTo(current - const Duration(seconds: 10));
    }
    _startHideTimer();
  }

  void _onYoutubeExitFullScreen() {
    _exitFullScreen();
  }

  Future<void> _initializeNativePlayer() async {
    try {
      String streamUrl = widget.videoUrl;

      // Helper: Auto-convert Google Drive 'view' links to 'download' links
      if (streamUrl.contains('drive.google.com')) {
        if (streamUrl.contains('/view')) {
          final parts = streamUrl.split('/d/');
          if (parts.length > 1) {
            final idPart = parts[1].split('/')[0];
            streamUrl =
                'https://drive.google.com/uc?export=download&id=$idPart';
          }
        }
      }

      streamUrl = streamUrl.trim();

      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(streamUrl));

      await _videoPlayerController!.initialize();

      if (widget.startAt != null) {
        await _videoPlayerController!.seekTo(widget.startAt!);
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: widget.autoPlay,
        looping: false,
        aspectRatio: 16 / 9,
        allowFullScreen: true,
        allowMuting: true,
        showControls:
            false, // Disable default controls to use our custom professional ones
        fullScreenByDefault: false,
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ],
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        systemOverlaysAfterFullScreen: SystemUiOverlay.values,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      // Listener forFullscreen entry/exit via Chewie
      _videoPlayerController!.addListener(_onControllerUpdate);

      _chewieController!.addListener(() {
        if (_chewieController!.isFullScreen) {
          _enterFullScreen();
        } else {
          _exitFullScreen();
        }
      });

      if (mounted) {
        setState(() {
          _isLoading = false;
          _startHideTimer();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading video: $e';
        });
      }
    }
  }

  void _onControllerUpdate() {
    if (mounted) {
      if (_videoPlayerController != null &&
          _videoPlayerController!.value.isPlaying) {
        widget.onProgress?.call(_videoPlayerController!.value.position);
      }
      setState(() {});
    }
  }

  Future<void> _enterFullScreen({bool updateState = true}) async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([]);
    widget.onFullScreenChanged?.call(true);
    if (updateState && mounted) setState(() {});
  }

  Future<void> _exitFullScreen({bool updateState = true}) async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    widget.onFullScreenChanged?.call(false);
    if (updateState && mounted) setState(() {});
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _videoPlayerController?.removeListener(_onControllerUpdate);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _youtubeController?.dispose();
    // 🚀 Ensure we reset system settings on player close WITHOUT calling setState
    _exitFullScreen(updateState: false);
    super.dispose();
  }

  Widget _buildControlsOverlay({bool isFullScreen = false}) {
    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: IgnorePointer(
        ignoring: !_showControls,
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: isFullScreen ? 20 : 0,
          ),
          color: Colors.black38, // Professional semi-transparent background
          child: Column(
            children: [
              // Top Bar: Back Button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    if (isFullScreen)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white, size: 28),
                        onPressed: () {
                          if (_isYouTube) {
                            _youtubeController?.toggleFullScreenMode();
                          } else {
                            _chewieController?.exitFullScreen();
                          }
                          _exitFullScreen(); // Force immediate restoration
                        },
                      ),
                    const Spacer(),
                  ],
                ),
              ),
              const Spacer(),
              // Middle Bar: Skip/Play Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10_rounded,
                        color: Colors.white, size: 48),
                    onPressed: _seekBackward,
                  ),
                  _buildPlayPauseButton(),
                  IconButton(
                    icon: const Icon(Icons.forward_10_rounded,
                        color: Colors.white, size: 48),
                    onPressed: _seekForward,
                  ),
                ],
              ),
              const Spacer(),
              // Bottom Bar: Progress
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    bool isPlaying;
    VoidCallback onPressed;

    if (_isYouTube) {
      isPlaying = _youtubeController!.value.isPlaying;
      onPressed = () {
        if (isPlaying) {
          _youtubeController!.pause();
        } else {
          _youtubeController!.play();
        }
        _startHideTimer();
      };
    } else {
      isPlaying = _videoPlayerController!.value.isPlaying;
      onPressed = () {
        if (isPlaying) {
          _videoPlayerController!.pause();
        } else {
          _videoPlayerController!.play();
        }
        _startHideTimer();
      };
    }

    return IconButton(
      icon: Icon(
        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
        color: Colors.white,
        size: 64,
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildBottomControls() {
    if (_isYouTube) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: ProgressBar(
                controller: _youtubeController,
                colors: const ProgressBarColors(
                  playedColor: Colors.red,
                  handleColor: Colors.redAccent,
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.white12,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                _youtubeController?.value.isFullScreen ?? false
                    ? Icons.fullscreen_exit_rounded
                    : Icons.fullscreen_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                _youtubeController?.toggleFullScreenMode();
                _startHideTimer();
              },
            ),
          ],
        ),
      );
    } else {
      if (_videoPlayerController == null ||
          !_videoPlayerController!.value.isInitialized) {
        return const SizedBox();
      }

      final duration = _videoPlayerController!.value.duration;
      final position = _videoPlayerController!.value.position;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 7),
                  activeTrackColor: Colors.red,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: Colors.redAccent,
                  overlayColor: Colors.red.withOpacity(0.2),
                ),
                child: Slider(
                  value: position.inSeconds
                      .toDouble()
                      .clamp(0, duration.inSeconds.toDouble()),
                  max: duration.inSeconds.toDouble(),
                  onChanged: (value) {
                    _videoPlayerController!
                        .seekTo(Duration(seconds: value.toInt()));
                    _startHideTimer();
                  },
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                _chewieController?.isFullScreen ?? false
                    ? Icons.fullscreen_exit_rounded
                    : Icons.fullscreen_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                if (_chewieController == null) return;
                if (_chewieController!.isFullScreen) {
                  _chewieController!.exitFullScreen();
                  _exitFullScreen();
                } else {
                  _chewieController!.enterFullScreen();
                  _enterFullScreen();
                }
                _startHideTimer();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            if (widget.thumbnailUrl != null)
              CachedNetworkImage(
                imageUrl: widget.thumbnailUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            const Center(child: CircularProgressIndicator(color: Colors.red)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: Center(
              child: Text(_errorMessage!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center)),
        ),
      );
    }

    if (_isYouTube && _youtubeController != null) {
      return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: false,
        ),
        builder: (context, player) {
          final isFullScreen = _youtubeController!.value.isFullScreen;
          return Container(
            color: Colors.black,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: GestureDetector(
                  onTap: _toggleControls,
                  behavior: HitTestBehavior.opaque,
                  child: Stack(
                    children: [
                      player,
                      _buildControlsOverlay(isFullScreen: isFullScreen),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    final isFullScreen = _chewieController?.isFullScreen ?? false;
    return Container(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: GestureDetector(
            onTap: _toggleControls,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                Chewie(
                  controller: _chewieController!,
                ),
                _buildControlsOverlay(isFullScreen: isFullScreen),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
