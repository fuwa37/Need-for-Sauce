import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheUtils {
  static CacheManager cacheManager =
      CacheManager(Config("nfs_cahce", stalePeriod: Duration(days: 1)));

  static Future<File> downloadAndCache(String url) async {
    return await cacheManager.getSingleFile(url);
  }
}
