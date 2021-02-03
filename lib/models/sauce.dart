part of models;

class SauceObject {
  double similarity;
  String imageUrl;
  dynamic imageSource;
  String videoUrl;
  String reply;
  String source;
  String title;
  bool sauceStatus;
  List<String> mangadexChapter;

  SauceObject({
    this.reply,
    this.imageSource,
    this.similarity,
    this.title,
    this.imageUrl,
    this.videoUrl,
    this.source,
    this.sauceStatus,
  });

  SauceObject.fromJSON(Map<dynamic, dynamic> data) {
    imageSource = data['image_source'];
    imageUrl = data['image_url'];
    videoUrl = data['vid_url'];
    similarity = data['similarity'];
    reply = data['reply'];
    title = data['title'];
    source = data['source'];
    sauceStatus = data['sauce_status'];
  }

  SauceObject.fromTrace(TraceDocs trace) {
    source = '<p>Powered by <a href="https://trace.moe/">Trace</a>';
    if (trace.addInfo) {
      source += ' & <a href="https://anilist.co/">AniList</a>';
    }
    source += '</p>';
    var output = '';

    trace.toJsonHtml().forEach((key, value) {
      if (value != null) {
        if (key.isEmpty) {
          output += "$value";
        } else {
          output += "<p>$key : $value</p>";
        }
      }
    });

    similarity = double.parse((trace.similarity * 100).toStringAsFixed(2));
    imageUrl =
        'https://media.trace.moe/image/${trace.anilistId.toString()}/${Uri.encodeComponent(trace.filename).toString()}' +
            '?t=' +
            ((trace.at == trace.at.truncate())
                ? trace.at.toInt().toString()
                : trace.at.toString()) +
            '&token=' +
            trace.tokenthumb;
    videoUrl =
        'https://media.trace.moe/video/${trace.anilistId.toString()}/${Uri.encodeComponent(trace.filename).toString()}' +
            '?t=' +
            ((trace.at == trace.at.truncate())
                ? trace.at.toInt().toString()
                : trace.at.toString()) +
            '&token=' +
            trace.tokenthumb;

    title = trace.titleRomaji;
    reply = output;
  }

  SauceObject.fromSauceNao(
      SauceNaoResultHeader header, SauceNaoResultDataAbstract data) {
    source = '<p>Powered by <a href="https://saucenao.com/">SauceNAO</a>';
    if (data?.addInfo != null) {
      source += ' & <a href=${data.addInfo[1]}>${data.addInfo[0]}</a>';
    }
    source += '</p>';

    if (data is SauceNaoMangadex37 && data.addInfo != null) {
      mangadexChapter = data.chapterPages;
    }

    var output = '';

    data.toJsonHtml().forEach((key, value) {
      if (value != null) {
        if (key.isEmpty) {
          output += "$value";
        } else {
          try {
            if (value?.isNotEmpty ?? false) output += "<p>$key : $value</p>";
          } on Exception catch (e) {
            print(e);
            output += "<p>$key : $value</p>";
          }
        }
      }
    });
    similarity = double.parse(header.similarity);
    imageUrl = header.thumbnail;
    title = data.title != null
        ? data.title
        : (data.source.isEmpty ||
                (Uri.tryParse(data.source)?.isAbsolute ?? false))
            ? ''
            : data.source + "${(data.part == null) ? '' : (' - ' + data.part)}";
    reply = output;
  }

  Map<String, dynamic> toJson() {
    return {
      'image_source': imageSource,
      'image_url': imageUrl,
      'vid_url': videoUrl,
      'similarity': similarity,
      'reply': reply,
      'title': title,
      'source': source,
      'sauce_status': sauceStatus,
    };
  }
}
