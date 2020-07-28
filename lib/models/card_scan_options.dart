// @author nateshmbhat created on 30,June,2020

class CardScanOptions {
  final bool scanExpiryDate;
  final bool scanCardHolderName;
  final bool scanCardIssuer;

  const CardScanOptions({
    this.scanExpiryDate = true,
    this.scanCardHolderName = false,
    this.scanCardIssuer = false,
  });

  Map<String, String> get map => {
        'scanExpiryDate': scanExpiryDate.toString(),
        'scanCardHolderName': scanCardHolderName.toString(),
        'scanCardIssuer': scanCardIssuer.toString(),
      };
}
