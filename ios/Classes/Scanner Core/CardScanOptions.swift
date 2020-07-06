//
//  CardScanOptions.swift
//  Card Scanner
//
//  Created by Mohammed Sadiq on 05/07/20.
//  Copyright © 2020 MZaink. All rights reserved.
//

import Foundation

public class CardScanOptions {
    var scanCardHolderName: Bool
    var scanExpiryDate: Bool

    init(scanCardHolderName: Bool = false, scanExpiryDate: Bool = false) {
        self.scanCardHolderName = scanCardHolderName
        self.scanExpiryDate = scanExpiryDate
    }

    init(from dictionary: [String: Any]) {
         self.scanCardHolderName = (dictionary["scanCardHolderName"] as? Bool) ?? false
         self.scanExpiryDate = (dictionary["scanExpiryDate"] as? Bool) ?? false
    }

    var dictionary: [String: Bool] {
        return [
            "scanCardHolderName": scanCardHolderName,
            "scanExpiryDate": scanExpiryDate,
        ]
    }
}
