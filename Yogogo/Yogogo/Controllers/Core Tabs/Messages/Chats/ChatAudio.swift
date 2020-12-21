//
//  ChatAudio.swift
//  Insdogram
//
//  Created by prince on 2020/12/21.
//

import Foundation
import AVFoundation

class ChatAudio {
    
    // MARK: -
    
    var recordingSession: AVAudioSession!
    
    var audioRecorder: AVAudioRecorder!
    
    var audioPlayer: AVAudioPlayer?
    
    var timer: Timer!
    
    var timePassed = 0
    
    // MARK: -
    
    func requestPermisson() -> Bool {
        var permission = false
        AVAudioSession.sharedInstance().requestRecordPermission { (status) in
            permission = status
        }
        return permission
    }
    
    // MARK: -
    
    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    // MARK: -
    
    func timePassedFrom(seconds: Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
