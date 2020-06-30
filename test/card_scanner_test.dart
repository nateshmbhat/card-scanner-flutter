import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:card_scanner/card_scanner.dart';

void main() {
  const MethodChannel channel = MethodChannel('nateshmbhat/card_scanner');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('scan_card', () async {});
}
