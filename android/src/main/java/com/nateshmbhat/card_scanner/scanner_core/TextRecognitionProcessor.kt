package com.nateshmbhat.card_scanner.scanner_core

import android.annotation.SuppressLint
import android.util.Log
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.nateshmbhat.card_scanner.onCardScanned
import com.nateshmbhat.card_scanner.scanner_core.models.CardDetails


class TextRecognitionProcessor(private val listener: onCardScanned) : ImageAnalysis.Analyzer {

  private val TAG: String? = "vision"
  private val cardDetailsSet: Set<CardDetails> = emptySet()

  @SuppressLint("UnsafeExperimentalUsageError")
  override fun analyze(imageProxy: ImageProxy) {
    val mediaImage = imageProxy.image
    if (mediaImage != null) {
      val image = InputImage.fromMediaImage(mediaImage, 0)

      val recognizer = TextRecognition.getClient()

      val result = recognizer.process(image)
              .addOnSuccessListener { visionText ->
                val cardScanner = CardScannerCore(visionText);
                val cardDetails = cardScanner.scanCard() ?: return@addOnSuccessListener
                listener(cardDetails)
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