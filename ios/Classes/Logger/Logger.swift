//
//  Logger.swift
//  card_scanner
//
//  Created by Mohammed Sadiq on 13/02/21.
//

import Foundation

func debugLog(_ data: String, scannerOptions: CardScannerOptions) {
    if scannerOptions.enableDebugLogs {
        NSLog(data)
    }
}
