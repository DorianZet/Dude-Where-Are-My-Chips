//
//  ViewController.swift
//  ChipsProject
//
//  Created by Mateusz Zacharski on 31/07/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var playButton: RoundedButton!
    @IBOutlet var settingsButton: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createParticles()
    }
    
    @IBAction func tapSettingsButton(_ sender: UIButton) {
        performSegue(withIdentifier: "SettingsSegue", sender: sender)
    }
    func createParticles() {
        let particleEmitter = CAEmitterLayer() // we use it to create particles (like in SpriteKit).
        
        particleEmitter.emitterPosition = CGPoint(x: view.frame.width / 2.0, y: -50) // position it at the horizontal center of our view and just off the top.
        particleEmitter.emitterShape = .line // shape it like a line so that particles are created across the width of the view
        particleEmitter.emitterSize = CGSize(width: view.frame.width, height: 1) // make it as wide as the view but only one point high.
        particleEmitter.renderMode = .additive // .additive rendering means that overlapping particles will get brighter.
        
        let cell = CAEmitterCell() // define a particle by using CAEmitterCell().
        cell.birthRate = 20
        cell.lifetime = 4.0
        cell.velocity = 450
        cell.emissionLongitude = .pi
        cell.spin = 0.8
        cell.spinRange = 1.1
        cell.scale = 0.05
        cell.color = UIColor(white: 1, alpha: 1).cgColor
        cell.contents = UIImage(named: "chip")?.cgImage
        particleEmitter.emitterCells = [cell]
        
//        particleEmitter.emitterCells = here you can put an array of different cells (to have the chips multicolored, you will have [redCell, blueCell, yellowCell]).
        
        view.layer.addSublayer(particleEmitter)
        particleEmitter.zPosition = -5
        
        
    }

    @IBAction func unwindToTitle(_ sender: UIStoryboardSegue) {}

}

