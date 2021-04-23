package com.nateshmbhat.card_scanner.scanner_core.models

import com.google.mlkit.vision.text.Text

open class ScanFilterResult(val visionText: Text, val textBlockIndex: Int, val textBlock: Text.TextBlock, val data: ScanResultData)

class ScanResultData(val data: String, val elementType: CardElementType)

enum class CardElementType {
  cardNumber, expiryDate, cardHolderName
}

enum class CardHolderNameScanPositions(val value: String) {
  belowCardNumber("belowCardNumber"),
  aboveCardNumber("aboveCardNumber")
}

class CardNumberScanResult(visionText: Text, textBlockIndex: Int, textBlock: Text.TextBlock,
                           val cardNumber: String) : ScanFilterResult(visionText, textBlockIndex,
        textBlock, data = ScanResultData(cardNumber, CardElementType.cardNumber))

class ExpiryDateScanResult(visionText: Text, textBlockIndex: Int, textBlock: Text.TextBlock,
                           val expiryDate: String) : ScanFilterResult(visionText, textBlockIndex,
        textBlock, data = ScanResultData(expiryDate, CardElementType.expiryDate))

class CardHolderNameScanResult(visionText: Text, textBlockIndex: Int, textBlock: Text.TextBlock,
                               val cardHolderName: String) : ScanFilterResult(visionText, textBlockIndex,
        textBlock, data = ScanResultData(cardHolderName, CardElementType.cardHolderName))

abstract class ScanFilter(val visionText: Text, val scannerOptions: CardScannerOptions) {
  abstract fun filter(): ScanFilterResult?
}