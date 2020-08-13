//
//  TableSettingsViewController.swift
//  ChipsProject
//
//  Created by Mateusz Zacharski on 03/08/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import UIKit

class TableSettingsViewController: UIViewController {
    var tableData = TableData.shared
    
    @IBOutlet var smallChips: RoundedButton!
    @IBOutlet var mediumChips: RoundedButton!
    @IBOutlet var largeChips: RoundedButton!
    
    @IBOutlet var oneBlind: RoundedButton!
    @IBOutlet var fiveBlind: RoundedButton!
    @IBOutlet var tenBlind: RoundedButton!
    
    @IBOutlet var namePlayers: RoundedButton!
    
    @IBOutlet var OKButton: RoundedButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func chooseSmallChips(_ sender: UIButton) {
        highlightChipsButtonSelection(sender: sender)
        tableData.startingChips = 500
    }
    @IBAction func chooseMediumChips(_ sender: UIButton) {
        highlightChipsButtonSelection(sender: sender)
        tableData.startingChips = 1000
    }
    @IBAction func chooseLargeChips(_ sender: UIButton) {
        highlightChipsButtonSelection(sender: sender)
        tableData.startingChips = 2000
    }
    
    @IBAction func chooseOneBlind(_ sender: UIButton) {
        highlightSmallBlindButtonSelection(sender: sender)
        tableData.smallBlind = 1
    }
    @IBAction func chooseFiveBlind(_ sender: UIButton) {
        highlightSmallBlindButtonSelection(sender: sender)
        tableData.smallBlind = 5
    }
    @IBAction func chooseTenBlind(_ sender: UIButton) {
        highlightSmallBlindButtonSelection(sender: sender)
        tableData.smallBlind = 10
    }
    
    @IBAction func chooseNamePlayers(_ sender: UIButton) {
        
        let ac = UIAlertController(title: "Name the players", message: nil, preferredStyle: .alert)
        addPlayersTextFields(for: ac)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            self?.tableData.playerNames.removeAll()
            for eachField in ac!.textFields! {
                if eachField.text! == "" {
                    self?.tableData.playerNames.append(eachField.placeholder!)
                } else {
                    self?.tableData.playerNames.append((eachField.text?.uppercased())!)
                }
            }
        })
        present(ac, animated: true)
    }
    
    @IBAction func chooseOKButton(_ sender: UIButton) {
        tableData.createPlayers()
    }
    
    
    func highlightChipsButtonSelection(sender: UIButton) {
        let allButtons = [smallChips, mediumChips, largeChips]
        
        for button in allButtons {
            button?.layer.borderColor = UIColor.black.cgColor
            button?.layer.borderWidth = 2
        }
        
        sender.layer.borderColor = UIColor.systemRed.cgColor
        sender.layer.borderWidth = 4
    }
    
    func highlightSmallBlindButtonSelection(sender: UIButton) {
        let allButtons = [oneBlind, fiveBlind, tenBlind]
        
        for button in allButtons {
            button?.layer.borderColor = UIColor.black.cgColor
            button?.layer.borderWidth = 2
        }
        
        sender.layer.borderColor = UIColor.systemRed.cgColor
        sender.layer.borderWidth = 4
    }
    
    func addPlayersTextFields(for alertController: UIAlertController) {
        let numberOfPlayers = tableData.numberOfPlayers
        if numberOfPlayers == 2 {
            alertController.addTextField()
            alertController.addTextField()
            alertController.textFields![0].placeholder = "PLAYER 1"
            alertController.textFields![1].placeholder = "PLAYER 2"
        } else if numberOfPlayers == 3 {
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.textFields![0].placeholder = "PLAYER 1"
            alertController.textFields![1].placeholder = "PLAYER 2"
            alertController.textFields![2].placeholder = "PLAYER 3"
        } else if numberOfPlayers == 4 {
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.textFields![0].placeholder = "PLAYER 1"
            alertController.textFields![1].placeholder = "PLAYER 2"
            alertController.textFields![2].placeholder = "PLAYER 3"
            alertController.textFields![3].placeholder = "PLAYER 4"
        } else if numberOfPlayers == 5 {
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.textFields![0].placeholder = "PLAYER 1"
            alertController.textFields![1].placeholder = "PLAYER 2"
            alertController.textFields![2].placeholder = "PLAYER 3"
            alertController.textFields![3].placeholder = "PLAYER 4"
            alertController.textFields![4].placeholder = "PLAYER 5"
        } else if numberOfPlayers == 6 {
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.textFields![0].placeholder = "PLAYER 1"
            alertController.textFields![1].placeholder = "PLAYER 2"
            alertController.textFields![2].placeholder = "PLAYER 3"
            alertController.textFields![3].placeholder = "PLAYER 4"
            alertController.textFields![4].placeholder = "PLAYER 5"
            alertController.textFields![5].placeholder = "PLAYER 6"
        } else if numberOfPlayers == 7 {
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.textFields![0].placeholder = "PLAYER 1"
            alertController.textFields![1].placeholder = "PLAYER 2"
            alertController.textFields![2].placeholder = "PLAYER 3"
            alertController.textFields![3].placeholder = "PLAYER 4"
            alertController.textFields![4].placeholder = "PLAYER 5"
            alertController.textFields![5].placeholder = "PLAYER 6"
            alertController.textFields![6].placeholder = "PLAYER 7"
        } else if numberOfPlayers == 8 {
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.textFields![0].placeholder = "PLAYER 1"
            alertController.textFields![1].placeholder = "PLAYER 2"
            alertController.textFields![2].placeholder = "PLAYER 3"
            alertController.textFields![3].placeholder = "PLAYER 4"
            alertController.textFields![4].placeholder = "PLAYER 5"
            alertController.textFields![5].placeholder = "PLAYER 6"
            alertController.textFields![6].placeholder = "PLAYER 7"
            alertController.textFields![7].placeholder = "PLAYER 8"
        } else {
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.addTextField()
            alertController.textFields![0].placeholder = "PLAYER 1"
            alertController.textFields![1].placeholder = "PLAYER 2"
            alertController.textFields![2].placeholder = "PLAYER 3"
            alertController.textFields![3].placeholder = "PLAYER 4"
            alertController.textFields![4].placeholder = "PLAYER 5"
            alertController.textFields![5].placeholder = "PLAYER 6"
            alertController.textFields![6].placeholder = "PLAYER 7"
            alertController.textFields![7].placeholder = "PLAYER 8"
            alertController.textFields![8].placeholder = "PLAYER 9"
        }
    }

}
