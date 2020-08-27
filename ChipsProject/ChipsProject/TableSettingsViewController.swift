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
    
    @IBOutlet var backButton: RoundedButton!
    @IBOutlet var OKButton: RoundedButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        let buttons = [smallChips, mediumChips, largeChips, oneBlind, fiveBlind, tenBlind, namePlayers, backButton, OKButton]
        
        for eachButton in buttons {
            eachButton?.titleLabel?.font = UIFont(name: "Pixel Emulator", size: 17)
        }
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
        
        for index in 1 ... numberOfPlayers {
            alertController.addTextField(configurationHandler: { textField in
                textField.placeholder = "PLAYER \(index)"
                textField.font = UIFont(name: "Pixel Emulator", size: 10)
            })
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
