import Flutter
import UIKit

public class SwiftCardScannerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "nateshmbhat/card_scanner", binaryMessenger: registrar.messenger())
    let instance = SwiftCardScannerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  var result: FlutterResult?

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterReply) {
    if (call.method == "scan_card") {
        let scanProcessor: ScanProcessor = ScanProcessor(cardScanOptions: CardScanOptions(from: (call.arguments as? [String: Any]) ?? [String: String]()))
        scanProcessor.scanProcessorDelegate = self
        scanProcessor.startScanning()
        self.result = result
    } else {
        result(FlutterMethodNotImplemented)
    }
  }
}

extension SwiftCardScannerPlugin: ScanProcessorDelegate {
    public func scanProcessor(_ scanProcessor: ScanProcessor, didFinishScanning card: Card) {
        if let result = self.result {
            result(card.dictionary)
        }
    }
}
