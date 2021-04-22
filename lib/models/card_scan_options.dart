// @author nateshmbhat created on 30,June,2020

enum CardHolderNameScanPosition { aboveCardNumber, belowCardNumber }

class CardScanOptions {
  final bool scanExpiryDate;
  final bool scanCardHolderName;
  final int initialScansToDrop;
  final int validCardsToScanBeforeFinishingScan;
  final List<String> cardHolderNameBlackListedWords;
  final bool considerPastDatesInExpiryDateScan;
  final int maxCardHolderNameLength;
  final bool enableLuhnCheck;
  final int cardScannerTimeOut;
  final bool enableDebugLogs;
  final List<CardHolderNameScanPosition> possibleCardHolderNamePositions;

  const CardScanOptions(
      {this.scanExpiryDate = true,
      this.scanCardHolderName = false,
      this.initialScansToDrop = 1,
      this.validCardsToScanBeforeFinishingScan = 6,
      this.cardHolderNameBlackListedWords = const [],
      this.considerPastDatesInExpiryDateScan = false,
      this.maxCardHolderNameLength = 26,
      this.enableLuhnCheck = true,
      this.enableDebugLogs = false,
      this.cardScannerTimeOut = 0,
      this.possibleCardHolderNamePositions = const [CardHolderNameScanPosition.belowCardNumber]});

  Map<String, String> get map {
    final List<String> possibleNamePositions = [];
    if (possibleCardHolderNamePositions.contains(CardHolderNameScanPosition.belowCardNumber))
      possibleNamePositions.add('belowCardNumber');
    if (possibleCardHolderNamePositions.contains(CardHolderNameScanPosition.aboveCardNumber))
      possibleNamePositions.add('aboveCardNumber');

    return {
      'scanExpiryDate': scanExpiryDate.toString(),
      'scanCardHolderName': scanCardHolderName.toString(),
      'initialScansToDrop': initialScansToDrop.toString(),
      'validCardsToScanBeforeFinishingScan': validCardsToScanBeforeFinishingScan.toString(),
      'cardHolderNameBlackListedWords': cardHolderNameBlackListedWords.join(","),
      'considerPastDatesInExpiryDateScan': considerPastDatesInExpiryDateScan.toString(),
      'maxCardHolderNameLength': maxCardHolderNameLength.toString(),
      'enableLuhnCheck': enableLuhnCheck.toString(),
      'cardScannerTimeOut': cardScannerTimeOut.toString(),
      'enableDebugLogs': enableDebugLogs.toString(),
      'possibleCardHolderNamePositions': possibleNamePositions.join(",")
    };
  }
}
