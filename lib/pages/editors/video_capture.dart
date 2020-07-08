import 'package:flutter/material.dart';
import 'package:need_for_sauce/pages/editors/video_control.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoCapture extends StatefulWidget {
  final _video;

  VideoCapture(this._video);

  @override
  State<StatefulWidget> createState() {
    return _VideoCaptureState();
  }
}

class _VideoCaptureState extends State<VideoCapture>
    with TickerProviderStateMixin {
  ChewieController _chewieController;
  VideoPlayerController _videoPlayerController;
  double value = 0;
  Duration _currentVideoPosition;
  AnimationController _cutBAnimationController;
  Animation<double> _cutBAnimation;

  void _videoListener() async {
    setState(() {
      _currentVideoPosition = _videoPlayerController.value.position;
    });
  }

  _getThumbnail() async {
    var thumb;

    try {
      thumb = await VideoThumbnail.thumbnailData(
        video: widget._video.path,
        imageFormat: ImageFormat.JPEG,
        timeMs: _currentVideoPosition.inMilliseconds,
        quality: 100,
      );
    } on NoSuchMethodError catch (e) {
      print(e);
      thumb = await VideoThumbnail.thumbnailData(
        video: widget._video,
        imageFormat: ImageFormat.JPEG,
        timeMs: _currentVideoPosition.inMilliseconds,
        quality: 100,
      );
    }

    Navigator.pop(context, thumb);
  }

  _initVideoPlayer() async {
    await _videoPlayerController.initialize();
    setState(() {
      _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          aspectRatio: _videoPlayerController.value.aspectRatio,
          autoPlay: false,
          showControls: false,
          errorBuilder: (context, error) {
            return Center(
              child: Text(error),
            );
          },
          placeholder: Center(
            child: CircularProgressIndicator(),
          ));
      _videoPlayerController.addListener(_videoListener);
      _currentVideoPosition = _videoPlayerController.value.position;
    });
  }

  @override
  void initState() {
    super.initState();

    _cutBAnimationController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this, value: 1);
    _cutBAnimation =
        CurvedAnimation(parent: _cutBAnimationController, curve: Curves.linear);

    if (widget._video is File) {
      print("file");
      _videoPlayerController = VideoPlayerController.file(widget._video);
    } else if (widget._video is String) {
      print("Url");
      _videoPlayerController = VideoPlayerController.network(widget._video);
    }
    _videoPlayerController.setVolume(0);
    _initVideoPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.5),
      floatingActionButton: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 16),
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            ScaleTransition(
              scale: _cutBAnimation,
              child: FloatingActionButton(
                elevation: 0,
                heroTag: null,
                onPressed: () {
                  _getThumbnail();
                },
                child: Icon(Icons.content_cut),
                tooltip: "Cut",
              ),
            ),
            SizedBox(
              height: 16,
            ),
            FloatingActionButton(
              elevation: 0,
              heroTag: null,
              onPressed: () {
                setState(() {
                  if (_videoPlayerController.value.isPlaying) {
                    _cutBAnimationController.forward();
                    _chewieController.pause();
                  } else {
                    if (_videoPlayerController.value.position ==
                        _videoPlayerController.value.duration) {
                      _chewieController.seekTo(Duration(milliseconds: 0));
                    }
                    _cutBAnimationController.reverse();
                    _chewieController.play();
                  }
                });
              },
              child: Icon(
                _videoPlayerController.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
              tooltip:
                  _videoPlayerController.value.isPlaying ? 'Pause' : 'Play',
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 36,
        color: Colors.blue,
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 32, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (_videoPlayerController.value.volume == 0) {
                      _videoPlayerController.setVolume(100);
                    } else {
                      _videoPlayerController.setVolume(0);
                    }
                  });
                },
                icon: Icon(
                  _videoPlayerController.value.volume == 0
                      ? Icons.volume_off
                      : Icons.volume_up,
                ),
                color: Colors.white,
                tooltip: "Mute",
              ),
              Flexible(
                fit: FlexFit.tight,
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  height: 48,
                  child: MaterialVideoProgressBar(
                    _videoPlayerController,
                    colors: ChewieProgressColors(
                        playedColor: Colors.white,
                        handleColor: Colors.white,
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.black),
                  ),
                ),
              ),
              Container(
                child: Text(
                  "${formatDuration(_currentVideoPosition ?? Duration(seconds: 0))}/${formatDuration(_videoPlayerController?.value?.duration ?? Duration(seconds: 0))}",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(
                width: 72,
              ),
            ],
          ),
        ),
      ),
      body: (_chewieController == null)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: EdgeInsets.fromLTRB(
                  0, MediaQuery.of(context).padding.top, 0, 0),
              height: MediaQuery.of(context).size.height -
                  (MediaQuery.of(context).padding.bottom),
              child: Chewie(
                controller: _chewieController,
              ),
            ),
    );
  }

  @override
  void dispose() {
    _chewieController.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }
}
