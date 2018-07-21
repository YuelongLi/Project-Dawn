//
//  ImageProcessor.swift
//  hackinit2018-AI-Object-Detection-for-Blind
//
//  Created by 王传正 on 2018/7/16.
//  Copyright © 2018年 Maverick. All rights reserved.
//

import UIKit
import AVFoundation

protocol ImageProcessorDelegate: class {
    func setupCameraView(with layer: AVCaptureVideoPreviewLayer)
}

class ImageProcessor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private let captureSession = AVCaptureSession()
    private let captureDevice = AVCaptureDevice.default(for: .video)!
    private var capturedFrame = UIImage()
    
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
        capturedFrame = imageFromSampleBuffer(sampleBuffer: sampleBuffer)
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage {
        
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let ciContext = CIContext()
        let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent)
        let image = UIImage(cgImage: cgImage!)
        
        return image
        
    }
    
}
