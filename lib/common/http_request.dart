import 'package:dio/dio.dart';

class Sauce {
  static Dio sauceBot() {
    BaseOptions options = new BaseOptions(
      baseUrl: 'https://sauce-bot.irs37.repl.co',
      receiveDataWhenStatusError: true,
      connectTimeout: 15 * 1000,
    );

    return Dio(options);
  }

  static Dio sauceNao(dbmask, {int minsim = 70, int numres = 6}) {
    BaseOptions options = new BaseOptions(
      baseUrl:
          'https://saucenao.com/search.php?db=999&output_type=2&minsim=$minsim&numres=$numres&dbmask=$dbmask',
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
}
