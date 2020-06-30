package com.nateshmbhat.card_scanner.scanner_core.models

import android.os.Parcel
import android.os.Parcelable

//@author nateshmbhat created on 29,June,2020

data class CardScanOptions(val scanExpiryDate: Boolean,
                           val scanCardHolderName: Boolean,
                           val scanCardIssuer: Boolean
):Parcelable {

  constructor(parcel: Parcel) : this(
          parcel.readByte() != 0.toByte(),
          parcel.readByte() != 0.toByte(),
          parcel.readByte() != 0.toByte()) {
  }

  constructor(configMap: Map<String, String>) : this(
          scanExpiryDate = configMap["scanCardExpiryDate"]?.toBoolean() ?: true,
          scanCardHolderName = configMap["scanCardHolderName"]?.toBoolean() ?: false,
          scanCardIssuer = configMap["scanCardIssuer"]?.toBoolean() ?: false
  )

  fun toMap(): Map<String, String> {
    return mapOf(
            Pair("scanCardExpiryDate", scanExpiryDate.toString()),
            Pair("scanCardHolderName", scanCardHolderName.toString()),
            Pair("scanCardIssuer", scanCardIssuer.toString())
    )
  }

  override fun writeToParcel(parcel: Parcel, flags: Int) {
    parcel.writeByte(if (scanExpiryDate) 1 else 0)
    parcel.writeByte(if (scanCardHolderName) 1 else 0)
    parcel.writeByte(if (scanCardIssuer) 1 else 0)
  }

  override fun describeContents(): Int {
    return 0
  }

  companion object CREATOR : Parcelable.Creator<CardScanOptions> {
    override fun createFromParcel(parcel: Parcel): CardScanOptions {
      return CardScanOptions(parcel)
    }

    override fun newArray(size: Int): Array<CardScanOptions?> {
      return arrayOfNulls(size)
    }
  }
}