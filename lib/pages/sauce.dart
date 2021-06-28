import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:html/dom.dart' as dom hide Text;
import 'package:html/parser.dart' as parser;
import 'package:need_for_sauce/common/caching_helper.dart';
import 'package:need_for_sauce/common/common.dart';
import 'package:need_for_sauce/common/notifier.dart';
import 'package:need_for_sauce/common/video_control.dart';
import 'package:need_for_sauce/models/models.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

// class _SaucePage extends StatefulWidget {
//   _SaucePage({Key key, @required this.sauces}) : super(key: key);

//   final Union2<SauceNaoObject, TraceObject> sauces;

//   @override
//   _SaucePageState createState() => _SaucePageState();
// }

class SaucePage extends StatelessWidget {
  SaucePage(
      {Key key, @required this.sauces, @required this.searchOptionNotifier})
      : super(key: key);

  final dynamic sauces;
  final SearchOptionNotifier searchOptionNotifier;

  @override
  Widget build(BuildContext context) {
    List<dynamic> sauceResults;
    sauces.switchCase((SauceNaoObject v) {
      sauceResults = v.results.toList();
    }, (TraceObject v) {
      sauceResults = v.docs.toList();
    });
    return Scaffold(
        appBar: AppBar(),
        body: ChangeNotifierProvider.value(
          value: searchOptionNotifier,
          child: ListView.separated(
            separatorBuilder: (context, index) => Divider(),
            itemCount: sauceResults.length,
            itemBuilder: (context, index) {
              return _result(
                  context, searchOptionNotifier, sauceResults[index]);
            },
          ),
        ));
  }

  Widget _result(BuildContext context,
      SearchOptionNotifier searchOptionNotifier, dynamic sauceResult) {
    Widget result;

    sauceResult.switchCase((SauceNaoResult v) {
      ImageProvider _imageProvider = imageProvider(v.header.thumbnail);
      result = Row(
        children: [
          Flexible(
            flex: 1,
            child: ExtendedImage(image: _imageProvider),
          ),
          Flexible(
            flex: 2,
            child: Padding(
                padding: EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snTitle(v.data),
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                    ),

                    Divider(),
                    // Flexible(
                    //   flex: 2,
                    //   child: GridView.count(
                    //     shrinkWrap: true,
                    //     crossAxisCount: 2,
                    //     childAspectRatio: 3.5,
                    //     children: v.data
                    //         .toJson()
                    //         .entries
                    //         .where((e) => (e.value != null &&
                    //             e.key != null &&
                    //             e.key.isNotEmpty &&
                    //             e.key != 'Title' &&
                    //             e.key != 'Source'))
                    //         .map((e) {
                    //       String txt;
                    //       if (e.value != null &&
                    //           e.key != null &&
                    //           e.key.isNotEmpty &&
                    //           e.key != 'Title' &&
                    //           e.key != 'Source') {
                    //         txt = "${e.key} : ${e.value}";
                    //         return Text(txt ?? '');
                    //       } else
                    //         return SizedBox();
                    //     }).toList(),
                    //   ),
                    // ),
                    Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {
                          if (searchOptionNotifier.addInfoOption == 1) {
                            loadingDialog(scaffoldContext: context);
                            v.data.withInfo().then((res) {
                              context.read<LoadingNotifier>().popDialog();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SauceDesc(SauceObject.fromSauceNao(
                                        v.header, res));
                                  },
                                ),
                              );
                            });
                          } else if (searchOptionNotifier.addInfoOption == 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return SauceDesc(SauceObject.fromSauceNao(
                                      v.header, v.data));
                                },
                              ),
                            );
                          } else {
                            bool _val;
                            showDialog(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (BuildContext context, setState) {
                                    return AlertDialog(
                                      content: Container(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                                "This sauce has more information.\nDo you want to see it?"),
                                            Text(
                                                "It will download additional information."),
                                            CheckboxListTile(
                                              onChanged: (val) {
                                                setState(() {
                                                  _val = val;
                                                });
                                              },
                                              value: _val ?? false,
                                              title: Text("Don't ask me again"),
                                            )
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: Text("NO"),
                                          onPressed: () {
                                            if (_val) {
                                              searchOptionNotifier
                                                  .setAddInfo(0);
                                            }
                                            Navigator.pop(context, false);
                                          },
                                        ),
                                        TextButton(
                                          child: Text("YES"),
                                          onPressed: () {
                                            if (_val) {
                                              searchOptionNotifier
                                                  .setAddInfo(1);
                                            }
                                            Navigator.pop(context, true);
                                          },
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                            ).then(
                              (res) {
                                print(res);
                                if (res == null) {
                                  searchOptionNotifier.setAddInfo(-1);
                                } else if (res) {
                                  loadingDialog(scaffoldContext: context);
                                  try {
                                    v.data.withInfo().then(
                                      (s) {
                                        context
                                            .read<LoadingNotifier>()
                                            .popDialog();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return SauceDesc(
                                                  SauceObject.fromSauceNao(
                                                      v.header, s));
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  } on NoInfoException catch (e) {
                                    print(e);
                                    context.read<LoadingNotifier>().popDialog();
                                  }
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return SauceDesc(
                                            SauceObject.fromSauceNao(
                                                v.header, v.data));
                                      },
                                    ),
                                  );
                                }
                              },
                            );
                          }
                        },
                        child: Text("MORE"),
                      ),
                    ),
                  ],
                )),
          ),
        ],
      );
      result = FutureBuilder(
        future: PaletteGenerator.fromImageProvider(_imageProvider),
        builder: (context, AsyncSnapshot<PaletteGenerator> snapshot) {
          if (snapshot.data == null) {
            return CircularProgressIndicator();
          }
          return SizedBox(
              height: MediaQuery.of(context).size.height / 6,
              width: MediaQuery.of(context).size.width,
              child: Card(
                child: Text("abx"),
                color: snapshot.data?.dominantColor?.color ?? Colors.white,
              ));
        },
      );
    }, (TraceDocs v) {
      result = _resultCard(
          title: v.titleRomaji,
          image:
              'https://media.trace.moe/image/${v.anilistId.toString()}/${Uri.encodeComponent(v.filename).toString()}' +
                  '?t=' +
                  ((v.at == v.at.truncate())
                      ? v.at.toInt().toString()
                      : v.at.toString()) +
                  '&token=' +
                  v.tokenthumb);
    });

    return result;
  }

  Card _resultCard(
      {@required String title, @required String image, Widget content}) {
    return Card(
      child: Row(children: [
        ExtendedImage(image: imageProvider(image)),
        Divider(),
        InkWell(
            onTap: () {},
            child: Column(
              children: [Text(title), Divider(), content ?? SizedBox()],
            )),
      ]),
    );
  }
}

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
                Share.share(_removeAllHtmlTags(widget.sauce.reply));
              },
              icon: Icon(Icons.share),
            )
          ],
        ),
        body: SingleChildScrollView(child: sauceResult()));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.sauce.mangadexChapter != null && mounted)
      widget.sauce.mangadexChapter.forEach((element) {
        precacheImage(ExtendedNetworkImageProvider(element), context);
      });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
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
                      onLinkTap: (url, _, __, ___) {
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
                        "spoiler": (context, child) {
                          return child;
                        },
                        "li": (context, child) {
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
                          onLinkTap: (url, _, __, ___) {
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

  Future<File> _cachingVideo(String url) async {
    return await CacheUtils.downloadAndCache(url);
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
                        return Slider(
                          value: index.toDouble(),
                          onChanged: (index) {
                            _pageController.jumpToPage(index.toInt());
                          },
                          max: widget.sauce.mangadexChapter.length.toDouble() -
                              1,
                          min: 0,
                          divisions: 1,
                        );
                      }),
                ))
          ],
        ),
      );
    }
  }

  Future<void> _initVideo() async {
    if (widget.sauce?.videoUrl != null ?? false) {
      _videoPlayerController = VideoPlayerController.file(
          await _cachingVideo(widget.sauce.videoUrl));

      if (_videoPlayerController == null)
        _videoPlayerController =
            VideoPlayerController.network(widget.sauce.videoUrl);
    } else {
      return;
    }
    _videoPlayerController.setVolume(0);
    _videoPlayerController.addListener(_videoListener);
    try {
      await _videoPlayerController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        showControls: false,
        allowPlaybackSpeedChanging: false,
        allowFullScreen: false,
      );
    } on Exception catch (e) {
      print(e);
    }
  }

  _pageListener() {}

  String _removeAllHtmlTags(String htmlString) {
    List<String> cleanStrings = [];
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

  Widget _videoBar() {
    return Container(
        color: Theme.of(context).primaryColor,
        child: VideoControls(
          _videoPlayerController,
          showTime: false,
        ));
  }

  void _videoListener() {
    if (_videoPlayerController.value.hasError) {
      media.value = _imageShow();
    }
  }

  Widget _videoPlayer() {
    return FutureBuilder(
        future: _init.timeout(Duration(seconds: 30)),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return _imageShow();
          }
          if (snapshot.connectionState == ConnectionState.waiting ||
              !_videoPlayerController.value.isInitialized) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Column(
            children: [
              AspectRatio(
                child: Chewie(
                  controller: _chewieController,
                ),
                aspectRatio: _videoPlayerController.value.aspectRatio,
              ),
              _videoBar(),
            ],
          );
        });
  }
}
