import 'dart:async';

import 'package:flutter/services.dart';

class CardScanner {
  static const MethodChannel _channel = const MethodChannel('nateshmbhat/card_scanner');

  static void init() {
    _channel.setMethodCallHandler((call) {
      print(call.method + "  -  " + call.arguments);
      return null;
    });
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> scanCard() async {
    final String value = await _channel.invokeMethod('scan_card');
    return value;
  }
}
