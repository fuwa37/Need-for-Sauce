part of models;

class TraceObject {
  int rawDocsCount;
  int rawDocsSearchTime;
  int reRankSearchTime;
  bool cacheHit;
  int trial;
  int limit;
  int limitTtl;
  int quota;
  int quotaTtl;
  List<TraceDocs> docs;

  TraceObject(
      {this.rawDocsCount,
      this.rawDocsSearchTime,
      this.reRankSearchTime,
      this.cacheHit,
      this.trial,
      this.limit,
      this.limitTtl,
      this.quota,
      this.quotaTtl,
      this.docs});

  TraceObject.fromJson(Map<String, dynamic> json) {
    rawDocsCount = json['RawDocsCount'];
    rawDocsSearchTime = json['RawDocsSearchTime'];
    reRankSearchTime = json['ReRankSearchTime'];
    cacheHit = json['CacheHit'];
    trial = json['trial'];
    limit = json['limit'];
    limitTtl = json['limit_ttl'];
    quota = json['quota'];
    quotaTtl = json['quota_ttl'];
    if (json['docs'] != null) {
      docs = new List<TraceDocs>();
      json['docs'].forEach((v) {
        docs.add(new TraceDocs.fromJson(v));
      });
    }
  }
}

class TraceDocs {
  double from;
  double to;
  int anilistId;
  double at;
  String date;
  String anime;
  String filename;
  dynamic episode;
  String tokenthumb;
  double similarity;
  String title;
  String titleNative;
  String titleChinese;
  String titleEnglish;
  String titleRomaji;
  int malId;
  List<String> synonyms;
  List<String> synonymsChinese;
  bool isAdult;
  String season;
  int seasonYear;
  int episodes;
  String format;
  String status;
  List<String> genres;
  String description;
  String source;
  bool addInfo = false;

  TraceDocs(
      {this.from,
      this.to,
      this.anilistId,
      this.at,
      this.date,
      this.anime,
      this.filename,
      this.episode,
      this.tokenthumb,
      this.similarity,
      this.title,
      this.titleNative,
      this.titleChinese,
      this.titleEnglish,
      this.titleRomaji,
      this.malId,
      this.synonyms,
      this.synonymsChinese,
      this.isAdult});

  TraceDocs.fromJson(Map<String, dynamic> json) {
    from = json['from'].toDouble();
    to = json['to'].toDouble();
    anilistId = json['anilist_id'];
    at = json['at'].toDouble();
    date = json['season'];
    anime = json['anime'];
    filename = json['filename'];
    episode = json['episode'];
    tokenthumb = json['tokenthumb'];
    similarity = json['similarity'];
    title = json['title'];
    titleNative = json['title_native'];
    titleChinese = json['title_chinese'];
    titleEnglish = json['title_english'];
    titleRomaji = json['title_romaji'];
    malId = json['mal_id'];
    synonyms = json['synonyms'].cast<String>();
    synonymsChinese = json['synonyms_chinese'].cast<String>();
    isAdult = json['is_adult'];
  }

  Map<String, dynamic> toJsonHtml() {
    String info = '';

    List<String> out = [
      season,
      seasonYear?.toString(),
      format,
      episodes?.toString(),
      status
    ];

    out.forEach((element) {
      if (element != null) {
        if (out.last != element) {
          info += "$element | ";
        } else {
          info += element;
        }
      }
    });

    return {
      "": "<h3>$titleNative</br>$titleRomaji</br>$titleEnglish</h3>",
      "<b>Season</b>": date,
      "<b>Episode</b>": episode,
      "<b>Time</b>":
          "${returnTime(Duration(milliseconds: (at * 1000).toInt()))}",
      "<b>Links</b>": "<a href='https://anilist.co/anime/$anilistId'>AniList</a>" +
          ((malId == null)
              ? ''
              : " | <a href='https://myanimelist.net/anime/$malId'>MyAnimeList</a>"),
      "<b>Info</b>": (info?.isNotEmpty ?? false) ? info : null,
      "<b>Genres</b>": genres?.join(', '),
      "<b>Source</b>": source,
      "<b>Description</b>": description
    };
  }

  Future<TraceDocs> withInfo() async {
    AnilistObject info = await AnilistObject.getInfo(this.anilistId);

    if (info == null) {
      return this;
    }

    var infoMedia = info.data.media;

    this.season = infoMedia.season;
    this.seasonYear = infoMedia.seasonYear;
    this.status = infoMedia.status;
    this.description = infoMedia.description;
    this.genres = infoMedia.genres;
    this.episodes = infoMedia.episodes;
    this.format = infoMedia.format;
    this.source = infoMedia.source;
    this.addInfo = true;

    return this;
  }
}
