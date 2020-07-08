import 'dart:async';

import 'package:flutter/services.dart';

class GetSignature {
  static const MethodChannel _channel =
      const MethodChannel('get_signature');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> get appSignature async {
    final String sign = await _channel.invokeMethod('getSignature');
    return sign;
  }
}
