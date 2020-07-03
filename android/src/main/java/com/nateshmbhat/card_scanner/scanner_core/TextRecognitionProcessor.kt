package com.nateshmbhat.card_scanner.scanner_core

import android.annotation.SuppressLint
import android.util.Log
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.nateshmbhat.card_scanner.onCardScanned
import com.nateshmbhat.card_scanner.scanner_core.models.CardDetails
import com.nateshmbhat.card_scanner.scanner_core.models.CardScanOptions


class TextRecognitionProcessor(private val scanOptions: CardScanOptions, private val onCardScanned: onCardScanned) : ImageAnalysis.Analyzer {
  companion object {
    private val TAG: String = "TextRecognitionProcess"

    ///Indicates the number of times scan result is dropped even after successful card number scan.
    ///This increases the chance of detecting correct text since the camera would have become stabilized after some time
    private const val MIN_NUMBER_OF_SCANS = 8
    private const val NUMBER_OF_SCAN_DROPS = 1
  }

  private var numberOfValidScans = 0
  private var finalCardDetails: CardDetails? = null

  private fun updateCardDetails(newCardDetails: CardDetails) {
    if (this.finalCardDetails == null) {
      this.finalCardDetails = newCardDetails
      return
    }

    this.finalCardDetails = this.finalCardDetails!!.copy(
            expiryDate = (if (finalCardDetails!!.expiryDate.isBlank()) {
              newCardDetails.expiryDate
            } else finalCardDetails!!.expiryDate),
            cardHolderName = (if (finalCardDetails!!.cardHolderName.isBlank()) {
              newCardDetails.cardHolderName
            } else finalCardDetails!!.cardHolderName),
            cardIssuer = (if (finalCardDetails!!.cardIssuer.isBlank()) {
              newCardDetails.cardIssuer
            } else finalCardDetails!!.cardIssuer)
    )
  }

  @SuppressLint("UnsafeExperimentalUsageError")
  override fun analyze(imageProxy: ImageProxy) {
    val mediaImage = imageProxy.image
    if (mediaImage != null) {
      val image = InputImage.fromMediaImage(mediaImage, 0)

      val recognizer = TextRecognition.getClient()

      val result = recognizer.process(image)
              .addOnSuccessListener { visionText ->
                for (block in visionText.textBlocks) {
                  Log.d(TAG, "visionText: TextBlock ============================")
                  Log.d(TAG, "visionText : ${block.text}")
                }
                val cardScanner = CardScannerCore(visionText, scanOptions);
                val cardDetails = cardScanner.scanCard(finalCardDetails)
                        ?: return@addOnSuccessListener

                this.numberOfValidScans++
                if (this.numberOfValidScans <= NUMBER_OF_SCAN_DROPS) {
                  return@addOnSuccessListener
                }

                if (this.numberOfValidScans < MIN_NUMBER_OF_SCANS) {
                  updateCardDetails(cardDetails)
                  return@addOnSuccessListener
                }
                onCardScanned(finalCardDetails ?: cardDetails)
              }
              .addOnFailureListener { e ->
                Log.e(TAG, "Error : $e")
              }
              .addOnCompleteListener { r ->
                imageProxy.close()
              }
    }
  }
}