// @author nateshmbhat created on 30,June,2020

enum CardHolderNameScanPosition { aboveCardNumber, belowCardNumber }

class CardScanOptions {
  final bool scanExpiryDate;
  final bool scanCardHolderName;

  /// This parameter is used so that some valid initial scan results containing false positives are dropped
  final int initialScansToDrop;
  final int validCardsToScanBeforeFinishingScan;

  ///Additional list of words that needs to be ignored when performing card holder name scan
  ///since card holder name scan can have many false positives. (There is no proper way to verify if a word is a name or not)
  ///By default words in [CardHolderNameConstants.defaultBlackListedWords] are used for blacklisting.
  ///This [cardHolderNameBlackListedWords] defaults to an empty set. If this parameter is set, then these words are added to the default blacklisted words
  final List<String> cardHolderNameBlackListedWords;

  /// setting this to true, will consider past dates also in expiry date scan.
  /// If a scanned date in the frame is before the current date, then that date is dropped.
  /// Defaults to [false]
  final bool considerPastDatesInExpiryDateScan;

  ///Defaults to [26]
  final int maxCardHolderNameLength;

  ///Scanned card numbers are put to "Luhn" algorithm check. Only if it passes the check , then its considered as a valid credit/debit card.
  ///Defaults to true since all real cards must pass [Luhn] algorithm
  final bool enableLuhnCheck;

  /// Timeout duration after which card scanner will just return the current optimal scan result which may contain false positives
  /// Timeout is useful when lighting conditions are bad and only few frames capture the card details.
  /// Once timeout happens, whatever the details captured till that time will be returned which can even be [null]
  /// Defaults to 0 or no-timeout
  final int cardScannerTimeOut;

  final bool enableDebugLogs;

  ///indicates possible positions are the expected positions for the card holder name with respect to the card number
  ///defaults to [CardHolderNameScanPosition.belowCardNumber]
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
