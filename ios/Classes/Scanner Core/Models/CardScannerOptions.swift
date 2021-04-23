//
//  CardScanOptions.swift
//  Card Scanner
//
//  Created by Mohammed Sadiq on 05/07/20.
//  Copyright © 2020 MZaink. All rights reserved.
//

import Foundation

public class CardScannerOptions {
    var scanCardHolderName: Bool = false
    var scanExpiryDate: Bool = false
    var initialScansToDrop: Int = 1
    var validCardsToScanBeforeFinishingScan: Int = 6
    var cardHolderNameBlackListedWords: [String] = []
    var considerPastDatesInExpiryDateScan: Bool = false
    var maxCardHolderNameLength: Int = 26
    var enableLuhnCheck: Bool = true
    var cardScannerTimeOut: Int = 0
    var enableDebugLogs: Bool = false
    var possibleCardHolderNamePositions: [String] = [CardHolderNameScanPositions.belowCardNumber.rawValue]
    var prompt: String = "Scan the back of your Credit Card to proceed"
    var cameraOrientation: CameraOrientation = .portrait
    
    init(
        scanCardHolderName: Bool = false,
        scanExpiryDate: Bool = false,
        initialScansToDrop: Int,
        validCardsToScanBeforeFinishingScan: Int,
        cardHolderNameBlackListedWords: [String],
        considerPastDatesInExpiryDateScan: Bool,
        maxCardHolderNameLength: Int,
        enableLuhnCheck: Bool,
        cardScannerTimeOut: Int,
        enableDebugLogs: Bool,
        possibleCardHolderNamePositions: [String]
    ) {
        self.scanCardHolderName = scanCardHolderName
        self.scanExpiryDate = scanExpiryDate
        self.initialScansToDrop = initialScansToDrop
        self.validCardsToScanBeforeFinishingScan = validCardsToScanBeforeFinishingScan
        self.cardHolderNameBlackListedWords = cardHolderNameBlackListedWords
        self.considerPastDatesInExpiryDateScan = considerPastDatesInExpiryDateScan
        self.maxCardHolderNameLength = maxCardHolderNameLength
        self.enableLuhnCheck = enableLuhnCheck
        self.cardScannerTimeOut = cardScannerTimeOut
        self.enableDebugLogs = enableDebugLogs
        self.possibleCardHolderNamePositions = possibleCardHolderNamePositions
    }
    
    init(from options: [String: String]?) {
        if let options = options {
            if let scanCardHolderName = options["scanCardHolderName"] {
                self.scanCardHolderName = (scanCardHolderName == "true")
            }
            
            if let scanExpirtyDate = options["scanExpiryDate"] {
                self.scanExpiryDate = (scanExpirtyDate == "true")
            }
            
            if let initialScansToDrop = options["initialScansToDrop"] {
                self.initialScansToDrop = Int(initialScansToDrop) ?? 1
            }
            
            if let validCardsToScanBeforeFinishingScan = options["validCardsToScanBeforeFinishingScan"] {
                self.validCardsToScanBeforeFinishingScan = Int(validCardsToScanBeforeFinishingScan) ?? 6
            }
            
            if let cardHolderNameBlackListedWords = options["cardHolderNameBlackListedWords"] {
                self.cardHolderNameBlackListedWords = cardHolderNameBlackListedWords.components(separatedBy: ",")
            }
            
            if let considerPastDatesInExpiryDateScan = options["considerPastDatesInExpiryDateScan"] {
                self.considerPastDatesInExpiryDateScan = (considerPastDatesInExpiryDateScan == "true")
            }
            
            if let maxCardHolderNameLength = options["maxCardHolderNameLength"] {
                self.maxCardHolderNameLength = Int(maxCardHolderNameLength) ?? 26
            }
            
            if let enableLuhnCheck = options["enableLuhnCheck"] {
                self.enableLuhnCheck = (enableLuhnCheck == "true")
            }
            
            if let cardScannerTimeOut = options["cardScannerTimeOut"] {
                self.cardScannerTimeOut = Int(cardScannerTimeOut) ?? 0
            }
            
            if let enableDebugLogs = options["enableDebugLogs"] {
                self.enableDebugLogs = (enableDebugLogs == "true")
            }
            
            if let possibleCardHolderNamePositions = options["possibleCardHolderNamePositions"] {
                self.possibleCardHolderNamePositions = possibleCardHolderNamePositions.components(separatedBy: ",")
            }
            
            if let prompt = options["prompt"] {
                self.prompt = prompt
            }
            
            if let cameraOrientation = options["cameraOrientation"], let orientation =  CameraOrientation(rawValue: cameraOrientation) {
                self.cameraOrientation = orientation
            }
        }
    }
}

enum CameraOrientation: String {
    case portrait
    case landscape
}
