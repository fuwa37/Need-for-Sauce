import 'dart:io';
import 'dart:typed_data';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:need_for_sauce/common/common.dart' show loadingDialog;
import 'package:need_for_sauce/common/notifier.dart' show LoadingNotifier;
import 'package:need_for_sauce/common/video_control.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
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
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double value = 0;
  Future<void> _init;

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

  @override
  void initState() {
    super.initState();
    _init = _initVideo();
  }

  Widget _bab() {
    return BottomAppBar(
        color: Colors.blue,
        child: Container(
          height: 48,
          child: FutureBuilder(
            future: _init,
            builder: (context, snapshot) {
              return VideoControls(_videoPlayerController);
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
      videoPlayerController: _videoPlayerController,
      showControls: false,
    );
  }

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
}
