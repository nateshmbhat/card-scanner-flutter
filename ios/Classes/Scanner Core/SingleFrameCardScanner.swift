//
//  SingleFrameCardScanner.swift
//  card_scanner
//
//  Created by Abhinav Kumar on 11/02/21.
//

import Foundation
import MLKitTextRecognition

class SingleFrameCardScanner {
    var cardScanOptions: CardScannerOptions
    
    init(withOptions cardScanOptions: CardScannerOptions) {
        self.cardScanOptions = cardScanOptions
    }
    
    func scanSingleFrame(visionText: Text) -> CardDetails? {
        guard let optionalCardNumberResult = CardNumberFilter(
            visionText: visionText,
            scannerOptions: cardScanOptions
        ).filter() as? CardNumberScanResult? else {
            debugLog("No card number found yet", scannerOptions: cardScanOptions)
            return nil
        }
        
        guard let cardNumberResult = optionalCardNumberResult else {
            return nil
        }
        
        guard cardNumberResult.cardNumber.isNotEmpty else {
            return nil
        }
        
        let cardExpiryResult: ExpiryDateScanResult? = ExpiryDateFilter(
            visionText: visionText,
            scannerOptions: cardScanOptions,
            cardNumberScanResult: cardNumberResult
        ).filter() as? ExpiryDateScanResult
        
        let cardHolderResult: CardHolderNameScanResult? = CardHolderNameFilter(
            visionText: visionText,
            scannerOptions: cardScanOptions,
            cardNumberScanResult: cardNumberResult
        ).filter() as? CardHolderNameScanResult
        
        return CardDetails(
            cardNumber: cardNumberResult.cardNumber,
            cardHolderName: cardHolderResult?.cardHolderName ?? "",
            expiryDate: cardExpiryResult?.expiryDate ?? ""
        )
    }
}
