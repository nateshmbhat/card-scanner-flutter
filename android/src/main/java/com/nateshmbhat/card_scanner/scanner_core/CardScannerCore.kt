package com.nateshmbhat.card_scanner.scanner_core

import com.google.mlkit.vision.text.Text
import com.nateshmbhat.card_scanner.scanner_core.models.CardDetails
import com.nateshmbhat.card_scanner.scanner_core.scan_utils.CardHolderNameScanUtil
import com.nateshmbhat.card_scanner.scanner_core.scan_utils.CardNumberScanUtil
import com.nateshmbhat.card_scanner.scanner_core.scan_utils.ExpiryScanUtil

//@author nateshmbhat created on 27,June,2020

class CardScannerCore(private val textItem: Text) {
  public fun scanCard(): CardDetails? {
    val cardNumber = CardNumberScanUtil.verifyAndExtractCardNumber(textItem) ?: return null

    val cardNumberBlockPosition = CardNumberScanUtil.getTextBlockContainingCardNumber(textItem)
            ?: return null
    val cardDates = ExpiryScanUtil.extractValidityDates(textItem, cardNumberBlockPosition)
    val cardHolderName = CardHolderNameScanUtil.extractCardHolderName(textItem, cardNumberBlockPosition, cardDates.dateBlockPosition)

    return CardDetails(cardNumber = cardNumber, validFromDate = cardDates.validFrom, expiryDate = cardDates.validTill,
        cardHolderName = cardHolderName
    )
  }
}


