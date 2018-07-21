//
//  ViewController.swift
//  hackinit2018-AI-Object-Detection-for-Blind
//
//  Created by 王传正 on 2018/7/16.
//  Copyright © 2018年 Maverick. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    private let captureDevice = AVCaptureDevice.default(for: .video)!
    private let imageProcessor = ImageProcessor()
    private let tts = TTSProcessor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageProcessor.delegate = self
        imageProcessor.setupCaptureSession()
    }
    
    @IBAction func toggleFlash(_ sender: UIButton) {
        try! captureDevice.lockForConfiguration()
        let torchIsOn = captureDevice.torchMode == .on
        captureDevice.torchMode = torchIsOn ? .off : .on
        captureDevice.unlockForConfiguration()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

extension CameraViewController: ImageProcessorDelegate {
    
    func setupCameraView(with layer: AVCaptureVideoPreviewLayer) {
        let layerToAdd = layer
        layerToAdd.frame = cameraView.bounds
        cameraView.layer.addSublayer(layerToAdd)
    }
    
    func setResultLabelText(to text: String) {
        resultLabel.text = text
    }
    
    func speak() {
        DispatchQueue.main.async {
            self.tts.speak(text: self.resultLabel.text!)
        }
    }
    
}
