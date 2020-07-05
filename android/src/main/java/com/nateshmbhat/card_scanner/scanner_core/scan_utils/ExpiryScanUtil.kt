package com.nateshmbhat.card_scanner.scanner_core.scan_utils

import com.google.mlkit.vision.text.Text
import kotlin.math.min

class ExpiryScanUtil {
  companion object {
    class CardDateItem(val expiryDate: String, val dateBlockPosition: Int) {}

    private val dateRegex = "(0[1-9]|1[0-2])/([0-9]{2})"
    private val datesLines: Regex = Regex("\\b(($dateRegex)|($dateRegex.*?$dateRegex))\\s*$", RegexOption.MULTILINE)

    private fun getLatestDateFrom(newDates: List<String>, oldDate: String): String {
      var latestDate = "";
      for (date in newDates) {
        if (isDateGreaterThan(date, latestDate)) latestDate = date;
      }
      if (isDateGreaterThan(oldDate, latestDate)) {
        latestDate = oldDate;
      }
      return latestDate;
    }

    private fun isDateGreaterThan(date1: String, date2: String): Boolean {
      if (date2.isBlank()) return true;
      if (date1.isBlank()) return false;
      val newDateYear = date1.substring(date1.indexOf('/') + 1).toInt();
      val oldDateYear = date2.substring(date2.indexOf('/') + 1).toInt();
      return newDateYear > oldDateYear;
    }

    ///Extract both valid from and valid to (expiry) dates
    fun extractExpiryDate(textItem: Text, cardNumberBlockPosition: Int): CardDateItem {
      val blocks = textItem.textBlocks.subList(cardNumberBlockPosition, min(textItem.textBlocks.size, cardNumberBlockPosition + 4))
      var expiryDate = "";
      var expiryBlockPosition: Int = -1;

      for (index in blocks.indices) {
        val block = blocks[index]
        val datesLine = datesLines.find(block.text)?.value ?: continue
        val dateStrings = Regex(dateRegex).findAll(datesLine).map { match -> match.value.trim() }.toList()

        val newerDate = getLatestDateFrom(dateStrings, expiryDate);
        if (isDateGreaterThan(newerDate, expiryDate)) {
          expiryDate = newerDate;
          expiryBlockPosition = index
        }
      }
      return CardDateItem(expiryDate, expiryBlockPosition);
    }
  }
}