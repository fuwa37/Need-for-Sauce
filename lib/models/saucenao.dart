part of models;

class SauceNaoObject {
  SauceNaoHeader header;
  List<SauceNaoResult> results;

  SauceNaoObject({
    this.header,
    this.results,
  });

  factory SauceNaoObject.fromJson(Map<String, dynamic> json) => SauceNaoObject(
        header: SauceNaoHeader.fromJson(json["header"]),
        results: json["results"] == null
            ? null
            : List<SauceNaoResult>.from(json["results"]
                .map((x) => SauceNaoResult.fromSauceNaoDataJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "header": header?.toJson(),
        "results": results == null
            ? null
            : List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class SauceNaoHeader {
  String userId;
  String accountType;
  String shortLimit;
  String longLimit;
  int longRemaining;
  int shortRemaining;
  int status;
  int resultsRequested;
  Map<String, SauceNaoIndex> index;
  String searchDepth;
  double minimumSimilarity;
  String queryImageDisplay;
  String queryImage;
  int resultsReturned;
  String message;

  SauceNaoHeader(
      {this.userId,
      this.accountType,
      this.shortLimit,
      this.longLimit,
      this.longRemaining,
      this.shortRemaining,
      this.status,
      this.resultsRequested,
      this.index,
      this.searchDepth,
      this.minimumSimilarity,
      this.queryImageDisplay,
      this.queryImage,
      this.resultsReturned,
      this.message});

  bool isShortLimit() {
    return (this.status == -2) ? true : false;
  }

  bool shortLimitReached() {
    return (this.shortRemaining == 0) ? true : false;
  }

  bool longLimitReached() {
    return (this.longRemaining == 0) ? true : false;
  }

  factory SauceNaoHeader.fromJson(Map<String, dynamic> json) => SauceNaoHeader(
      userId: json["user_id"].toString(),
      accountType: json["account_type"].toString(),
      shortLimit: json["short_limit"],
      longLimit: json["long_limit"],
      longRemaining: json["long_remaining"],
      shortRemaining: json["short_remaining"],
      status: json["status"],
      resultsRequested: (json["results_requested"] is int)
          ? json["results_requested"]
          : int.parse(json["results_requested"]),
      index: Map.from(json["index"]).map((k, v) =>
          MapEntry<String, SauceNaoIndex>(k, SauceNaoIndex.fromJson(v))),
      searchDepth: json["search_depth"],
      minimumSimilarity: json["minimum_similarity"].toDouble(),
      queryImageDisplay: json["query_image_display"],
      queryImage: json["query_image"],
      resultsReturned: (json["results_returned"] is int)
          ? json["results_returned"]
          : int.parse(json["results_returned"]),
      message: json["message"]);

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "account_type": accountType,
        "short_limit": shortLimit,
        "long_limit": longLimit,
        "long_remaining": longRemaining,
        "short_remaining": shortRemaining,
        "status": status,
        "results_requested": resultsRequested,
        "index": Map.from(index)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "search_depth": searchDepth,
        "minimum_similarity": minimumSimilarity,
        "query_image_display": queryImageDisplay,
        "query_image": queryImage,
        "results_returned": resultsReturned,
        "message": message,
      };
}

class SauceNaoIndex {
  int status;
  int parentId;
  int id;
  int results;

  SauceNaoIndex({
    this.status,
    this.parentId,
    this.id,
    this.results,
  });

  factory SauceNaoIndex.fromJson(Map<String, dynamic> json) => SauceNaoIndex(
        status: json["status"],
        parentId: json["parent_id"],
        id: json["id"],
        results: json["results"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "parent_id": parentId,
        "id": id,
        "results": results,
      };
}

class SauceNaoResult {
  SauceNaoResultHeader header;
  SauceNaoResultDataAbstract data;

  SauceNaoResult({
    this.header,
    this.data,
  });

  factory SauceNaoResult.fromJson(Map<String, dynamic> json) => SauceNaoResult(
        header: SauceNaoResultHeader.fromJson(json["header"]),
        data: SauceNaoResultData.fromJson(json["data"]),
      );

  factory SauceNaoResult.fromSauceNaoDataJson(Map<String, dynamic> json) =>
      SauceNaoResult(
        header: SauceNaoResultHeader.fromJson(json["header"]),
        data: jsonToSauceNaoData(json["header"], json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "header": header?.toJson(),
        "data": data?.toJson(),
      };

  SauceNaoResultDataAbstract toSauceNaoData() {
    switch (this.header.indexId) {
      case 5:
      case 6:
        {
          return SauceNaoPixiv56.fromSauceNaoResultDataAbstract(this.data);
        }
      case 34:
        {
          return SauceNaoDeviantArt34.fromSauceNaoResultDataAbstract(this.data);
        }
      case 31:
      case 32:
        {
          return SauceNaoBcy3132.fromSauceNaoResultDataAbstract(this.data);
        }
      case 35:
        {
          return SauceNaoPawoo35.fromSauceNaoResultDataAbstract(this.data);
        }
      case 21:
      case 22:
        {
          return SauceNaoAnime2122.fromSauceNaoResultDataAbstract(this.data);
        }
      case 8:
        {
          return SauceNaoNicoSeiga8.fromSauceNaoResultDataAbstract(this.data);
        }
      case 9:
      case 12:
      case 25:
      case 26:
      case 27:
      case 28:
      case 29:
      case 30:
        {
          return SauceNaoDanYanGelKonSanApe621Idol912262527282930
              .fromSauceNaoResultDataAbstract(this.data);
        }
      case 36:
        {
          return SauceNaoMadokami36.fromSauceNaoResultDataAbstract(this.data);
        }
      case 23:
      case 24:
        {
          return SauceNaoMoviesShows2324.fromSauceNaoResultDataAbstract(
              this.data);
        }
      case 37:
        {
          return SauceNaoMangadex37.fromSauceNaoResultDataAbstract(this.data);
        }
      case 18:
        {
          return SauceNaoH18.fromSauceNaoResultDataAbstract(
              this.data, this.header);
        }
      case 11:
        {
          return SauceNaoNijie11.fromSauceNaoResultDataAbstract(this.data);
        }
      case 20:
        {
          return SauceNaoMedibang20.fromSauceNaoResultDataAbstract(this.data);
        }
      default:
        {
          return SauceNaoResultData.fromSauceNaoResultDataAbstract(this.data);
        }
    }
  }

  static SauceNaoResultDataAbstract jsonToSauceNaoData(
      Map<String, dynamic> header, Map<String, dynamic> snd) {
    switch (header["index_id"]) {
      case 5:
      case 6:
        {
          return SauceNaoPixiv56.fromJson(snd);
        }
      case 34:
        {
          return SauceNaoDeviantArt34.fromJson(snd);
        }
      case 31:
      case 32:
        {
          return SauceNaoBcy3132.fromJson(snd);
        }
      case 35:
        {
          return SauceNaoPawoo35.fromJson(snd);
        }
      case 21:
      case 22:
        {
          return SauceNaoAnime2122.fromJson(snd);
        }
      case 8:
        {
          return SauceNaoNicoSeiga8.fromJson(snd);
        }
      case 9:
      case 12:
      case 25:
      case 26:
      case 27:
      case 28:
      case 29:
      case 30:
        {
          return SauceNaoDanYanGelKonSanApe621Idol912262527282930.fromJson(snd);
        }
      case 36:
        {
          return SauceNaoMadokami36.fromJson(snd);
        }
      case 23:
      case 24:
        {
          return SauceNaoMoviesShows2324.fromJson(snd);
        }
      case 37:
        {
          return SauceNaoMangadex37.fromJson(snd);
        }
      case 18:
        {
          return SauceNaoH18.fromJson(snd, header["index_name"]);
        }
      case 11:
        {
          return SauceNaoNijie11.fromJson(snd);
        }
      case 20:
        {
          return SauceNaoMedibang20.fromJson(snd);
        }
      default:
        {
          return SauceNaoResultData.fromJson(snd);
        }
    }
  }
}

abstract class SauceNaoResultDataAbstract {
  List<String> extUrls;
  String title;
  int daId;
  String authorName;
  String authorUrl;
  int pixivId;
  String memberName;
  int memberId;
  int bcyId;
  int memberLinkId;
  String bcyType;
  DateTime createdAt;
  int pawooId;
  String pawooUserAcct;
  String pawooUserUsername;
  String pawooUserDisplayName;
  int konachanId;
  String source;
  int anidbAid;
  int idolId;
  int apId;
  int e621Id;
  int gelbooruId;
  int yandereId;
  String part;
  String year;
  String estTime;
  int seigaId;
  int sankakuId;
  dynamic creator;
  String material;
  String characters;
  int danbooruId;
  int muId;
  String type;
  String imdbId;
  int mdId;
  int malId;
  String artist;
  String author;
  String engName;
  String jpName;
  int nijieId;
  String url;

  Map<String, dynamic> toJson();

  Map<String, dynamic> toJsonMarkdown();
}

class SauceNaoResultData extends SauceNaoResultDataAbstract {
  List<String> extUrls;
  String title;
  String source;

  SauceNaoResultData({
    this.extUrls,
    this.title,
    this.source,
  });

  factory SauceNaoResultData.fromJson(Map<String, dynamic> json) =>
      SauceNaoResultData(
        extUrls: json["ext_urls"] == null
            ? null
            : List<String>.from(json["ext_urls"].map((x) => x)),
        title: json["title"],
        source: json["source"],
      );

  factory SauceNaoResultData.fromSauceNaoResultDataAbstract(
          SauceNaoResultDataAbstract sn) =>
      SauceNaoResultData(
        extUrls: sn.extUrls,
        source: sn.source,
        title: sn.title,
      );

  Map<String, dynamic> toJson() => {
        "ext_urls":
            extUrls == null ? null : List<dynamic>.from(extUrls.map((x) => x)),
        "title": title,
        "source": source,
      };

  Map<String, dynamic> toJsonMarkdown() => {
        "": title != null
            ? "#### $title"
            : source != null ? "#### $source" : null,
        "**Link**": extUrls == null
            ? null
            : "[${Uri.parse(extUrls[0]).host}](${extUrls[0]})"
      };
}

class SauceNaoResultHeader {
  String similarity;
  String thumbnail;
  int indexId;
  String indexName;

  SauceNaoResultHeader({
    this.similarity,
    this.thumbnail,
    this.indexId,
    this.indexName,
  });

  factory SauceNaoResultHeader.fromJson(Map<String, dynamic> json) =>
      SauceNaoResultHeader(
        similarity: json["similarity"],
        thumbnail: json["thumbnail"],
        indexId: json["index_id"],
        indexName: json["index_name"],
      );

  Map<String, dynamic> toJson() => {
        "similarity": similarity,
        "thumbnail": thumbnail,
        "index_id": indexId,
        "index_name": indexName,
      };
}