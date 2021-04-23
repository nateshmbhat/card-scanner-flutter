package com.nateshmbhat.card_scanner.scanner_core

import android.annotation.SuppressLint
import android.os.CountDownTimer
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.nateshmbhat.card_scanner.SingleFrameCardScanner
import com.nateshmbhat.card_scanner.logger.debugLog
import com.nateshmbhat.card_scanner.onCardScanFailed
import com.nateshmbhat.card_scanner.onCardScanned
import com.nateshmbhat.card_scanner.scanner_core.models.CardDetails
import com.nateshmbhat.card_scanner.scanner_core.models.CardScannerOptions
import com.nateshmbhat.card_scanner.scanner_core.optimizer.CardDetailsScanOptimizer


class CardScanner(private val scannerOptions: CardScannerOptions, private val onCardScanned: onCardScanned, private val onCardScanFailed: onCardScanFailed) : ImageAnalysis.Analyzer {
  val singleFrameCardScanner: SingleFrameCardScanner = SingleFrameCardScanner(scannerOptions)
  val cardDetailsScanOptimizer: CardDetailsScanOptimizer = CardDetailsScanOptimizer(scannerOptions)
  var scanCompleted: Boolean = false

  init {
    if (scannerOptions.cardScannerTimeOut > 0) {
      val timer = object : CountDownTimer((scannerOptions.cardScannerTimeOut * 1000).toLong(), 1000) {
        override fun onTick(millisUntilFinished: Long) {}

        override fun onFinish() {
          debugLog("Card scanner timeout reached", scannerOptions);
          val cardDetails = cardDetailsScanOptimizer.getOptimalCardDetails()
          if (cardDetails != null) {
            finishCardScanning(cardDetails)
          } else {
            onCardScanFailed()
          }
          debugLog("Finishing card scan with card details : ${cardDetails}", scannerOptions);
        }
      }
      timer.start()
    }
  }

  companion object {
    private val TAG: String = "TextRecognitionProcess"
  }

  @SuppressLint("UnsafeExperimentalUsageError")
  override fun analyze(imageProxy: ImageProxy) {
    val mediaImage = imageProxy.image
    if (mediaImage != null) {
      val image = InputImage.fromMediaImage(mediaImage, 90)

      val recognizer = TextRecognition.getClient()

      val result = recognizer.process(image)
              .addOnSuccessListener { visionText ->
                if (scanCompleted) return@addOnSuccessListener
                val cardDetails = singleFrameCardScanner.scanSingleFrame(visionText)
                        ?: return@addOnSuccessListener;

                if (scannerOptions.enableDebugLogs) {
                  debugLog("----------------------------------------------------", scannerOptions)
                  for (block in visionText.textBlocks) {
                    debugLog("visionText: TextBlock ============================", scannerOptions)
                    debugLog("visionText : ${block.text}", scannerOptions)
                  }
                  debugLog("----------------------------------------------------", scannerOptions)

                  debugLog("Card details : $cardDetails", scannerOptions)
                }
                cardDetailsScanOptimizer.processCardDetails(cardDetails)
                if (cardDetailsScanOptimizer.isReadyToFinishScan()) {
                  finishCardScanning(cardDetailsScanOptimizer.getOptimalCardDetails()!!)
                }
              }
              .addOnFailureListener { e ->
                debugLog("Error : $e", scannerOptions)
              }
              .addOnCompleteListener { r ->
                imageProxy.close()
              }
    }
  }

  private fun finishCardScanning(cardDetails: CardDetails) {
    debugLog("OPTIMAL Card details : $cardDetails", scannerOptions)
    scanCompleted = true
    onCardScanned(cardDetails)
  }
}