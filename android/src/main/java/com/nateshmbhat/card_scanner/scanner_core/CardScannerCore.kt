package com.nateshmbhat.card_scanner.scanner_core

import com.google.mlkit.vision.text.Text
import com.nateshmbhat.card_scanner.scanner_core.models.CardDetails
import com.nateshmbhat.card_scanner.scanner_core.models.CardScanOptions
import com.nateshmbhat.card_scanner.scanner_core.scan_utils.CardHolderNameScanUtil
import com.nateshmbhat.card_scanner.scanner_core.scan_utils.CardIssuerScanUtil
import com.nateshmbhat.card_scanner.scanner_core.scan_utils.CardNumberScanUtil
import com.nateshmbhat.card_scanner.scanner_core.scan_utils.ExpiryScanUtil

//@author nateshmbhat created on 27,June,2020

class CardScannerCore(private val textItem: Text, private val scanOptions: CardScanOptions) {
  fun scanCard(finalCardDetails: CardDetails?): CardDetails? {
    val cardNumber = CardNumberScanUtil.verifyAndExtractCardNumber(textItem) ?: return null

    val cardNumberBlockPosition = CardNumberScanUtil.getTextBlockContainingCardNumber(textItem)
            ?: return null

    var expiryDate: ExpiryScanUtil.Companion.CardDateItem = ExpiryScanUtil.Companion.CardDateItem("", -1)
    var cardHolderName: String = ""
    var cardIssuer = ""

    if (scanOptions.scanExpiryDate && finalCardDetails?.expiryDate?.isBlank() ?: true) {
      expiryDate = ExpiryScanUtil.extractValidityDates(textItem, cardNumberBlockPosition)
    }

    if (scanOptions.scanCardHolderName && (finalCardDetails?.cardHolderName?.isBlank() ?: true)) {
      cardHolderName = CardHolderNameScanUtil.extractCardHolderName(
              textItem,
              cardNumberBlockPosition,
              expiryDate.dateBlockPosition
      )
    }

    if (scanOptions.scanCardIssuer && (finalCardDetails?.cardIssuer?.isEmpty() ?: true)) {
      cardIssuer = CardIssuerScanUtil.extractCardIssuer(textItem, cardNumberBlockPosition)
    }

    return CardDetails(cardNumber = cardNumber, expiryDate = expiryDate.expiryDate,
            cardHolderName = cardHolderName, cardIssuer = cardIssuer
    )
  }
}


