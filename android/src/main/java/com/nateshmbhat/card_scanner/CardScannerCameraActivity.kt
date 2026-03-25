package com.nateshmbhat.card_scanner

import android.Manifest
import android.animation.ObjectAnimator
import android.animation.ValueAnimator
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import android.view.View
import android.view.ViewTreeObserver.OnGlobalLayoutListener
import android.view.animation.AccelerateDecelerateInterpolator
import android.widget.ImageButton
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.TextRecognizer
import com.nateshmbhat.card_scanner.logger.debugLog
import com.nateshmbhat.card_scanner.scanner_core.CardScanner
import com.nateshmbhat.card_scanner.scanner_core.models.CardDetails
import com.nateshmbhat.card_scanner.scanner_core.models.CardScannerOptions
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import com.google.mlkit.vision.text.latin.TextRecognizerOptions


typealias onCardScanned = (cardDetails: CardDetails?) -> Unit
typealias onCardScanFailed = () -> Unit

class CardScannerCameraActivity : AppCompatActivity() {
  private var previewUseCase: Preview? = null
  private var cameraProvider: ProcessCameraProvider? = null
  private var cameraSelector: CameraSelector? = null
  private var textRecognizer: TextRecognizer? = null
  private var analysisUseCase: ImageAnalysis? = null
  private var cardScannerOptions: CardScannerOptions? = null
  private var cardScanner: CardScanner? = null
  private var camera: Camera? = null
  private var isTorchOn: Boolean = false
  private lateinit var cameraExecutor: ExecutorService
  lateinit var animator: ObjectAnimator
  lateinit var scannerLayout: View
  lateinit var scannerBar: View
  lateinit var backButton: View
  lateinit var flashButton: ImageButton

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(R.layout.card_scanner_camera_activity)
    cardScannerOptions = intent.getParcelableExtra<CardScannerOptions>(CARD_SCAN_OPTIONS)

    scannerLayout = findViewById(R.id.scannerLayout)
    scannerBar = findViewById(R.id.scannerBar)
    backButton = findViewById(R.id.backButton)
    flashButton = findViewById(R.id.flashButton)
    supportActionBar?.hide()

    val promptText = findViewById<TextView>(R.id.promptText)
    val prompt = cardScannerOptions?.prompt ?: ""
    if (prompt.isEmpty()) {
      promptText.visibility = View.GONE
    } else {
      promptText.text = prompt
    }

    val vto = scannerLayout.viewTreeObserver
    backButton.setOnClickListener {
      finish()
    }
    flashButton.setOnClickListener {
      toggleFlashlight()
    }
    vto.addOnGlobalLayoutListener(object : OnGlobalLayoutListener {
      override fun onGlobalLayout() {
        scannerLayout.viewTreeObserver.removeOnGlobalLayoutListener(this)
        animator = ObjectAnimator.ofFloat(scannerBar, "translationY",
                scannerLayout.y - scannerBar.height,
                (scannerLayout.y +
                        scannerLayout.height - scannerBar.height))
        animator.repeatMode = ValueAnimator.REVERSE
        animator.repeatCount = ValueAnimator.INFINITE
        animator.interpolator = AccelerateDecelerateInterpolator()
        animator.duration = 3000
        animator.start()
      }
    })

    cameraExecutor = Executors.newSingleThreadExecutor()

    // Request camera permissions
    if (allPermissionsGranted()) {
      startCamera()
    } else {
      ActivityCompat.requestPermissions(
              this, REQUIRED_PERMISSIONS, REQUEST_CODE_PERMISSIONS)
    }
  }

  private fun startCamera() {
    val cameraProviderFuture = ProcessCameraProvider.getInstance(this)
    cameraProviderFuture.addListener({
      cameraProvider = cameraProviderFuture.get()
      cameraSelector = CameraSelector.Builder().requireLensFacing(CameraSelector.LENS_FACING_BACK).build()
      bindAllCameraUseCases()
    }, ContextCompat.getMainExecutor(this))
  }


  private fun allPermissionsGranted() = REQUIRED_PERMISSIONS.all {
    ContextCompat.checkSelfPermission(
            baseContext, it) == PackageManager.PERMISSION_GRANTED
  }

  override fun onRequestPermissionsResult(
          requestCode: Int, permissions: Array<String>, grantResults:
          IntArray) {
    if (requestCode == REQUEST_CODE_PERMISSIONS) {
      if (allPermissionsGranted()) {
        startCamera()
      } else {
        Toast.makeText(this,
                "Permissions not granted by the user.",
                Toast.LENGTH_SHORT).show()
        finish()
      }
    }
  }

  private fun bindAllCameraUseCases() {
    bindPreviewUseCase()
    bindAnalysisUseCase()
  }

  private fun bindPreviewUseCase() {
    if(cameraProvider == null){
      return
    }

    if (previewUseCase != null) {
      cameraProvider!!.unbind(previewUseCase)
    }

    previewUseCase = Preview.Builder().build()
    val previewView = findViewById<PreviewView>(R.id.cameraView)

    previewUseCase!!.setSurfaceProvider(previewView.surfaceProvider)
    camera = cameraProvider!!.bindToLifecycle( /* lifecycleOwner= */this, cameraSelector!!, previewUseCase)
  }

  private fun bindAnalysisUseCase() {
    if (cameraProvider == null) {
      return
    }

    if (analysisUseCase != null) {
      cameraProvider!!.unbind(analysisUseCase)
    }

    if(textRecognizer != null){
      textRecognizer!!.close()
    }

    textRecognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)

    debugLog("card scanner options : $cardScannerOptions", cardScannerOptions)
    cardScanner = CardScanner(cardScannerOptions, { cardDetails ->
      debugLog("Card recognized : $cardDetails", cardScannerOptions)

      val returnIntent: Intent = Intent()
      returnIntent.putExtra(SCAN_RESULT, cardDetails)
      setResult(Activity.RESULT_OK, returnIntent)
      finish()
    }, onCardScanFailed = {
      onBackPressed()
    })
    val analysisUseCase = ImageAnalysis.Builder().build()
            .also {
              it.setAnalyzer(cameraExecutor, cardScanner!!)
            }
    cameraProvider!!.bindToLifecycle( /* lifecycleOwner= */this, cameraSelector!!, analysisUseCase)
  }

  private fun toggleFlashlight() {
    camera?.let {
      if (it.cameraInfo.hasFlashUnit()) {
        isTorchOn = !isTorchOn
        it.cameraControl.enableTorch(isTorchOn)
        flashButton.setImageResource(if (isTorchOn) R.drawable.ic_flash_on else R.drawable.ic_flash_off)
      }
    }
  }

  companion object {
    private const val TAG = "CameraXBasic"
    private const val REQUEST_CODE_PERMISSIONS = 10
    private val REQUIRED_PERMISSIONS = arrayOf(Manifest.permission.CAMERA)
    const val SCAN_RESULT: String = "scan_result"
    const val CARD_SCAN_OPTIONS = "card_scan_options"
  }

  override fun onResume() {
    super.onResume()
    bindAllCameraUseCases()
  }

  override fun onPause() {
    super.onPause()
    textRecognizer?.close()
  }

  override fun onDestroy() {
    super.onDestroy()
    cardScanner?.cancelTimer()
    textRecognizer?.close()
  }

  override fun onBackPressed() {
    setResult(Activity.RESULT_CANCELED)
    super.onBackPressed()
  }
}