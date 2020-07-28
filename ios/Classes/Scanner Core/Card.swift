//
//  Card.swift
//  Card Scanner
//
//  Created by Mohammed Sadiq on 05/07/20.
//  Copyright © 2020 MZaink. All rights reserved.
//

import Foundation

public class Card: CustomStringConvertible {
    var number: String
    var name: String
    var expiryDate: String

    init(number: String = "", name: String = "", expiryDate: String = "") {
        self.number = number
        self.name = name
        self.expiryDate = expiryDate
    }

    public var description: String {
        return """
        Card Number: \(number)
        Card Holder Name: \(name)
        Expiry Date: \(expiryDate)
        """
    }

    var dictionary: [String: String] {
        return [
            "cardNumber": number,
            "cardHolderName": name,
            "expiryDate": expiryDate,
            "cardIssuer": ""
        ]
    }
}
