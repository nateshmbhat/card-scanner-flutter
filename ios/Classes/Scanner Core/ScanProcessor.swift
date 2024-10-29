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
    var cameraViewController: CameraViewController?
    
    init(withOptions cardScanOptions: CardScannerOptions) {
        self.cardScanOptions = cardScanOptions
        self.singleFrameCardScanner = SingleFrameCardScanner(withOptions: cardScanOptions)
        self.cardDetailsScanOptimizer = CardDetailsScanOptimizer(scannerOptions: cardScanOptions)
    }
    
    func startScanning() {
        cameraViewController = makeCameraViewController()
        UIApplication.shared.keyWindow?.rootViewController?.present(
            cameraViewController!,
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
            print("extract image error")
            return
        }

        preprocessImage(frameImage) { preprocessedText in
            guard let preprocessedText = preprocessedText else {
                print("preprocessed text error")
                return
            }

             print("Preprocessed text: \(preprocessedText.text)")

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
            print("ui image to ci image fail")
            completion(nil)
            return
        }

        let grayscaleFilter = CIFilter(name: "CIColorControls")
        grayscaleFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        grayscaleFilter?.setValue(0.0, forKey: kCIInputSaturationKey)
        
        guard let grayscaleImage = grayscaleFilter?.outputImage else {
            print("grayscale fail")
            completion(nil)
            return
        }

        let sharpenLuminanceFilter = CIFilter(name: "CISharpenLuminance")
        sharpenLuminanceFilter?.setValue(grayscaleImage, forKey: kCIInputImageKey)
        sharpenLuminanceFilter?.setValue(0.4, forKey: "inputSharpness")

        guard let sharpenLuminanceImage = sharpenLuminanceFilter?.outputImage else {
            print("sharpen luminance fail")
            completion(nil)
            return
        }

        let highlightShadowFilter = CIFilter(name: "CIHighlightShadowAdjust")
        highlightShadowFilter?.setValue(sharpenLuminanceImage, forKey: kCIInputImageKey)
        highlightShadowFilter?.setValue(1.0, forKey: "inputHighlightAmount")

        guard let balancedImage = highlightShadowFilter?.outputImage else {
            print("lighting adjustment fail")
            completion(nil)
            return
        }

        let exposureAdjustFilter = CIFilter(name: "CIExposureAdjust")
        exposureAdjustFilter?.setValue(balancedImage, forKey: kCIInputImageKey)
        exposureAdjustFilter?.setValue(0.5, forKey: "inputEV")

        guard let exposureAdjustImage = exposureAdjustFilter?.outputImage else {
            print("exposure adjust fail")
            completion(nil)
            return
        }

        let vignetteFilter = CIFilter(name: "CIVignette")
        vignetteFilter?.setValue(exposureAdjustImage, forKey: kCIInputImageKey)
        vignetteFilter?.setValue(1.0, forKey: "inputRadius")

        guard let vignetteImage = vignetteFilter?.outputImage else {
            print("vignette fail")
            completion(nil)
            return
        }

        let unsharpMaskFilter = CIFilter(name: "CIUnsharpMask")
        unsharpMaskFilter?.setValue(vignetteImage, forKey: kCIInputImageKey)
        unsharpMaskFilter?.setValue(2.5, forKey: "inputRadius")
        unsharpMaskFilter?.setValue(0.5, forKey: "inputIntensity")

        guard let sharpenedImage = unsharpMaskFilter?.outputImage else {
            print("sharpening fail")
            completion(nil)
            return
        }

        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(sharpenedImage, from: sharpenedImage.extent) else {
            print("cgimage congtext fail")
            completion(nil)
            return
        }

        let preprocessedUIImage = UIImage(cgImage: cgImage)
    
        let visionImage = VisionImage(image: preprocessedUIImage)
        let textRecognizer = TextRecognizer.textRecognizer()

        textRecognizer.process(visionImage) { recognizedText, error in
            if let error = error {
                print("Error recognizing text")
                completion(nil)
            } else if let recognizedText = recognizedText {
                completion(recognizedText)
            } else {
                print("No text recognized.")
                completion(nil)
            }
        }
    }

    func extractImageFromText(sampleBuffer: CMSampleBuffer) -> UIImage? {

        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("getImagebuffer fail")
            return nil
        }
        
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            print("Error: Unable to create CGImage from CIImage")
            return nil
        }
        
        let uiImage = UIImage(cgImage: cgImage) 

        return uiImage
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
