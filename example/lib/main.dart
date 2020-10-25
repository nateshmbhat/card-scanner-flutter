import 'package:flutter/material.dart';
import 'dart:async';
import 'package:card_scanner/card_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CardDetails _cardDetails;

  Future<void> scanCard() async {
    var cardDetails =
        await CardScanner.scanCard(scanOptions: CardScanOptions(scanCardHolderName: true));

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
          title: const Text('card_scanner app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton(
                onPressed: () async {
                  var status = await Permission.camera.request();
                  if (status == PermissionStatus.granted) {
                    scanCard();
                  }
                },
                child: Text('scan card'),
              ),
              Text('$_cardDetails')
            ],
          ),
        ),
      ),
    );
  }
}
