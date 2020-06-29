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
  companion object {
    private val TAG: String = "TextRecognitionProcess"
    ///Indicates the number of times scan result is dropped even after successful card number scan.
    ///This increases the chance of detecting correct text since the camera would have become stabilized after some time
    private const val NUMBER_OF_SCAN_SKIPS  = 3
  }

  private val cardDetailsSet: Set<CardDetails> = emptySet()
  private var scansSkipped = 0 

  @SuppressLint("UnsafeExperimentalUsageError")
  override fun analyze(imageProxy: ImageProxy) {
    val mediaImage = imageProxy.image
    if (mediaImage != null) {
      val image = InputImage.fromMediaImage(mediaImage, 0)

      val recognizer = TextRecognition.getClient()

      val result = recognizer.process(image)
              .addOnSuccessListener { visionText ->
                for(block in visionText.textBlocks){
                  Log.d(TAG, "analyse , visionText : ${block.text}")
                }
                val cardScanner = CardScannerCore(visionText);
                val cardDetails = cardScanner.scanCard() ?: return@addOnSuccessListener
                if(this.scansSkipped<NUMBER_OF_SCAN_SKIPS){
                  this.scansSkipped++
                  return@addOnSuccessListener
                }
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