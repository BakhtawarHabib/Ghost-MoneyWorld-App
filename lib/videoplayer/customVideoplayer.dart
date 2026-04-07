import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ModernVideoPlayer extends StatefulWidget {
  final String url;
  final String thumbnail;

  const ModernVideoPlayer({
    super.key,
    required this.url,
    required this.thumbnail,
  });

  @override
  State<ModernVideoPlayer> createState() => _ModernVideoPlayerState();
}

class _ModernVideoPlayerState extends State<ModernVideoPlayer> {
  late VideoPlayerController _controller;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _togglePlay() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio:
          _controller.value.isInitialized
              ? _controller.value.aspectRatio
              : 16 / 9,
      child: Stack(
        children: [
          _controller.value.isInitialized
              ? GestureDetector(
                onTap: _toggleControls,
                child: VideoPlayer(_controller),
              )
              : Image.network(widget.thumbnail, fit: BoxFit.cover),

          if (_showControls)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 50,
                      color: Colors.white,
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause_circle
                            : Icons.play_circle,
                      ),
                      onPressed: _togglePlay,
                    ),

                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: Colors.red,
                        bufferedColor: Colors.white38,
                        backgroundColor: Colors.white30,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.replay_10),
                          color: Colors.white,
                          onPressed: () {
                            final pos = _controller.value.position;
                            _controller.seekTo(
                              pos - const Duration(seconds: 10),
                            );
                          },
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: const Icon(Icons.forward_10),
                          color: Colors.white,
                          onPressed: () {
                            final pos = _controller.value.position;
                            _controller.seekTo(
                              pos + const Duration(seconds: 10),
                            );
                          },
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: const Icon(Icons.fullscreen),
                          color: Colors.white,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
