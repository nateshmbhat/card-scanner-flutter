package com.basys.card_scanner.scanner_core.models

import com.google.mlkit.vision.text.Text

open class ScanFilterResult(val visionText: Text, val textBlockIndex: Int, val textBlock: Text.TextBlock, val data: ScanResultData)

class ScanResultData(val data: String, val elementType: CardElementType)

enum class CardElementType {
  CardNumber, ExpiryDate, CardHolderName
}

enum class CardHolderNameScanPositions(val value: String) {
  BelowCardNumber("belowCardNumber"),
  AboveCardNumber("aboveCardNumber")
}

class CardNumberScanResult(visionText: Text, textBlockIndex: Int, textBlock: Text.TextBlock,
                           val cardNumber: String) : ScanFilterResult(visionText, textBlockIndex,
        textBlock, data = ScanResultData(cardNumber, CardElementType.CardNumber))

class ExpiryDateScanResult(visionText: Text, textBlockIndex: Int, textBlock: Text.TextBlock,
                           val expiryDate: String) : ScanFilterResult(visionText, textBlockIndex,
        textBlock, data = ScanResultData(expiryDate, CardElementType.ExpiryDate))

class CardHolderNameScanResult(visionText: Text, textBlockIndex: Int, textBlock: Text.TextBlock,
                               val cardHolderName: String) : ScanFilterResult(visionText, textBlockIndex,
        textBlock, data = ScanResultData(cardHolderName, CardElementType.CardHolderName))

abstract class ScanFilter(val visionText: Text, val scannerOptions: CardScannerOptions) {
  abstract fun filter(): ScanFilterResult?
}