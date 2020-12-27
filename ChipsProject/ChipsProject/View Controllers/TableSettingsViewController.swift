//
//  TableSettingsViewController.swift
//  ChipsProject
//
//  Created by Mateusz Zacharski on 03/08/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//
import AVFoundation
import UIKit

class TableSettingsViewController: UIViewController {
    var tableData: TableData!
    
    let maximumNumberOfPlayers = 9
    let minimumNumberOfPlayers = 2
    var currentNumberOfPlayers = 2
    
    let maximumStartingChips = 10000
    let minimumStartingChips = 500
    var currentStartingChips = 500
    
    let maximumSmallBlind = 100
    let minimumSmallBlind = 5
    var currentSmallBlind = 5
    
    var buttonAudioPlayer = AVAudioPlayer()

    @IBOutlet var viewInScrollView: UIView!
    
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
    
    @IBOutlet var blindsTitleLabel: UILabel!
    @IBOutlet var startingChipsTitleLabel: UILabel!
    @IBOutlet var tableSettingsTitleLabel: UILabel!
    @IBOutlet var numberOfPlayersTitleLabel: UILabel!
    
    @IBOutlet var numbeOfPlayersAboveTitle: UILabel!
    @IBOutlet var startingChipsAboveTitle: UILabel!
    @IBOutlet var blindsAboveTitle: UILabel!
    
    var soundOn = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.global().async {
            self.tableData = TableData()
            self.checkForSound(sound: &self.soundOn)
            self.buttonAudioPlayer.loadSounds(forSoundNames: ["bigButton.aiff", "smallButton.aiff"])
        }

        view.backgroundColor = .darkGray
        viewInScrollView.backgroundColor = .darkGray
        configureButtonsAndLabels()
        
        numberOfPlayersLabel.text = "\(currentNumberOfPlayers) PLAYERS"
        startingChipsLabel.text = "500"
        blindsLabel.text = "5/10"
        
        DispatchQueue.global().async {
            self.tableData.numberOfPlayers = self.minimumNumberOfPlayers
            self.tableData.startingChips = self.minimumStartingChips
            self.tableData.smallBlind = self.minimumSmallBlind
        }
        
        let labels = [blindsTitleLabel, startingChipsTitleLabel, tableSettingsTitleLabel, numberOfPlayersTitleLabel]
        
        for eachLabel in labels {
            eachLabel?.textColor = .systemYellow
        }
        
    }
    
    @IBAction func tapMinusOnePlayersButton(_ sender: UIButton) {
        playSound(isSoundOn: soundOn, for: "smallButton.aiff", inAudioPlayer: &buttonAudioPlayer)

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
        playSound(isSoundOn: soundOn, for: "smallButton.aiff", inAudioPlayer: &buttonAudioPlayer)

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
        playSound(isSoundOn: soundOn, for: "smallButton.aiff", inAudioPlayer: &buttonAudioPlayer)

        currentStartingChips -= 500

        if currentStartingChips < minimumStartingChips {
            currentStartingChips = maximumStartingChips
        }
        tableData.startingChips = currentStartingChips
        startingChipsLabel.text = "\(currentStartingChips)"
    }
    
    @IBAction func tapPlusChipsButton(_ sender: Any) {
        playSound(isSoundOn: soundOn, for: "smallButton.aiff", inAudioPlayer: &buttonAudioPlayer)

        currentStartingChips += 500

        if currentStartingChips > maximumStartingChips {
            currentStartingChips = minimumStartingChips
        }
        tableData.startingChips = currentStartingChips
        startingChipsLabel.text = "\(currentStartingChips)"
    }
    
    @IBAction func tapMinusBlindsButton(_ sender: Any) {
        playSound(isSoundOn: soundOn, for: "smallButton.aiff", inAudioPlayer: &buttonAudioPlayer)

        currentSmallBlind -= 5

        if currentSmallBlind < minimumSmallBlind {
            currentSmallBlind = maximumSmallBlind
        }
        tableData.smallBlind = currentSmallBlind
        blindsLabel.text = "\(currentSmallBlind)/\(currentSmallBlind * 2)"
    }
    
    @IBAction func tapPlusBlindsButton(_ sender: Any) {
        playSound(isSoundOn: soundOn, for: "smallButton.aiff", inAudioPlayer: &buttonAudioPlayer)

        currentSmallBlind += 5

        if currentSmallBlind > maximumSmallBlind {
            currentSmallBlind = minimumSmallBlind
        }
        tableData.smallBlind = currentSmallBlind
        blindsLabel.text = "\(currentSmallBlind)/\(currentSmallBlind * 2)"
    }
    
    @IBAction func chooseNamePlayers(_ sender: UIButton) {
        playSound(isSoundOn: soundOn, for: "bigButton.aiff", inAudioPlayer: &buttonAudioPlayer)

        let ac = UIAlertController(title: "NAME THE PLAYERS", message: nil, preferredStyle: .alert)
        if #available(iOS 13.0, *) {
            ac.overrideUserInterfaceStyle = .dark
        }
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

        ac.addAction(cancelAction)
        ac.addAction(okAction)
        present(ac, animated: true)
    }
    
    @IBAction func chooseBackButton(_ sender: UIButton) {
        playSound(isSoundOn: soundOn, for: "bigButton.aiff", inAudioPlayer: &buttonAudioPlayer)

        performSegue(withIdentifier: "UnwindToChoosePlayersSegue", sender: sender)
    }
    
    @IBAction func chooseOKButton(_ sender: UIButton) {
        playSound(isSoundOn: soundOn, for: "bigButton.aiff", inAudioPlayer: &buttonAudioPlayer)

        if tableData.smallBlind >= 1 && tableData.startingChips >= 500 {
            
            DispatchQueue.global().async {
                self.tableData.createPlayers()

                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "PokerTableSegue", sender: sender)
                }
            }
        } else {
            return
        }
        
    }

    func addPlayersTextFields(for alertController: UIAlertController) {
        let numberOfPlayers = tableData.numberOfPlayers
        
        for index in 1 ... numberOfPlayers {
            alertController.addTextField(configurationHandler: { textField in
                textField.placeholder = "PLAYER \(index)"
                textField.autocapitalizationType = .allCharacters
                textField.delegate = self
            })
        }
    }
    
    func addPlayersTextFields(for alertController: PMAlertController) {
        let numberOfPlayers = tableData.numberOfPlayers
        
        for index in 1 ... numberOfPlayers {
            alertController.addTextField { (textField) in
                textField?.placeholder = "PLAYER \(index)"
                textField?.font = UIFont(name: "Pixel Emulator", size: 10)
                textField?.textColor = .systemYellow
                textField?.delegate = self
            }
        }
    }
    
    func configureButtonsAndLabels() {
        let plusAndMinusButtons = [minusOnePlayersButton, plusOnePlayersButton, minusBlindsButton, plusBlindsButton, minusChipsButton, plusChipsButton]
        
        for eachButton in plusAndMinusButtons {
            eachButton?.layer.borderColor = UIColor.clear.cgColor
            eachButton?.layer.borderWidth = 0
            eachButton?.backgroundColor = .clear
        }
        
        let labels = [numberOfPlayersLabel, blindsLabel, startingChipsLabel, blindsAboveTitle, startingChipsAboveTitle, numbeOfPlayersAboveTitle]
        
        let allButtons = [minusOnePlayersButton, plusOnePlayersButton, plusChipsButton, minusChipsButton, plusBlindsButton, minusBlindsButton, namePlayers, backButton, OKButton]
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            for eachLabel in labels {
                eachLabel?.font = UIFont(name: "Pixel Emulator", size: 17)
            }
            tableSettingsTitleLabel.font = UIFont(name: "Pixel Emulator", size: 22)
            
            for eachButton in allButtons {
                eachButton?.titleLabel?.font = UIFont(name: "Pixel Emulator", size: 17)
            }
        } else {

            for eachLabel in labels {
                eachLabel?.font = UIFont(name: "Pixel Emulator", size: 25)
            }
            tableSettingsTitleLabel.font = UIFont(name: "Pixel Emulator", size: 33)
            
            for eachButton in allButtons {
                eachButton?.titleLabel?.font = UIFont(name: "Pixel Emulator", size: 25)
            }
        }
        
        // Setting titleEdgeInsets for really small buttons, e.g. on iPhone SE 2016:
        OKButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        OKButton.titleLabel?.adjustsFontSizeToFitWidth = true
        OKButton.titleLabel?.numberOfLines = 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PokerTableSegue" {
            let destVC = segue.destination as! PokerTableViewController
            destVC.tableData = tableData
        }
    }
    
}

extension TableSettingsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        // make sure the result is under 16 characters
        return updatedText.count <= 10
    }
}
