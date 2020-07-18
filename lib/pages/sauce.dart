import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:need_for_sauce/models/models.dart';
import 'package:share/share.dart';
import 'package:need_for_sauce/common/common.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom hide Text;

class SauceDesc extends StatefulWidget {
  final SauceObject sauce;

  SauceDesc(this.sauce);

  @override
  State<StatefulWidget> createState() {
    return SauceDescState();
  }
}

class SauceDescState extends State<SauceDesc> {
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;
  ScrollController _helpController = ScrollController();
  Future<void> _future;

  Future<void> initVideoPlayer() async {
    await _videoPlayerController.initialize();
    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoPlay: false,
      );
    });
  }

  Widget _videoPlayer() {
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          return (_chewieController == null)
              ? _imageShow()
              : Chewie(
                  controller: _chewieController,
                );
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
                            14 * MediaQuery.of(context).textScaleFactor)),
                    'code': Style(
                        fontSize: FontSize(
                            10 * MediaQuery.of(context).textScaleFactor)),
                  },
                ))),
      ],
    );
  }

  Widget _noConn() {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text("No connection to server"),
        ));
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
    if (widget.sauce?.videoUrl != null ?? false) {
      _videoPlayerController =
          VideoPlayerController.network(widget.sauce.videoUrl);
      _future = initVideoPlayer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return (widget.sauce == null)
        ? _noConn()
        : Scaffold(
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
    _chewieController?.dispose();
    super.dispose();
  }
}
