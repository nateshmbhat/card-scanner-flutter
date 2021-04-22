package com.nateshmbhat.card_scanner.scanner_core.optimizer

import android.util.Log
import com.nateshmbhat.card_scanner.logger.debugLog
import com.nateshmbhat.card_scanner.scanner_core.models.CardDetails
import com.nateshmbhat.card_scanner.scanner_core.models.CardScannerOptions

class CardDetailsScanOptimizer(private val _scannerOptions: CardScannerOptions) {
  private val _expiryDateFrequency: MutableMap<String, Int> = mutableMapOf()
  private val _cardNumberFrequency: MutableMap<String, Int> = mutableMapOf()
  private val _cardHolderNameFrequency: MutableMap<String, Int> = mutableMapOf()
  private var _optimalCardNumber: String? = null
  private var _optimalExpiryDate: String? = null
  private var _optimalCardHolderName: String? = null
  private var numberOfCardDetailsProcessed: Int = 0;

  fun processCardDetails(cardDetails: CardDetails) {
    if (cardDetails.cardNumber.isEmpty()) return;
    val cardNumber = cardDetails.cardNumber
    val expiryDate = cardDetails.expiryDate
    val cardHolder = cardDetails.cardHolderName;
    numberOfCardDetailsProcessed++;

    ///drop first few scan results which have more chances of errors
    if (numberOfCardDetailsProcessed <= _scannerOptions.initialScansToDrop) return;
    _handleCardNumber(cardNumber);
    _handleExpiryDateNumber(expiryDate);
    _handleCardHolderName(cardHolder);
    _updateOptimalData();
  }

  fun isReadyToFinishScan(): Boolean {
    return numberOfCardDetailsProcessed > _scannerOptions.validCardsToScanBeforeFinishingScan;
  }

  private fun _updateOptimalData() {
    _optimalCardNumber = _getMostFrequentData(_cardNumberFrequency);
    _optimalExpiryDate = _getMostFrequentData(_expiryDateFrequency);
    _optimalCardHolderName = _getMostFrequentData(_cardHolderNameFrequency);
  }

  private fun _handleCardNumber(cardNumber: String) {
    if (cardNumber.isEmpty()) return;
    _cardNumberFrequency[cardNumber] = (_cardNumberFrequency[cardNumber] ?: 0) + 1
  }

  private fun _handleExpiryDateNumber(expiryDate: String) {
    if (expiryDate.isEmpty()) return;
    _expiryDateFrequency[expiryDate] = (_expiryDateFrequency[expiryDate] ?: 0) + 1
  }

  private fun _handleCardHolderName(cardHolderName: String) {
    if (cardHolderName.isEmpty()) return;
    _cardHolderNameFrequency[cardHolderName] = (_cardHolderNameFrequency[cardHolderName] ?: 0) + 1
  }

  private fun _getMostFrequentData(frequencyMap: MutableMap<String, Int>): String? {
    var mostFrequentEntry: Map.Entry<String, Int>? = null
    for (entry in frequencyMap.entries) {
      if (mostFrequentEntry == null || entry.value >= mostFrequentEntry.value) {
        mostFrequentEntry = entry;
      }
    }
    return mostFrequentEntry?.key;
  }

  fun printStatus() {
    debugLog(" card number : " + _cardNumberFrequency[_optimalCardNumber
            ?: ""] + " , expiry = " + _expiryDateFrequency[_optimalExpiryDate
            ?: ""] + " , holder name = " + _cardHolderNameFrequency[_optimalCardHolderName], _scannerOptions);
  }

  fun getOptimalCardDetails(): CardDetails? {
    if (_optimalCardNumber == null) return null;
    printStatus()
    return CardDetails(cardNumber = _optimalCardNumber!!, cardHolderName = _optimalCardHolderName
            ?: "", expiryDate = _optimalExpiryDate ?: "");
  }
}