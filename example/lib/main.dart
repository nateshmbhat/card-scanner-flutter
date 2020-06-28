import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:card_scanner/card_scanner.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, String> _cardDetails;

  @override
  void initState() {
    CardScanner.init();
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanCard() async {
    Map<String, String> cardDetails = {};
    try {
      cardDetails = await CardScanner.scanCard();
    } on PlatformException catch(e) {
      print('Failed to get platform version : $e');
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _cardDetails = cardDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton(
                onPressed: () async {
                  scanCard();
                },
                child: Text('scan card'),
              ),
              Text('Card Details : $_cardDetails')
            ],
          ),
        ),
      ),
    );
  }
}
