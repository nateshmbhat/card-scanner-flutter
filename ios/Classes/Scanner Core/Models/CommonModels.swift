//
//  CommonModels.swift
//  card_scanner
//
//  Created by Abhinav Kumar on 12/02/21.
//

import Foundation
import MLKitTextRecognition

class ScanFilterResult {
    private var visionText: Text
    private var textBlockIndex: Int
    private var textBlock: TextBlock
    private var data: ScanResultData
    
    init(visionText: Text, textBlockIndex: Int, textBlock: TextBlock, data: ScanResultData) {
        self.visionText = visionText
        self.textBlockIndex = textBlockIndex
        self.textBlock = textBlock
        self.data = data
    }
}

class ScanResultData {
    var data: String
    var elementType: CardElementType
    
    init(data: String, elementType: CardElementType) {
        self.data = data
        self.elementType = elementType
    }
}

enum CardElementType {
    case cardNumber
    case expiryDate
    case cardHolderName
}

class CardNumberScanResult : ScanFilterResult {
    var visionText: Text
    var textBlockIndex: Int
    var textBlock: TextBlock
    var cardNumber: String
    
    init(visionText: Text, textBlockIndex: Int, textBlock: TextBlock, cardNumber: String){
        self.visionText = visionText
        self.textBlockIndex = textBlockIndex
        self.textBlock = textBlock
        self.cardNumber = cardNumber
        
        super.init(
            visionText: visionText,
            textBlockIndex: textBlockIndex,
            textBlock: textBlock,
            data: ScanResultData(data: cardNumber, elementType: CardElementType.cardNumber)
        )
        
    }
}

class ExpiryDateScanResult : ScanFilterResult {
    var visionText: Text
    var textBlockIndex: Int
    var textBlock: TextBlock
    var expiryDate: String
    
    init(visionText: Text, textBlockIndex: Int, textBlock: TextBlock, expiryDate: String) {
        self.visionText = visionText
        self.textBlockIndex = textBlockIndex
        self.textBlock = textBlock
        self.expiryDate = expiryDate
        
        super.init(visionText: visionText, textBlockIndex: textBlockIndex, textBlock: textBlock, data: ScanResultData(data: expiryDate, elementType: CardElementType.expiryDate))
    }
}

class CardHolderNameScanResult : ScanFilterResult {
    var visionText: Text
    var textBlockIndex: Int
    var textBlock: TextBlock
    var cardHolderName: String
    
    init(visionText: Text, textBlockIndex: Int, textBlock: TextBlock, cardHolderName: String){
        self.visionText = visionText
        self.textBlockIndex = textBlockIndex
        self.textBlock = textBlock
        self.cardHolderName = cardHolderName
        
        super.init(visionText: visionText, textBlockIndex: textBlockIndex, textBlock: textBlock, data: ScanResultData(data: cardHolderName, elementType: CardElementType.cardHolderName))
    }
}

protocol ScanFilter {
    func filter() -> ScanFilterResult?
}

enum CardHolderNameScanPositions: String {
    case belowCardNumber = "belowCardNumber"
    case aboveCardNumber = "aboveCardNumber"
    
    init?(value: String) {
        switch value {
        case "belowCardNumber":
            self = .belowCardNumber
        case "aboveCardNumber":
            self = .aboveCardNumber
        default:
            return nil
        }
    }
}

extension String {
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    var sanitized: String {
        let newLineRemoved = replacingOccurrences(of: "\n", with: "")
        let newLineAndSpacesRemoved = newLineRemoved.replacingOccurrences(of: " ", with: "")
        return newLineAndSpacesRemoved
    }
    
    var cardNumberSized: String {
        return ((self as NSString).substring(to: count >= 16 ? 16 : count) as String)
    }
}


extension Dictionary where Key == String, Value == Int {
    var mostFrequentData: String? {
        return self.sorted { (first, second) -> Bool in
            first.value > second.value
        }.first?.key
    }
}
