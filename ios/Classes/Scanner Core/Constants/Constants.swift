//
//  Constants.swift
//  card_scanner
//
//  Created by Abhinav Kumar on 12/02/21.
//

import Foundation
struct CardScannerRegexps {
    static let cardNumberRegex = "^(\\s*\\d\\s*){16}$"
    static let expiryDateRegex = "(0[1-9]|1[0-2])/([0-9]{2})"
    static let cardHolderName = "^ *(([A-Z.]+ {0,2}){1,8}) *$" // A line containing name has : minimum 1 word and maximum 8 words
}

struct CardHolderNameConstants {
    static let defaultBlackListedWords =
        [
            "valid",
            "doll",
            "through",
            "thru",
            "valid thru",
            "alid thru",
            "alid thr",
            "valid through",
            "from",
            "valid from",
            "alid from",
            "alid fro",
            "international",
            "rupay",
            "meal",
            "pass",
            "meal pass",
            "debit",
            "debit card",
            "visa",
            "mastercard",
            "platinum",
            "axis",
            "sbi",
            "axis bank",
            "credit",
            "card",
            "boi",
            "titanium",
            "bank",
            "global",
            "state bank",
            "of",
            "the",
            "india",
            "valid only",
            "classic",
            "gold",
            "sbi card",
            "visa classic",
            "visa signature",
            "visa gold",
            "electronic",
            "use only",
            "electronic use only",
            "only",
            "use",
            "expires",
            "end",
            "expires end",
            "valid till",
            "expire date",
            "date",
            "expiry",
            "expiry date",
            "premier",
            "world",
            "uk",
            "hsbc",
            "cvv",
            "cvc",
            "more",
            "amex",
            "valid from valid thru",
            "valid from valid till",
            "member since",
            "prepaid",
            "HSBC UK".lowercased(),
            "HSBC".lowercased()
        ]
}
