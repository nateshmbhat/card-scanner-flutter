//
//  CardDetails.swift
//  card_scanner
//
//  Created by Abhinav Kumar on 12/02/21.
//

import Foundation

public class CardDetails: CustomStringConvertible {
    var cardNumber: String = ""
    var cardHolderName: String = ""
    var expiryDate: String = ""
    
    init(cardNumber: String = "", cardHolderName: String = "", expiryDate: String = "") {
        self.cardNumber = cardNumber
        self.cardHolderName = cardHolderName
        self.expiryDate = expiryDate
    }
    
    init(from options: [String: String]?) {
        if let options = options {
            if let cardNumber = options["cardNumber"] {
                self.cardNumber = cardNumber
            }
            
            if let cardHolderName = options["cardHolderName"] {
                self.cardHolderName = cardHolderName
            }
            
            if let expiryDate = options["expiryDate"] {
                self.expiryDate = expiryDate
            }
        }
    }
    
    public var description: String {
        return """
        Card Number: \(cardNumber)
        Card Holder Name: \(cardHolderName)
        Expiry Date: \(expiryDate)
        """
    }
    
    var dictionary: [String: String] {
        return [
            "cardNumber": cardNumber,
            "cardHolderName": cardHolderName,
            "expiryDate": expiryDate,
            "cardIssuer": ""
        ]
    }
}
