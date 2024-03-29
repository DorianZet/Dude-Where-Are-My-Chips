//
//  SettingsViewController.swift
//  ChipsProject
//
//  Created by Mateusz Zacharski on 03/08/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import AVFoundation
import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var usButton: UIButton!
    @IBOutlet var ukButton: UIButton!
    
    var buttonAudioPlayer = AVAudioPlayer()
    
    var soundOn = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForSound(sound: &soundOn)
        
        buttonAudioPlayer.loadSounds(forSoundNames: ["bigButton.aiff"])
        view.backgroundColor = .darkGray

        usButton.layer.borderColor = UIColor.black.cgColor
        usButton.layer.borderWidth = 4
            
        ukButton.layer.borderColor = UIColor.black.cgColor
        ukButton.layer.borderWidth = 4
        
        configureButtonsForDevice()
        
        titleLabel.textColor = .systemYellow
        subtitleLabel.textColor = .systemYellow
        
        titleLabel.text = "SETTINGS"
        subtitleLabel.text = "NO, SERIOUSLY, THESE ARE THE SETTINGS!"
    }
    
    @IBAction func tapBackButton(_ sender: UIButton) {
        playSound(isSoundOn: soundOn, for: "bigButton.aiff", inAudioPlayer: &buttonAudioPlayer)
        performSegue(withIdentifier: "UnwindToTitleSegue", sender: sender)
    }
    
    @IBAction func tapUsButton(_ sender: Any) {
        playSound(isSoundOn: soundOn, for: "bigButton.aiff", inAudioPlayer: &buttonAudioPlayer)

        let defaults = UserDefaults.standard
        defaults.set("usChips", forKey: "version")
        UIView.animate(withDuration: 0.2) {
            self.usButton.layer.borderColor = UIColor.systemYellow.cgColor
            self.ukButton.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    @IBAction func tapUkButton(_ sender: Any) {
        playSound(isSoundOn: soundOn, for: "bigButton.aiff", inAudioPlayer: &buttonAudioPlayer)

        let defaults = UserDefaults.standard
        defaults.set("ukChips", forKey: "version")
        
        UIView.animate(withDuration: 0.2) {
            self.ukButton.layer.borderColor = UIColor.systemYellow.cgColor
            self.usButton.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    func configureButtonsForDevice() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            titleLabel.font = UIFont(name: "PixelEmulator", size: 22)
            subtitleLabel.font = UIFont(name: "PixelEmulator", size: 13)
            backButton.titleLabel?.font = UIFont(name: "PixelEmulator", size: 17)
        } else {
            titleLabel.font = UIFont(name: "PixelEmulator", size: 33)
            subtitleLabel.font = UIFont(name: "PixelEmulator", size: 19)
            backButton.titleLabel?.font = UIFont(name: "PixelEmulator", size: 25)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UnwindToTitleSegue" {
            
            let destVC = segue.destination as! ViewController
            destVC.chipsEmitter.removeFromSuperlayer()
            destVC.createParticles()
        }
    }
    
}
