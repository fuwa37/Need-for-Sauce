library models;

import 'dart:convert';
import 'package:need_for_sauce/common/http_request.dart';
import 'package:need_for_sauce/common/common.dart';
import 'package:dio/dio.dart';

part 'anilist.dart';

part 'mal.dart';

part 'nhentai.dart';

part 'sauce.dart';

part 'saucenao.dart';

part 'saucenaodata.dart';

part 'trace.dart';

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}

String returnTime(Duration time) {
  return "${(time.inHours > 0) ? (time.inHours.toString().padLeft(2, '0') + ':') : ""}${time.inMinutes.remainder(60).toString().padLeft(2, '0')}:${time.inSeconds.remainder(60).toString().padLeft(2, '0')}";
}
