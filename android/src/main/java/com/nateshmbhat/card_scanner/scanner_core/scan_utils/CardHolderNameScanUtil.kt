package com.nateshmbhat.card_scanner.scanner_core.scan_utils

import com.google.mlkit.vision.text.Text
import java.util.*
import kotlin.math.max
import kotlin.math.min

//@author nateshmbhat created on 29,June,2020
class CardHolderNameScanUtil {
  companion object {
    private val holderNameRegex = Regex("^\\s*(([A-Z.]+\\s{0,2}){1,6})\\s*$", RegexOption.MULTILINE)
    private val blackListedWords = arrayOf("valid", "through", "thru", "valid thru", "valid through", "from", "valid from", "international"
    )

    fun extractCardHolderName(text: Text, cardNumberBlockPosition: Int, cardExpiryDateBlockPosition: Int): String {
      val startBlock = max(cardNumberBlockPosition,cardExpiryDateBlockPosition)
      val searchBlocks = text.textBlocks.subList(startBlock, min(text.textBlocks.size, startBlock + 2))
      for (block in searchBlocks) {
        val cardHolder = holderNameRegex.find(block.text)?.value?.trim() ?: continue
        if (isValidName(cardHolder)) return cardHolder
      }
      return ""
    }

    private fun isValidName(cardHolder: String): Boolean {
      if (CardIssuerScanUtil.ISSUER_LIST.contains(cardHolder.trim().toLowerCase(Locale.getDefault()))) return false
      return !blackListedWords.contains (cardHolder.trim().toLowerCase(Locale.getDefault()))
    }
  }
}