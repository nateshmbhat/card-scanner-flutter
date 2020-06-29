package com.nateshmbhat.card_scanner.scanner_core.scan_utils

import android.util.Log
import com.google.mlkit.vision.text.Text

class CardNumberScanUtil {
  companion object {
    private val cardNumberRegex: Regex = Regex("^(\\s*\\d\\s*){15,16}$", RegexOption.MULTILINE)
    private const val TAG = "scanCard"
    private fun extractCardNumber(block: Text.TextBlock): String? {
      return cardNumberRegex.find(block.text)?.value
    }

    ///returns cleaned card number if it passes Luhn algorithm else null
    public fun verifyAndExtractCardNumber(textItem: Text): String? {
      val cardNumberTextBlockPosition = getTextBlockContainingCardNumber(textItem)
              ?: return null
      val cardNumber = extractCardNumber(textItem.textBlocks[cardNumberTextBlockPosition])
              ?: return null
      val cleanedCardNumber = cleanRawCardNumber(cardNumber)

      if (!checkLuhnAlgorithm(cleanedCardNumber)) {
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