package com.basys.card_scanner.scanner_core.optimizer

import com.basys.card_scanner.logger.debugLog
import com.basys.card_scanner.scanner_core.models.CardDetails
import com.basys.card_scanner.scanner_core.models.CardScannerOptions

class CardDetailsScanOptimizer(private val _scannerOptions: CardScannerOptions) {
  private val _expiryDateFrequency: MutableMap<String, Int> = mutableMapOf()
  private val _cardNumberFrequency: MutableMap<String, Int> = mutableMapOf()
  private val _cardHolderNameFrequency: MutableMap<String, Int> = mutableMapOf()
  private var _optimalCardNumber: String? = null
  private var _optimalExpiryDate: String? = null
  private var _optimalCardHolderName: String? = null
  private var numberOfCardDetailsProcessed: Int = 0

  fun processCardDetails(cardDetails: CardDetails) {
    if (cardDetails.cardNumber.isEmpty()) return
    val cardNumber = cardDetails.cardNumber
    val expiryDate = cardDetails.expiryDate
    val cardHolder = cardDetails.cardHolderName
    numberOfCardDetailsProcessed++

    ///drop first few scan results which have more chances of errors
    if (numberOfCardDetailsProcessed <= _scannerOptions.initialScansToDrop) return
    handleCardNumber(cardNumber)
    handleExpiryDateNumber(expiryDate)
    handleCardHolderName(cardHolder)
    updateOptimalData()
  }

  fun isReadyToFinishScan(): Boolean {
    return numberOfCardDetailsProcessed > _scannerOptions.validCardsToScanBeforeFinishingScan
  }

  private fun updateOptimalData() {
    _optimalCardNumber = getMostFrequentData(_cardNumberFrequency)
    _optimalExpiryDate = getMostFrequentData(_expiryDateFrequency)
    _optimalCardHolderName = getMostFrequentData(_cardHolderNameFrequency)
  }

  private fun handleCardNumber(cardNumber: String) {
    if (cardNumber.isEmpty()) return
    _cardNumberFrequency[cardNumber] = (_cardNumberFrequency[cardNumber] ?: 0) + 1
  }

  private fun handleExpiryDateNumber(expiryDate: String) {
    if (expiryDate.isEmpty()) return
    _expiryDateFrequency[expiryDate] = (_expiryDateFrequency[expiryDate] ?: 0) + 1
  }

  private fun handleCardHolderName(cardHolderName: String) {
    if (cardHolderName.isEmpty()) return
    _cardHolderNameFrequency[cardHolderName] = (_cardHolderNameFrequency[cardHolderName] ?: 0) + 1
  }

  private fun getMostFrequentData(frequencyMap: MutableMap<String, Int>): String? {
    var mostFrequentEntry: Map.Entry<String, Int>? = null
    for (entry in frequencyMap.entries) {
      if (mostFrequentEntry == null || entry.value >= mostFrequentEntry.value) {
        mostFrequentEntry = entry
      }
    }
    return mostFrequentEntry?.key
  }

  private fun printStatus() {
    debugLog(" card number : " + _cardNumberFrequency[_optimalCardNumber
            ?: ""] + " , expiry = " + _expiryDateFrequency[_optimalExpiryDate
            ?: ""] + " , holder name = " + _cardHolderNameFrequency[_optimalCardHolderName], _scannerOptions)
  }

  fun getOptimalCardDetails(): CardDetails? {
    if (_optimalCardNumber == null) return null
    printStatus()
    return CardDetails(cardNumber = _optimalCardNumber!!, cardHolderName = _optimalCardHolderName
            ?: "", expiryDate = _optimalExpiryDate ?: "")
  }
}