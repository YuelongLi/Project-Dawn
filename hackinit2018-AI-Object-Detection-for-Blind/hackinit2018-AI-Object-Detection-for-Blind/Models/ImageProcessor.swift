//
//  ImageProcessor.swift
//  hackinit2018-AI-Object-Detection-for-Blind
//
//  Created by 王传正 on 2018/7/16.
//  Copyright © 2018年 Maverick. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

protocol ImageProcessorDelegate: class {
    func setupCameraView(with layer: AVCaptureVideoPreviewLayer)
    func setResultLabelText(to text: String)
    func speak()
}

class ImageProcessor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private let captureSession = AVCaptureSession()
    private let captureDevice = AVCaptureDevice.default(for: .video)!
    private var capturedFrame = UIImage()
    private var calibrationList = [String]()
    
    weak var delegate: ImageProcessorDelegate?
    
    func setupCaptureSession() {
        
        let input = try! AVCaptureDeviceInput(device: captureDevice)
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoQueue"))
        let connection = output.connection(with: .video)
        connection?.videoOrientation = .portrait
        captureSession.addInput(input)
        captureSession.addOutput(output)
        
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        delegate?.setupCameraView(with: layer)
        
        captureSession.startRunning()
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let capturedFrame = imageFromSampleBuffer(sampleBuffer: sampleBuffer)
        detect(capturedFrame)
        delegate?.speak()
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CIImage {

        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!

        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
//        let ciContext = CIContext()
//        let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent)
//        let image = UIImage(cgImage: cgImage!)

        return ciImage

    }
    
    private func detect(_ image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Cannot load Places ML model")
        }
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                    fatalError("Unexpected result type from VNCoreMLRequest")
            }
            DispatchQueue.main.async {
                self?.delegate?.setResultLabelText(to: topResult.identifier)
//                if self?.calibrationList.count == 10 {
//                    self?.calibrationList.removeFirst()
//                }
//                self?.calibrationList.append(topResult.identifier)
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
        
    }
    
}
