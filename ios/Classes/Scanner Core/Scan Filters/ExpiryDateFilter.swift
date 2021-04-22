//
//  ExpiryDateFilter.swift
//  card_scanner
//
//  Created by Abhinav Kumar on 12/02/21.
//

import Foundation
import MLKitTextRecognition

class ExpiryDateFilter : ScanFilter {
    var visionText: Text
    var scannerOptions: CardScannerOptions
    private var cardNumberScanResult: CardNumberScanResult
    
    private var expiryDateRegex: NSRegularExpression = try! NSRegularExpression(pattern: CardScannerRegexps.expiryDateRegex, options: .anchorsMatchLines)
    
    var maxBlocksBelowCardNumberToSearchForExpiryDate = 4
    var expiryDateFormat = "MM/yy"
    
    init(visionText: Text, scannerOptions: CardScannerOptions, cardNumberScanResult: CardNumberScanResult) {
        self.visionText = visionText
        self.scannerOptions = scannerOptions
        self.cardNumberScanResult = cardNumberScanResult
    }
    
    func filter() -> ScanFilterResult? {
        guard cardNumberScanResult.cardNumber.isNotEmpty else { return nil }
        guard scannerOptions.scanExpiryDate else { return nil }
        
        var scanResults: [ExpiryDateScanResult] = []
        
        let maxTextBlockIndexToSearchExpiryDate = min(
            cardNumberScanResult.textBlockIndex + maxBlocksBelowCardNumberToSearchForExpiryDate,
            visionText.blocks.count - 1
        )
        
        for index in cardNumberScanResult.textBlockIndex...maxTextBlockIndexToSearchExpiryDate {
            let block = visionText.blocks[index]
            for line in block.lines {
                let potentialDate = line.text
                let nsString = potentialDate as NSString
                if (!(expiryDateRegex.numberOfMatches(in: line.text, range: NSRange(location: 0, length: line.text.count)) > 0)) {
                    continue
                }
                
                for match in expiryDateRegex.matches(in: potentialDate, range: NSRange(location: 0, length: potentialDate.count)) {
                    
                    let expiryDate = nsString.substring(with: match.range).trimmingCharacters(in: .whitespacesAndNewlines)
                    if (isValidExpiryDate(expiryDate: expiryDate)) {
                        scanResults.append(
                            ExpiryDateScanResult(
                                visionText: visionText,
                                textBlockIndex: index,
                                textBlock: block,
                                expiryDate: expiryDate
                            )
                        )
                    }
                }
                
                if (scanResults.count > 2) { break }
            }
        }
        
        if (scanResults.isEmpty) { return nil }
        return chooseMostRecentDate(expiryDateResults: scanResults)
    }
    
    func chooseMostRecentDate(expiryDateResults: [ExpiryDateScanResult]) -> ExpiryDateScanResult {
        if (expiryDateResults.count == 1) { return expiryDateResults[0] }
        var mostRecentDateResult = expiryDateResults[0]
        for (_, expiryDateResult) in expiryDateResults[1..<expiryDateResults.count].enumerated(){
            let currentMostRecent = parseExpiryDate(expiryDate: mostRecentDateResult.expiryDate)
            let newDate = parseExpiryDate(expiryDate: expiryDateResult.expiryDate)
            if (newDate > currentMostRecent) {
                mostRecentDateResult = expiryDateResult
            }
        }
        return mostRecentDateResult
    }
    
    func isValidExpiryDate(expiryDate: String) -> Bool{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = expiryDateFormat
        
        guard let expiryDateTime = dateFormatter.date(from: expiryDate) else { return false }
        let currentDateTime = Date()
        if (scannerOptions.considerPastDatesInExpiryDateScan) {
            return true
        } else {
            return expiryDateTime > currentDateTime
        }
    }
    
    func parseExpiryDate(expiryDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = expiryDateFormat
        let date = dateFormatter.date(from: expiryDate)!
        return date
    }
}
