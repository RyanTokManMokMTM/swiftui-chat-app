//
//  SoundManager.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 22/7/2023.
//

import Foundation
import AVKit

class SoundManager : ObservableObject {
    static let shared = SoundManager()
    var player : AVAudioPlayer?
    
    func playSound(url : URL, repeatTime : Int = 50){
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = repeatTime
            player?.play()
        } catch let err {
            print(err.localizedDescription)
        }
    }
    func stopPlaying(){
        player?.stop()
        player = nil
    }
}


