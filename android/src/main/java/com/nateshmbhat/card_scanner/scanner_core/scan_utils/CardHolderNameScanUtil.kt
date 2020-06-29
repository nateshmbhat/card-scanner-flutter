package com.nateshmbhat.card_scanner.scanner_core.scan_utils

import com.google.mlkit.vision.text.Text
import kotlin.math.min

//@author nateshmbhat created on 29,June,2020
class CardHolderNameScanUtil {
  companion object {
    private val holderNameRegex = Regex("^\\s*(([A-Z.]+\\s{0,2}){1,6})\\s*$", RegexOption.MULTILINE)

    fun extractCardHolderName(text: Text, cardNumberBlockPosition: Int, cardExpiryDateBlockPosition: Int): String {
      val startBlock = if (cardExpiryDateBlockPosition == -1) cardNumberBlockPosition else cardExpiryDateBlockPosition
      val subBlocks = text.textBlocks.subList(startBlock, min(text.textBlocks.size, startBlock + 2))
      for (block in subBlocks) {
        return holderNameRegex.find(block.text)?.value ?: continue
      }
      return String()
    }
  }
}