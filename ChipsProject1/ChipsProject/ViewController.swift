//
//  ViewController.swift
//  ChipsProject
//
//  Created by Mateusz Zacharski on 31/07/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//
import AVFoundation
import UIKit
import GoogleMobileAds

class ViewController: UIViewController {
    @IBOutlet var playButton: RoundedButton!
    @IBOutlet var settingsButton: RoundedButton!
    @IBOutlet var aboutButton: RoundedButton!
    
    var chipsEmitter: CAEmitterLayer!
    
    var buttonAudioPlayer = AVAudioPlayer()
    
    var soundOn = true
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setExclusiveTouchForAllButtons()
        configureButtonsForDevice()
        
        buttonAudioPlayer.loadSounds(forSoundNames: ["bigButton.aiff"])
        checkForSound()
        
        view.backgroundColor = .darkGray
        createParticles()
        
    }
    
    @IBAction func tapPlayButton(_ sender: UIButton) {
        playSound(for: "bigButton.aiff")
    }
    @IBAction func tapSettingsButton(_ sender: UIButton) {
        playSound(for: "bigButton.aiff")
        performSegue(withIdentifier: "SettingsSegue", sender: sender)
    }
    @IBAction func tapAboutButton(_ sender: Any) {
        playSound(for: "bigButton.aiff")
        
        UIView.animate(withDuration: 0.2) {
            self.view.alpha = 0.8
        }
        
        let pm = PMAlertController(title: "ABOUT THIS APP", description: "Hi there! I'm Mateusz Zacharski,\nthe creator of this app. If you have any questions or requests, you can send them to mateusz.zacharski@gmail.com.\nDon't be a stranger!\n\nAll sounds are taken from BRAND NAME AUDIO YouTube channel with the author's permission.\n\n© 2020, Mateusz Zacharski. All rights reserved.", image: UIImage(named: "myPhoto.png"), style: .alert)
        
        pm.alertView.backgroundColor = .darkGray
        pm.alertImage.backgroundColor = .darkGray
        pm.alertView.layer.cornerRadius = 0
        pm.alertView.layer.borderWidth = 4
        pm.alertView.layer.shadowColor = UIColor.clear.cgColor
        pm.alertView.layer.borderColor = UIColor.black.cgColor
        pm.alertView.layer.masksToBounds = true
        pm.alertDescription.textColor = .systemYellow
        
        let okAct = PMAlertAction(title: "OK", style: .default) { [weak self] in
            UIView.animate(withDuration: 0.2) {
                self?.view.alpha = 1
            }
        }
        okAct.setTitleColor(.systemYellow, for: .normal)
        
        pm.addAction(okAct)

        pm.gravityDismissAnimation = false
        
        present(pm, animated: true)
    }
    func createParticles() {
        chipsEmitter = CAEmitterLayer() // we use it to create particles (like in SpriteKit).
        
        chipsEmitter.emitterPosition = CGPoint(x: view.frame.width / 2.0, y: -50) // position it at the horizontal center of our view and just off the top.
        chipsEmitter.emitterShape = .line // shape it like a line so that particles are created across the width of the view
        chipsEmitter.emitterSize = CGSize(width: view.frame.width, height: 1) // make it as wide as the view but only one point high.
        chipsEmitter.renderMode = .backToFront // .backToFront rendering means that overlapping particles will render in different zPositions.
        
        let cell = CAEmitterCell() // define a particle by using CAEmitterCell().
        cell.birthRate = 10
        cell.lifetime = 4.0
        cell.velocity = 400
        cell.emissionLongitude = .pi
        cell.spin = 0.8
        cell.spinRange = 1.1
        cell.color = UIColor(white: 1, alpha: 1).cgColor
        
        let defaults = UserDefaults.standard
        let version = defaults.string(forKey: "version")
        
        if version == "ukChips" {
            cell.scale = cell.scale / UIScreen.main.scale
            cell.scale *= 1.1
            cell.contents = UIImage(named: "chipUK")?.cgImage
            
        } else if version == "usChips" {
            cell.scale = cell.scale / UIScreen.main.scale
            cell.scale *= 0.33
            cell.contents = UIImage(named: "chipUS")?.cgImage
        } else {
            defaults.set("usChips", forKey: "version")
            cell.scale = cell.scale / UIScreen.main.scale
            cell.scale *= 0.33
            cell.contents = UIImage(named: "chipUS")?.cgImage
        }

        
        chipsEmitter.emitterCells = [cell]
        
        view.layer.addSublayer(chipsEmitter)
        chipsEmitter.zPosition = -5
    }
    
    
    
    func playSound(for fileString: String) {
        if soundOn == true {
            let path = Bundle.main.path(forResource: fileString, ofType: nil)
            if let path = path {
                let url = URL(fileURLWithPath: path)
                
                do {
                    buttonAudioPlayer = try AVAudioPlayer(contentsOf: url)
                    buttonAudioPlayer.play()
                    buttonAudioPlayer.volume = 0.09
                } catch {
                    print("couldn't load the file \(fileString)")
                }
            } else {
                print("path couldnt be found")
            }
        }
    }
    
    func checkForSound() {
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
    
    func setExclusiveTouchForAllButtons() {
        for subview in self.view.subviews {
            if subview is UIButton {
                let button = subview as! UIButton
                button.isExclusiveTouch = true
            }
        }
    }
    
    func configureButtonsForDevice() {
        let allButtons = [playButton, settingsButton, aboutButton]
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            for eachButton in allButtons {
                eachButton?.titleLabel?.font = UIFont(name: "PixelEmulator", size: 17)
            }
        } else {
            for eachButton in allButtons {
                eachButton?.titleLabel?.font = UIFont(name: "PixelEmulator", size: 25)
            }
        }
    }

    @IBAction func unwindToTitle(_ sender: UIStoryboardSegue) {}

}

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
