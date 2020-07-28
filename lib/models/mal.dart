part of models;

class MalObject {
  String requestHash;
  bool requestCached;
  int requestCacheExpiry;
  int malId;
  String url;
  String imageUrl;
  String trailerUrl;
  String title;
  String titleEnglish;
  String titleJapanese;
  List<String> titleSynonyms;
  String type;
  String source;
  int episodes;
  String status;
  bool airing;
  MalAired aired;
  String duration;
  String rating;
  double score;
  int scoredBy;
  int rank;
  int popularity;
  int members;
  int favorites;
  String synopsis;
  String background;
  String premiered;
  String broadcast;
  MalRelated related;
  List<MalProp> producers;
  List<MalProp> licensors;
  List<MalProp> studios;
  List<MalProp> genres;
  List<String> openingThemes;
  List<String> endingThemes;

  MalObject({
    this.requestHash,
    this.requestCached,
    this.requestCacheExpiry,
    this.malId,
    this.url,
    this.imageUrl,
    this.trailerUrl,
    this.title,
    this.titleEnglish,
    this.titleJapanese,
    this.titleSynonyms,
    this.type,
    this.source,
    this.episodes,
    this.status,
    this.airing,
    this.aired,
    this.duration,
    this.rating,
    this.score,
    this.scoredBy,
    this.rank,
    this.popularity,
    this.members,
    this.favorites,
    this.synopsis,
    this.background,
    this.premiered,
    this.broadcast,
    this.related,
    this.producers,
    this.licensors,
    this.studios,
    this.genres,
    this.openingThemes,
    this.endingThemes,
  });

  factory MalObject.fromJson(Map<String, dynamic> json) => MalObject(
        requestHash: json["request_hash"],
        requestCached: json["request_cached"],
        requestCacheExpiry: json["request_cache_expiry"],
        malId: json["mal_id"],
        url: json["url"],
        imageUrl: json["image_url"],
        trailerUrl: json["trailer_url"],
        title: json["title"],
        titleEnglish: json["title_english"],
        titleJapanese: json["title_japanese"],
        titleSynonyms: json["title_synonyms"] == null
            ? null
            : List<String>.from(json["title_synonyms"].map((x) => x)),
        type: json["type"],
        source: json["source"],
        episodes: json["episodes"],
        status: json["status"],
        airing: json["airing"],
        aired: json["aired"] == null ? null : MalAired.fromJson(json["aired"]),
        duration: json["duration"],
        rating: json["rating"],
        score: json["score"].toDouble(),
        scoredBy: json["scored_by"],
        rank: json["rank"],
        popularity: json["popularity"],
        members: json["members"],
        favorites: json["favorites"],
        synopsis: json["synopsis"],
        background: json["background"],
        premiered: json["premiered"],
        broadcast: json["broadcast"],
        related: json["related"] == null
            ? null
            : MalRelated.fromJson(json["related"]),
        producers: json["producers"] == null
            ? null
            : List<MalProp>.from(
                json["producers"].map((x) => MalProp.fromJson(x))),
        licensors: json["licensors"] == null
            ? null
            : List<MalProp>.from(
                json["licensors"].map((x) => MalProp.fromJson(x))),
        studios: json["studios"] == null
            ? null
            : List<MalProp>.from(
                json["studios"].map((x) => MalProp.fromJson(x))),
        genres: json["genres"] == null
            ? null
            : List<MalProp>.from(
                json["genres"].map((x) => MalProp.fromJson(x))),
        openingThemes: json["opening_themes"] == null
            ? null
            : List<String>.from(json["opening_themes"].map((x) => x)),
        endingThemes: json["ending_themes"] == null
            ? null
            : List<String>.from(json["ending_themes"].map((x) => x)),
      );

  static Future<MalObject> getInfo(int id) async {
    var response = await Sauce.mal().get("/${id.toString()}");

    return MalObject.fromJson(response.data);
  }
}

class MalAired {
  DateTime from;
  DateTime to;
  MalTimeProp prop;
  String string;

  MalAired({
    this.from,
    this.to,
    this.prop,
    this.string,
  });

  factory MalAired.fromJson(Map<String, dynamic> json) => MalAired(
        from: json["from"] == null ? null : DateTime.parse(json["from"]),
        to: json["to"] == null ? null : DateTime.parse(json["to"]),
        prop: json["prop"] == null ? null : MalTimeProp.fromJson(json["prop"]),
        string: json["string"],
      );
}

class MalTimeProp {
  MalFrom from;
  MalFrom to;

  MalTimeProp({
    this.from,
    this.to,
  });

  factory MalTimeProp.fromJson(Map<String, dynamic> json) => MalTimeProp(
        from: json["from"] == null ? null : MalFrom.fromJson(json["from"]),
        to: json["to"] == null ? null : MalFrom.fromJson(json["to"]),
      );
}

class MalFrom {
  int day;
  int month;
  int year;

  MalFrom({
    this.day,
    this.month,
    this.year,
  });

  factory MalFrom.fromJson(Map<String, dynamic> json) => MalFrom(
        day: json["day"],
        month: json["month"],
        year: json["year"],
      );
}

class MalProp {
  int malId;
  MalType type;
  String name;
  String url;

  MalProp({
    this.malId,
    this.type,
    this.name,
    this.url,
  });

  factory MalProp.fromJson(Map<String, dynamic> json) => MalProp(
        malId: json["mal_id"],
        type: json["type"] == null ? null : malTypeValues.map[json["type"]],
        name: json["name"],
        url: json["url"],
      );
}

enum MalType { ANIME, MANGA }

final malTypeValues =
    EnumValues({"anime": MalType.ANIME, "manga": MalType.MANGA});

class MalRelated {
  List<MalProp> adaptation;
  List<MalProp> sequel;
  List<MalProp> prequel;
  List<MalProp> alternativeVersion;
  List<MalProp> sideStory;
  List<MalProp> other;

  MalRelated({
    this.adaptation,
    this.sequel,
    this.prequel,
    this.alternativeVersion,
    this.sideStory,
    this.other,
  });

  factory MalRelated.fromJson(Map<String, dynamic> json) => MalRelated(
        adaptation: json["Adaptation"] == null
            ? null
            : List<MalProp>.from(
                json["Adaptation"].map((x) => MalProp.fromJson(x))),
        sequel: json["Sequel"] == null
            ? null
            : List<MalProp>.from(
                json["Sequel"].map((x) => MalProp.fromJson(x))),
        prequel: json["Prequel"] == null
            ? null
            : List<MalProp>.from(
                json["Prequel"].map((x) => MalProp.fromJson(x))),
        alternativeVersion: json["Alternative version"] == null
            ? null
            : List<MalProp>.from(
                json["Alternative version"].map((x) => MalProp.fromJson(x))),
        sideStory: json["Side story"] == null
            ? null
            : List<MalProp>.from(
                json["Side story"].map((x) => MalProp.fromJson(x))),
        other: json["Other"] == null
            ? null
            : List<MalProp>.from(json["Other"].map((x) => MalProp.fromJson(x))),
      );
}
