//
//  ChoosePlayersViewController.swift
//  ChipsProject
//
//  Created by Mateusz Zacharski on 03/08/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import UIKit

class ChoosePlayersViewController: UIViewController {
    var tableData = TableData.shared
    
    @IBOutlet var twoPlayers: RoundedButton!
    @IBOutlet var threePlayers: RoundedButton!
    @IBOutlet var fourPlayers: RoundedButton!
    @IBOutlet var fivePlayers: RoundedButton!
    @IBOutlet var sixPlayers: RoundedButton!
    @IBOutlet var sevenPlayers: RoundedButton!
    @IBOutlet var eightPlayers: RoundedButton!
    @IBOutlet var ninePlayers: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    
    @IBAction func choose2Players(_ sender: UIButton) {
        tableData.numberOfPlayers = 2
        highlightButtonSelection(sender: sender)
    }
    @IBAction func choose3Players(_ sender: UIButton) {
        tableData.numberOfPlayers = 3
        highlightButtonSelection(sender: sender)
    }
    @IBAction func choose4Players(_ sender: UIButton) {
        tableData.numberOfPlayers = 4
        highlightButtonSelection(sender: sender)
    }
    @IBAction func choose5Players(_ sender: UIButton) {
        tableData.numberOfPlayers = 5
        highlightButtonSelection(sender: sender)
    }
    @IBAction func choose6Players(_ sender: UIButton) {
        tableData.numberOfPlayers = 6
        highlightButtonSelection(sender: sender)
    }
    @IBAction func choose7Players(_ sender: UIButton) {
        tableData.numberOfPlayers = 7
        highlightButtonSelection(sender: sender)
    }
    @IBAction func choose8Players(_ sender: UIButton) {
        tableData.numberOfPlayers = 8
        highlightButtonSelection(sender: sender)
    }
    @IBAction func choose9Players(_ sender: UIButton) {
        tableData.numberOfPlayers = 9
        highlightButtonSelection(sender: sender)
    }
    
    func highlightButtonSelection(sender: UIButton) {
        let allButtons = [twoPlayers, threePlayers, fourPlayers, fivePlayers, sixPlayers, sevenPlayers, eightPlayers, ninePlayers]
        
        for button in allButtons {
            button?.layer.borderColor = UIColor.black.cgColor
            button?.layer.borderWidth = 2

        }
        
        sender.layer.borderColor = UIColor.systemRed.cgColor
        sender.layer.borderWidth = 4
    }
    
    @IBAction func unwindToChoosePlayers(_ sender: UIStoryboardSegue) {}

}
