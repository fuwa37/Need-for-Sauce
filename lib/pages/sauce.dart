import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:need_for_sauce/models/models.dart';
import 'package:share/share.dart';
import 'package:need_for_sauce/common/common.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom hide Text;
import 'package:cached_video_player/cached_video_player.dart';
import 'package:need_for_sauce/common/video_control.dart';

class SauceDesc extends StatefulWidget {
  final SauceObject sauce;

  SauceDesc(this.sauce);

  @override
  State<StatefulWidget> createState() {
    return SauceDescState();
  }
}

class SauceDescState extends State<SauceDesc> {
  CachedVideoPlayerController _videoPlayerController;
  ScrollController _helpController = ScrollController();
  Future<void> _init;

  void _videoListener() async {
    setState(() {});
  }

  Future<void> _initVideo() async {
    if (widget.sauce?.videoUrl != null ?? false) {
      _videoPlayerController =
          CachedVideoPlayerController.network(widget.sauce.videoUrl);
    } else {
      return;
    }
    _videoPlayerController.setVolume(0);
    await _videoPlayerController.initialize();
    _videoPlayerController.addListener(_videoListener);
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
        future: _init,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          return (_videoPlayerController.value != null &&
                  _videoPlayerController.value.initialized)
              ? Column(
                  children: [
                    AspectRatio(
                      child: CachedVideoPlayer(
                        _videoPlayerController,
                      ),
                      aspectRatio: _videoPlayerController.value.aspectRatio,
                    ),
                    _videoBar()
                  ],
                )
              : _imageShow();
        });
  }

  Widget _imageShow() {
    return ExtendedImage(
      image: imageProvider(widget.sauce.imageUrl),
      fit: BoxFit.fitWidth,
      mode: ExtendedImageMode.none,
      enableLoadState: true,
    );
  }

  Widget sauceResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        (widget.sauce.videoUrl == null)
            ? (widget.sauce.imageUrl == null) ? Container() : _imageShow()
            : _videoPlayer(),
        Padding(
            padding: EdgeInsets.all(10),
            child: MediaQuery(
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
                  },
                ))),
      ],
    );
  }

  String removeAllHtmlTags(String htmlString) {
    List<String> cleanStrings = new List<String>();
    dom.Document parsed = parser.parse(
        htmlString.replaceAll('</br>', '</p><p>').replaceAll('<h3>', '<p>'));
    List<dom.Element> ps = parsed.querySelectorAll('p');

    if (ps.isNotEmpty)
      ps.forEach((f) {
        if (f.text != '') cleanStrings.add(f.text);
      });

    return cleanStrings.join('\n');
  }

  @override
  void initState() {
    super.initState();
    _init = _initVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (widget?.sauce?.sauceStatus ?? true)
            ? Text(
                widget.sauce.title,
                softWrap: true,
              )
            : null,
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
      body: SingleChildScrollView(
        child: sauceResult(),
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }
}
