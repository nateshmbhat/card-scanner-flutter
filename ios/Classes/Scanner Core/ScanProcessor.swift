//
//  CardScanProcessorCore.swift
//  Card ScanProcessor
//
//  Created by Mohammed Sadiq on 26/07/20.
//  Copyright © 2020 MZaink. All rights reserved.
//

import UIKit
import MLKitTextRecognition
import MLKitVision
import CoreImage
import AVFoundation

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
    func camera(_ camera: CameraViewController, didScan scanResult: Text, sampleBuffer: CMSampleBuffer) {
        guard let frameImage = extractImageFromText(sampleBuffer: sampleBuffer) else {
            return
        }

        preprocessImage(frameImage) { preprocessedText in
            guard let preprocessedText = preprocessedText else {
                return
            }

            guard let cardDetails = self.singleFrameCardScanner.scanSingleFrame(visionText: preprocessedText) else {
                return
            }

            self.cardDetailsScanOptimizer.processCardDetails(cardDetails: cardDetails)

            if self.cardDetailsScanOptimizer.isReadyToFinishScan() {
                self.vibrateToIndicateScanEnd()

                self.card.cardNumber = self.cardDetailsScanOptimizer.getOptimalCardDetails()?.cardNumber ?? ""
                self.card.cardHolderName = self.cardDetailsScanOptimizer.getOptimalCardDetails()?.cardHolderName ?? ""
                self.card.expiryDate = self.cardDetailsScanOptimizer.getOptimalCardDetails()?.expiryDate ?? ""

                self.scanProcessorDelegate?.scanProcessor(self, didFinishScanning: self.card)
                
                camera.stopScanning()
            }
        }
    }

    func preprocessImage(_ image: UIImage, completion: @escaping (Text?) -> Void) {
        guard let ciImage = CIImage(image: image) else {
            completion(nil)
            return
        }
        
        // Convert to Grayscale
        let grayscaleFilter = CIFilter(name: "CIColorControls")
        grayscaleFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        grayscaleFilter?.setValue(0.0, forKey: kCIInputSaturationKey) // Remove saturation for grayscale
        
        guard let grayscaleImage = grayscaleFilter?.outputImage else {
            completion(nil)
            return
        }
        
        // Enhance Contrast
        let contrastFilter = CIFilter(name: "CIColorControls")
        contrastFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        contrastFilter?.setValue(1.5, forKey: kCIInputContrastKey) // Increase contrast

        guard let contrastEnhancedImage = contrastFilter?.outputImage else {
            completion(nil)
            return
        }

        // Edge Detection
        let edgeDetectionFilter = CIFilter(name: "CIEdges")
        edgeDetectionFilter?.setValue(contrastEnhancedImage, forKey: kCIInputImageKey)
        edgeDetectionFilter?.setValue(1.0, forKey: kCIInputIntensityKey) // Edge intensity
        
        guard let edgeDetectedImage = edgeDetectionFilter?.outputImage else {
            completion(nil)
            return
        }
        
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            completion(nil)
            return
        }

        let preprocessedUIImage = UIImage(cgImage: cgImage)
    
        let visionImage = VisionImage(image: preprocessedUIImage)
        let textRecognizer = TextRecognizer.textRecognizer()

        textRecognizer.process(visionImage) { recognizedText, error in
            if let error = error {
                completion(nil)
            } else if let recognizedText = recognizedText {
                completion(recognizedText)
            } else {
                completion(nil)
            }
        }
    }

    func extractImageFromText(sampleBuffer: CMSampleBuffer) -> UIImage? {

        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
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
