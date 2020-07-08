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
        bottomNavigationBar: BottomAppBar(
          color: Colors.blue,
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
            child: Row(
              children: [
                IconButton(
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      if (_videoPlayerController.value.isPlaying) {
                        _chewieController.pause();
                      } else {
                        if (_videoPlayerController.value.position ==
                            _videoPlayerController.value.duration) {
                          _chewieController.seekTo(Duration(milliseconds: 0));
                        }
                        _chewieController.play();
                      }
                    });
                  },
                  icon: Icon(
                    _videoPlayerController.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  tooltip:
                      _videoPlayerController.value.isPlaying ? 'Pause' : 'Play',
                ),
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
              ],
            ),
          ),
        ),
        body: (_chewieController == null)
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: EdgeInsets.fromLTRB(
                    0, MediaQuery.of(context).padding.top, 0, 0),
                child: Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height -
                          (MediaQuery.of(context).padding.bottom),
                      child: Chewie(
                        controller: _chewieController,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                            Colors.black.withOpacity(0.25),
                            Colors.transparent
                          ])),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.content_cut,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _getThumbnail();
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ));
  }

  @override
  void dispose() {
    _chewieController.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }
}
