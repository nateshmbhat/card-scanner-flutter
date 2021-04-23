package com.nateshmbhat.card_scanner.scanner_core.scan_filters

import com.google.mlkit.vision.text.Text
import com.nateshmbhat.card_scanner.logger.debugLog
import com.nateshmbhat.card_scanner.scanner_core.constants.CardScannerRegexps
import com.nateshmbhat.card_scanner.scanner_core.models.CardNumberScanResult
import com.nateshmbhat.card_scanner.scanner_core.models.CardScannerOptions
import com.nateshmbhat.card_scanner.scanner_core.models.ScanFilter

class CardNumberFilter(visionText: Text, scannerOptions: CardScannerOptions) : ScanFilter(visionText, scannerOptions) {
  private val cardNumberRegex: Regex = Regex(CardScannerRegexps.cardNumberRegex, RegexOption.MULTILINE)

  fun _isValidCardNumber(cardNumber: String): Boolean {
    return true;
//    if (scannerOptions.customBinNumbersToScan?.isEmpty ?? true) {
//    return true;
//  } else {
//    for (var binNumber in scannerOptions.customBinNumbersToScan) {
//      if (cardNumber.startsWith(binNumber.trim()?.replaceAll(' ', ''))) return true;
//    }
//    return false;
//  }
  }

  override fun filter(): CardNumberScanResult? {
    for ((index, block) in visionText.textBlocks.withIndex()) {
      if (cardNumberRegex.containsMatchIn(block.text)) {
        val cardNumber = cardNumberRegex.find(block.text)!!.value.trim().replace(Regex("\\s+"), "")
        if (!_isValidCardNumber(cardNumber)) continue;
        debugLog("card number = $cardNumber", scannerOptions);
        if (scannerOptions.enableLuhnCheck && !checkLuhnAlgorithm(cardNumber)) {
          debugLog("Luhn check failed !", scannerOptions);
          continue;
        }
        return CardNumberScanResult(
                textBlockIndex = index, textBlock = block, cardNumber = cardNumber, visionText = visionText);
      }
    }
    return null;
  }

  ///[cleanedCardNumber] is card number without any extra space and with only the digits of the card
  private fun checkLuhnAlgorithm(cleanedCardNumber: String): Boolean {
    val digitList = cleanedCardNumber.reversed().mapIndexed { index, digit ->
      var num = "$digit".toInt()
      if (index % 2 == 1) {
        num = (num * 2)
        num = if (num == 0) num else if (num % 9 == 0) 9 else num % 9
      }
      num
    }

    return (digitList.sum()) % 10 == 0
  }
}