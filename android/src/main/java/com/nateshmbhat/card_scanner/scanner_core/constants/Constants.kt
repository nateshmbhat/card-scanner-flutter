package com.nateshmbhat.card_scanner.scanner_core.constants

abstract class CardScannerRegexps {
  companion object {
    val cardNumberRegex = "^(\\s*\\d\\s*){16}\$";
    val expiryDateRegex = "(0[1-9]|1[0-2])/([0-9]{2})";
    val cardHolderName = "^ *(([A-Z.]+ {0,2}){1,8}) *\$"; // A line containing name has : minimum 1 word and maximum 8 words
  }
}


abstract class CardHolderNameConstants {
  companion object {
    val defaultBlackListedWords =
            setOf<String>(
                    "valid",
                    "doll",
                    "through",
                    "thru",
                    "valid thru",
                    "alid thru",
                    "alid thr",
                    "thrd",
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
                    "prepaid")
  };
}