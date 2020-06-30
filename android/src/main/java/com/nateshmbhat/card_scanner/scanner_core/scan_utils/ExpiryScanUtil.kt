package com.nateshmbhat.card_scanner.scanner_core.scan_utils

import com.google.mlkit.vision.text.Text
import kotlin.math.min

class ExpiryScanUtil {
  companion object {
    class CardDateItem(val expiryDate: String, val dateBlockPosition: Int) {}

    private val dateRegex = "(0[1-9]|1[0-2])/([0-9]{2})"
    private val cardNumberRegex: Regex = Regex("\\b(($dateRegex)|($dateRegex.*?$dateRegex))\\s*$", RegexOption.MULTILINE)


    ///Extract both valid from and valid to (expiry) dates
    fun extractValidityDates(textItem: Text, cardNumberBlockPosition: Int): CardDateItem {
      val expiryBlockPosition: Int
      val blocks = textItem.textBlocks.subList(cardNumberBlockPosition, min(textItem.textBlocks.size, cardNumberBlockPosition + 3))
      for (index in blocks.indices) {
        val block = blocks[index]
        val datesLine = cardNumberRegex.find(block.text)?.value ?: continue
        val dateStrings = Regex(dateRegex).findAll(datesLine).map { match -> match.value.trim() }.toList()
        expiryBlockPosition = index

        val expiryDate: String
        expiryDate = if (dateStrings.size > 1) {
          dateStrings[1] // valid from date string case handled here
        } else {
          dateStrings[0]
        }
        return CardDateItem(expiryDate, expiryBlockPosition)
      }
      return CardDateItem("", -1)
    }
  }
}