//
//  CardDetailsScanOptimizer.swift
//  card_scanner
//
//  Created by Abhinav Kumar on 12/02/21.
//

import Foundation

class CardDetailsScanOptimizer {
    private var scannerOptions: CardScannerOptions
    
    private var cardNumberFrequencyTable: [String: Int] = [:]
    private var expiryDateFrequencyTable: [String: Int] = [:]
    private var cardHolderNameFrequencyTable: [String: Int] = [:]
    private var optimalCardNumber: String? = nil
    private var optimalExpiryDate: String? = nil
    private var optimalCardHolderName: String? = nil
    private var numberOfCardDetailsProcessed: Int = 0
    
    init(scannerOptions: CardScannerOptions) {
        self.scannerOptions = scannerOptions
    }
    
    func processCardDetails(cardDetails: CardDetails) {
        guard cardDetails.cardNumber.isNotEmpty else { return }
        
        numberOfCardDetailsProcessed += 1
        
        // drop first few scan results which have more chances of errors
        guard numberOfCardDetailsProcessed > scannerOptions.initialScansToDrop else { return }
        
        handle(cardNumber: cardDetails.cardNumber)
        handle(expiryDate: cardDetails.expiryDate)
        handle(cardHolderName: cardDetails.cardHolderName)
        
        updateOptimalData()
        printStatus()
    }
    
    func isReadyToFinishScan() -> Bool {
        return numberOfCardDetailsProcessed > scannerOptions.validCardsToScanBeforeFinishingScan
    }
    
    private func updateOptimalData() {
        optimalCardNumber = cardNumberFrequencyTable.mostFrequentData
        optimalExpiryDate = expiryDateFrequencyTable.mostFrequentData
        optimalCardHolderName = cardHolderNameFrequencyTable.mostFrequentData
    }
    
    private func handle(cardNumber: String?) {
        guard let cardNumber = cardNumber, cardNumber.isNotEmpty else { return }
        
        let sanitizedCardNumber = cardNumber.sanitized.cardNumberSized
        
        cardNumberFrequencyTable[sanitizedCardNumber] = (cardNumberFrequencyTable[sanitizedCardNumber] ?? 0) + 1
    }
    
    private func handle(expiryDate: String?) {
        guard let expiryDate = expiryDate, expiryDate.isNotEmpty else { return }
    
        expiryDateFrequencyTable[expiryDate] = (expiryDateFrequencyTable[expiryDate] ?? 0) + 1
    }
    
    private func handle(cardHolderName: String?) {
        guard let cardHolderName = cardHolderName, cardHolderName.isNotEmpty else { return }
        
        cardHolderNameFrequencyTable[cardHolderName] = (cardHolderNameFrequencyTable[cardHolderName] ?? 0) + 1
    }
    
    func printStatus() {
        debugLog("Card Number : \(optimalCardNumber ?? "Not Yet Scanner")", scannerOptions: scannerOptions)
        debugLog("Card Number Freq : \(cardNumberFrequencyTable[optimalCardNumber ?? ""] ?? 0)", scannerOptions: scannerOptions)
        debugLog("Expiry Date =  \(optimalExpiryDate ?? "Not Yet Scanner")", scannerOptions: scannerOptions)
        debugLog("Expiry Date Freq : \(expiryDateFrequencyTable[optimalExpiryDate ?? ""] ?? 0)", scannerOptions: scannerOptions)
        debugLog("Card Holder Name :  \(optimalCardHolderName ?? "Not Yet Scanner")", scannerOptions: scannerOptions)
        debugLog("Card Holder Name Freq :  \(cardHolderNameFrequencyTable[optimalCardHolderName ?? ""] ?? 0)", scannerOptions: scannerOptions)
        debugLog("Scanner Options = \(scannerOptions)", scannerOptions: scannerOptions)
    }
    
    func getOptimalCardDetails() -> CardDetails? {
        guard let optimalCardNumber = optimalCardNumber else {
            return nil
        }
        
        printStatus()
        
        return CardDetails(
            cardNumber: optimalCardNumber,
            cardHolderName: optimalCardHolderName ?? "",
            expiryDate: optimalExpiryDate ?? ""
        )
    }
}
