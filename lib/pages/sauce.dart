import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:need_for_sauce/models/models.dart';
import 'package:share/share.dart';
import 'package:need_for_sauce/common/common.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom hide Text;
import 'package:need_for_sauce/common/video_control.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:chewie/chewie.dart' hide ChewieProgressColors;
import 'package:video_player/video_player.dart';

class SauceDesc extends StatefulWidget {
  final SauceObject sauce;

  SauceDesc(this.sauce);

  @override
  State<StatefulWidget> createState() {
    return SauceDescState();
  }
}

class SauceDescState extends State<SauceDesc> with TickerProviderStateMixin {
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;
  ScrollController _helpController = ScrollController();
  Future<void> _init;
  ValueNotifier<int> page = ValueNotifier(0);
  ValueNotifier<Widget> media = ValueNotifier(Container());
  PageController _pageController = PageController(initialPage: 0);

  void _videoListener() async {
    if (_videoPlayerController.value.position ==
        _videoPlayerController.value.duration) {
      print("completed");
    }
    if (_videoPlayerController.value.hasError) {
      media.value = _imageShow();
    }
  }

  Future<void> _initVideo() async {
    if (widget.sauce?.videoUrl != null ?? false) {
      _videoPlayerController =
          VideoPlayerController.network(widget.sauce.videoUrl);
    } else {
      return;
    }
    _videoPlayerController.setVolume(0);
    _videoPlayerController.addListener(_videoListener);
    _videoPlayerController.setLooping(true);
    try {
      await _videoPlayerController.initialize();
      _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController, showControls: false);
    } on Exception catch (e) {
      print(e);
    }
  }

  Widget _videoBar() {
    return Container(
      color: Colors.blue,
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

  Widget _videoPlayer() {
    return FutureBuilder(
        future: _init.timeout(Duration(seconds: 15)),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _imageShow();
          }
          return (_videoPlayerController.value.initialized)
              ? Column(
                  children: [
                    AspectRatio(
                      child: Chewie(
                        controller: _chewieController,
                      ),
                      aspectRatio: _videoPlayerController.value.aspectRatio,
                    ),
                    _videoBar()
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  Widget _imageShow() {
    if (widget.sauce.mangadexChapter == null) {
      return ExtendedImage(
          image: imageProvider(widget.sauce.imageUrl),
          fit: BoxFit.fitWidth,
          mode: ExtendedImageMode.none,
          enableLoadState: true,
          loadStateChanged: (ExtendedImageState state) {
            switch (state.extendedImageLoadState) {
              case LoadState.loading:
                {
                  return Center(child: CircularProgressIndicator());
                }
              case LoadState.completed:
                {
                  return ExtendedRawImage(
                    image: state.extendedImageInfo?.image,
                    fit: BoxFit.fitWidth,
                  );
                }
              case LoadState.failed:
                {
                  return Center(
                    child: Text("Failed to load image"),
                  );
                }
              default:
                {
                  return Text("Failed");
                }
            }
          });
    } else {
      return Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height / 1.25,
            maxWidth: MediaQuery.of(context).size.width),
        child: Stack(
          children: [
            PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  page.value = index;
                },
                reverse: true,
                scrollDirection: Axis.horizontal,
                itemCount: widget.sauce.mangadexChapter.length,
                itemBuilder: (context, index) {
                  return ExtendedImage(
                      image: imageProvider(widget.sauce.mangadexChapter[index]),
                      mode: ExtendedImageMode.none,
                      enableLoadState: true,
                      loadStateChanged: (ExtendedImageState state) {
                        switch (state.extendedImageLoadState) {
                          case LoadState.loading:
                            {
                              return Center(child: CircularProgressIndicator());
                            }
                          case LoadState.completed:
                            {
                              return ExtendedRawImage(
                                image: state.extendedImageInfo?.image,
                                fit: BoxFit.contain,
                              );
                            }
                          case LoadState.failed:
                            {
                              return Center(
                                child: Text("Failed to load image"),
                              );
                            }
                          default:
                            {
                              return Text("Failed");
                            }
                        }
                      });
                }),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  height: 48,
                  child: ValueListenableBuilder(
                      valueListenable: page,
                      builder: (context, int index, child) {
                        return FlutterSlider(
                            rtl: true,
                            step: FlutterSliderStep(
                              isPercentRange: false,
                            ),
                            values: [index.toDouble()],
                            onDragging: (index, a, b) {
                              _pageController.jumpToPage(a.toInt());
                            },
                            max:
                                widget.sauce.mangadexChapter.length.toDouble() -
                                    1,
                            min: 0,
                            tooltip: FlutterSliderTooltip(
                                disableAnimation: true,
                                format: (value) {
                                  value = value.split('.').first;
                                  if (value == '0') {
                                    return "Sauce";
                                  }
                                  return value;
                                },
                                textStyle: TextStyle(
                                    fontSize: 12, color: Colors.white),
                                boxStyle: FlutterSliderTooltipBox(
                                    decoration:
                                        BoxDecoration(color: Colors.blue))),
                            handler: FlutterSliderHandler(
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                    color: Colors.blue, shape: BoxShape.circle),
                              ),
                              decoration: BoxDecoration(),
                            ));
                      }),
                ))
          ],
        ),
      );
    }
  }

  _pageListener() {}

  Widget sauceResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        (widget.sauce.videoUrl == null)
            ? (widget.sauce.imageUrl == null)
                ? Container()
                : _imageShow()
            : ValueListenableBuilder(
                valueListenable: media,
                builder: (context, Widget value, child) {
                  return value;
                },
              ),
        Padding(
            padding: EdgeInsets.all(8),
            child: Stack(
              children: [
                MediaQuery(
                    data: MediaQueryData(textScaleFactor: 1),
                    child: Html(
                      shrinkWrap: true,
                      data: (widget?.sauce?.sauceStatus ?? true)
                          ? """
                      <code><a href='help'>Got wrong result?</a>
                      </br>Similarity: ${widget.sauce.similarity}%</code>
                      </br>${widget.sauce.reply}
                      """
                          : widget.sauce.reply,
                      onLinkTap: (url) {
                        print(url);
                        canLaunch(url).then((value) {
                          if (value) {
                            launch(url);
                          } else {
                            if (url == 'help') {
                              properImageHelp(context, _helpController);
                            }
                          }
                        });
                      },
                      style: {
                        'p': Style(
                            fontSize: FontSize(
                                15 * MediaQuery.of(context).textScaleFactor)),
                        'code': Style(
                            fontSize: FontSize(
                                12 * MediaQuery.of(context).textScaleFactor)),
                        'pre': Style(
                            fontFamily: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .fontFamily,
                            fontSize: FontSize(
                                15 * MediaQuery.of(context).textScaleFactor))
                      },
                      customRender: {
                        "spoiler": (context, child, attributes, element) {
                          return child;
                        },
                        "li": (context, child, attributes, element) {
                          return child;
                        }
                      },
                    )),
                Positioned(
                  right: 0,
                  top: -8,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: MediaQuery(
                        data: MediaQueryData(textScaleFactor: 1),
                        child: Html(
                          shrinkWrap: true,
                          data: (widget?.sauce?.source != null)
                              ? widget.sauce.source
                              : '',
                          onLinkTap: (url) {
                            canLaunch(url).then((value) {
                              if (value) {
                                launch(url);
                              }
                            });
                          },
                          style: {
                            'p': Style(
                                fontSize: FontSize(12 *
                                    MediaQuery.of(context).textScaleFactor),
                                textAlign: TextAlign.right),
                          },
                        )),
                  ),
                ),
              ],
            )),
      ],
    );
  }

  String removeAllHtmlTags(String htmlString) {
    List<String> cleanStrings = new List<String>();
    String replaced =
        htmlString.replaceAll('</br>', '</p><p>').replaceAll('<h3>', '<p>');
    dom.Document parsed = parser.parse(replaced);
    List<dom.Element> links = parsed.querySelectorAll('a');

    if (links.isNotEmpty) {
      links.forEach((element) {
        var link = element.attributes["href"];
        replaced = replaced.replaceAll(element.text, "$link\n");
      });
    }

    parsed = parser.parse(replaced);

    List<dom.Element> ps = parsed.querySelectorAll('p');

    if (ps.isNotEmpty)
      ps.forEach((f) {
        if (f.text != '') {
          cleanStrings.add(f.text);
        }
        if (f.text == "Description : ") {
          dom.Element pre = parsed.querySelector('pre');
          cleanStrings.add(pre?.text ?? '');
        }
      });

    return cleanStrings.join('\n');
  }

  @override
  void initState() {
    super.initState();
    _init = _initVideo();
    media.value = _videoPlayer();
    if (widget.sauce.mangadexChapter != null)
      widget.sauce.mangadexChapter.insert(0, widget.sauce.imageUrl);
    _pageController.addListener(_pageListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.sauce.mangadexChapter != null)
      widget.sauce.mangadexChapter.forEach((element) {
        precacheImage(ExtendedNetworkImageProvider(element), context);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget?.sauce?.title ?? '',
            softWrap: true,
          ),
          actions: [
            IconButton(
              tooltip: "Share",
              onPressed: () {
                Share.share(removeAllHtmlTags(widget.sauce.reply));
              },
              icon: Icon(Icons.share),
            )
          ],
        ),
        body: SingleChildScrollView(child: sauceResult()));
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }
}
