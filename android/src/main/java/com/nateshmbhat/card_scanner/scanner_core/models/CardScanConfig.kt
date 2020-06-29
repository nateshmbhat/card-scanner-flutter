package com.nateshmbhat.card_scanner.scanner_core.models

//@author nateshmbhat created on 29,June,2020

data class CardScanConfig(val scanCardExpiryDate: Boolean,
                          val scanCardHolderName: Boolean,
                          val scanCardIssuer: Boolean
) {

  constructor(configMap: Map<String, String>) : this(
          scanCardExpiryDate = configMap["scanCardExpiryDate"]?.toBoolean() ?: false,
          scanCardHolderName = configMap["scanCardHolderName"]?.toBoolean() ?: false,
          scanCardIssuer = configMap["scanCardIssuer"]?.toBoolean() ?: false
  )

  fun toMap(): Map<String, String> {
    return mapOf(
            Pair("scanCardExpiryDate", scanCardExpiryDate.toString()),
            Pair("scanCardHolderName", scanCardHolderName.toString()),
            Pair("scanCardIssuer", scanCardIssuer.toString())
    )
  }
}