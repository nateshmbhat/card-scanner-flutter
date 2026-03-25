import Flutter
import UIKit

public class SwiftCardScannerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "nateshmbhat/card_scanner", binaryMessenger: registrar.messenger())
        let instance = SwiftCardScannerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    var result: FlutterResult?
    var scanTimer: Timer?

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "scan_card") {
            let scanProcessor: ScanProcessor = ScanProcessor(withOptions: CardScannerOptions(from: call.arguments as? [String: String]))

            scanProcessor.scanProcessorDelegate = self
            var secondsRemaining = CardScannerOptions(from: call.arguments as? [String: String]).cardScannerTimeOut

            self.result = result

            DispatchQueue.main.async {
                scanProcessor.startScanning()
            }

            if secondsRemaining != 0 {
                scanTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                    if secondsRemaining <= 0 {
                        timer.invalidate()
                        self?.scanTimer = nil
                        DispatchQueue.main.async {
                            guard let pendingResult = self?.result else { return }
                            self?.result = nil
                            pendingResult(nil)
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
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}

extension SwiftCardScannerPlugin: ScanProcessorDelegate {
    public func scanProcessor(_ scanProcessor: ScanProcessor, didFinishScanning card: CardDetails) {
        scanTimer?.invalidate()
        scanTimer = nil
        if let result = self.result {
            self.result = nil
            result(card.dictionary)
        }
    }
}
