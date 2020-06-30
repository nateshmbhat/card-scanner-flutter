import 'dart:async';
import 'package:card_scanner/models/card_details.dart';
import 'package:card_scanner/models/card_scan_options.dart';
import 'package:flutter/services.dart';

export 'package:card_scanner/models/card_details.dart';
export 'package:card_scanner/models/card_scan_options.dart';

class CardScanner {
  static const MethodChannel _channel = const MethodChannel('nateshmbhat/card_scanner');
  static const _scan_card = 'scan_card';

  static Future<CardDetails> scanCard({CardScanOptions scanOptions}) async {
    scanOptions ??= CardScanOptions();
    final value = await _channel.invokeMapMethod<String, String>(_scan_card, scanOptions.toMap());
    print("method channel : GOT VALUE FROM METHOD CHANNEL : $value");
    if (value == null) {
      return null;
    } else {
      return Future.value(CardDetails.fromMap(value));
    }
  }
}
