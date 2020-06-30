// @author nateshmbhat created on 30,June,2020

class CardScanOptions {
  final scanExpiryDate;
  final scanCardHolderName;
  final scanCardIssuer;

  CardScanOptions(
      {this.scanExpiryDate = true,
      this.scanCardHolderName = false,
      this.scanCardIssuer = false});

  Map<String, String> toMap() {
    Map<String, String> map = {};
    map['scanExpiryDate'] = scanExpiryDate.toString();
    map['scanCardHolderName'] = scanCardHolderName.toString();
    map['scanCardIssuer'] = scanCardIssuer.toString();
    return map;
  }
}
