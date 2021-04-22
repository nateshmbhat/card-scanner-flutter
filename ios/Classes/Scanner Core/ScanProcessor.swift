//
//  CardScanProcessorCore.swift
//  Card ScanProcessor
//
//  Created by Mohammed Sadiq on 26/07/20.
//  Copyright © 2020 MZaink. All rights reserved.
//

import UIKit
import MLKitTextRecognition

public protocol ScanProcessorDelegate {
    func scanProcessor(_ scanProcessor: ScanProcessor, didFinishScanning card: CardDetails)
}

public class ScanProcessor {
    var scanProcessorDelegate: ScanProcessorDelegate?
    var card: CardDetails = CardDetails()
    
    var datesCollectedSoFar: [String] = []
    var validScansSoFar: Int = 0
    var singleFrameCardScanner: SingleFrameCardScanner
    var cardDetailsScanOptimizer: CardDetailsScanOptimizer
    var cardScanOptions: CardScannerOptions
    
    init(withOptions cardScanOptions: CardScannerOptions) {
        self.cardScanOptions = cardScanOptions
        self.singleFrameCardScanner = SingleFrameCardScanner(withOptions: cardScanOptions)
        self.cardDetailsScanOptimizer = CardDetailsScanOptimizer(scannerOptions: cardScanOptions)
    }
    
    func startScanning() {
        let cameraViewController: CameraViewController = makeCameraViewController()
        UIApplication.shared.keyWindow?.rootViewController?.present(
            cameraViewController,
            animated: true,
            completion: nil
        )
    }
    
    func makeCameraViewController() -> CameraViewController {
        let cameraViewController: CameraViewController = CameraViewController()
        cameraViewController.cameraDelegate = self
        cameraViewController.cameraOrientation = cardScanOptions.cameraOrientation
        cameraViewController.prompt = cardScanOptions.prompt
        cameraViewController.modalPresentationStyle = .fullScreen
        
        return cameraViewController
    }
}

// MARK:- CameraDelegate
extension ScanProcessor: CameraDelegate {
    func camera(_ camera: CameraViewController, didScan scanResult: Text) {
        guard let cardDetails = singleFrameCardScanner.scanSingleFrame(visionText: scanResult) else {
            return
        }
        
        cardDetailsScanOptimizer.processCardDetails(cardDetails: cardDetails)
    
        if (cardDetailsScanOptimizer.isReadyToFinishScan()) {
            vibrateToIndicateScanEnd()
            
            card.cardNumber = cardDetailsScanOptimizer.getOptimalCardDetails()?.cardNumber ?? ""
            card.cardHolderName = cardDetailsScanOptimizer.getOptimalCardDetails()?.cardHolderName ?? ""
            card.expiryDate = cardDetailsScanOptimizer.getOptimalCardDetails()?.expiryDate ?? ""
            
            scanProcessorDelegate?.scanProcessor(self, didFinishScanning: card)
            camera.stopScanning()
        }
    }
    
    func vibrateToIndicateScanEnd() {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
    }
    
    func cameraDidStopScanning(_ camera: CameraViewController) {
        if (cardDetailsScanOptimizer.isReadyToFinishScan()) {
            // Delegate back to Flutter from here
            scanProcessorDelegate?.scanProcessor(self, didFinishScanning: card)
        }
    }
}
