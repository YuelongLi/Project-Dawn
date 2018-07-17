//
//  TTSProcessor.swift
//  hackinit2018-AI-Object-Detection-for-Blind
//
//  Created by 王传正 on 2018/7/16.
//  Copyright © 2018年 Maverick. All rights reserved.
//

import UIKit
import AVFoundation

class TTSProcessor {
    
    private let synthesizer = AVSpeechSynthesizer()
    
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        synthesizer.speak(utterance)
    }
    
}
