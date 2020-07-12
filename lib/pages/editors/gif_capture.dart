import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';

List<List<int>> _getImagesMemory(img.Animation anim) {
  return anim.map((e) => img.encodeJpg(e)).toList();
}

class GifCapture extends StatefulWidget {
  final _gif;

  GifCapture(this._gif);

  @override
  State<StatefulWidget> createState() {
    return GifCaptureState();
  }
}

class GifCaptureState extends State<GifCapture> with TickerProviderStateMixin {
  List<int> _imagesTick = List<int>();
  List<List<int>> _imagesMemory = List<List<int>>();
  int _imageIdx = 0;
  Stopwatch stopwatch;
  AnimationController _animationController;
  Animation<int> _animation;
  bool _isRepeated = true;
  Future<void> _init;

  Future<void> _getGif() async {
    stopwatch = Stopwatch()..start();
    var gif;

    if (widget._gif is String) {
      var res = await Dio()
          .get(widget._gif, options: Options(responseType: ResponseType.bytes));

      gif = res.data;
    } else if (widget._gif is File) {
      gif = widget._gif.readAsBytesSync();
    }

    if (gif != null) {
      var _imgs = img.decodeGifAnimation(gif);
      _imagesMemory.addAll(await compute(_getImagesMemory, _imgs));
      _imagesTick.addAll(_imgs.map((e) => e.duration));
      var _ticks = _imagesTick.fold(
          0, (previousValue, element) => previousValue + element);
      var _duration = _ticks * 10;
      _animationController = AnimationController(
          vsync: this,
          value: 0,
          duration: Duration(milliseconds: _duration.toInt()));
      _animation = IntTween(begin: 0, end: _imagesTick.length - 1)
          .animate(_animationController);
      _animationController.addListener(() {
        setState(() {
          _imageIdx = _animation.value;
        });
      });
    }
  }

  Widget _bab() {
    return BottomAppBar(
        color: Colors.blue,
        child: Container(
            height: 48,
            child: FutureBuilder(
              future: _init,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox();
                } else {
                  return Row(
                    children: [
                      IconButton(
                        color: Colors.white,
                        icon: (_animationController?.isAnimating ?? false)
                            ? Icon(Icons.pause)
                            : Icon(Icons.play_arrow),
                        onPressed: (_animationController == null)
                            ? null
                            : () {
                                if (_animationController.isAnimating) {
                                  setState(() {
                                    _animationController.stop();
                                  });
                                } else {
                                  if (_animationController.isCompleted) {
                                    _animationController.forward(from: 0);
                                  } else {
                                    _animationController.forward(
                                        from: ((_imageIdx + 1) /
                                            _imagesMemory.length));
                                  }
                                  if (_isRepeated) {
                                    _animationController.repeat();
                                  }
                                }
                              },
                      ),
                      IconButton(
                        color: (_isRepeated) ? Colors.white : Colors.black,
                        icon: Icon(Icons.repeat),
                        onPressed: (_animationController == null)
                            ? null
                            : () {
                                setState(() {
                                  _isRepeated = !_isRepeated;
                                });
                                if (_animationController.isAnimating &&
                                    _isRepeated) {
                                  _animationController.repeat();
                                } else if (_animationController.isAnimating &&
                                    !_isRepeated) {
                                  _animationController.animateTo(1);
                                }
                              },
                      ),
                      Flexible(
                        child: Slider(
                          activeColor: Colors.white,
                          inactiveColor: Colors.grey,
                          onChanged: (_animationController == null)
                              ? null
                              : (val) {
                                  setState(() {
                                    _imageIdx = val.toInt();
                                  });
                                },
                          onChangeStart: (_animationController == null)
                              ? null
                              : (val) {
                                  setState(() {
                                    _animationController.stop();
                                  });
                                },
                          label: "${_imageIdx + 1}",
                          min: 0,
                          max: (_animationController == null)
                              ? 0
                              : _imagesMemory.length.toDouble() - 1,
                          value: (_animationController == null)
                              ? 0
                              : _imageIdx.toDouble(),
                          divisions: (_animationController == null)
                              ? null
                              : _imagesMemory.length - 1,
                        ),
                      )
                    ],
                  );
                }
              },
            )));
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
                  child: ExtendedImage.memory(
                    _imagesMemory[_imageIdx],
                    gaplessPlayback: true,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    mode: ExtendedImageMode.none,
                    enableLoadState: true,
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
                          Navigator.pop(context, _imagesMemory[_imageIdx]);
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _init = _getGif();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _imagesMemory.forEach((element) {
      precacheImage(ExtendedMemoryImageProvider(element), context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.5),
      bottomNavigationBar: _bab(),
      body: _body(),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}
