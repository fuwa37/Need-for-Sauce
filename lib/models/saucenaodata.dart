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

  Map<String, dynamic> toJson() => {
        "ext_urls":
            extUrls == null ? null : List<dynamic>.from(extUrls.map((x) => x)),
        "title": title,
        "pixiv_id": pixivId,
        "member_name": memberName,
        "member_id": memberId,
        "member_url": memberUrl
      };

  Map<String, dynamic> toJsonMarkdown() => {
        "": "### $title",
        "**Pixiv ID**": "[$pixivId](${extUrls[0]})",
        "**Member Name**": "[$memberName]($memberUrl)",
      };
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

  Map<String, dynamic> toJson() => {
        "ext_urls":
            extUrls == null ? null : List<dynamic>.from(extUrls.map((x) => x)),
        "title": title,
        "da_id": daId,
        "author_name": authorName,
        "author_url": authorUrl,
      };

  Map<String, dynamic> toJsonMarkdown() => {
        "": "### $title",
        "**DeviantArt ID**": "[$daId](${extUrls[0]})",
        "**Author**": "[$authorName]($authorUrl)",
      };
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

  Map<String, dynamic> toJson() => {
        "ext_urls":
            extUrls == null ? null : List<dynamic>.from(extUrls.map((x) => x)),
        "title": title,
        "bcy_id": bcyId,
        "member_name": memberName,
        "member_id": memberId,
        "member_link_id": memberLinkId,
        "bcy_type": bcyType,
        "member_url": memberUrl
      };

  Map<String, dynamic> toJsonMarkdown() => {
        "": "### $title",
        "**bcy ID**": "[$bcyId]()",
        "**Author**": "[$memberName]($memberUrl)",
      };
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

  Map<String, dynamic> toJson() => {
        "ext_urls":
            extUrls == null ? null : List<dynamic>.from(extUrls.map((x) => x)),
        "created_at": createdAt.toIso8601String(),
        "pawoo_id": pawooId,
        "pawoo_user_acct": pawooUserAcct,
        "pawoo_user_username": pawooUserUsername,
        "pawoo_user_display_name": pawooUserDisplayName,
      };

  Map<String, dynamic> toJsonMarkdown() => {
        "**Pawoo ID**": "[$pawooId](${extUrls[0]} + /$pawooId)",
        "**Author**": "$pawooUserDisplayName([@$pawooUserAcct](${extUrls[0]})",
      };
}

class SauceNaoAnime2122 extends SauceNaoResultDataAbstract {
  List<String> extUrls;
  String source;
  int anidbAid;
  String part;
  String year;
  String estTime;

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
        source: sn.source,
        anidbAid: sn.anidbAid,
        part: sn.part,
        year: sn.year,
        estTime: sn.estTime,
      );

  Map<String, dynamic> toJson() => {
        "ext_urls":
            extUrls == null ? null : List<dynamic>.from(extUrls.map((x) => x)),
        "source": source,
        "anidb_aid": anidbAid,
        "part": part,
        "year": year,
        "est_time": estTime,
      };

  Map<String, dynamic> toJsonMarkdown() => {
        "": "## $source",
        "**Episode**": part,
        "**Time**": estTime,
        "**AniDB Link**": "[$anidbAid](${extUrls[0]})"
      };
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

  Map<String, dynamic> toJson() => {
        "ext_urls":
            extUrls == null ? null : List<dynamic>.from(extUrls.map((x) => x)),
        "title": title,
        "seiga_id": seigaId,
        "member_name": memberName,
        "member_id": memberId,
      };

  Map<String, dynamic> toJsonMarkdown() => {
        "": "### $title",
        "**Seiga ID**": "[$seigaId](${extUrls[0]})",
        "**Member**": "[$memberName]($memberUrl)",
      };
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

  Map<String, dynamic> toJson() => {
        "ext_urls":
            extUrls == null ? null : List<dynamic>.from(extUrls.map((x) => x)),
        "mu_id": muId,
        "source": source,
        "part": part,
        "type": type,
      };

  Map<String, dynamic> toJsonMarkdown() => {
        "": "### $part",
        "**MU Link**": "[$muId](${extUrls[0]})",
      };
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

  Map<String, dynamic> toJson() => {
        "ext_urls":
            extUrls == null ? null : List<dynamic>.from(extUrls.map((x) => x)),
        "source": source,
        "imdb_id": imdbId,
        "part": part,
        "year": year,
        "est_time": estTime,
      };

  Map<String, dynamic> toJsonMarkdown() => {
        "": "### $source",
        "**Episode**": part,
        "**Time**": estTime,
        "**IMDB Link**": "[$imdbId](${extUrls[0]})"
      };
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

  Map<String, dynamic> toJson() => {
        "ext_urls":
            extUrls == null ? null : List<dynamic>.from(extUrls.map((x) => x)),
        "md_id": mdId,
        "mu_id": muId,
        "mal_id": malId,
        "source": source,
        "part": part,
        "artist": artist,
        "author": author,
      };

  Map<String, dynamic> toJsonMarkdown() => {
        "": "### $source$part",
        "**Artist**": artist,
        "**Author**": author,
        "**Link**": extUrls[0] == null
            ? null
            : "[${getHostName(extUrls[0])}](${extUrls[0]})"
      };
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

  SauceNaoH18({
    this.source,
    this.creator,
    this.engName,
    this.jpName,
    this.page,
    this.numPages,
    this.id,
    this.tags,
    this.thumbPage,
  });

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
        page:int.tryParse(
            snh.indexName?.split('-')?.last?.trim()?.split('.')?.first),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "source": source,
        "creator":
            creator == null ? null : List<dynamic>.from(creator?.map((x) => x)),
        "eng_name": engName,
        "jp_name": jpName,
        "page": page,
        "num_pages": numPages,
        "tags": tags == null ? null : List<dynamic>.from(tags?.map((x) => x)),
        "thumbPage": thumbPage,
      };

  Map<String, dynamic> toJsonMarkdown() => {
        "": "### $source\n\n$engName\n\n$jpName\n",
        "**ID**": (id == null) ? null : "[#$id](https://nhentai.net/g/$id)",
        "**Page**": page,
        "**Creator(s)**": creator?.join(', '),
        "**Total Pages**": numPages,
        "**Tag(s)**": tags?.join(', '),
      };

  Future<SauceNaoH18> withInfo() async {
    NhentaiResult info = await NhentaiResult.getInfo(source);
    if (info == null) {
      return this;
    }

    String thumbPage =
        "https://nhentai.net/galleries/${info.mediaId}/${page}t.jpg";

    return SauceNaoH18(
      source: source,
      creator: creator,
      engName: engName,
      jpName: jpName,
      page: page,
      numPages: info?.numPages,
      id: info?.id,
      thumbPage: thumbPage,
      tags: info?.tags == null ? null : NhentaiResult.getTags(info.tags),
    );
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
        "": "### $source",
        "**Creator(s)**": creator,
        "**Link**": "[${getHostName(extUrls[0])}](${extUrls[0]})",
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

  Map<String, dynamic> toJson() => {
        "ext_urls":
            extUrls == null ? null : List<dynamic>.from(extUrls.map((x) => x)),
        "title": title,
        "nijie_id": nijieId,
        "member_name": memberName,
        "member_id": memberId,
        "member_url": memberUrl,
      };

  Map<String, dynamic> toJsonMarkdown() => {
        "": "### $title",
        "**Nijie ID**": "[$nijieId](${extUrls[0]})",
        "**Member**": "[$memberName]($memberUrl)",
      };
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

  Map<String, dynamic> toJson() => {
        "ext_urls":
            extUrls == null ? null : List<dynamic>.from(extUrls.map((x) => x)),
        "title": title,
        "url": url,
        "member_name": memberName,
        "member_id": memberId,
        "member_link": memberLink,
      };

  Map<String, dynamic> toJsonMarkdown() => {
        "": "### $title",
        "**Member**": "[$memberName]($memberLink)",
        "**Link**": url == null ? null : "[${getHostName(url)}]($url)"
      };
}

class SauceNaoDanYanGelKonSanApe621Idol912262527282930
    extends SauceNaoResultDataAbstract {
  SauceNaoDanYanGelKonSanApe621Idol912262527282930({
    this.extUrls,
    this.konachanId,
    this.yandereId,
    this.danbooruId,
    this.idolId,
    this.apId,
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
  int apId;
  int danbooruId;
  int sankakuId;
  int e621Id;
  int gelbooruId;
  int yandereId;
  dynamic creator;
  String material;
  String characters;
  String source;

  factory SauceNaoDanYanGelKonSanApe621Idol912262527282930.fromJson(
          Map<String, dynamic> json) =>
      SauceNaoDanYanGelKonSanApe621Idol912262527282930(
        extUrls: json["ext_urls"] == null
            ? null
            : List<String>.from(json["ext_urls"].map((x) => x)),
        konachanId: json["konachan_id"],
        yandereId: json["yandere_id"],
        e621Id: json["e621_id"],
        apId: json["ap_id"] ??
            json["anime-pictures_id"] ??
            json["anime_pictures_id"],
        // no documentation
        idolId: json["idol_id"],
        danbooruId: json["danbooru_id"],
        gelbooruId: json["gelbooru_id"],
        sankakuId: json["sankaku_id"],
        creator: json["creator"],
        material: json["material"],
        characters: json["characters"],
        source: json["source"],
      );

  factory SauceNaoDanYanGelKonSanApe621Idol912262527282930.fromSauceNaoResultDataAbstract(
          SauceNaoResultDataAbstract sn) =>
      SauceNaoDanYanGelKonSanApe621Idol912262527282930(
        extUrls: sn.extUrls,
        konachanId: sn.konachanId,
        yandereId: sn.yandereId,
        e621Id: sn.e621Id,
        apId: sn.apId,
        idolId: sn.idolId,
        danbooruId: sn.danbooruId,
        gelbooruId: sn.gelbooruId,
        sankakuId: sn.sankakuId,
        creator: sn.creator,
        material: sn.material,
        characters: sn.characters,
        source: sn.source,
      );

  Map<String, dynamic> toJson() {
    var map = {
      "ext_urls":
          extUrls == null ? null : List<dynamic>.from(extUrls.map((x) => x)),
      "konachan_id": konachanId,
      "yandere_id": yandereId,
      "danbooru_id": danbooruId,
      "idol_id": idolId,
      "ap_id": apId,
      "gelbooru_id": gelbooruId,
      "e621_id": e621Id,
      "sankaku_id": sankakuId,
      "creator": creator,
      "material": material,
      "characters": characters,
      "source": source,
    };
    return map;
  }

  Map<String, dynamic> toJsonMarkdown() => {
        "**Yande.re ID**":
            yandereId == null ? null : "[$yandereId](${extUrls[0]})",
        "**Danbooru ID**":
            danbooruId == null ? null : "[$danbooruId](${extUrls[0]})",
        "**Sankaku ID**":
            sankakuId == null ? null : "[$sankakuId](${extUrls[0]})",
        "**Gelbooru ID**":
            sankakuId == null ? null : "[$gelbooruId](${extUrls[0]})",
        "**Konachan ID**":
            konachanId == null ? null : "[$konachanId](${extUrls[0]})",
        "**Anime-Pictures ID**": apId == null ? null : "[$apId](${extUrls[0]})",
        "**e621 ID**": e621Id == null ? null : "[$e621Id](${extUrls[0]})",
        "**Idol Complex ID**":
            idolId == null ? null : "[$idolId](${extUrls[0]})",
        "**Creator(s)**": creator,
        "**Material(s)**": material,
        "**Character(s)**": characters,
        "**Alt. Source**": source == null
            ? null
            : Uri.parse(source).isAbsolute
                ? "(${getHostName(source)})[${getSourceUrl(source)}]"
                : null,
      };
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

  Map<String, dynamic> toJson() => {
        "ext_urls":
            extUrls == null ? null : List<dynamic>.from(extUrls.map((x) => x)),
        "source": source,
        "creator": creator,
      };

  Map<String, dynamic> toJsonMarkdown() => {
        "": "### $source",
        "**Creator(s)**": creator,
        "**Link**": "[${getHostName(extUrls[0])}](${extUrls[0]})"
      };
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
        "": title == null ? null : "### $title",
        "**Company**": company == null ? null : company,
        "**Getchu ID**": getchuId == null ? null : "[$getchuId]($getchuUrl)",
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
        "**Drawr ID**": extUrls == null
            ? null
            : "[${Uri.parse(extUrls[0]).host}](${extUrls[0]})",
        "**Member**": memberName == null ? null : memberName,
      };
}*/
