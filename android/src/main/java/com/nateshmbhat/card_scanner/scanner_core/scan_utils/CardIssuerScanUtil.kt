package com.nateshmbhat.card_scanner.scanner_core.scan_utils

import com.google.mlkit.vision.text.Text
import kotlin.math.max
import kotlin.math.min

//@author nateshmbhat created on 29,June,2020
class CardIssuerScanUtil {
  companion object {
    public val ISSUER_LIST: Array<String> = arrayOf("visa", "mastercard", "jcb", "diners club", "american express",
            "discover")
    private val issuersRegex = Regex("\\b(visa|mastercard|jcb|diners club|american express|discover|master card)\\b", setOf(RegexOption.IGNORE_CASE,RegexOption.MULTILINE))

    fun extractCardIssuer(visionText: Text, cardNumberBlockPosition: Int): String {
      val startPosition = max(cardNumberBlockPosition - 2, 0)
      val searchBlocks = visionText.textBlocks.subList(startPosition, min(startPosition + 6, visionText.textBlocks.size))

      for (block in searchBlocks) {
        return issuersRegex.find(block.text)?.value?.trim() ?: continue
      }
      return ""
    }
  }
}