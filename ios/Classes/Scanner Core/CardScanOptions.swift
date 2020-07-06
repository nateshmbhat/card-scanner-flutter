//
//  CardScanOptions.swift
//  Card Scanner
//
//  Created by Mohammed Sadiq on 05/07/20.
//  Copyright © 2020 MZaink. All rights reserved.
//

import Foundation

public class CardScanOptions {
    var scanCardHolderName: Bool = false
    var scanExpirtyDate: Bool = false
    
    init(scanCardHolderName: Bool = false, scanExpiryDate: Bool = false) {
        self.scanCardHolderName = scanCardHolderName
        self.scanExpirtyDate = scanExpiryDate
    }
    
    init(from dictionary: [String: String]?) {
        if let options = dictionary {
            if let scanCardHolderName = options["scanCardHolderName"] {
                self.scanCardHolderName = (scanCardHolderName == "true")
            }
            
            if let scanExpirtyDate = options["scanExpiryDate"] {
                self.scanExpirtyDate = (scanExpirtyDate == "true")
            }
        }
    }
}
