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

  static Future<Map<String,String>> scanCard() async {
    final value = await _channel.invokeMapMethod<String,String>('scan_card');
    print("method channel : GOT VALUE FROM METHOD CHANNEL : $value");
    return value;
  }
}
