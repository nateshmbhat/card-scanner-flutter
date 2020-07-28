// @author nateshmbhat created on 03,July,2020

import 'package:card_scanner/card_scanner.dart';

class CardUtils {
  final mastercard =
      RegExp(r'^(5[1-5][0-9]{14}|2(22[1-9][0-9]{12}|2[3-9][0-9]{13}|[3-6][0-9]{14}|7[0-1][0-9]{13}|720[0-9]{12}))$');
  final visa = RegExp(r'^4[0-9]{12}(?:[0-9]{3})?$');
  final amex = RegExp(r'^3[47][0-9]{13}$');
  final bCGlobal = RegExp(r'^(6541|6556)[0-9]{12}$');
  final carteBlanc = RegExp(r'^389[0-9]{11}$');
  final dinersClub = RegExp(r'^3(?:0[0-5]|[68][0-9])[0-9]{11}$');
  final discover = RegExp(
      r'^65[4-9][0-9]{13}|64[4-9][0-9]{13}|6011[0-9]{12}|(622(?:12[6-9]|1[3-9][0-9]|[2-8][0-9][0-9]|9[01][0-9]|92[0-5])[0-9]{10})$');
  final instaPayment = RegExp(r'^63[7-9][0-9]{13}$');
  final jCB = RegExp(r'^(?:2131|1800|35\d{3})\d{11}$');
  final koreanLocalCard = RegExp(r'^9[0-9]{15}$');
  final maestro = RegExp(r'^(5018|5020|5038|6304|6759|6761|6763)[0-9]{8,15}$');

  final solo = RegExp(r'^(6334|6767)[0-9]{12}|(6334|6767)[0-9]{14}|(6334|6767)[0-9]{15}$');
  final unionPay = RegExp(r'^(62[0-9]{14,17})$');
  final unknown = RegExp(r'.*');

  CardIssuer getCardIssuer(String cardNumber) {
    cardNumber = cardNumber.replaceAll(' ', '');
    var issuerMap = <RegExp, CardIssuer>{
      mastercard: CardIssuer.mastercard,
      visa: CardIssuer.visa,
      amex: CardIssuer.amex,
      bCGlobal: CardIssuer.bCGlobal,
      carteBlanc: CardIssuer.carteBlanche,
      dinersClub: CardIssuer.dinersClub,
      discover: CardIssuer.discover,
      instaPayment: CardIssuer.instaPayment,
      jCB: CardIssuer.jcb,
      koreanLocalCard: CardIssuer.koreanLocal,
      maestro: CardIssuer.maestro,
      solo: CardIssuer.solo,
      unionPay: CardIssuer.unionPay,
      unknown: CardIssuer.unknown
    };

    var matchingRegex = <RegExp>[
      mastercard,
      visa,
      amex,
      dinersClub,
      maestro,
      jCB,
      discover,
      bCGlobal,
      carteBlanc,
      instaPayment,
      solo,
      unionPay,
      koreanLocalCard,
      unknown,
    ].firstWhere((element) => element.hasMatch(cardNumber));

    return issuerMap[matchingRegex];
  }
}
