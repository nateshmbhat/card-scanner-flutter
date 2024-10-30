package com.basys.card_scanner.scanner_core

import android.annotation.SuppressLint
import android.content.Context
import android.os.CountDownTimer
import androidx.annotation.OptIn
import androidx.camera.core.ExperimentalGetImage
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import com.basys.card_scanner.SingleFrameCardScanner
import com.basys.card_scanner.logger.debugLog
import com.basys.card_scanner.onCardScanFailed
import com.basys.card_scanner.onCardScanned
import com.basys.card_scanner.scanner_core.models.CardDetails
import com.basys.card_scanner.scanner_core.models.CardScannerOptions
import com.basys.card_scanner.scanner_core.optimizer.CardDetailsScanOptimizer
import jp.co.cyberagent.android.gpuimage.GPUImage
import jp.co.cyberagent.android.gpuimage.filter.*

class CardScanner(
  private val context: Context,
  private val scannerOptions: CardScannerOptions,
  private val onCardScanned: onCardScanned,
  private val onCardScanFailed: onCardScanFailed
) : ImageAnalysis.Analyzer {

  private val singleFrameCardScanner: SingleFrameCardScanner = SingleFrameCardScanner(scannerOptions)
  private val cardDetailsScanOptimizer: CardDetailsScanOptimizer = CardDetailsScanOptimizer(scannerOptions)
  private var scanCompleted: Boolean = false

  init {
    if (scannerOptions.cardScannerTimeOut > 0) {
      val timer = object : CountDownTimer((scannerOptions.cardScannerTimeOut * 1000).toLong(), 1000) {
        override fun onTick(millisUntilFinished: Long) {}

        override fun onFinish() {
          debugLog("Card scanner timeout reached", scannerOptions)
          val cardDetails = cardDetailsScanOptimizer.getOptimalCardDetails()
          if (cardDetails != null) {
            finishCardScanning(cardDetails)
          } else {
            onCardScanFailed()
          }
          debugLog("Finishing card scan with card details : $cardDetails", scannerOptions)
        }
      }
      timer.start()
    }
  }

  companion object {
    private const val TAG = "TextRecognitionProcess"
  }

  @OptIn(ExperimentalGetImage::class)
  @SuppressLint("UnsafeExperimentalUsageError")
  override fun analyze(imageProxy: ImageProxy) {
    val mediaImage = imageProxy.image
    if (mediaImage != null) {
      val image = InputImage.fromMediaImage(mediaImage, 90)
      val preprocessedImage = preprocessImage(image)

      val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)

      recognizer.process(preprocessedImage)
        .addOnSuccessListener { visionText ->
          if (scanCompleted) return@addOnSuccessListener
          val cardDetails = singleFrameCardScanner.scanSingleFrame(visionText)
            ?: return@addOnSuccessListener

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
        .addOnCompleteListener {
          imageProxy.close()
        }
    }
  }

  private fun preprocessImage(inputImage: InputImage): InputImage {
    val bitmap = inputImage.bitmapInternal ?: return inputImage
    val gpuImage = GPUImage(context)

    gpuImage.setFilter(GPUImageGrayscaleFilter())
    gpuImage.setFilter(GPUImageSharpenFilter().apply { setSharpness(1.0f) })
    gpuImage.setFilter(GPUImageExposureFilter().apply { setExposure(0.5f) })
    gpuImage.setFilter(GPUImageVignetteFilter())

    val preprocessedBitmap = gpuImage.getBitmapWithFilterApplied(bitmap)

    return InputImage.fromBitmap(preprocessedBitmap, inputImage.rotationDegrees)
  }

  private fun finishCardScanning(cardDetails: CardDetails) {
    debugLog("OPTIMAL Card details : $cardDetails", scannerOptions)
    scanCompleted = true
    onCardScanned(cardDetails)
  }
}