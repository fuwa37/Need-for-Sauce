part of models;

// https://github.com/md-y/mangadex-full-api/blob/master/src/enum/demographic.js
Map<int, String> demographicMap = {
  1: "Shounen",
  2: "Shoujo",
  3: "Seinen",
  4: "Josei"
};

// https://github.com/md-y/mangadex-full-api/blob/master/src/enum/pubstatus.js
Map<int, String> pubStatusMap = {
  1: "Ongoing",
  2: "Completed",
  3: "Cancelled",
  4: "Hiatus"
};

// https://github.com/md-y/mangadex-full-api/blob/master/src/enum/link.js
Map<String, dynamic> linksMap = {
  /**
     * Bookwalker
     */
  "bw": {"name": "Bookwalker", "prefix": "https://bookwalker.jp/"},
  /**
     * Baka-Updates Manga / MangaUpdates
     */
  "mu": {
    "name": "Baka-Updates Manga",
    "prefix": "https://www.mangaupdates.com/series.html?id="
  },
  /**
     * MyAnimeList
     */
  "mal": {"name": "My Anime List", "prefix": "https://myanimelist.net/manga/"},
  /**
     * Amazon
     */
  "amz": {"name": "Amazon", "prefix": ""},
  /**
     * eBook Japan
     */
  "ebj": {"name": "eBook Japan", "prefix": ""},
  /**
     * Official English Translation
     */
  "engtl": {"name": "Official English Translation", "prefix": ""},
  /**
     * Raw
     */
  "raw": {"name": "Raw", "prefix": ""},
  /**
     * Novel Updates
     */
  "nu": {
    "name": "Novel Updates",
    "prefix": "https://www.novelupdates.com/series/"
  },
  /**
     * CD Japan
     */
  "cdj": {"name": "CD Japan", "prefix": ""},
  /**
     * Kitsu
     */
  "kt": {"name": "Kitsu", "prefix": "https://kitsu.io/manga/"},
  /**
     * Anime-Planet
     */
  "ap": {
    "name": "Anime Planet",
    "prefix": "https://www.anime-planet.com/manga/"
  },
  /**
     * AniList
     */
  "al": {"name": "AniList", "prefix": "https://anilist.co/manga/"},
  /**
     * Doujinshi.org
     */
  "dj": {"name": "Doujinshi.org", "prefix": "https://www.doujinshi.org/book/"}
};

// https://github.com/md-y/mangadex-full-api/blob/master/src/enum/genre.js
Map<int, String> genreMap = {
  1: "4-Koma",
  2: "Action",
  3: "Adventure",
  4: "Award Winning",
  5: "Comedy",
  6: "Cooking",
  7: "Doujinshi",
  8: "Drama",
  9: "Ecchi",
  10: "Fantasy",
  11: "Gyaru",
  12: "Harem",
  13: "Historical",
  14: "Horror",
  16: "Martial Arts",
  17: "Mecha",
  18: "Medical",
  19: "Music",
  20: "Mystery",
  21: "Oneshot",
  22: "Psychological",
  23: "Romance",
  24: "School Life",
  25: "Sci-Fi",
  28: "Shoujo Ai",
  30: "Shounen Ai",
  31: "Slice of Life",
  32: "Smut",
  33: "Sports",
  34: "Supernatural",
  35: "Tragedy",
  36: "Long Strip",
  37: "Yaoi",
  38: "Yuri",
  40: "Video Games",
  41: "Isekai",
  42: "Adaptation",
  43: "Anthology",
  44: "Web Comic",
  45: "Full Color",
  46: "User Created",
  47: "Official Colored",
  48: "Fan Colored",
  49: "Gore",
  50: "Sexual Violence",
  51: "Crime",
  52: "Magical Girls",
  53: "Philosophical",
  54: "Superhero",
  55: "Thriller",
  56: "Wuxia",
  57: "Aliens",
  58: "Animals",
  59: "Crossdressing",
  60: "Demons",
  61: "Delinquents",
  62: "Genderswap",
  63: "Ghosts",
  64: "Monster Girls",
  65: "Loli",
  66: "Magic",
  67: "Military",
  68: "Monsters",
  69: "Ninja",
  70: "Office Workers",
  71: "Police",
  72: "Post-Apocalyptic",
  73: "Reincarnation",
  74: "Reverse Harem",
  75: "Samurai",
  76: "Shota",
  77: "Survival",
  78: "Time Travel",
  79: "Vampires",
  80: "Traditional Games",
  81: "Virtual Reality",
  82: "Zombies",
  83: "Incest",
  84: "Mafia"
};

class MangaDexObject {
  MangaDexObject({
    this.coverUrl,
    this.description,
    this.title,
    this.altNames,
    this.artist,
    this.author,
    this.status,
    this.genres,
    this.lastChapter,
    this.langName,
    this.langFlag,
    this.hentai,
    this.links,
    this.rating,
    this.selectedChapter,
  });

  String coverUrl;
  String description;
  String title;
  List<String> altNames;
  String artist;
  String author;
  String status;
  List<String> genres;
  String lastChapter;
  String langName;
  String langFlag;
  int hentai;
  List<MangaDexLink> links;
  Rating rating;
  MangaDexChapter selectedChapter;

  factory MangaDexObject.fromJson(Map<String, dynamic> json) => MangaDexObject(
        coverUrl: json["cover_url"],
        description: json["description"],
        title: json["title"],
        altNames: json["alt_names"] == null
            ? null
            : List<String>.from(json["alt_names"].map((x) => x)),
        artist: json["artist"],
        author: json["author"],
        status: pubStatusMap[json["status"]],
        genres: json["genres"] == null
            ? null
            : List<String>.from(json["genres"].map((x) => genreMap[x])),
        lastChapter: json["last_chapter"],
        langName: json["lang_name"],
        langFlag: json["lang_flag"],
        hentai: json["hentai"],
        links: json["links"] == null ? null : _links(json["links"]),
        rating: json["rating"] == null ? null : Rating.fromJson(json["rating"]),
      );

  static List<MangaDexLink> _links(Map<String, dynamic> links) {
    return links.entries.map((e) {
      var map = linksMap[e.key];
      return MangaDexLink(
          name: map['name'],
          prefix: map['prefix'],
          url: "${map['prefix']}${e.value}");
    }).toList();
  }

  static Future<MangaDexObject> getInfo(String id) async {
    var response;
    try {
      response = await Sauce.mangaDex().get('manga/$id');
    } on DioError catch (e) {
      switch (e.type) {
        case DioErrorType.receiveTimeout:
        case DioErrorType.sendTimeout:
        case DioErrorType.connectTimeout:
          {
            throw NoInfoException("Connection timeout");
          }
        case DioErrorType.response:
          {
            if (e.response.statusCode == 404) {
              throw NoInfoException("No manga with id $id found");
            }
            throw NoInfoException("Couldn't connect to internet");
          }
        case DioErrorType.cancel:
        case DioErrorType.other:
          {
            throw NoInfoException("Couldn't connect to mangadex.org");
          }
      }
    }
    if (response?.data['manga'] == null) return null;

    return MangaDexObject.fromJson(response.data['manga']);
  }
}

class MangaDexLink {
  MangaDexLink({this.name, this.prefix, this.url});

  String name;
  String prefix;
  String url;
}

class Rating {
  Rating({
    this.bayesian,
    this.mean,
    this.users,
  });

  String bayesian;
  String mean;
  String users;

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
        bayesian: json["bayesian"],
        mean: json["mean"],
        users: json["users"],
      );

  Map<String, dynamic> toJson() => {
        "bayesian": bayesian,
        "mean": mean,
        "users": users,
      };
}

class MangaDexChapter {
  MangaDexChapter({
    this.id,
    this.timestamp,
    this.hash,
    this.volume,
    this.chapter,
    this.title,
    this.langName,
    this.langCode,
    this.mangaId,
    this.groupId,
    this.groupName,
    this.groupId2,
    this.groupName2,
    this.groupId3,
    this.groupName3,
    this.comments,
    this.server,
    this.pageArray,
    this.longStrip,
    this.status,
    this.link,
  });

  int id;
  int timestamp;
  String hash;
  String volume;
  String chapter;
  String title;
  String langName;
  String langCode;
  int mangaId;
  int groupId;
  String groupName;
  int groupId2;
  String groupName2;
  int groupId3;
  String groupName3;
  int comments;
  String server;
  List<String> pageArray;
  bool longStrip;
  String status;
  String link;

  factory MangaDexChapter.fromJson(Map<String, dynamic> json) {
    List<String> pagesUrl = [];

    if (json["server"] != null &&
        json["hash"] != null &&
        (json["page_array"] != null && json["page_array"] is List)) {
      pagesUrl = List.from(json["page_array"])
          .map((e) =>
              "${json['server'].replaceAll('/data/', '/data-saver/')}${json['hash']}/$e")
          .toList();
    } else {
      pagesUrl = null;
    }

    // https://github.com/md-y/mangadex-full-api/blob/77563519abb20d38de6669da01169e34cff50781/src/structure/chapter.js#L30
    var link;
    if (json["status"] != "OK" || json["status"] != "unavailable") {
      if (json["status"] == "delayed")
        link = json["group_website"];
      else if (json["status"] == "external") link = json["external"];
    }

    return MangaDexChapter(
      id: json["id"],
      timestamp: json["timestamp"],
      hash: json["hash"],
      volume: json["volume"],
      chapter: json["chapter"],
      title: json["title"],
      langName: json["lang_name"],
      langCode: json["lang_code"],
      mangaId: json["manga_id"],
      groupId: json["group_id"],
      groupName: json["group_name"],
      groupId2: json["group_id_2"],
      groupName2: json["group_name_2"],
      groupId3: json["group_id_3"],
      groupName3: json["group_name_3"],
      comments: json["comments"],
      server: json["server"],
      pageArray: pagesUrl,
      longStrip: json["long_strip"] == null ? null : (json["long_strip"] == 1),
      status: json["status"],
      link: link,
    );
  }

  static Future<MangaDexChapter> getInfo(String id) async {
    var response;
    try {
      response = await Sauce.mangaDex().get('chapter/$id');
    } on DioError catch (e) {
      switch (e.type) {
        case DioErrorType.receiveTimeout:
        case DioErrorType.sendTimeout:
        case DioErrorType.connectTimeout:
          {
            throw NoInfoException("Connection timeout");
          }
        case DioErrorType.response:
          {
            if (e.response.statusCode == 404) {
              throw NoInfoException("No chapter with id $id found");
            }
            throw NoInfoException("Couldn't connect to internet");
          }
        case DioErrorType.cancel:
        case DioErrorType.other:
          {
            print(e.message);
            throw NoInfoException("Couldn't connect to mangadex.org");
          }
      }
    }
    if (response == null) return null;

    return MangaDexChapter.fromJson(response.data);
  }
}
