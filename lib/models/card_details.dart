// @author nateshmbhat created on 30,June,2020

class CardDetails {
  var _cardNumber = "";
  var _cardIssuer = "";
  var _cardHolderName = "";
  var _expiryDate = "";

  get cardNumber => _cardNumber;

  CardDetails.fromMap(Map<String, String> map) {
    _cardNumber = map['cardNumber'];
    _cardIssuer = map['cardIssuer'];
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
    return ''' 
    cardNumber = "$cardNumber"
    cardIssuer = "$cardIssuer"
    cardHolderName = "$cardHolderName"
    expiryDate = "$expiryDate"
    ''';
  }

  get cardIssuer => _cardIssuer;

  get cardHolderName => _cardHolderName;

  get expiryDate => _expiryDate;
}
