package com.nateshmbhat.card_scanner.logger

import android.util.Log
import com.nateshmbhat.card_scanner.scanner_core.models.CardScannerOptions

fun debugLog(message: String, scannerOptions: CardScannerOptions, tag: String = "card_scanner_debug_log") {
  if (scannerOptions.enableDebugLogs) {
    Log.d(tag, message)
  }
}