package com.nateshmbhat.card_scanner

import com.google.mlkit.vision.text.Text
import com.nateshmbhat.card_scanner.scanner_core.models.CardDetails
import com.nateshmbhat.card_scanner.scanner_core.models.CardScannerOptions
import com.nateshmbhat.card_scanner.scanner_core.scan_filters.CardHolderNameFilter
import com.nateshmbhat.card_scanner.scanner_core.scan_filters.CardNumberFilter
import com.nateshmbhat.card_scanner.scanner_core.scan_filters.ExpiryDateFilter

class SingleFrameCardScanner(private val scannerOptions: CardScannerOptions) {
  fun scanSingleFrame(visionText: Text): CardDetails? {
    val cardNumberResult = CardNumberFilter(visionText, scannerOptions).filter();
    if (cardNumberResult?.cardNumber?.isEmpty() != false) {
      return null;
    }
    val cardExpiryResult = ExpiryDateFilter(visionText, scannerOptions, cardNumberResult).filter();
    val cardHolderResult = CardHolderNameFilter(visionText, scannerOptions, cardNumberResult).filter();
    return CardDetails(cardNumber = cardNumberResult.cardNumber, expiryDate = cardExpiryResult?.expiryDate
            ?: "", cardHolderName = cardHolderResult?.cardHolderName ?: "");
  }
}