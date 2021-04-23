package com.nateshmbhat.card_scanner.scanner_core.scan_filters

import com.google.mlkit.vision.text.Text
import com.nateshmbhat.card_scanner.scanner_core.constants.CardScannerRegexps
import com.nateshmbhat.card_scanner.scanner_core.models.*
import java.text.SimpleDateFormat
import java.util.*
import kotlin.math.min

class ExpiryDateFilter(visionText: Text, scannerOptions: CardScannerOptions, private val cardNumberScanResult: CardNumberScanResult) : ScanFilter(visionText, scannerOptions) {
  private val expiryDateRegex: Regex = Regex(CardScannerRegexps.expiryDateRegex, RegexOption.MULTILINE)
  val _maxBlocksBelowCardNumberToSearchForExpiryDate = 4;
  val _expiryDateFormat = "MM/yy";

  override fun filter(): ExpiryDateScanResult? {
    if (cardNumberScanResult.cardNumber.isEmpty()) return null;
    if (!scannerOptions.scanExpiryDate) return null;

    val scanResults: MutableList<ExpiryDateScanResult> = mutableListOf()
    val maxTextBlockIndexToSearchExpiryDate = min(
            cardNumberScanResult.textBlockIndex + _maxBlocksBelowCardNumberToSearchForExpiryDate, visionText.textBlocks.size - 1);

    for (index in cardNumberScanResult.textBlockIndex..maxTextBlockIndexToSearchExpiryDate) {
      val block = visionText.textBlocks[index]
      if (!expiryDateRegex.containsMatchIn(block.text)) continue;
      for (match in expiryDateRegex.findAll(block.text)) {
        val expiryDate = match.groupValues[0].trim().replace(Regex("\\s+"), "")
        if (_isValidExpiryDate(expiryDate)) {
          scanResults.add(ExpiryDateScanResult(
                  textBlockIndex = index, textBlock = block, expiryDate = expiryDate, visionText = visionText));
        }
      }
      if (scanResults.size > 2) break;
    }

    if (scanResults.isEmpty()) return null;
    return _chooseMostRecentDate(scanResults);
  }

  fun _chooseMostRecentDate(expiryDateResults: List<ExpiryDateScanResult>): ExpiryDateScanResult {
    if (expiryDateResults.size == 1) return expiryDateResults[0];

    var mostRecentDateResult = expiryDateResults[0]
    for ((index, expiryDateResult) in expiryDateResults.subList(1, expiryDateResults.size).withIndex()) {
      val currentMostRecent = _parseExpiryDate(mostRecentDateResult.expiryDate);
      val newDate = _parseExpiryDate(expiryDateResult.expiryDate);
      if (newDate.after(currentMostRecent)) {
        mostRecentDateResult = expiryDateResult;
      }
    }
    return mostRecentDateResult;
  }

  fun _isValidExpiryDate(expiryDate: String): Boolean {
    val expiryDateTime = SimpleDateFormat(_expiryDateFormat, Locale.US).parse(expiryDate)
    val currentDateTime = SimpleDateFormat(_expiryDateFormat, Locale.US).parse(
            SimpleDateFormat(_expiryDateFormat, Locale.US).format(Date()))
    if (scannerOptions.considerPastDatesInExpiryDateScan) {
      return true;
    } else {
      return expiryDateTime.after(currentDateTime);
    }
  }

  fun _parseExpiryDate(expiryDate: String): Date {
    return SimpleDateFormat(_expiryDateFormat, Locale.US).parse(expiryDate)
  }
}
