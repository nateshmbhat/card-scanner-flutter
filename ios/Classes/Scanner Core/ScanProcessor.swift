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
        guard let frameImage = extractImageFromText(scanResult, sampleBuffer: sampleBuffer) else {
            print("Error: Unable to extract image from scan result")
            return
        }

        guard let preprocessedImage = preprocessImage(frameImage) else {
            print("Error: Image preprocessing failed")
            return
        }
        guard let cardDetails = singleFrameCardScanner.scanSingleFrame(visionText: preprocessedImage) else {
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

    // Helper function to preprocess a UIImage (grayscale conversion, contrast enhancement, edge detection)
    func preprocessImage(_ image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else {
            print("Error: Failed to create CIImage from UIImage")
            return nil
        }
        
        // Step 1: Convert to Grayscale
        let grayscaleFilter = CIFilter(name: "CIColorControls")
        grayscaleFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        grayscaleFilter?.setValue(0.0, forKey: kCIInputSaturationKey) // Remove saturation for grayscale
        
        guard let grayscaleImage = grayscaleFilter?.outputImage else {
            print("Error: Grayscale conversion failed")
            return nil
        }
        
        // Step 2: Enhance Contrast
        let contrastFilter = CIFilter(name: "CIColorControls")
        contrastFilter?.setValue(grayscaleImage, forKey: kCIInputImageKey)
        contrastFilter?.setValue(1.5, forKey: kCIInputContrastKey) // Increase contrast

        guard let contrastEnhancedImage = contrastFilter?.outputImage else {
            print("Error: Contrast enhancement failed")
            return nil
        }

        // Step 3: Apply Edge Detection
        let edgeDetectionFilter = CIFilter(name: "CIEdges")
        edgeDetectionFilter?.setValue(contrastEnhancedImage, forKey: kCIInputImageKey)
        edgeDetectionFilter?.setValue(1.0, forKey: kCIInputIntensityKey) // Edge intensity
        
        guard let edgeDetectedImage = edgeDetectionFilter?.outputImage else {
            print("Error: Edge detection failed")
            return nil
        }
        
        // Convert the processed CIImage back to UIImage
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(edgeDetectedImage, from: edgeDetectedImage.extent) {
            return UIImage(cgImage: cgImage)
        } else {
            print("Error: Failed to convert CIImage to CGImage")
            return nil
        }
    }

    // Helper function to extract UIImage from the Text object (camera frame)
    func extractImageFromText(_ scanResult: Text, sampleBuffer: CMSampleBuffer) -> UIImage? {
        // Convert CMSampleBuffer (camera frame) to UIImage
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Error: Unable to get image buffer from sample buffer")
            return nil
        }
        
        // Create a CIImage from the image buffer
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        // Convert CIImage to UIImage
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            print("Error: Unable to create CGImage from CIImage")
            return nil
        }
        
        // Return the final UIImage
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
