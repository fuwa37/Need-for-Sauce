part of models;

String getHostName(String url) {
  var a = Uri.parse(url).host.toString().split('.');
  var b;
  try {
    b = '${a[1]}.${a[2]}';
  } on RangeError catch (e) {
    print(e);
    b = '${a[0]}.${a[1]}';
  }
  if (b == 'pximg.net') {
    b = 'pixiv.net';
  }
  return b;
}

String getSourceUrl(String url) {
  if (Uri.parse(url).host == 'www.pixiv.net') {
    return url;
  } else if (getHostName(url) == 'pixiv.net') {
    var a = Uri.parse(url).pathSegments.last.split('.').first;
    return "https://www.pixiv.net/en/artworks/$a";
  } else
    return url;
}

class SauceNaoPixiv56 extends SauceNaoResultDataAbstract {
  List<String> extUrls;
  String title;
  int pixivId;
  String memberName;
  int memberId;
  String memberUrl;

  SauceNaoPixiv56({
    this.extUrls,
    this.title,
    this.pixivId,
    this.memberName,
    this.memberId,
    this.memberUrl,
  });

  factory SauceNaoPixiv56.fromJson(
          Map<String, dynamic> json) =>
      SauceNaoPixiv56(
          extUrls:
              json["ext_urls"] ==
                      null
                  ? null
                  : List<String>.from(json["ext_urls"].map((x) => x)),
          title: json["title"],
          pixivId: json["pixiv_id"],
          memberName: json["member_name"],
          memberId: json["member_id"],
          memberUrl:
              "https://www.pixiv.net/member.php?id=${json["member_id"]}");

  factory SauceNaoPixiv56.fromSauceNaoResultDataAbstract(
          SauceNaoResultDataAbstract sn) =>
      SauceNaoPixiv56(
          extUrls: sn.extUrls,
          title: sn.title,
          pixivId: sn.pixivId,
          memberName: sn.memberName,
          memberId: sn.memberId,
          memberUrl: "https://www.pixiv.net/member.php?id=${sn.memberId}");

  Map<String, dynamic> toJsonHtml() => {
        "": "<h3>$title</h3>",
        "<b>Pixiv ID<b>": "<a href=${extUrls[0]}>$pixivId</a>",
        "<b>Member Name<b>": "<a href=$memberUrl>$memberName</a>",
      };

  Future<SauceNaoPixiv56> withInfo() async {
    return this;
  }
}

class SauceNaoDeviantArt34 extends SauceNaoResultDataAbstract {
  List<String> extUrls;
  String title;
  int daId;
  String authorName;
  String authorUrl;

  SauceNaoDeviantArt34({
    this.extUrls,
    this.title,
    this.daId,
    this.authorName,
    this.authorUrl,
  });

  factory SauceNaoDeviantArt34.fromJson(Map<String, dynamic> json) =>
      SauceNaoDeviantArt34(
        extUrls: json["ext_urls"] == null
            ? null
            : List<String>.from(json["ext_urls"].map((x) => x)),
        title: json["title"],
        daId: json["da_id"],
        authorName: json["author_name"],
        authorUrl: json["author_url"],
      );

  factory SauceNaoDeviantArt34.fromSauceNaoResultDataAbstract(
          SauceNaoResultDataAbstract sn) =>
      SauceNaoDeviantArt34(
          extUrls: sn.extUrls,
          title: sn.title,
          daId: sn.daId,
          authorName: sn.authorName,
          authorUrl: sn.authorUrl);

  Map<String, dynamic> toJsonHtml() => {
        "": "<h3>$title</h3>",
        "<b>DeviantArt ID</b>": "<a href=${extUrls[0]}>$daId</a>",
        "<b>Author</b>": "<a href=$authorUrl>$authorName</a>",
      };

  Future<SauceNaoDeviantArt34> withInfo() async {
    return this;
  }
}

class SauceNaoBcy3132 extends SauceNaoResultDataAbstract {
  List<String> extUrls;
  String title;
  int bcyId;
  String memberName;
  int memberId;
  int memberLinkId;
  String bcyType;
  String memberUrl;

  SauceNaoBcy3132(
      {this.extUrls,
      this.title,
      this.bcyId,
      this.memberName,
      this.memberId,
      this.memberLinkId,
      this.bcyType,
      this.memberUrl});

  factory SauceNaoBcy3132.fromJson(Map<String, dynamic> json) =>
      SauceNaoBcy3132(
        extUrls: json["ext_urls"] == null
            ? null
            : List<String>.from(json["ext_urls"].map((x) => x)),
        title: json["title"],
        bcyId: json["bcy_id"],
        memberName: json["member_name"],
        memberId: json["member_id"],
        memberUrl: "https://bcy.net/u/${json["member_id"]}",
        memberLinkId: json["member_link_id"],
        bcyType: json["bcy_type"],
      );

  factory SauceNaoBcy3132.fromSauceNaoResultDataAbstract(
          SauceNaoResultDataAbstract sn) =>
      SauceNaoBcy3132(
        extUrls: sn.extUrls,
        title: sn.title,
        bcyId: sn.bcyId,
        memberName: sn.memberName,
        memberId: sn.memberId,
        memberUrl: "https://bcy.net/u/${sn.memberId}",
        memberLinkId: sn.memberLinkId,
        bcyType: sn.bcyType,
      );

  Map<String, dynamic> toJsonHtml() => {
        "": "<h3>$title</h3>",
        "<b>bcy ID</b>": bcyId,
        "<b>Author</b>": "<a href=$memberUrl>$memberName</a>",
      };

  Future<SauceNaoBcy3132> withInfo() async {
    return this;
  }
}

class SauceNaoPawoo35 extends SauceNaoResultDataAbstract {
  List<String> extUrls;
  DateTime createdAt;
  int pawooId;
  String pawooUserAcct;
  String pawooUserUsername;
  String pawooUserDisplayName;

  SauceNaoPawoo35({
    this.extUrls,
    this.createdAt,
    this.pawooId,
    this.pawooUserAcct,
    this.pawooUserUsername,
    this.pawooUserDisplayName,
  });

  factory SauceNaoPawoo35.fromJson(Map<String, dynamic> json) =>
      SauceNaoPawoo35(
        extUrls: json["ext_urls"] == null
            ? null
            : List<String>.from(json["ext_urls"].map((x) => x)),
        createdAt: DateTime.parse(json["created_at"]),
        pawooId: json["pawoo_id"],
        pawooUserAcct: json["pawoo_user_acct"],
        pawooUserUsername: json["pawoo_user_username"],
        pawooUserDisplayName: json["pawoo_user_display_name"],
      );

  factory SauceNaoPawoo35.fromSauceNaoResultDataAbstract(
          SauceNaoResultDataAbstract sn) =>
      SauceNaoPawoo35(
        extUrls: sn.extUrls,
        createdAt: sn.createdAt,
        pawooId: sn.pawooId,
        pawooUserAcct: sn.pawooUserAcct,
        pawooUserUsername: sn.pawooUserUsername,
        pawooUserDisplayName: sn.pawooUserDisplayName,
      );

  Map<String, dynamic> toJsonHtml() => {
        "<b>Pawoo ID</b>": "<a href=${extUrls[0]}/$pawooId>$pawooId</a>",
        "<b>Author</b>":
            "$pawooUserDisplayName(<a href=${extUrls[0]}>@$pawooUserAcct</a>)",
      };

  Future<SauceNaoPawoo35> withInfo() async {
    return this;
  }
}

class SauceNaoAnime2122 extends SauceNaoResultDataAbstract {
  List<String> extUrls;
  String source;
  int anidbAid;
  String part;
  String year;
  String estTime;
  bool isAdult;
  String season;
  int seasonYear;
  int episodes;
  String format;
  String status;
  int anilistId;
  int malId;
  List<String> genres;
  String description;
  String sourceMaterial;
  List<String> addInfo;

  SauceNaoAnime2122({
    this.extUrls,
    this.source,
    this.anidbAid,
    this.part,
    this.year,
    this.estTime,
  });

  factory SauceNaoAnime2122.fromJson(Map<String, dynamic> json) =>
      SauceNaoAnime2122(
        extUrls: json["ext_urls"] == null
            ? null
            : List<String>.from(json["ext_urls"].map((x) => x)),
        source: json["source"],
        anidbAid: json["anidb_aid"],
        part: json["part"],
        year: json["year"],
        estTime: json["est_time"],
      );

  factory SauceNaoAnime2122.fromSauceNaoResultDataAbstract(
          SauceNaoResultDataAbstract sn) =>
      SauceNaoAnime2122(
        extUrls: sn.extUrls,
        source: sn.source,
        anidbAid: sn.anidbAid,
        part: sn.part,
        year: sn.year,
        estTime: sn.estTime,
      );

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
      "": "<h3>$source</h3>",
      "<b>Episode</b>": part,
      "<b>Time</b>": estTime,
      "<b>Links</b>": (extUrls == null)
          ? null
          : "<a href=${extUrls[0]}>AniDb</a>" +
              ((anilistId == null)
                  ? ''
                  : " | <a href='https://anilist.co/anime/$anilistId'>AniList</a>") +
              ((malId == null)
                  ? ''
                  : " | <a href='https://myanimelist.net/anime/$malId'>MyAnimeList</a>"),
      "<b>Info</b>": (info?.isNotEmpty ?? false) ? info : null,
      "<b>Genres</b>": genres?.join(', '),
      "<b>Source</b>": source,
      "<b>Description</b>": description
    };
  }

  Future<SauceNaoAnime2122> withInfo() async {
    AnimeRelation relation =
        await AnimeRelation.getRelation(aniDbId: this.anidbAid);

    if (relation == null) return this;
    this.anilistId = relation.anilistId;
    this.malId = relation.malId;

    AnilistObject info = await AnilistObject.getInfo(relation.anilistId);

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
    this.sourceMaterial = infoMedia.source;
    this.addInfo = ['AniList', 'https://anilist.co/'];

    return this;
  }
}

class SauceNaoNicoSeiga8 extends SauceNaoResultDataAbstract {
  List<String> extUrls;
  String title;
  int seigaId;
  String memberName;
  int memberId;
  String memberUrl;

  SauceNaoNicoSeiga8(
      {this.extUrls,
      this.title,
      this.seigaId,
      this.memberName,
      this.memberId,
      this.memberUrl});

  factory SauceNaoNicoSeiga8.fromJson(Map<String, dynamic> json) =>
      SauceNaoNicoSeiga8(
          extUrls: json["ext_urls"] == null
              ? null
              : List<String>.from(json["ext_urls"].map((x) => x)),
          title: json["title"],
          seigaId: json["seiga_id"],
          memberName: json["member_name"],
          memberId: json["member_id"],
          memberUrl:
              "https://seiga.nicovideo.jp/user/illust/${json["member_id"]}");

  factory SauceNaoNicoSeiga8.fromSauceNaoResultDataAbstract(
          SauceNaoResultDataAbstract sn) =>
      SauceNaoNicoSeiga8(
        extUrls: sn.extUrls,
        title: sn.title,
        seigaId: sn.seigaId,
        memberName: sn.memberName,
        memberId: sn.memberId,
        memberUrl: "https://seiga.nicovideo.jp/user/illust/${sn.memberId}",
      );

  Map<String, dynamic> toJsonHtml() => {
        "": "<h3>$title</h3>",
        "<b>Seiga ID</b>": "<a href=${extUrls[0]}>$seigaId</a>",
        "<b>Member</b>": "<a href=$memberUrl>$memberName</a>",
      };

  Future<SauceNaoNicoSeiga8> withInfo() async {
    return this;
  }
}

class SauceNaoMadokami36 extends SauceNaoResultDataAbstract {
  List<String> extUrls;
  int muId;
  String source;
  String part;
  String type;

  SauceNaoMadokami36({
    this.extUrls,
    this.muId,
    this.source,
    this.part,
    this.type,
  });

  factory SauceNaoMadokami36.fromJson(Map<String, dynamic> json) =>
      SauceNaoMadokami36(
        extUrls: json["ext_urls"] == null
            ? null
            : List<String>.from(json["ext_urls"].map((x) => x)),
        muId: json["mu_id"],
        source: json["source"],
        part: json["part"],
        type: json["type"],
      );

  factory SauceNaoMadokami36.fromSauceNaoResultDataAbstract(
          SauceNaoResultDataAbstract sn) =>
      SauceNaoMadokami36(
        extUrls: sn.extUrls,
        muId: sn.muId,
        source: sn.source,
        part: sn.memberName,
        type: sn.type,
      );

  Map<String, dynamic> toJsonHtml() => {
        "": "<h3>$part</h3>",
        "<b>MU Link</b>": "<a href=${extUrls[0]}>$muId</a>",
      };

  Future<SauceNaoMadokami36> withInfo() async {
    return this;
  }
}

class SauceNaoMoviesShows2324 extends SauceNaoResultDataAbstract {
  List<String> extUrls;
  String source;
  String imdbId;
  String part;
  String year;
  String estTime;

  SauceNaoMoviesShows2324({
    this.extUrls,
    this.source,
    this.imdbId,
    this.part,
    this.year,
    this.estTime,
  });

  factory SauceNaoMoviesShows2324.fromJson(Map<String, dynamic> json) =>
      SauceNaoMoviesShows2324(
        extUrls: json["ext_urls"] == null
            ? null
            : List<String>.from(json["ext_urls"].map((x) => x)),
        source: json["source"],
        imdbId: json["imdb_id"],
        part: json["part"],
        year: json["year"],
        estTime: json["est_time"],
      );

  factory SauceNaoMoviesShows2324.fromSauceNaoResultDataAbstract(
          SauceNaoResultDataAbstract sn) =>
      SauceNaoMoviesShows2324(
        extUrls: sn.extUrls,
        source: sn.title,
        imdbId: sn.imdbId,
        part: sn.part,
        year: sn.year,
        estTime: sn.estTime,
      );

  Map<String, dynamic> toJsonHtml() => {
        "": "<h3>$source</h3>",
        "<b>Episode</b>": part,
        "<b>Time</b>": estTime,
        "<b>IMDB Link</b>": (extUrls[0] == null)
            ? null
            : "<a href=${extUrls[0]}>${getHostName(extUrls[0])}</a>"
      };

  Future<SauceNaoMoviesShows2324> withInfo() async {
    return this;
  }
}

class SauceNaoMangadex37 extends SauceNaoResultDataAbstract {
  List<String> extUrls;
  int mdId;
  int muId;
  int malId;
  String source;
  String part;
  String artist;
  String author;
  List<String> chapterPages;
  List<MangaDexLink> altLink;
  String description;
  String status;
  List<String> genres;
  String rating;
  List<String> addInfo;

  SauceNaoMangadex37({
    this.extUrls,
    this.mdId,
    this.muId,
    this.malId,
    this.source,
    this.part,
    this.artist,
    this.author,
  });

  factory SauceNaoMangadex37.fromJson(Map<String, dynamic> json) =>
      SauceNaoMangadex37(
        extUrls: json["ext_urls"] == null
            ? null
            : List<String>.from(json["ext_urls"].map((x) => x)),
        mdId: json["md_id"],
        muId: json["mu_id"],
        malId: json["mal_id"],
        source: json["source"],
        part: json["part"],
        artist: json["artist"],
        author: json["author"],
      );

  factory SauceNaoMangadex37.fromSauceNaoResultDataAbstract(
          SauceNaoResultDataAbstract sn) =>
      SauceNaoMangadex37(
        extUrls: sn.extUrls,
        mdId: sn.mdId,
        muId: sn.muId,
        malId: sn.malId,
        source: sn.source,
        part: sn.part,
        artist: sn.artist,
        author: sn.author,
      );

  Map<String, dynamic> toJsonHtml() {
    var links = List<String>();
    if (altLink != null) {
      altLink.forEach((e) {
        links.add("<a href=${e.url}>${e.name}</a>");
      });
    }

    return {
      "": "<h3>$source$part</h3>",
      "<b>Artist</b>": artist,
      "<b>Author</b>": author,
      "<b>Status</b>": status,
      "<b>Tags</b>": genres?.join(', '),
      "<b>Rating</b>": rating,
      "<b>Links</b>": extUrls[0] == null
          ? null
          : "</br><a href=${extUrls[0]}>${getHostName(extUrls[0])}</a>" +
              ((links.isEmpty) ? '' : " | ${links.join(" | ")}"),
      "<b>Description</b>": (description == null)
          ? null
          : "<pre>${bbCodetoHtml(description)}</pre>"
    };
  }

  Future<SauceNaoMangadex37> withInfo() async {
    MangaDexChapter chapter =
        await MangaDexChapter.getInfo(this.mdId.toString());

    if (chapter == null) return this;

    MangaDexObject info =
        await MangaDexObject.getInfo(chapter.mangaId.toString());

    if (info == null) return this;

    this.chapterPages = chapter.pageArray;
    this.altLink = info.links;
    this.description = info.description;
    this.status = info.status;
    this.genres = info.genres;
    this.rating = info.rating.bayesian;
    this.addInfo = ['MangaDex', 'https://mangadex.org/'];

    return this;
  }
}

class SauceNaoH18 extends SauceNaoResultDataAbstract {
  String source;
  dynamic creator;
  String engName;
  String jpName;
  int page;
  int numPages;
  int id;
  List<String> tags;
  String thumbPage;
  List<String> addInfo;

  SauceNaoH18(
      {this.source,
      this.creator,
      this.engName,
      this.jpName,
      this.page,
      this.numPages,
      this.id,
      this.tags,
      this.thumbPage,
      this.addInfo});

  factory SauceNaoH18.fromJson(Map<String, dynamic> json, String indexName) =>
      SauceNaoH18(
        source: json["source"],
        creator: json["creator"] == null
            ? null
            : List<String>.from(json["creator"].map((x) => x)),
        engName: json["eng_name"],
        jpName: json["jp_name"],
        page: int.tryParse(
            indexName?.split('-')?.last?.trim()?.split('.')?.first),
      );

  factory SauceNaoH18.fromSauceNaoResultDataAbstract(
          SauceNaoResultDataAbstract snd, SauceNaoResultHeader snh) =>
      SauceNaoH18(
        source: snd.source,
        creator: snd.creator,
        engName: snd.engName,
        jpName: snd.jpName,
        page: int.tryParse(
            snh.indexName?.split('-')?.last?.trim()?.split('.')?.first),
      );

  Map<String, dynamic> toJsonHtml() => {
        "": "<h3>$source</br>$engName</br>$jpName</h3>",
        "<b>ID</b>":
            (id == null) ? null : "<a href=https://nhentai.net/g/$id>#$id</a>",
        "<b>Page</b>": page,
        "<b>Creator(s)</b>": creator?.join(', '),
        "<b>Total Pages</b>": numPages,
        "<b>Tag(s)</b>": tags?.join(', '),
      };

  Future<SauceNaoH18> withInfo() async {
    NhentaiResult info = await NhentaiResult.getInfo(source);
    if (info == null) {
      return this;
    }

    String thumbPage = (info?.mediaId != null)
        ? "https://t.nhentai.net/galleries/${info.mediaId}/${page}t.jpg"
        : null;

    this.numPages = info?.numPages;
    this.thumbPage = thumbPage;
    this.id = info?.id;
    this.tags = info?.tags == null ? null : NhentaiResult.getTags(info.tags);
    this.addInfo = ['nhentai', 'https://nhentai.net/'];

    return this;
  }
}

// Index not updated
/*class SauceNaoFakku16 extends SauceNaoResultDataAbstract {
  SauceNaoFakku16({
    this.extUrls,
    this.source,
    this.creator,
  });

  List<String> extUrls;
  String source;
  dynamic creator;

  factory SauceNaoFakku16.fromJson(Map<String, dynamic> json) =>
      SauceNaoFakku16(
        extUrls: json["ext_urls"] == null
            ? null
            : List<String>.from(json["ext_urls"].map((x) => x)),
        source: json["source"] == null ? null : json["source"],
        creator: json["creator"] == null ? null : json["creator"],
      );

  Map<String, dynamic> toJson() => {
        "ext_urls":
            extUrls == null ? null : List<dynamic>.from(extUrls.map((x) => x)),
        "source": source == null ? null : source,
        "creator": creator == null ? null : creator,
      };

  Map<String, dynamic> toJsonMarkdown() => {
        "": "<h3>$source",
        "<b>Creator(s)<b>": creator,
        "<b>Link<b>": "[${getHostName(extUrls[0])}](${extUrls[0]})",
      };
}*/

class SauceNaoNijie11 extends SauceNaoResultDataAbstract {
  List<String> extUrls;
  String title;
  int nijieId;
  String memberName;
  int memberId;
  String memberUrl;

  SauceNaoNijie11({
    this.extUrls,
    this.title,
    this.nijieId,
    this.memberName,
    this.memberId,
    this.memberUrl,
  });

  factory SauceNaoNijie11.fromJson(Map<String, dynamic> json) =>
      SauceNaoNijie11(
          extUrls: json["ext_urls"] == null
              ? null
              : List<String>.from(json["ext_urls"].map((x) => x)),
          title: json["title"],
          nijieId: json["nijie_id"],
          memberName: json["member_name"],
          memberId: json["member_id"],
          memberUrl: "https://nijie.info/members.php?id=${json["member_id"]}");

  factory SauceNaoNijie11.fromSauceNaoResultDataAbstract(
          SauceNaoResultDataAbstract sn) =>
      SauceNaoNijie11(
        extUrls: sn.extUrls,
        title: sn.title,
        nijieId: sn.nijieId,
        memberName: sn.memberName,
        memberId: sn.memberId,
        memberUrl: "https://nijie.info/members.php?id=${sn.memberId}",
      );

  Map<String, dynamic> toJsonHtml() => {
        "": "<h3>$title</h3>",
        "<b>Nijie ID</b>": "<a href=${extUrls[0]}>$nijieId</a>",
        "<b>Member</b>": "<a href=$memberUrl>$memberName</a>",
      };

  Future<SauceNaoNijie11> withInfo() async {
    return this;
  }
}

class SauceNaoMedibang20 extends SauceNaoResultDataAbstract {
  List<String> extUrls;
  String title;
  String url;
  String memberName;
  int memberId;
  String memberLink;

  SauceNaoMedibang20(
      {this.extUrls,
      this.title,
      this.url,
      this.memberName,
      this.memberId,
      this.memberLink});

  factory SauceNaoMedibang20.fromJson(Map<String, dynamic> json) =>
      SauceNaoMedibang20(
        extUrls: json["ext_urls"] == null
            ? null
            : List<String>.from(json["ext_urls"].map((x) => x)),
        title: json["title"],
        url: json["url"],
        memberName: json["member_name"],
        memberId: json["member_id"],
        memberLink: "https://medibang.com/author/${json["member_id"]}",
      );

  factory SauceNaoMedibang20.fromSauceNaoResultDataAbstract(
          SauceNaoResultDataAbstract sn) =>
      SauceNaoMedibang20(
        extUrls: sn.extUrls,
        title: sn.title,
        url: sn.url,
        memberId: sn.memberId,
        memberLink: "https://medibang.com/author/${sn.memberId}",
      );

  Map<String, dynamic> toJsonHtml() => {
        "": "<h3>$title</h3>",
        "<b>Member</b>": "<a href=$memberLink>$memberName</a>",
        "<b>Link</b>":
            url == null ? null : "<a href=$url>${getHostName(url)}</a>"
      };

  Future<SauceNaoMedibang20> withInfo() async {
    return this;
  }
}

class SauceNaoDanYanGelKonSane621Idol9122625272930
    extends SauceNaoResultDataAbstract {
  SauceNaoDanYanGelKonSane621Idol9122625272930({
    this.extUrls,
    this.konachanId,
    this.yandereId,
    this.danbooruId,
    this.idolId,
    this.sankakuId,
    this.e621Id,
    this.gelbooruId,
    this.creator,
    this.material,
    this.characters,
    this.source,
  });

  List<String> extUrls;
  int konachanId;
  int idolId;
  int danbooruId;
  int sankakuId;
  int e621Id;
  int gelbooruId;
  int yandereId;
  dynamic creator;
  String material;
  String characters;
  String source;
  String tags;
  List<String> addInfo;

  factory SauceNaoDanYanGelKonSane621Idol9122625272930.fromJson(
          Map<String, dynamic> json) =>
      SauceNaoDanYanGelKonSane621Idol9122625272930(
        extUrls: json["ext_urls"] == null
            ? null
            : List<String>.from(json["ext_urls"].map((x) => x)),
        konachanId: json["konachan_id"],
        yandereId: json["yandere_id"],
        e621Id: json["e621_id"],
        idolId: json["idol_id"],
        danbooruId: json["danbooru_id"],
        gelbooruId: json["gelbooru_id"],
        sankakuId: json["sankaku_id"],
        creator: json["creator"],
        material: json["material"],
        characters: json["characters"],
        source: json["source"],
      );

  factory SauceNaoDanYanGelKonSane621Idol9122625272930.fromSauceNaoResultDataAbstract(
          SauceNaoResultDataAbstract sn) =>
      SauceNaoDanYanGelKonSane621Idol9122625272930(
        extUrls: sn.extUrls,
        konachanId: sn.konachanId,
        yandereId: sn.yandereId,
        e621Id: sn.e621Id,
        idolId: sn.idolId,
        danbooruId: sn.danbooruId,
        gelbooruId: sn.gelbooruId,
        sankakuId: sn.sankakuId,
        creator: sn.creator,
        material: sn.material,
        characters: sn.characters,
        source: sn.source,
      );

  Map<String, dynamic> toJsonHtml() => {
        "<b>Yande.re ID</b>":
            yandereId == null ? null : "<a href=${extUrls[0]}>$yandereId</a>",
        "<b>Danbooru ID</b>":
            danbooruId == null ? null : "<a href=${extUrls[0]}>$danbooruId</a>",
        "<b>Sankaku ID</b>":
            sankakuId == null ? null : "<a href=${extUrls[0]}>$sankakuId</a>",
        "<b>Gelbooru ID</b>":
            gelbooruId == null ? null : "<a href=${extUrls[0]}>$gelbooruId</a>",
        "<b>Konachan ID</b>":
            konachanId == null ? null : "<a href=${extUrls[0]}>$konachanId</a>",
        "<b>e621 ID</b>":
            e621Id == null ? null : "<a href=${extUrls[0]}>$e621Id</a>",
        "<b>Idol Complex ID</b>":
            idolId == null ? null : "<a href=${extUrls[0]}>$idolId</a>",
        "<b>Creator(s)</b>": creator,
        "<b>Material(s)</b>": material,
        "<b>Character(s)</b>":
            (characters?.isEmpty ?? true) ? null : characters,
        "<b>Tags(s)</b>":
            (tags?.isEmpty ?? true) ? null : tags,
        "<b>Alt. Source</b>": source == null
            ? null
            : Uri.parse(source).isAbsolute
                ? "<a href=${getSourceUrl(source)}>${getHostName(source)}</a>"
                : null,
      };

  Future<SauceNaoDanYanGelKonSane621Idol9122625272930> withInfo() async {
    if (idolId != null || sankakuId != null) return this;

    var info;

    if (danbooruId != null) {
      info = await DanbooruObject.getInfo(danbooruId);
      if (info == null) return this;

      this.tags = (info as DanbooruObject).tagString;
      this.addInfo = ['Danbooru', ' https://danbooru.donmai.us/'];
    } else if (gelbooruId != null) {
      info = await GelbooruObject.getInfo(gelbooruId);
      if (info == null) return this;

      this.tags = (info as GelbooruObject).tags;
      this.addInfo = ['Gelbooru', 'https://gelbooru.com/'];
    } else if (yandereId != null) {
      info = await YandereObject.getInfo(yandereId);
      if (info == null) return this;

      this.tags = (info as YandereObject).tags;
      this.addInfo = ['Yande.re', 'https://yande.re/'];
    } else if (konachanId != null) {
      info = await KonachanObject.getInfo(konachanId);
      if (info == null) return this;

      this.tags = (info as KonachanObject).tags;
      this.addInfo = ['Konachan', 'https://konachan.net/'];
    } else if (e621Id != null) {
      info = await E621Object.getInfo(e621Id);
      if (info == null) return this;

      this.tags = (info as E621Object).tags?.join(' ');
      this.addInfo = ['MangaDex', 'https://e621.net/'];
    }

    return this;
  }
}

class SauceNao2DMarket19 extends SauceNaoResultDataAbstract {
  SauceNao2DMarket19({
    this.extUrls,
    this.source,
    this.creator,
  });

  List<String> extUrls;
  String source;
  dynamic creator;

  factory SauceNao2DMarket19.fromJson(Map<String, dynamic> json) =>
      SauceNao2DMarket19(
        extUrls: json["ext_urls"] == null
            ? null
            : List<String>.from(json["ext_urls"].map((x) => x)),
        source: json["source"],
        creator: json["creator"],
      );

  factory SauceNao2DMarket19.fromSauceNaoResultDataAbstract(
          SauceNaoResultDataAbstract sn) =>
      SauceNao2DMarket19(
        extUrls: sn.extUrls,
        source: sn.source,
        creator: sn.creator,
      );

  Map<String, dynamic> toJsonHtml() => {
        "": "<h3>$source</h3>",
        "<b>Creator(s)</b>": creator,
        "<b>Link</b>": extUrls[0] == null
            ? null
            : "<a href=${extUrls[0]}>${getHostName(extUrls[0])}</a>"
      };

  Future<SauceNao2DMarket19> withInfo() async {
    return this;
  }
}

// Website closed
/*class SauceNaoPortalgraphics33 {
  List<String> extUrls;
  String title;
  int pgId;
  String memberName;
  int memberId;

  SauceNaoPortalgraphics33({
    this.extUrls,
    this.title,
    this.pgId,
    this.memberName,
    this.memberId,
  });

  factory SauceNaoPortalgraphics33.fromJson(Map<String, dynamic> json) =>
      SauceNaoPortalgraphics33(
        extUrls: json["ext_urls"] == null
            ? null
            : List<String>.from(json["ext_urls"].map((x) => x)),
        title: json["title"] == null ? null : json["title"],
        pgId: json["pg_id"] == null ? null : json["pg_id"],
        memberName: json["member_name"] == null ? null : json["member_name"],
        memberId: json["member_id"] == null ? null : json["member_id"],
      );

  Map<String, dynamic> toJson() => {
        "ext_urls":
            extUrls == null ? null : List<dynamic>.from(extUrls.map((x) => x)),
        "title": title == null ? null : title,
        "pg_id": pgId == null ? null : pgId,
        "member_name": memberName == null ? null : memberName,
        "member_id": memberId == null ? null : memberId,
      };
}*/

// Index not updated, replaced by Index #18
/*class SauceNaoHMag0 {
  String title;
  String part;
  String date;

  SauceNaoHMag0({
    this.title,
    this.part,
    this.date,
  });

  factory SauceNaoHMag0.fromJson(Map<String, dynamic> json) => SauceNaoHMag0(
        title: json["title"] == null ? null : json["title"],
        part: json["part"] == null ? null : json["part"],
        date: json["date"] == null ? null : json["date"],
      );

  Map<String, dynamic> toJson() => {
        "title": title == null ? null : title,
        "part": part == null ? null : part,
        "date": date == null ? null : date,
      };
}*/

// Index not updated, replaced by Index #18
/*class SauceNaoCg2 {
  String title;
  String company;
  String getchuId;
  String getchuUrl;

  SauceNaoCg2({this.title, this.company, this.getchuId, this.getchuUrl});

  factory SauceNaoCg2.fromJson(Map<String, dynamic> json) => SauceNaoCg2(
      title: json["title"] == null ? null : json["title"],
      company: json["company"] == null ? null : json["company"],
      getchuId: json["getchu_id"] == null ? null : json["getchu_id"],
      getchuUrl: json["getchu_id"] == null
          ? null
          : "getchu.com/soft.phtml?id=${json["getchu_id"]}");

  Map<String, dynamic> toJson() => {
        "title": title == null ? null : title,
        "company": company == null ? null : company,
        "getchu_id": getchuId == null ? null : getchuId,
        "getchu_url": getchuUrl == null ? null : getchuUrl,
      };

  Map<String, dynamic> toJsonMarkdown() => {
        "": title == null ? null : "<h3>$title",
        "<b>Company<b>": company == null ? null : company,
        "<b>Getchu ID<b>": getchuId == null ? null : "[$getchuId]($getchuUrl)",
      };
}*/

// Website closed
/*class SauceNaoDrawr10 {
  List<String> extUrls;
  DateTime title;
  int drawrId;
  String memberName;
  int memberId;

  SauceNaoDrawr10({
    this.extUrls,
    this.title,
    this.drawrId,
    this.memberName,
    this.memberId,
  });

  factory SauceNaoDrawr10.fromJson(Map<String, dynamic> json) =>
      SauceNaoDrawr10(
        extUrls: json["ext_urls"] == null
            ? null
            : List<String>.from(json["ext_urls"].map((x) => x)),
        title: json["title"] == null ? null : DateTime.parse(json["title"]),
        drawrId: json["drawr_id"] == null ? null : json["drawr_id"],
        memberName: json["member_name"] == null ? null : json["member_name"],
        memberId: json["member_id"] == null ? null : json["member_id"],
      );

  Map<String, dynamic> toJson() => {
        "ext_urls":
            extUrls == null ? null : List<dynamic>.from(extUrls.map((x) => x)),
        "title": title == null ? null : title.toIso8601String(),
        "drawr_id": drawrId == null ? null : drawrId,
        "member_name": memberName == null ? null : memberName,
        "member_id": memberId == null ? null : memberId,
      };

  Map<String, dynamic> toJsonMarkdown() => {
        "<b>Drawr ID<b>": extUrls == null
            ? null
            : "[${Uri.parse(extUrls[0]).host}](${extUrls[0]})",
        "<b>Member<b>": memberName == null ? null : memberName,
      };
}*/
