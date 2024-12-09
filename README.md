<p align="center">
  <img src="https://raw.githubusercontent.com/nateshmbhat/card-scanner-flutter/master/.github/logobig.gif?sanitize=true" width="250px">
</p>
<h2 align="center">Fast, Accurate, and Secure</h2>
<h2 align="center">The credit and debit card scanner for Flutter</h2>

<!-- [![](https://img.shields.io/pub/v/card_scanner)](https://pub.dev/packages/card_scanner) -->

[![](https://img.shields.io/badge/package-flutter-blue)](https://github.com/jackson-chandler-basys/card-scanner-flutter)
[![](https://img.shields.io/github/license/nateshmbhat/card-scanner-flutter)](https://github.com/jackson-chandler-basys/card-scanner-flutter)
[![](https://img.shields.io/github/languages/code-size/nateshmbhat/card-scanner-flutter)](https://github.com/jackson-chandler-basys/card-scanner-flutter)
[![](https://img.shields.io/badge/platform-android%20%26%20ios-bg)](https://github.com/nateshmbhat/card-scanner-flutter)

**card_scanner** is a flutter plugin for accurately and quickly scanning debit and credit cards.
**card_scanner** was orginally forked from [Natesh Bhat](https://github.com/nateshmbhat/card-scanner-flutter).

## Features

- 🔒 Fully **OFFLINE** scan makes it a completely **secure scanner**
- 🎈 Can scan **Expiry date**,, **Card Holder name**, **Card Issuer** (lacked by other scanners), and **Card number**✨
- 💯 Embossed card support
- 🔋 Powered by Google's Machine Learning models
- ⚡️ Great performance and accuracy
- 🧹 Auto checks the card number for errors using card checksum algorithms
- 🎚 Supports controlling parameters that determine the balance between speed and accuracy
- ❤️ Simple, powerful, and intuitive API

## Install

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  card_scanner: <latest-version>
```

> get the [latest version number here](https://pub.dev/packages/card_scanner#-installing-tab-)

## Usage

Just import the package and call `scanCard`:

```dart
import 'package:card_scanner/card_scanner.dart';
var cardDetails = await CardScanner.scanCard();

print(cardDetails);
```

Example Output:

```dart
Card Number = 5173949117389006
Expiry Date = 11/26
```

The above code opens the device camera, looks for a valid card and gets the required details and returns the `CardDetails` object.

---

### Scan Options

If you wish to obtain the card holder name and card issuer, you can specify the options:

```dart
import 'package:card_scanner/card_scanner.dart';
var cardDetails = await CardScanner.scanCard(
    scanOptions: CardScanOptions(
        scanCardHolderName: true,
        scanCardIssuer: true,
    ),
);


print(cardDetails);
```

Example Output :

```dart
Card Number = 5173949117389006
Expiry Date = 11/26
Card Issuer = mastercard
Card Holder Name = PAUL SAMUELSON
```

## iOS Requirements

- The minimum target for iOS should be >= 14.0.0
- Comment out the `use_frameworks!` line from under `Podfile` of your Flutter project.
  You can find this `Podfile` under `your_flutter_project/ios/Podfile`

<!-- ### [Documentation & Samples](https://pub.dev/documentation/card_scanner/latest/) 📖 -->
