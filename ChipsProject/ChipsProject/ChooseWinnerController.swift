//
//  ChooseWinnerController.swift
//  ChipsProject
//
//  Created by Mateusz Zacharski on 10/08/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import UIKit

class ChooseWinnerController: UIViewController {
    @IBOutlet var p1Button: RoundedButton!
    @IBOutlet var p2Button: RoundedButton!
    @IBOutlet var p3Button: RoundedButton!
    @IBOutlet var p4Button: RoundedButton!
    @IBOutlet var p5Button: RoundedButton!
    @IBOutlet var p6Button: RoundedButton!
    @IBOutlet var p7Button: RoundedButton!
    @IBOutlet var p8Button: RoundedButton!
    @IBOutlet var p9Button: RoundedButton!
    
    @IBOutlet var p1Score: RoundedLabel!
    @IBOutlet var p2Score: RoundedLabel!
    @IBOutlet var p3Score: RoundedLabel!
    @IBOutlet var p4Score: RoundedLabel!
    @IBOutlet var p5Score: RoundedLabel!
    @IBOutlet var p6Score: RoundedLabel!
    @IBOutlet var p7Score: RoundedLabel!
    @IBOutlet var p8Score: RoundedLabel!
    @IBOutlet var p9Score: RoundedLabel!
    
    @IBOutlet var OKButton: RoundedButton!
    
    var tableData = TableData.shared
    
    var winnerPlayer = PlayerData(playerName: String(), playerChips: Int(), playerBet: Int(), playerBetInThisState: Int())
    
    var buttons = [UIButton]()
    var labels = [UILabel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpButtonsAndScores()

        tableData.newHandNeeded = true
    }
    
    @IBAction func tapOKButton(_ sender: Any) {
        
    }
    
    func setUpButtonsAndScores() {
        buttons = [p1Button, p2Button, p3Button, p4Button, p5Button, p6Button, p7Button, p8Button, p9Button]
        labels = [p1Score, p2Score, p3Score, p4Score, p5Score, p6Score, p7Score, p8Score, p9Score]
        
        let playerCount = tableData.activePlayers.count
        var playerIndex = 0

        for eachButton in buttons {
            eachButton.isHidden = false
            eachButton.setTitle(tableData.activePlayers[playerIndex].playerName, for: .normal)
            playerIndex += 1
            if playerIndex > playerCount - 1 {
                break
            }
        }
        
        playerIndex = 0
        
        for eachLabel in labels {
            eachLabel.isHidden = false
            eachLabel.text = "\(tableData.activePlayers[playerIndex].playerChips)"
            playerIndex += 1
            if playerIndex > playerCount - 1 {
                break
            }
        }
    }
    
    func highlightButtonSelection(sender: UIButton) {
        
        for button in buttons {
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 2
        }
        
        sender.layer.borderColor = UIColor.systemRed.cgColor
        sender.layer.borderWidth = 4
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func buttonTapped(_ sender: UIButton) {
        highlightButtonSelection(sender: sender)
        
        if sender.tag == 0 {
            let filteredWinners = tableData.activePlayers.filter { $0.playerName == p1Button.titleLabel?.text }
            winnerPlayer = filteredWinners[0]
        } else if sender.tag == 1 {
            let filteredWinners = tableData.activePlayers.filter { $0.playerName == p2Button.titleLabel?.text }
            winnerPlayer = filteredWinners[0]
        } else if sender.tag == 2 {
            let filteredWinners = tableData.activePlayers.filter { $0.playerName == p3Button.titleLabel?.text }
            winnerPlayer = filteredWinners[0]
        } else if sender.tag == 3 {
            let filteredWinners = tableData.activePlayers.filter { $0.playerName == p4Button.titleLabel?.text }
            winnerPlayer = filteredWinners[0]
        } else if sender.tag == 4 {
            let filteredWinners = tableData.activePlayers.filter { $0.playerName == p5Button.titleLabel?.text }
            winnerPlayer = filteredWinners[0]
        } else if sender.tag == 5 {
            let filteredWinners = tableData.activePlayers.filter { $0.playerName == p6Button.titleLabel?.text }
            winnerPlayer = filteredWinners[0]
        } else if sender.tag == 6 {
            let filteredWinners = tableData.activePlayers.filter { $0.playerName == p7Button.titleLabel?.text }
            winnerPlayer = filteredWinners[0]
        } else if sender.tag == 7 {
            let filteredWinners = tableData.activePlayers.filter { $0.playerName == p8Button.titleLabel?.text }
            winnerPlayer = filteredWinners[0]
        } else if sender.tag == 8 {
            let filteredWinners = tableData.activePlayers.filter { $0.playerName == p9Button.titleLabel?.text }
            winnerPlayer = filteredWinners[0]
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if winnerPlayer.playerName == "" {
            return
        } else {
            tableData.winnerPlayer = winnerPlayer
            
            tableData.winnerPlayer.playerChips += tableData.potChips
            print("added chips")
        }
        
        let destVC = segue.destination as! PokerTableViewController
        destVC.newHand()
    }
    

}
