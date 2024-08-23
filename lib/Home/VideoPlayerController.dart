import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  VideoPlayerWidget({required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..addListener(() {
        if (_controller.value.hasError) {
          setState(() {
            _isError = true;
          });
        }
      })
      ..initialize().then((_) {
        setState(() {});
      }).catchError((error) {
        setState(() {
          _isError = true;
        });
        print('Error initializing video player: $error');
      });
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return Center(child: Text('Error loading video', style: TextStyle(color: Colors.white)));
    }

    return _controller.value.isInitialized
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    )
        : Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
