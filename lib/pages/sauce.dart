import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:need_for_sauce/models/models.dart';
import 'package:share/share.dart';
import 'package:need_for_sauce/common/common.dart';

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
  Future<void> _future;

  Future<void> initVideoPlayer() async {
    await _videoPlayerController.initialize();
    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoPlay: false,
        looping: true,
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
          child: MarkdownBody(
              onTapLink: (String link) {
                launch(link);
              },
              selectable: false,
              styleSheet: MarkdownStyleSheet(
                  p: TextStyle(fontSize: 16, color: Colors.black),
                  h3: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
              data: (widget?.sauce?.sauceStatus ?? true)
                  ? "```Similarity: ${widget.sauce.similarity}%```\n\n${widget.sauce.reply}"
                  : widget.sauce.reply),
        ),
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
                    Share.share(widget.sauce.reply);
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
