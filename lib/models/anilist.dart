part of models;

class AnilistObject {
  AnilistData data;

  AnilistObject({this.data});

  AnilistObject.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new AnilistData.fromJson(json['data']) : null;
  }

  static Future<AnilistObject> getInfo(int anilistId) async {
    var query = r'''
                query ($id: Int) {
                  Media (id: $id, type: ANIME) {
                    title {
                      romaji
                      english
                      native
                      userPreferred
                    }
                    season
                    seasonYear
                    format
                    status
                    episodes
                    isAdult
                    genres
                    description
                    source
                  }
                }
                ''';
    var id = {'id': anilistId};

    var response;
    try {
      response = await Sauce.anilist()
          .post('', data: json.encode({'query': query, 'variables': id}));
    } on DioError catch (e) {
      switch (e.type) {
        case DioErrorType.RECEIVE_TIMEOUT:
        case DioErrorType.SEND_TIMEOUT:
        case DioErrorType.CONNECT_TIMEOUT:
          {
            throw NoInfoException("Connection timeout");
          }
        case DioErrorType.RESPONSE:
        case DioErrorType.CANCEL:
        case DioErrorType.DEFAULT:
          {
            throw NoInfoException("Couldn't connect to anilist.co");
          }
      }
    }
    if (response == null) return null;

    return AnilistObject.fromJson(response.data);
  }
}

class AnilistData {
  AnilistMedia media;

  AnilistData({this.media});

  AnilistData.fromJson(Map<String, dynamic> json) {
    media =
        json['Media'] != null ? new AnilistMedia.fromJson(json['Media']) : null;
  }
}

class AnilistMedia {
  AnilistTitle title;
  String season;
  int seasonYear;
  String format;
  String status;
  int episodes;
  bool isAdult;
  List<String> genres;
  String description;
  String source;

  AnilistMedia(
      {this.title,
      this.season,
      this.seasonYear,
      this.format,
      this.status,
      this.episodes,
      this.isAdult,
      this.genres,
      this.description,
      this.source});

  AnilistMedia.fromJson(Map<String, dynamic> json) {
    title =
        json['title'] != null ? new AnilistTitle.fromJson(json['title']) : null;
    season = json['season'];
    seasonYear = json['seasonYear'];
    format = json['format'];
    status = json['status'];
    episodes = json['episodes'];
    isAdult = json['isAdult'];
    genres = json['genres'].cast<String>();
    description = json['description'];
    source = json['source'];
  }
}

class AnilistTitle {
  String romaji;
  String english;
  String native;
  String userPreferred;

  AnilistTitle({this.romaji, this.english, this.native, this.userPreferred});

  AnilistTitle.fromJson(Map<String, dynamic> json) {
    romaji = json['romaji'];
    english = json['english'];
    native = json['native'];
    userPreferred = json['userPreferred'];
  }
}
