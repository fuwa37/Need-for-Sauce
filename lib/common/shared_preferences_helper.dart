import 'package:shared_preferences/shared_preferences.dart';
import 'package:need_for_sauce/models/models.dart';
import 'dart:convert';

// Based on https://saucenao.com/tools/examples/api/identify_images_v1.1.py
// Commented index, site closed or index API broken/not updated
const Map<String, dynamic> indexSauceNaoDB = {
  // "index_hmags": '1',
  // "index_reserved": '1',
  // "index_hcg": '1',
  // "index_ddbobjects": '1',
  // "index_ddbsamples": '1',
  "Pixiv": '1',
  // "index_pixivhistorical": '1',
  "Niconico Seiga": '1',
  "Danbooru": '1',
  // "index_drawr": '1',
  "Nijie": '1',
  "Yande.re": '1',
  // "index_animeop": '1', unknown source
  // "index_shutterstock": '1',
  // "index_fakku": '1',
  "H-Manga": '1',
  "2D-Market": '1',
  "MediBang": '1',
  "Anime": '1',
  "H-Anime": '1',
  "Movies": '1',
  "TV Series": '1',
  "Gelbooru": '1',
  "Konachan": '1',
  // "index_sankaku": '1',
  "Anime-Pictures": '1',
  "e621": '1',
  "Idol Complex": '1',
  "bcy Illust": '1',
  "bcy Cosplay": '1',
  // "index_portalgraphics": '1',
  "devianArt": '1',
  "Pawoo": '1',
  // "index_madokami": '1',
  "MangaDex": '1',
};

String sauceNaoDBMask(Map<String, String> index) {
  var dbmask = int.parse(
      (index["MangaDex"] +
          (index['index_madokami'] ?? '0') +
          index['Pawoo'] +
          index['devianArt'] +
          (index['index_portalgraphics'] ?? '0') +
          index['bcy Cosplay'] +
          index['bcy Illust'] +
          index['Idol Complex'] +
          index['e621'] +
          index['Anime-Pictures'] +
          (index['index_sankaku'] ?? '0') +
          index['Konachan'] +
          index['Gelbooru'] +
          index['TV Series'] +
          index['Movies'] +
          index['H-Anime'] +
          index['Anime'] +
          index['MediBang'] +
          index['2D-Market'] +
          index['H-Manga'] +
          (index['index_fakku'] ?? '0') +
          (index['index_shutterstock'] ?? '0') +
          (index['index_reserved'] ?? '0') +
          (index['index_animeop'] ?? '0') +
          index['Yande.re'] +
          index['Nijie'] +
          (index['index_drawr'] ?? '0') +
          index['Danbooru'] +
          index['Niconico Seiga'] +
          index['Anime'] +
          index['Pixiv'] + // index #6, pixiv historical
          index['Pixiv'] +
          (index['index_ddbsamples'] ?? '0') +
          (index['index_ddbobjects'] ?? '0') +
          (index['index_hcg'] ?? '0') +
          index['H-Anime'] +
          (index['index_hmags'] ?? '0')),
      radix: 2);

  return dbmask.toString();
}

enum SearchOption { SauceBot, Trace, SauceNao }

final searchOptionValues = EnumValues({
  "SauceNAO": SearchOption.SauceNao,
  "Trace": SearchOption.Trace,
  "Sauce Bot": SearchOption.SauceBot
});

class SharedPreferencesUtils {
  static SharedPreferences _prefs;

  static Future<SharedPreferences> getPrefs() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    return _prefs;
  }

  static Future<bool> setAllIndexes(bool val) async {
    var prefs = await getPrefs();

    var map = Map.from(indexSauceNaoDB);

    if (!val) {
      map.updateAll((key, value) => '0');
    }

    return (await prefs.setBool('all_db', val) &&
        await prefs.setString('dbmask', json.encode(map)));
  }

  static Future<bool> getAllIndexes() async {
    var prefs = await getPrefs();

    return prefs.getBool('all_db');
  }

  static Future<bool> removeAllIndexes() async {
    var prefs = await getPrefs();

    return prefs.remove('all_db');
  }

  static Future<bool> setSauceNaoMask(String db, String value) async {
    print("$db, $value");
    var prefs = await getPrefs();

    var map = await getSauceNaoMask();

    map[db] = value;

    return prefs.setString("dbmask", json.encode(map));
  }

  static Future<Map<String, dynamic>> getSauceNaoMask() async {
    var prefs = await getPrefs();

    var map = prefs.getString("dbmask");

    if (map == null) {
      return Map.from(indexSauceNaoDB);
    } else {
      return json.decode(map);
    }
  }

  static Future<bool> setSourceOption(SearchOption options) async {
    var prefs = await getPrefs();

    return prefs.setString(
        'search_option', searchOptionValues.reverse[options]);
  }

  static Future<SearchOption> getSourceOption() async {
    var prefs = await getPrefs();

    var option = prefs.get('search_option')?.toString();

    if (option == null || searchOptionValues.map[option] == null) {
      return SearchOption.SauceNao;
    }

    return searchOptionValues.map[option];
  }

  static Future<bool> setAddInfo(bool s) async {
    var prefs = await getPrefs();

    return prefs.setBool("add_info", s);
  }

  static Future<bool> getAddInfo() async {
    var prefs = await getPrefs();

    var option = prefs.get('add_info')?.toString();

    if (option == null) {
      return false;
    }

    return prefs.getBool('add_info') ?? false;
  }

  static Future<bool> setSauce(SauceObject s) async {
    SharedPreferences prefs = await getPrefs();

    return prefs.setString(DateTime.now().millisecondsSinceEpoch.toString(),
        jsonEncode(s.toJson()));
  }

  static Future<Set<String>> getSauces() async {
    SharedPreferences prefs = await getPrefs();

    return prefs.getKeys();
  }

  static Future<SauceObject> getSauce(String s) async {
    SharedPreferences prefs = await getPrefs();

    return SauceObject.fromJSON(jsonDecode(prefs.getString(s)));
  }

  static Future<bool> removeSauce(String s) async {
    SharedPreferences prefs = await getPrefs();

    return prefs.remove(s);
  }

  static Future<bool> removeSauces() async {
    SharedPreferences prefs = await getPrefs();
    var temp = prefs.getKeys();

    try {
      temp.forEach((s) {
        prefs.remove(s);
      });
    } on Exception catch (e) {
      print(e);
      return false;
    }

    return true;
  }
}
