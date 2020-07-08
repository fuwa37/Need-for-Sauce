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
    var output = '';

    trace.toJsonMarkdown().forEach((key, value) {
      if (value != null) {
        if (key.isEmpty) {
          output += "$value\n";
        } else {
          output += "$key: $value\n\n";
        }
      }
    });

    similarity = double.parse((trace.similarity * 100).toStringAsFixed(2));
    imageUrl = 'https://trace.moe/thumbnail.php?anilist_id=' +
        trace.anilistId.toString() +
        '&file=' +
        Uri.encodeQueryComponent(trace.filename).toString() +
        '&t=' +
        trace.at.toString() +
        '&token=' +
        trace.tokenthumb;
    videoUrl = 'https://trace.moe/preview.php?anilist_id=' +
        trace.anilistId.toString() +
        '&file=' +
        Uri.encodeQueryComponent(trace.filename).toString() +
        '&t=' +
        trace.at.toString() +
        '&token=' +
        trace.tokenthumb;
    title = trace.titleRomaji;
    reply = output;
  }

  SauceObject.fromSauceNao(
      SauceNaoResultHeader header, SauceNaoResultDataAbstract data) {
    var output = '';

    data.toJsonMarkdown().forEach((key, value) {
      if (value != null) {
        if (key.isEmpty) {
          output += "$value\n";
        } else {
          output += "$key: $value\n\n";
        }
      }
    });

    similarity = double.parse(header.similarity);
    imageUrl = header.thumbnail;
    title = data.title != null
        ? data.title
        : (data.source.isEmpty || Uri.parse(data.source).isAbsolute)
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
