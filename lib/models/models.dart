library models;

import 'dart:convert';
import 'package:need_for_sauce/common/http_request.dart';
import 'package:need_for_sauce/common/common.dart';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

part 'anilist.dart';

part 'mal.dart';

part 'nhentai.dart';

part 'sauce.dart';

part 'saucenao.dart';

part 'saucenaodata.dart';

part 'trace.dart';

part 'mangadex.dart';

part 'booru.dart';

part 'models.g.dart';

class AnimeRelation {
  int aniDbId;
  int anilistId;
  int malId;
  int kitsuId;

  AnimeRelation({this.aniDbId, this.anilistId, this.malId, this.kitsuId});

  factory AnimeRelation.fromJson(Map<String, dynamic> json) => AnimeRelation(
      aniDbId: json['anidb'],
      anilistId: json['anilist'],
      malId: json['myanimelist'],
      kitsuId: json['kitsu']);

  static Future<AnimeRelation> getRelation(
      {int aniDbId, int anilistId, int malId, int kitsuId}) async {
    var data = {
      'anidb': aniDbId,
      'anilist': anilistId,
      'malId': malId,
      'kitsu': kitsuId,
    };

    data.removeWhere((key, value) => value == null);

    var response;
    try {
      response = await Sauce.animeRelation().post('', data: [data]);
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
            throw NoInfoException("Couldn't connected");
          }
      }
    }
    if (response?.data[0] == null) return null;

    return AnimeRelation.fromJson(response.data[0]);
  }
}
