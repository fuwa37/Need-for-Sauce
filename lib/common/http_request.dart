import 'package:dio/dio.dart';

class Sauce {
  static Dio sauceNao(dbmask, api, {int minsim = 70, int numres = 6}) {
    BaseOptions options = new BaseOptions(
      baseUrl:
          'https://saucenao.com/search.php?db=999&output_type=2&minsim=$minsim&numres=$numres&dbmask=$dbmask&api_key=$api',
      receiveDataWhenStatusError: true,
      connectTimeout: 15 * 1000,
    );

    return Dio(options);
  }

  static Dio trace() {
    BaseOptions options = new BaseOptions(
      baseUrl: 'https://trace.moe/api/search',
      receiveDataWhenStatusError: true,
      connectTimeout: 15 * 1000,
    );

    return Dio(options);
  }

  static Dio mal() {
    BaseOptions options = new BaseOptions(
      baseUrl: 'https://api.jikan.moe/v3/anime',
      receiveDataWhenStatusError: true,
      connectTimeout: 15 * 1000,
    );

    return Dio(options);
  }

  static Dio anilist() {
    BaseOptions options = new BaseOptions(
      baseUrl: 'https://graphql.anilist.co',
      receiveDataWhenStatusError: true,
      connectTimeout: 15 * 1000,
      headers: {'Content-type': 'application/json'},
    );

    return Dio(options);
  }

  static Dio nhentai() {
    BaseOptions options = new BaseOptions(
      baseUrl: 'https://nhentai.net',
      receiveDataWhenStatusError: true,
      connectTimeout: 15 * 1000,
    );

    return Dio(options);
  }

  static Dio animeRelation() {
    BaseOptions options = new BaseOptions(
      baseUrl: 'https://relations.yuna.moe/api/ids',
      receiveDataWhenStatusError: true,
      connectTimeout: 15 * 1000,
    );

    return Dio(options);
  }

  static Dio mangaDex() {
    BaseOptions options = new BaseOptions(
      baseUrl: 'https://mangadex.org/api/',
      receiveDataWhenStatusError: true,
      connectTimeout: 15 * 1000,
    );

    return Dio(options);
  }

  static Dio booru(String path, String id) {
    var url;
    switch (path) {
      case "danbooru":
        url = "https://danbooru.donmai.us/posts/$id.json";
        break;
      case "gelbooru":
        url =
            "https://gelbooru.com/index.php?page=dapi&s=post&q=index&json=1&id=$id";
        break;
      case "yandere":
        url = "https://yande.re/post.json?tags=id:$id";
        break;
      case "konachan":
        url = "https://konachan.net/post.json?tags=id:$id";
        break;
      case "e621":
        url = "https://e621.net/posts/$id.json";
        break;
    }

    BaseOptions options = new BaseOptions(
        baseUrl: url,
        receiveDataWhenStatusError: true,
        connectTimeout: 15 * 1000,
        queryParameters: {"User-Agent": "NeedforSauce/0.4.1"});

    return Dio(options);
  }
}
