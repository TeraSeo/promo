import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({required this.videoUrl, Key? key}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  bool isMuted = true;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      showControls: false,
    );

    // Initialize the AudioPlayer inside ChewieController
    _chewieController.setVolume(isMuted ? 0.0 : 1.0);
  }

  void toggleMute() {
    setState(() {
      isMuted = !isMuted;
      _chewieController.setVolume(isMuted ? 0.0 : 1.0);
    });
  }

  void setMuteStatus() {
    isMuted = true;
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('videoPlayerKey${widget.videoUrl}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction == 0) {
          // Widget is not visible, pause or dispose video here
          if (this.mounted) {
            _videoPlayerController.pause();
          }
        } else {
          // Widget is visible, resume or initialize video here
          if (this.mounted) {
            _videoPlayerController.play();
          }
        }
      },
      child: Stack(
        children: [
          GestureDetector(
            onTap: toggleMute,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Chewie(
                controller: _chewieController,
              ),
            ),
          ),
          Positioned(
            bottom: 10.0,
            right: 10.0,
            child: IconButton(
              onPressed: toggleMute,
              icon: Icon(
                isMuted ? Icons.volume_off : Icons.volume_up,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}
