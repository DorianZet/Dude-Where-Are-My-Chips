//
//  AVAudioPlayer+Ext.swift
//  ChipsProject
//
//  Created by Mateusz Zacharski on 27/12/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import AVFoundation

extension AVAudioPlayer {
    func loadSounds(forSoundNames soundStrings: [String]) {
        var player = self
        for each in soundStrings {
            let path = Bundle.main.path(forResource: each, ofType: nil)
            if let path = path {
                let url = URL(fileURLWithPath: path)
                do {
                    player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    print("\(each) sound loaded!")
                } catch {
                    print("couldn't load the file \(each)")
                }
            }
        }
    }
}
