// @author nateshmbhat created on 30,June,2020

import 'package:card_scanner/utils.dart';

class CardDetails {
  String _cardNumber = "";
  String _cardIssuer = "";
  String _cardHolderName = "";
  String _expiryDate = "";

  CardDetails.fromMap(Map<String, String> map) {
    _cardNumber = map['cardNumber'] ?? '';
    _cardIssuer = CardUtils().getCardIssuer(_cardNumber).toString();
    _cardHolderName = map['cardHolderName'] ?? '';
    _expiryDate = map['expiryDate'] ?? '';
  }

  Map<String, String> get map => {
        'cardNumber': _cardNumber,
        'cardIssuer': _cardIssuer,
        'cardHolderName': _cardHolderName,
        'expiryDate': _expiryDate,
      };

  @override
  String toString() {
    var string = '';
    string += _cardNumber.isEmpty ? "" : 'Card Number = $cardNumber\n';
    string += _expiryDate.isEmpty ? "" : 'Expiry Date = $expiryDate\n';
    string += _cardIssuer.isEmpty ? "" : 'Card Issuer = $cardIssuer\n';
    string += _cardHolderName.isEmpty ? "" : 'Card Holder Name = $cardHolderName\n';
    return string;
  }

  String get cardNumber => _cardNumber;

  String get cardIssuer => _cardIssuer;

  String get cardHolderName => _cardHolderName;

  String get expiryDate => _expiryDate;
}
