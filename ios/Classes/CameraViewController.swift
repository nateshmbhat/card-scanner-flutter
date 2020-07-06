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

    @IBOutlet weak var cameraView: UIView!

    public override func viewDidLoad() {
        super.viewDidLoad()

        gainCameraPermission()

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

        captureSession.addInput(input)

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame

        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.alwaysDiscardsLateVideoFrames = true
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Video Queue"))
        captureSession.addOutput(dataOutput)

        startScanning()
    }

    func refocus() {
        do {
            try device.lockForConfiguration()
            device.focusMode = .autoFocus
        } catch {
            print(error)
        }
    }

    func gainCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.setupCaptureSession()

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
            print("Camera Permissions Error")
            dismiss(animated: true, completion: nil)
        }
    }

    func startScanning() {

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.stopScanning()
            self.cameraDelegate?.cameraDidStopScanning(self)
        }

        captureSession.startRunning()
    }

    func stopScanning() {
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
                print("Text Recognizer", "Something went wrong while setting up TextRecognizer")
                return
            }

            cameraDelegate?.camera(self, didScan: result)
            refocus()
        }
    }

    func scanDropLimitReached() -> Bool {
        return scansDroppedSinceLastReset == CameraViewController.maxScansToDrop
    }
}

extension CameraViewController {
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
