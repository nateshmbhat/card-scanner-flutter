//
//  CardScanProcessorCore.swift
//  Card ScanProcessor
//
//  Created by Mohammed Sadiq on 05/07/20.
//  Copyright © 2020 MZaink. All rights reserved.
//

import Foundation
import MLKitTextRecognition

public protocol ScanProcessorDelegate {
    func scanProcessor(_ scanProcessor: ScanProcessor, didFinishScanning card: Card)
}

public class ScanProcessor {
    var scanProcessorDelegate: ScanProcessorDelegate?
    var card: Card = Card(number: "", name: "", expiryDate: "")
    
    var datesCollectedSoFar: [String] = []
    var validScansSoFar: Int = 0
    var cardScanned: Bool = false
    
    var cardScanOptions: CardScanOptions
    
    init(withOptions cardScanOptions: CardScanOptions) {
        self.cardScanOptions = cardScanOptions
    }
    
    func startScanning() {
        let cameraViewController: CameraViewController = CameraViewController()
        cameraViewController.cameraDelegate = self
        UIApplication.shared.keyWindow?.rootViewController?.present(cameraViewController, animated: true, completion: nil)
    }
}

// MARK:- CameraDelegate
extension ScanProcessor: CameraDelegate {
    public func camera(_ camera: CameraViewController, didScan scanResult: Text) {
        guard let cardNumberBlock: TextBlock = extractCardNumber(from: scanResult), let startingPointForFurtherExtractions = scanResult.blocks.firstIndex(of: cardNumberBlock) else {
            return
        }
        
        card.number = cardNumberBlock.text.replacingOccurrences(of: "\\s", with: "", options: [.regularExpression])
        
        updateValidScansCount()
        
        if cardScanOptions.scanCardHolderName == true{
            if let cardHolderName: String = extractCardHolderName(from: scanResult, with: startingPointForFurtherExtractions) {
                card.name = cardHolderName
            }
        }
        
        if cardScanOptions.scanExpirtyDate == true {
            if let expiryDate: String = extractExpiryDate(from: scanResult) {
                card.expiryDate = expiryDate
            }
        }
        
        if noMoreFurtherScanningIsRequired() {
            // Delegate back to Flutter from here
            cardScanned = true
            scanProcessorDelegate?.scanProcessor(self, didFinishScanning: card)
            NSLog(String(describing: card))
            camera.stopScanning()
        }
    }
    
    public func cameraDidStopScanning(_ camera: CameraViewController) {
        if (!cardScanned) {
            // Delegate back to Flutter from here
            scanProcessorDelegate?.scanProcessor(self, didFinishScanning: card)
            NSLog(String(describing: card))
        }
    }
}

// MARK:- Utilities for extraction
extension ScanProcessor {
    static let maxValidScansLimit: Int = 8
    
    static let blackListedWords: [String] = ["valid", "through", "thru", "valid thru", "valid through", "from", "valid from", "international", "rupay", "debit", "platinum", "axis", "sbi", "axis bank", "credit", "card", "titanium", "bank", "global", "state bank", "of", "the", "india", "valid only", "classic", "gold", "sbi card", "visa classic", "visa signature", "visa gold", "electronic", "use only", "electronic use only", "only", "use", "visa", "a", "debit card", "credit card", "more benefits", "rak bank", "rakbank", "scan to discover", "customer care", "customer", "care", "match", "check", "check out", "manager", "gold", "uae", "india", "debit & prepaid", "ubi", "united bandk of india", "mastercard", "mastereo", "mastro", "signature", "corporate card", "corporate", "prepaid gift card", "gift", "gift plus", "prepaid", "we understand your world", "world", "understand", "valid only in india", "regalia", "easyshop", "millennia", "infinite", "cardholder", "Union Bank", "Good people to bank with", "valid thru valid from", "validthruvalid from", "valid thruvalid from", "valid from valid thru", "valid fromvalid thru", "valid thruvalid from"]
    
    func extractCardNumber(from scan: Text) -> TextBlock? {
        guard let safeCardNumberRegEx = try? NSRegularExpression(pattern: "^(\\s*\\d\\s*){15,16}$", options: [.anchorsMatchLines]) else {
            return nil
        }
        
        for block in scan.blocks {
            for line in block.lines {
                if let _ = safeCardNumberRegEx.firstMatch(in: line.text, range: NSRange(line.text.startIndex..., in: line.text)) {
                    let cardNumber: String = line.text.replacingOccurrences(of: "\\s", with: "", options: [.regularExpression])
                    if cardNumber.isLuhnValid {
                        return block
                    }
                }
            }
        }
        
        return nil
    }
    
    func extractCardHolderName(from scan: Text, with startingPoint: Int) -> String? {
        guard let safeCardHolderNameRegEx = try? NSRegularExpression(pattern: "^ *(([A-Z.]+ {0,2}){1,6}) *$", options: [.anchorsMatchLines]) else {
            return nil
        }
        
        let blocksToBeSearched: [TextBlock] = [TextBlock](scan.blocks[startingPoint..<min(startingPoint + 5, scan.blocks.count)])
        
        for block in blocksToBeSearched {
            for line in block.lines {
                if safeCardHolderNameRegEx.firstMatch(in: line.text, range: NSRange(line.text.startIndex..., in: line.text)) != nil {
                    let potentiallyAName: String = line.text.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if potentiallyAName.isAValidName {
                        return potentiallyAName
                    }
                }
            }
        }
        
        return nil
    }
    
    func extractExpiryDate(from scan: Text) -> String? {
        guard let datesRegEx = try? NSRegularExpression(pattern: "(0[1-9]|1[0-2])/(\\d{2})") else {
            return nil
        }
        
        let matchedDates = datesRegEx.matches(in: scan.text, options: [], range: NSRange(location: 0, length: scan.text.utf16.count))
        
        for matchedDate in matchedDates {
            let date = String(scan.text[Range(matchedDate.range, in: scan.text)!])
            datesCollectedSoFar.append(date)
        }
        
        if datesCollectedSoFar.isEmpty {
            return nil
        }
        
        var latestDateCollectedSoFar = ""
        var latestYear = 0
        
        for date in datesCollectedSoFar {
            if let yearFromDate = date.split(separator: "/").last, let year: Int = Int(String(yearFromDate)) {
                if year > latestYear {
                    latestYear = year
                    latestDateCollectedSoFar = date
                }
            }
        }
        
        return latestDateCollectedSoFar
    }
    
    func updateValidScansCount() {
        validScansSoFar += 1
    }
    
    func noMoreFurtherScanningIsRequired() -> Bool {
        return maxValidScansLimitReached() || enoughDetailsHaveBeenGathered()
    }
    
    func maxValidScansLimitReached() -> Bool {
        return validScansSoFar == ScanProcessor.maxValidScansLimit
    }
    
    func enoughDetailsHaveBeenGathered() -> Bool {
        var cardHasEnoughDetails: Bool = card.number.isNotEmpty
        
        if (cardScanOptions.scanCardHolderName) {
            cardHasEnoughDetails = cardHasEnoughDetails && card.name.isNotEmpty
        }
        
        if (cardScanOptions.scanExpirtyDate) {
            cardHasEnoughDetails = cardHasEnoughDetails && card.expiryDate.isNotEmpty
        }
        
        return cardHasEnoughDetails
    }
}

extension String {
    var isLuhnValid: Bool {
        var luhn_sum = 0
        var digit_count = 0
        
        let reversedCardNumber = String(self.reversed())
        for c in reversedCardNumber {
            if let this_digit = Int(String(c)) {
                digit_count += 1
                //double every even digit
                if digit_count % 2 == 0{
                    if this_digit * 2 > 9 {
                        luhn_sum = luhn_sum + this_digit * 2 - 9
                    } else {
                        luhn_sum = luhn_sum + this_digit * 2
                    }
                } else {
                    luhn_sum = luhn_sum + this_digit
                }
            }
        }
        
        return luhn_sum % 10 == 0
    }
    
    var isAValidName: Bool {
        return !ScanProcessor.blackListedWords.contains(self.lowercased()) && self.count > 3
    }
    
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
}

