//
//  CardHolderNameFilter.swift
//  card_scanner
//
//  Created by Abhinav Kumar on 12/02/21.
//

import Foundation
import MLKitTextRecognition

class CardHolderNameFilter : ScanFilter {
    private var cardHolderRegex: NSRegularExpression =  try! NSRegularExpression(pattern: CardScannerRegexps.cardHolderName, options: .anchorsMatchLines)
    var maxBlocksBelowCardNumberToSearchForName = 4
    
    func filter() -> ScanFilterResult? {
        guard scannerOptions.scanCardHolderName else { return nil }
        guard cardNumberScanResult.cardNumber.isNotEmpty else { return nil }
        
        // Search from card number block and below [_maxBlocksBelowCardNumberToSearchForName] blocks
        let minTextBlockIndexToSearchName = max(cardNumberScanResult.textBlockIndex - (scannerOptions.possibleCardHolderNamePositions.contains(CardHolderNameScanPositions.aboveCardNumber.rawValue) ? 1 : 0) , 0)
        
        let maxTextBlockIndexToSearchName =
            min(cardNumberScanResult.textBlockIndex +
                    (scannerOptions.possibleCardHolderNamePositions.contains(CardHolderNameScanPositions.belowCardNumber.rawValue)  ? maxBlocksBelowCardNumberToSearchForName : 0), visionText.blocks.count - 1)
        
        for index in minTextBlockIndexToSearchName...maxTextBlockIndexToSearchName {
            let block = visionText.blocks[index]
            let transformedBlockText = transformBlockText(blockText: block.text)
            let nsString = transformedBlockText as NSString
            if (!(cardHolderRegex.numberOfMatches(in: transformedBlockText, range: NSRange(location: 0, length: transformedBlockText.count)) > 0)) {
                continue
            }
            
            let firstMatch = cardHolderRegex.firstMatch(in: transformedBlockText, range: NSRange(location: 0, length: transformedBlockText.count))
            
            let cardHolderName = nsString.substring(with: firstMatch?.range ?? NSRange(location: 0, length: 0)).trimmingCharacters(in: .whitespacesAndNewlines) as String
            
            
            if (isValidName(cardHolder: cardHolderName)) {
                return CardHolderNameScanResult(
                    visionText: visionText, textBlockIndex: index, textBlock: block, cardHolderName: cardHolderName)
            }
        }
        return nil
    }
    
    var visionText: Text
    var scannerOptions: CardScannerOptions
    private var cardNumberScanResult: CardNumberScanResult
    
    init(visionText: Text, scannerOptions: CardScannerOptions, cardNumberScanResult: CardNumberScanResult) {
        self.visionText = visionText
        self.scannerOptions = scannerOptions
        self.cardNumberScanResult = cardNumberScanResult
    }
    
    func isValidName(cardHolder: String) -> Bool {
        if (cardHolder.count < 3 || cardHolder.count > scannerOptions.maxCardHolderNameLength) {
            debugLog("maxCardHolderName length = \(scannerOptions.maxCardHolderNameLength)", scannerOptions: scannerOptions)
            return false
        }
        
        if (cardHolder.hasPrefix("valid from") || cardHolder.hasPrefix("valid thru")) { return false }
        if (cardHolder.hasSuffix("valid from") || cardHolder.hasSuffix("valid thru")) { return false }
        var defaultBlackListedWords = CardHolderNameConstants.defaultBlackListedWords
        defaultBlackListedWords.append(contentsOf: scannerOptions.cardHolderNameBlackListedWords)
        
        if (defaultBlackListedWords.contains(cardHolder.lowercased())) {
            return false
        }
        return true
    }
    
    func transformBlockText(blockText: String) -> String {
        return blockText.replacingOccurrences(of: "c", with: "C")
            .replacingOccurrences(of: "o", with: "O")
            .replacingOccurrences(of: "p", with: "P")
            .replacingOccurrences(of: "v", with: "V")
            .replacingOccurrences(of: "w", with: "W")
    }
}

