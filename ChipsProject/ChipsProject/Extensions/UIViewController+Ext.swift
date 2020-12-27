//
//  UIViewController+Ext.swift
//  ChipsProject
//
//  Created by Mateusz Zacharski on 27/12/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import UIKit
import AVFoundation

extension UIViewController {
    func checkForSound(sound soundOn: inout Bool) {
        let defaults = UserDefaults.standard
        let sound = defaults.string(forKey: "sound")
        
        if sound == "soundOn" {
            soundOn = true
        } else if sound == "soundOff" {
            soundOn = false
        } else {
            defaults.set("soundOn", forKey: "sound")
            soundOn = true
        }
    }
    
    func playSound(isSoundOn soundOn: Bool, for fileString: String, inAudioPlayer audioPlayer: inout AVAudioPlayer) {
        if soundOn == true {
            let path = Bundle.main.path(forResource: fileString, ofType: nil)
            if let path = path {
                let url = URL(fileURLWithPath: path)
                
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer.play()
                    audioPlayer.volume = 0.09
                } catch {
                    print("couldn't load the file \(fileString)")
                }
            } else {
                print("path couldn't be found")
            }
        }
    }
}

