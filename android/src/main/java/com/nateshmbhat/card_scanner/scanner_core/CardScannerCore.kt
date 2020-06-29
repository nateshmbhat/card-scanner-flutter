package com.nateshmbhat.card_scanner.scanner_core

import android.util.Log
import com.google.mlkit.vision.text.Text
import com.nateshmbhat.card_scanner.scanner_core.models.CardDetails

//@author nateshmbhat created on 27,June,2020

class CardScannerCore(private val textItem: Text) {
  public fun scanCard(): CardDetails? {
    val cardNumber = CardNumberScanUtil.verifyAndExtractCardNumber(textItem) ?: return null

    val cardNumberBlockPosition = CardNumberScanUtil.getTextBlockContainingCardNumber(textItem)
            ?: return null
//    val validFromAndExpiryDates = ExpiryScanUtil.extractValidityDates(textItem, cardNumberBlockPosition)
    return CardDetails(cardNumber = cardNumber)
  }
}


class ExpiryScanUtil {
  companion object {
    private val cardNumberRegex: Regex = Regex("^\\s*(\\d{2}/\\d{2})\\s*$", RegexOption.MULTILINE)
//    fun extractValidityDates(textItem: Text, cardNumberBlockPosition: Int) : Pair<String,String> {
//
//    }
  }
}


class CardNumberScanUtil {
  companion object {
    private val cardNumberRegex: Regex = Regex("^(\\s*\\d\\s*){15,16}$", RegexOption.MULTILINE)
    private const val TAG = "scanCard"
    private fun extractCardNumber(block: Text.TextBlock): String? {
      return cardNumberRegex.find(block.text)?.value
    }

    ///returns cleaned card number if it passes Luhn algorithm else null
    public fun verifyAndExtractCardNumber(textItem: Text): String? {
      val cardNumberTextBlockPosition = CardNumberScanUtil.getTextBlockContainingCardNumber(textItem)
              ?: return null
      val cardNumber = CardNumberScanUtil.extractCardNumber(textItem.textBlocks[cardNumberTextBlockPosition])
              ?: return null
      val cleanedCardNumber = cleanRawCardNumber(cardNumber)

      if (!CardNumberScanUtil.checkLuhnAlgorithm(cleanedCardNumber)) {
        Log.d(TAG, "scanCard: card : $cardNumber , Luhn FAILED ");
        return null
      }

      Log.d(TAG, "scanCard: card : $cardNumber , Luhn PASSED ");
      return cleanedCardNumber
    }


    ///trims and removes all intermediate spaces for the card number
    private fun cleanRawCardNumber(cardNumber: String): String {
      return cardNumber.trim().replace(Regex("\\s+"), "")
    }

    ///returns the text block index containing the card number
    public fun getTextBlockContainingCardNumber(textItem: Text): Int? {
      for (index in textItem.textBlocks.indices) {
        val textBlock = textItem.textBlocks[index]
        if (cardNumberRegex.containsMatchIn(textBlock.text)) return index
      }
      return null
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
  }
}
