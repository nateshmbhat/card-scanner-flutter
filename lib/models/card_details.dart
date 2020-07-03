// @author nateshmbhat created on 30,June,2020

import 'package:card_scanner/utils.dart';

class CardDetails {
  var _cardNumber = "";
  var _cardIssuer = "";
  var _cardHolderName = "";
  var _expiryDate = "";

  get cardNumber => _cardNumber;

  CardDetails.fromMap(Map<String, String> map) {
    _cardNumber = map['cardNumber'];
    _cardIssuer = map['cardIssuer'].isNotEmpty ? map['cardIssuer'] : CardUtils().getCardIssuer(_cardNumber).toString();
    _cardHolderName = map['cardHolderName'];
    _expiryDate = map['expiryDate'];
  }

  toMap() {
    Map<String, String> map = {};
    map['cardNumber'] = _cardNumber;
    map['cardIssuer'] = _cardIssuer;
    map['cardHolderName'] = _cardHolderName;
    map['expiryDate'] = _expiryDate;
  }

  @override
  String toString() {
    var string = '';
    string += _cardNumber.isEmpty ? "" : 'Card Number = $cardNumber\n';
    string += _expiryDate.isEmpty ? "" : 'Expiry Date = $expiryDate\n';
    string += _cardIssuer.isEmpty ? "" : 'Card Issuer = $cardIssuer\n';
    string += _cardHolderName.isEmpty ? "" : 'Card Holder Name = $cardHolderName\n';
    return string;
  }

  get cardIssuer => _cardIssuer;

  get cardHolderName => _cardHolderName;

  get expiryDate => _expiryDate;
}
