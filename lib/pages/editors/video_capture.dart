import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:chewie/chewie.dart' hide ChewieProgressColors;
import 'package:provider/provider.dart';
import 'package:need_for_sauce/common/notifier.dart' show LoadingNotifier;
import 'package:need_for_sauce/common/common.dart' show loadingDialog;
import 'package:need_for_sauce/common/video_control.dart';

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
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double value = 0;
  Future<void> _init;

  Future<Uint8List> _thumbnail() async {
    Uint8List thumb;

    try {
      thumb = await VideoThumbnail.thumbnailData(
        video: widget._video.path,
        imageFormat: ImageFormat.JPEG,
        timeMs: _videoPlayerController.value.position.inMilliseconds,
        quality: 100,
      );
    } on NoSuchMethodError catch (e) {
      print(e);
      thumb = await VideoThumbnail.thumbnailData(
        video: widget._video,
        imageFormat: ImageFormat.JPEG,
        timeMs: _videoPlayerController.value.position.inMilliseconds,
        quality: 100,
      );
    }

    return thumb;
  }

  _getThumbnail() async {
    loadingDialog(scaffoldContext: _scaffoldKey.currentContext);

    _thumbnail().then((value) {
      if (value == null) return;

      context.read<LoadingNotifier>().popDialog();
      Navigator.pop(context, value);
    }).catchError((onError) {
      print(onError);
    });
  }

  Future<void> _initVideo() async {
    if (widget._video is File) {
      _videoPlayerController = VideoPlayerController.file(widget._video);
    } else if (widget._video is String) {
      _videoPlayerController = VideoPlayerController.network(widget._video);
    }
    _videoPlayerController.setVolume(0);
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController, showControls: false);
  }

  Widget _bab() {
    return BottomAppBar(
        color: Colors.blue,
        child: Container(
          height: 48,
          child: FutureBuilder(
            future: _init,
            builder: (context, snapshot) {
              return Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      color: Colors.white,
                      onPressed: (_videoPlayerController.value.duration == null)
                          ? null
                          : () {
                              setState(() {
                                if (_videoPlayerController.value.isPlaying) {
                                  _videoPlayerController.pause();
                                } else {
                                  if (_videoPlayerController.value.position ==
                                      _videoPlayerController.value.duration) {
                                    _videoPlayerController
                                        .seekTo(Duration(milliseconds: 0));
                                  }
                                  _videoPlayerController.play();
                                }
                              });
                            },
                      icon: Icon(
                        _videoPlayerController.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      tooltip: _videoPlayerController.value.isPlaying
                          ? 'Pause'
                          : 'Play',
                    ),
                    IconButton(
                      onPressed: (_videoPlayerController.value.duration == null)
                          ? null
                          : () {
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
                        "${formatDuration(_videoPlayerController?.value?.position ?? Duration(seconds: 0))}/${formatDuration(_videoPlayerController?.value?.duration ?? Duration(seconds: 0))}",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ));
  }

  Widget _body() {
    return FutureBuilder(
        future: _init,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                  0, MediaQuery.of(context).padding.top, 0, 0),
              child: Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height -
                        (MediaQuery.of(context).padding.bottom),
                    child: Center(
                      child: AspectRatio(
                        child: Chewie(
                          controller: _chewieController,
                        ),
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                      ),
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
                          tooltip: "Back",
                        ),
                        IconButton(
                          tooltip: "Done",
                          icon: Icon(
                            Icons.done,
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
            );
          }
        });
  }

  @override
  void initState() {
    super.initState();
    _init = _initVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white.withOpacity(0.5),
        bottomNavigationBar: _bab(),
        body: _body());
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}
