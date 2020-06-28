package com.nateshmbhat.card_scanner.scanner_core

import android.util.Log
import com.google.mlkit.vision.text.Text
import com.nateshmbhat.card_scanner.scanner_core.models.CardDetails

//@author nateshmbhat created on 27,June,2020

class CardScannerCore(private val textItem: Text) {
  private val cardNumberRegex: Regex = Regex("^(\\s*\\d\\s*){15,16}$", RegexOption.MULTILINE)
  private lateinit var cardDetails: CardDetails

  public fun scanCard(): CardDetails? {
    if (!isCardNumberInText(textItem.text)) {
      return null
    }
    val cardNumber: String? = extractCardNumber(textItem.textBlocks);
    cardNumber ?: return null
    val cleanedCardNumber = cleanRawCardNumber(cardNumber)

    if (!checkLuhnAlgorithm(cleanedCardNumber)) {
      Log.d(TAG, "scanCard: card : $cardNumber , Luhn FAILED ");
      return null
    }
    cardDetails = CardDetails(cardNumber = cleanedCardNumber)
    return cardDetails
  }

  private fun extractCardNumber(textBlocks: List<Text.TextBlock>): String? {
    for (block in textBlocks) {
      val cardNumber = cardNumberRegex.find(block.text)?.value
      if (cardNumber != null) return cardNumber
    }
    return null
  }

  private fun isCardNumberInText(text: String): Boolean {
    return cardNumberRegex.containsMatchIn(text)
  }

  ///trims and removes all intermediate spaces for the card number
  private fun cleanRawCardNumber(cardNumber: String): String {
    return cardNumber.trim().replace(Regex("\\s+"), "")
  }

  ///Expects the result of [cleanRawCardNumber] to be passed here
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

  companion object {
    private const val TAG = "CardScannerCore"
  }
}
