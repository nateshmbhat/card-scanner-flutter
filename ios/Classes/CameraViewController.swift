//
//  CameraViewController.swift
//  Card Scanner
//
//  Created by Mohammed Sadiq on 05/07/20.
//  Copyright © 2020 MZaink. All rights reserved.
//

import UIKit
import AVFoundation
import MLKitTextRecognition
import MLKitVision

public protocol CameraDelegate {
    func camera(_ camera: CameraViewController, didScan scanResult: Text)
    func cameraDidStopScanning(_ camera: CameraViewController)
}

public class CameraViewController: UIViewController {
    static let maxScansToDrop: Int = 2

    var scansDroppedSinceLastReset: Int = 0

    var cameraDelegate: CameraDelegate?
    var captureSession: AVCaptureSession!
    var device: AVCaptureDevice!
    var input: AVCaptureDeviceInput!

    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        gainCameraPermission()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isBeingDismissed {
            stopScanning()
        }
    }
    
    public override func viewWillLayoutSubviews() {
        let width = self.view.frame.width
        let navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: width, height: 44))
        self.view.addSubview(navigationBar);
        let navigationItem = UINavigationItem(title: "Scan Card")
        let closeButton = UIBarButtonItem(title: "Close", style: .done, target: nil, action: #selector(selectorX))
        navigationItem.leftBarButtonItem = closeButton
        navigationBar.setItems([navigationItem], animated: false)
    }
    
    @objc func selectorX() {
        stopScanning()
        cameraDelegate?.cameraDidStopScanning(self)
    }
    
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let safeCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        guard let safeCaptureDeviceInput = try? AVCaptureDeviceInput(device: safeCaptureDevice) else {
            return
        }
        
        device = safeCaptureDevice
        input = safeCaptureDeviceInput
        
        refocus()
        
        addInputDeviceToSession()
        
        createAndAddPreviewLayer()
        
        addOutputToInputDevice()
        
        overlayCardLens()
        
        startScanning()
    }
    
    func gainCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCaptureSession()
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupCaptureSession()
                }
            }
            
        case .denied, .restricted:
            // The user has previously denied access; or
            // The user can't grant access due to restrictions.
            fallthrough
            
        @unknown default:
            NSLog("Camera Permissions Error")
            dismiss(animated: true, completion: nil)
        }
    }
    
    func addInputDeviceToSession() {
        captureSession.addInput(input)
    }
    
    func createAndAddPreviewLayer() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
    }
    
    func addOutputToInputDevice() {
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.alwaysDiscardsLateVideoFrames = true
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Video Queue"))
        captureSession.addOutput(dataOutput)
    }
    
    func refocus() {
        do {
            try device.lockForConfiguration()
            device.focusMode = .autoFocus
        } catch {
            print(error)
        }
    }
    
    func overlayCardLens() {
        overlayBezierForCard()
        overlayTopSideIndicator()
    }
    
    func overlayBezierForCard() {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: CGRect(x: 64, y: 84, width: 300, height: 480), cornerRadius: 10).cgPath
        layer.strokeColor = UIColor.black.cgColor
        layer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(layer)
    }
    
    func overlayTopSideIndicator() {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: CGRect(x: 334, y: 94, width: 20, height: 20), cornerRadius: 20).cgPath
        layer.fillColor = UIColor.black.cgColor
        view.layer.addSublayer(layer)
    }
    
    public func startScanning() {
        // TODO: Turn on based on duration option in CardOptions
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//            self.stopScanning()
//            self.cameraDelegate?.cameraDidStopScanning(self)
//        }
        
        captureSession.startRunning()
    }
    
    public func stopScanning() {
        DispatchQueue.main.async {
            self.device.unlockForConfiguration()
            self.captureSession.stopRunning()
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let visionImage = VisionImage(buffer: sampleBuffer)

        visionImage.orientation = CameraViewController.imageOrientation(videoOrientation: connection.videoOrientation)

        let textRecognizer = TextRecognizer.textRecognizer()

        scansDroppedSinceLastReset += 1

        if scanDropLimitReached() {
            scansDroppedSinceLastReset = 0
            guard let result = try? textRecognizer.results(in: visionImage) else {
                NSLog("Text Recognizer", "Something went wrong while setting up TextRecognizer")
                return
            }

            cameraDelegate?.camera(self, didScan: result)
            refocus()
        }
    }
}

extension CameraViewController {
    func scanDropLimitReached() -> Bool {
        return scansDroppedSinceLastReset == CameraViewController.maxScansToDrop
    }
    
    static func imageOrientation(videoOrientation: AVCaptureVideoOrientation) -> UIImage.Orientation {
        switch videoOrientation {
        case .portrait:
            return .right
        case .portraitUpsideDown:
            return .left
        case .landscapeRight:
            return .up
        case .landscapeLeft:
            return .down
        @unknown default:
            return .up
        }
    }

    static func imageOrientation(
        deviceOrientation: UIDeviceOrientation,
        cameraPosition: AVCaptureDevice.Position
    ) -> UIImage.Orientation {
        switch deviceOrientation {
        case .portrait:
            return cameraPosition == .front ? .leftMirrored : .right
        case .landscapeLeft:
            return cameraPosition == .front ? .downMirrored : .up
        case .portraitUpsideDown:
            return cameraPosition == .front ? .rightMirrored : .left
        case .landscapeRight:
            return cameraPosition == .front ? .upMirrored : .down
        case .faceDown, .faceUp, .unknown:
            return .up
        @unknown default:
            return .up
        }
    }
}
