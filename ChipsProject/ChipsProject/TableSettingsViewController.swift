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
    let maximumNumberOfPlayers = 9
    let minimumNumberOfPlayers = 2
    var currentNumberOfPlayers = 2
    
    let maximumStartingChips = 10000
    let minimumStartingChips = 500
    var currentStartingChips = 500
    
    let maximumSmallBlind = 100
    let minimumSmallBlind = 5
    var currentSmallBlind = 5
    
    @IBOutlet var numberOfPlayersLabel: UILabel!
    @IBOutlet var plusOnePlayersButton: UIButton!
    @IBOutlet var minusOnePlayersButton: UIButton!
    
    @IBOutlet var startingChipsLabel: RoundedLabel!
    @IBOutlet var plusChipsButton: UIButton!
    @IBOutlet var minusChipsButton: UIButton!
    
    @IBOutlet var blindsLabel: RoundedLabel!
    @IBOutlet var plusBlindsButton: UIButton!
    @IBOutlet var minusBlindsButton: UIButton!
        
    @IBOutlet var namePlayers: RoundedButton!
    
    @IBOutlet var backButton: RoundedButton!
    @IBOutlet var OKButton: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureButtons()
        
        numberOfPlayersLabel.text = "\(currentNumberOfPlayers) PLAYERS"
        startingChipsLabel.text = "500"
        blindsLabel.text = "5/10"
        
        tableData.numberOfPlayers = minimumNumberOfPlayers
        tableData.startingChips = minimumStartingChips
        tableData.smallBlind = minimumSmallBlind
    }
    
    @IBAction func tapMinusOnePlayersButton(_ sender: UIButton) {
        currentNumberOfPlayers -= 1
        if tableData.playerNames != ["PLAYER 1", "PLAYER 2", "PLAYER 3", "PLAYER 4", "PLAYER 5", "PLAYER 6", "PLAYER 7", "PLAYER 8", "PLAYER 9"] {
            tableData.playerNames = ["PLAYER 1", "PLAYER 2", "PLAYER 3", "PLAYER 4", "PLAYER 5", "PLAYER 6", "PLAYER 7", "PLAYER 8", "PLAYER 9"]
        }

        if currentNumberOfPlayers < minimumNumberOfPlayers {
            currentNumberOfPlayers = maximumNumberOfPlayers
        }
        tableData.numberOfPlayers = currentNumberOfPlayers
        numberOfPlayersLabel.text = "\(currentNumberOfPlayers) PLAYERS"
    }
    @IBAction func tapPlusOnePlayersButton(_ sender: UIButton) {
        currentNumberOfPlayers += 1

        if tableData.playerNames != ["PLAYER 1", "PLAYER 2", "PLAYER 3", "PLAYER 4", "PLAYER 5", "PLAYER 6", "PLAYER 7", "PLAYER 8", "PLAYER 9"] {
            tableData.playerNames = ["PLAYER 1", "PLAYER 2", "PLAYER 3", "PLAYER 4", "PLAYER 5", "PLAYER 6", "PLAYER 7", "PLAYER 8", "PLAYER 9"]
        }

        if currentNumberOfPlayers > maximumNumberOfPlayers {
            currentNumberOfPlayers = minimumNumberOfPlayers
        }
        tableData.numberOfPlayers = currentNumberOfPlayers
        numberOfPlayersLabel.text = "\(currentNumberOfPlayers) PLAYERS"
    }
    
    
    @IBAction func tapMinusChipsButton(_ sender: Any) {
        currentStartingChips -= 500

        if currentStartingChips < minimumStartingChips {
            currentStartingChips = maximumStartingChips
        }
        tableData.startingChips = currentStartingChips
        startingChipsLabel.text = "\(currentStartingChips)"
    }
    @IBAction func tapPlusChipsButton(_ sender: Any) {
        currentStartingChips += 500

        if currentStartingChips > maximumStartingChips {
            currentStartingChips = minimumStartingChips
        }
        tableData.startingChips = currentStartingChips
        startingChipsLabel.text = "\(currentStartingChips)"
    }
    
    @IBAction func tapMinusBlindsButton(_ sender: Any) {
        currentSmallBlind -= 5

        if currentSmallBlind < minimumSmallBlind {
            currentSmallBlind = maximumSmallBlind
        }
        tableData.smallBlind = currentSmallBlind
        blindsLabel.text = "\(currentSmallBlind)/\(currentSmallBlind * 2)"
    }
    @IBAction func tapPlusBlindsButton(_ sender: Any) {
        currentSmallBlind += 5

        if currentSmallBlind > maximumSmallBlind {
            currentSmallBlind = minimumSmallBlind
        }
        tableData.smallBlind = currentSmallBlind
        blindsLabel.text = "\(currentSmallBlind)/\(currentSmallBlind * 2)"
    }
    
    @IBAction func chooseNamePlayers(_ sender: UIButton) {
        
        let ac = UIAlertController(title: "Name the players", message: nil, preferredStyle: .alert)
        ac.setTitleT(font: UIFont(name: "Pixel Emulator", size: 15), color: .black)
        addPlayersTextFields(for: ac)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            self?.tableData.playerNames.removeAll()
            for eachField in ac!.textFields! {
                if eachField.text! == "" {
                    self?.tableData.playerNames.append(eachField.placeholder!)
                } else {
                    self?.tableData.playerNames.append((eachField.text?.uppercased())!)
                }
            }
        }
        
        cancelAction.titleTextColor = .black
        okAction.titleTextColor = .black

        ac.addAction(cancelAction)
        ac.addAction(okAction)
        present(ac, animated: true)
    }
    
    @IBAction func chooseBackButton(_ sender: UIButton) {
        performSegue(withIdentifier: "UnwindToChoosePlayersSegue", sender: sender)
        
    }
    @IBAction func chooseOKButton(_ sender: UIButton) {
        if tableData.smallBlind >= 1 && tableData.startingChips >= 500 {
            tableData.createPlayers()
            performSegue(withIdentifier: "PokerTableSegue", sender: sender)
        } else {
            return
        }
        
    }

    func addPlayersTextFields(for alertController: UIAlertController) {
        let numberOfPlayers = tableData.numberOfPlayers
        
        for index in 1 ... numberOfPlayers {
            alertController.addTextField(configurationHandler: { textField in
                textField.placeholder = "PLAYER \(index)"
                textField.font = UIFont(name: "Pixel Emulator", size: 10)
            })
        }
    }
    
    func configureButtons() {
        let plusAndMinusButtons = [minusOnePlayersButton, plusOnePlayersButton, minusBlindsButton, plusBlindsButton, minusChipsButton, plusChipsButton]
        
        for eachButton in plusAndMinusButtons {
            eachButton?.layer.borderColor = UIColor.clear.cgColor
            eachButton?.layer.borderWidth = 0
            eachButton?.backgroundColor = .clear
        }
        
        let allButtons = [minusOnePlayersButton, plusOnePlayersButton, plusChipsButton, minusChipsButton, plusBlindsButton, minusBlindsButton, namePlayers, backButton, OKButton]
        
        for eachButton in allButtons {
            eachButton?.titleLabel?.font = UIFont(name: "Pixel Emulator", size: 17)
        }
        
        let labels = [numberOfPlayersLabel, blindsLabel, startingChipsLabel]
        
        for eachLabel in labels {
            eachLabel?.font = UIFont(name: "Pixel Emulator", size: 17)
        }
    }
}

extension UIAlertController {
    
    //Set background color of UIAlertController
    func setBackgroundColor(color: UIColor) {
        if let bgView = self.view.subviews.first, let groupView = bgView.subviews.first, let contentView = groupView.subviews.first {
            contentView.backgroundColor = color
        }
    }
    
    //Set title font and title color
    func setTitleT(font: UIFont?, color: UIColor?) {
        guard let title = self.title else { return }
        let attributeString = NSMutableAttributedString(string: title)//1
        if let titleFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font : titleFont],//2
                                          range: NSMakeRange(0, title.utf8.count))
        }
        
        if let titleColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : titleColor],//3
                                          range: NSMakeRange(0, title.utf8.count))
        }
        self.setValue(attributeString, forKey: "attributedTitle")//4
    }
    
    //Set message font and message color
    func setMessage(font: UIFont?, color: UIColor?) {
        guard let message = self.message else { return }
        let attributeString = NSMutableAttributedString(string: message)
        if let messageFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font : messageFont],
                                          range: NSMakeRange(0, message.utf8.count))
        }
        
        if let messageColorColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor : messageColorColor],
                                          range: NSMakeRange(0, message.utf8.count))
        }
        self.setValue(attributeString, forKey: "attributedMessage")
    }
    
    //Set tint color of UIAlertController
    func setTint(color: UIColor) {
        self.view.tintColor = color
    }
}

extension UIAlertAction {
    var titleTextColor: UIColor? {
        get { return self.value(forKey: "titleTextColor") as? UIColor }
        set { self.setValue(newValue, forKey: "titleTextColor") }
    }
}
