package com.basys.card_scanner

import android.app.Activity
import android.content.Context
import android.content.Intent
import com.basys.card_scanner.scanner_core.models.CardDetails
import com.basys.card_scanner.scanner_core.models.CardScannerOptions
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

/**
 * CardScannerPlugin
 */
class CardScannerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {

    companion object {
        private const val SCAN_REQUEST_CODE = 49193
        const val METHOD_CHANNEL_NAME = "basys/card_scanner"
        var channel: MethodChannel? = null
    }

    private var activity: Activity? = null
    private var context: Context? = null
    private var pendingResult: MethodChannel.Result? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL_NAME)
        channel?.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        context = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "scan_card" -> {
                if (activity == null) {
                    result.error("no_activity", "card_scanner plugin requires a foreground activity.", null)
                    return
                }
                if (pendingResult != null) {
                    result.error("ALREADY_ACTIVE", "Scan card is already active", null)
                    return
                }
                pendingResult = result
                showCameraActivity(call)
            }
            else -> result.notImplemented()
        }
    }

    private fun showCameraActivity(call: MethodCall) {
        val map = call.arguments as Map<String, String>
        val cardScannerOptions = CardScannerOptions(map)
        val intent = Intent(context, CardScannerCameraActivity::class.java)
        intent.putExtra(CardScannerCameraActivity.CARD_SCAN_OPTIONS, cardScannerOptions)
        activity?.startActivityForResult(intent, SCAN_REQUEST_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == SCAN_REQUEST_CODE) {
            when (resultCode) {
                Activity.RESULT_OK -> {
                    if (data != null && data.hasExtra(CardScannerCameraActivity.SCAN_RESULT)) {
                        val cardDetails = data.getParcelableExtra<CardDetails>(CardScannerCameraActivity.SCAN_RESULT)
                        pendingResult?.success(cardDetails?.toMap())
                    } else {
                        pendingResult?.success(null)
                    }
                    pendingResult = null
                }
                Activity.RESULT_CANCELED -> {
                    pendingResult?.success(null)
                    pendingResult = null
                }
            }
            return true
        }
        return false
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    override fun onDetachedFromActivity() {}
}




