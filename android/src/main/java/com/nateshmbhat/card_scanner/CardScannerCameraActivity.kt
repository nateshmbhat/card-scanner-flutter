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


typealias onCardScanned = (cardDetails: CardDetails?) -> Unit
typealias onCardScanFailed = () -> Unit

class CardScannerCameraActivity : AppCompatActivity() {
  private var previewUseCase: Preview? = null;
  private var cameraProvider: ProcessCameraProvider? = null
  private var cameraSelector: CameraSelector? = null
  private var textRecognizer: TextRecognizer? = null
  private var analysisUseCase: ImageAnalysis? = null
  private lateinit var cardScannerOptions: CardScannerOptions
  private lateinit var cameraExecutor: ExecutorService
  lateinit var animator: ObjectAnimator
  lateinit var scannerLayout: View
  lateinit var scannerBar: View
  lateinit var backButton: View

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(R.layout.card_scanner_camera_activity)
    cardScannerOptions = intent.getParcelableExtra<CardScannerOptions>(CARD_SCAN_OPTIONS)

    scannerLayout = findViewById(R.id.scannerLayout);
    scannerBar = findViewById(R.id.scannerBar);
    backButton = findViewById(R.id.backButton)
    supportActionBar?.hide();

    val vto = scannerLayout.viewTreeObserver;
    backButton.setOnClickListener {
      finish()
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
    cameraProviderFuture.addListener(Runnable {
      this.cameraProvider = cameraProviderFuture.get()
      this.cameraSelector = CameraSelector.Builder().requireLensFacing(CameraSelector.LENS_FACING_BACK).build()

      try {
        bindAllCameraUseCases()
      } catch (exc: Exception) {
        debugLog("Use case binding failed : $exc", cardScannerOptions)
      }
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
    if (previewUseCase != null) {
      cameraProvider?.unbind(previewUseCase)
    }
    previewUseCase = Preview.Builder().build()
    val previewView = findViewById<PreviewView>(R.id.cameraView)
    previewUseCase!!.setSurfaceProvider(previewView.surfaceProvider)
    cameraProvider?.bindToLifecycle( /* lifecycleOwner= */this, cameraSelector!!, previewUseCase)
  }

  private fun bindAnalysisUseCase() {
    if (cameraProvider == null) {
      return
    }
    if (analysisUseCase != null) {
      cameraProvider?.unbind(analysisUseCase)
    }
    textRecognizer?.close()
    textRecognizer = TextRecognition.getClient()

    debugLog("card scanner options : $cardScannerOptions", cardScannerOptions)
    val analysisUseCase = ImageAnalysis.Builder().build()
            .also {
              it.setAnalyzer(cameraExecutor, CardScanner(cardScannerOptions, { cardDetails ->
                debugLog("Card recognized : $cardDetails", cardScannerOptions)

                val returnIntent: Intent = Intent()
                returnIntent.putExtra(SCAN_RESULT, cardDetails)
                setResult(Activity.RESULT_OK, returnIntent)
                this.finish()
              }, onCardScanFailed = {
                onBackPressed()
              }))
            }
    cameraProvider!!.bindToLifecycle( /* lifecycleOwner= */this, cameraSelector!!, analysisUseCase)
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
    textRecognizer?.close()
  }

  override fun onBackPressed() {
    setResult(Activity.RESULT_CANCELED)
    super.onBackPressed()
  }
}