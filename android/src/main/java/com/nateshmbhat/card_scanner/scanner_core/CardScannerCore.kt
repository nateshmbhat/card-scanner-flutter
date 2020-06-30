package com.nateshmbhat.card_scanner.scanner_core

import com.google.mlkit.vision.text.Text
import com.nateshmbhat.card_scanner.scanner_core.models.CardDetails
import com.nateshmbhat.card_scanner.scanner_core.scan_utils.CardHolderNameScanUtil
import com.nateshmbhat.card_scanner.scanner_core.scan_utils.CardIssuerScanUtil
import com.nateshmbhat.card_scanner.scanner_core.scan_utils.CardNumberScanUtil
import com.nateshmbhat.card_scanner.scanner_core.scan_utils.ExpiryScanUtil

//@author nateshmbhat created on 27,June,2020

class CardScannerCore(private val textItem: Text) {
  fun scanCard(finalCardDetails: CardDetails?): CardDetails? {
    val cardNumber = CardNumberScanUtil.verifyAndExtractCardNumber(textItem) ?: return null

    val cardNumberBlockPosition = CardNumberScanUtil.getTextBlockContainingCardNumber(textItem)
            ?: return null

    var cardDates: ExpiryScanUtil.Companion.CardDateItem = ExpiryScanUtil.Companion.CardDateItem("", "", -1)
    var cardHolderName: String = ""
    var cardIssuer = ""

    if (finalCardDetails == null || finalCardDetails.expiryDate.isEmpty()) {
      cardDates = ExpiryScanUtil.extractValidityDates(textItem, cardNumberBlockPosition)
    }
    if (finalCardDetails == null || finalCardDetails.cardHolderName.isEmpty()) {
      cardHolderName = CardHolderNameScanUtil.extractCardHolderName(
              textItem,
              cardNumberBlockPosition,
              cardDates.dateBlockPosition
      )
    }
    if (finalCardDetails == null || finalCardDetails.cardIssuer.isEmpty()) {
      cardIssuer = CardIssuerScanUtil.extractCardIssuer(textItem, cardNumberBlockPosition)
    }

    return CardDetails(cardNumber = cardNumber, validFromDate = cardDates.validFrom, expiryDate = cardDates.validTill,
            cardHolderName = cardHolderName, cardIssuer = cardIssuer
    )
  }
}


