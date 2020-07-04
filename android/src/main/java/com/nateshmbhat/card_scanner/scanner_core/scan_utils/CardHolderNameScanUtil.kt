package com.nateshmbhat.card_scanner.scanner_core.scan_utils

import com.google.mlkit.vision.text.Text
import java.util.*
import kotlin.math.max
import kotlin.math.min

//@author nateshmbhat created on 29,June,2020
class CardHolderNameScanUtil {
  companion object {
    private val holderNameRegex = Regex("^ *(([A-Z.]+ {0,2}){1,6}) *$", RegexOption.MULTILINE)
    private val blackListedWords = setOf("valid", "through", "thru", "valid thru", "valid through", "from", "valid from", "international", "rupay", "debit", "platinum",
            "axis", "sbi", "axis bank", "credit", "card", "titanium", "bank", "global", "state bank", "of", "the", "india", "valid only", "classic", "gold", "sbi card",
            "visa classic", "visa signature", "visa gold", "electronic", "use only", "electronic use only", "only", "use"
            , "expires", "end", "expires end", "valid till", "expire date", "date", "expiry", "expiry date", "premier",
            "world", "uk", "hsbc", "amex"
    )

    fun extractCardHolderName(visionText: Text, cardNumberBlockPosition: Int, cardExpiryDateBlockPosition: Int): String {
      val textBlockStartPosition = max(cardNumberBlockPosition, cardExpiryDateBlockPosition)
      val searchBlocks = visionText.textBlocks.subList(textBlockStartPosition, min(visionText.textBlocks.size, textBlockStartPosition + 4))
      for (block in searchBlocks) {
        val cardHolder = holderNameRegex.find(block.text)?.value?.trim() ?: continue
        if (isValidName(cardHolder)) return cardHolder
      }
      return ""
    }

    private fun isValidName(cardHolder: String): Boolean {
      if (cardHolder.length < 3) return false;
      if (CardIssuerScanUtil.ISSUER_LIST.contains(cardHolder.toLowerCase(Locale.getDefault()))) return false
      return !blackListedWords.contains(cardHolder.toLowerCase(Locale.getDefault()))
    }
  }
}