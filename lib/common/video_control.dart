// From Chewie package

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class MaterialVideoProgressBar extends StatefulWidget {
  MaterialVideoProgressBar(
    this.controller, {
    ChewieProgressColors colors,
    this.onDragEnd,
    this.onDragStart,
    this.onDragUpdate,
  }) : colors = colors ?? ChewieProgressColors();

  final VideoPlayerController controller;
  final ChewieProgressColors colors;
  final Function() onDragStart;
  final Function() onDragEnd;
  final Function() onDragUpdate;

  @override
  _VideoProgressBarState createState() {
    return _VideoProgressBarState();
  }
}

class _VideoProgressBarState extends State<MaterialVideoProgressBar> {
  _VideoProgressBarState() {
    listener = () {
      if (!mounted) return;
      setState(() {});
    };
  }

  VoidCallback listener;
  bool _controllerWasPlaying = false;

  VideoPlayerController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    void seekToRelativePosition(Offset globalPosition) {
      final box = context.findRenderObject() as RenderBox;
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position = controller.value.duration * relative;
      controller.seekTo(position);
    }

    return GestureDetector(
      onHorizontalDragStart: (DragStartDetails details) {
        print(details);
        if (!controller.value.initialized) {
          return;
        }
        _controllerWasPlaying = controller.value.isPlaying;
        if (_controllerWasPlaying) {
          controller.pause();
        }

        if (widget.onDragStart != null) {
          widget.onDragStart();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);

        if (widget.onDragUpdate != null) {
          widget.onDragUpdate();
        }
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (!controller.value.isPlaying) {
          controller.pause();
        }

        if (_controllerWasPlaying) {
          controller.play();
        }

        if (widget.onDragEnd != null) {
          widget.onDragEnd();
        }
      },
      onTapDown: (TapDownDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        if (!controller.value.isPlaying) {
          controller.pause();
        }
        seekToRelativePosition(details.globalPosition);
      },
      child: Center(
        child: Container(
          height: MediaQuery.of(context).size.height / 2,
          width: MediaQuery.of(context).size.width,
          color: Colors.transparent,
          child: CustomPaint(
            painter: _ProgressBarPainter(
              controller.value,
              widget.colors,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  _ProgressBarPainter(this.value, this.colors);

  VideoPlayerValue value;
  ChewieProgressColors colors;

  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const height = 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, size.height / 2),
          Offset(size.width, size.height / 2 + height),
        ),
        const Radius.circular(4.0),
      ),
      colors.backgroundPaint,
    );
    if (!value.initialized) {
      return;
    }
    final double playedPartPercent =
        value.position.inMilliseconds / value.duration.inMilliseconds;
    final double playedPart =
        playedPartPercent > 1 ? size.width : playedPartPercent * size.width;
    for (final DurationRange range in value.buffered) {
      final double start = range.startFraction(value.duration) * size.width;
      final double end = range.endFraction(value.duration) * size.width;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(start, size.height / 2),
            Offset(end, size.height / 2 + height),
          ),
          const Radius.circular(4.0),
        ),
        colors.bufferedPaint,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, size.height / 2),
          Offset(playedPart, size.height / 2 + height),
        ),
        const Radius.circular(4.0),
      ),
      colors.playedPaint,
    );
    canvas.drawCircle(
      Offset(playedPart, size.height / 2 + height / 2),
      height * 3,
      colors.handlePaint,
    );
  }
}

String formatDuration(Duration position) {
  final ms = position.inMilliseconds;

  int seconds = ms ~/ 1000;
  final int hours = seconds ~/ 3600;
  seconds = seconds % 3600;
  var minutes = seconds ~/ 60;
  seconds = seconds % 60;

  final hoursString = hours >= 10
      ? '$hours'
      : hours == 0
          ? '00'
          : '0$hours';

  final minutesString = minutes >= 10
      ? '$minutes'
      : minutes == 0
          ? '00'
          : '0$minutes';

  final secondsString = seconds >= 10
      ? '$seconds'
      : seconds == 0
          ? '00'
          : '0$seconds';

  final formattedTime =
      '${hoursString == '00' ? '' : hoursString + ':'}$minutesString:$secondsString';

  return formattedTime;
}

class VideoControl extends StatefulWidget {
  VideoControl(this.videoPlayerController);

  final VideoPlayerController videoPlayerController;

  @override
  _VideoControlState createState() => _VideoControlState();
}

class _VideoControlState extends State<VideoControl> {
  VideoPlayerController get _videoPlayerController =>
      widget.videoPlayerController;

  @override
  Widget build(BuildContext context) {
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
            tooltip: _videoPlayerController.value.isPlaying ? 'Pause' : 'Play',
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
  }
}
