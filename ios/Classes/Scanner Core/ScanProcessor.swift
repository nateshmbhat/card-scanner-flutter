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
            print("extract image error")
            return
        }

    //     DispatchQueue.main.async {
    //     preview.image = frameImage
    // }

        preprocessImage(frameImage) { preprocessedText in
            guard let preprocessedText = preprocessedText else {
                print("preprocessed text error")
                return
            }

             print("Preprocessed text: \(preprocessedText.text)")

            guard let cardDetails = self.singleFrameCardScanner.scanSingleFrame(visionText: preprocessedText) else {
                //print("No Card Details")
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
        
        //Convert to Grayscale
        let grayscaleFilter = CIFilter(name: "CIColorControls")
        grayscaleFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        grayscaleFilter?.setValue(0.0, forKey: kCIInputSaturationKey)
        //grayscaleFilter?.setValue(0.1, forKey: kCIInputBrightnessKey)  // Slightly increase brightness to lighten darker background
        //grayscaleFilter?.setValue(0.95, forKey: kCIInputContrastKey)
        
        guard let grayscaleImage = grayscaleFilter?.outputImage else {
            print("grayscale fail")
            completion(nil)
            return
        }

        // let noiseReductionFilter = CIFilter(name: "CINoiseReduction")
        // noiseReductionFilter?.setValue(grayscaleImage, forKey: kCIInputImageKey)
        // noiseReductionFilter?.setValue(0.02, forKey: "inputNoiseLevel")  // Reduce noise without losing detail
        // noiseReductionFilter?.setValue(0.4, forKey: "inputSharpness")

        // guard let denoisedImage = noiseReductionFilter?.outputImage else {
        //     print("noise reduction fail")
        //     completion(nil)
        //     return
        // }
        
        //Enhance Contrast
        // let contrastFilter = CIFilter(name: "CIColorControls")
        // contrastFilter?.setValue(grayscaleImage, forKey: kCIInputImageKey)
        // contrastFilter?.setValue(0.9, forKey: kCIInputContrastKey) // Increase contrast

        // guard let contrastEnhancedImage = contrastFilter?.outputImage else {
        //     print("contrast fail")
        //     completion(nil)
        //     return
        // }

        // Edge Detection
        // let edgeDetectionFilter = CIFilter(name: "CIEdges")
        // edgeDetectionFilter?.setValue(grayscaleImage, forKey: kCIInputImageKey)
        // edgeDetectionFilter?.setValue(1.1, forKey: kCIInputIntensityKey) // Edge intensity
        
        // guard let edgeDetectedImage = edgeDetectionFilter?.outputImage else {
        //     print("grayscale fail")
        //     completion(nil)
        //     return
        // }

        // Adaptive Thresholding
        // let thresholdFilter = CIFilter(name: "CIThresholdToZero")
        // thresholdFilter?.setValue(grayscaleImage, forKey: kCIInputImageKey)

        // guard let thresholdedImage = thresholdFilter?.outputImage else {
        //     print("thresholding fail")
        //     completion(nil)
        //     return
        // }

        // let blurFilter = CIFilter(name: "CIGaussianBlur")
        // blurFilter?.setValue(grayscaleImage, forKey: kCIInputImageKey)
        // blurFilter?.setValue(1.0, forKey: kCIInputRadiusKey) // You can adjust the radius

        // guard let blurredImage = blurFilter?.outputImage else {
        //     print("blurring fail")
        //     completion(nil)
        //     return
        // }

        // let unsharpMaskFilter = CIFilter(name: "CIUnsharpMask")
        // unsharpMaskFilter?.setValue(grayscaleImage, forKey: kCIInputImageKey)
        // unsharpMaskFilter?.setValue(1.5, forKey: kCIInputIntensityKey) // Intensity of sharpening
        // unsharpMaskFilter?.setValue(1.0, forKey: kCIInputRadiusKey) // Adjust the radius

        // guard let sharpenedImage = unsharpMaskFilter?.outputImage else {
        //     print("sharpening fail")
        //     completion(nil)
        //     return
        // }
        
        let highlightShadowFilter = CIFilter(name: "CIHighlightShadowAdjust")
        highlightShadowFilter?.setValue(grayscaleImage, forKey: kCIInputImageKey)
        highlightShadowFilter?.setValue(0.8, forKey: "inputHighlightAmount")
        highlightShadowFilter?.setValue(1.0, forKey: "inputShadowAmount")

        guard let balancedImage = highlightShadowFilter?.outputImage else {
            print("lighting adjustment fail")
            completion(nil)
            return
        }

        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(balancedImage, from: grayscaleImage.extent) else {
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
