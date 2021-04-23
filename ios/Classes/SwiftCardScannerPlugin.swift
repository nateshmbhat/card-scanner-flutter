import Flutter
import UIKit

public class SwiftCardScannerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "nateshmbhat/card_scanner", binaryMessenger: registrar.messenger())
        let instance = SwiftCardScannerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    var result: FlutterResult?
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "scan_card") {
            let scanProcessor: ScanProcessor = ScanProcessor(withOptions: CardScannerOptions(from: call.arguments as? [String: String]))
            
            scanProcessor.scanProcessorDelegate = self
            var secondsRemaining = CardScannerOptions(from: call.arguments as? [String: String]).cardScannerTimeOut
            
            DispatchQueue.main.async {
                scanProcessor.startScanning()
            }
            
            if secondsRemaining != 0 {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (Timer) in
                    if secondsRemaining <= 0 {
                        Timer.invalidate()
                        DispatchQueue.main.async {
                            UIApplication.shared.keyWindow?.rootViewController?.dismiss(
                                animated: true,
                                completion: nil
                            )
                        }
                    } else {
                        secondsRemaining -= 1
                    }
                }
            }
            
            self.result = result
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}

extension SwiftCardScannerPlugin: ScanProcessorDelegate {
    public func scanProcessor(_ scanProcessor: ScanProcessor, didFinishScanning card: CardDetails) {
        if let result = self.result {
            result(card.dictionary)
        }
    }
}
