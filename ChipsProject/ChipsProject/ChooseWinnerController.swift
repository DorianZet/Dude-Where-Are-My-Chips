//
//  ChooseWinnerController.swift
//  ChipsProject
//
//  Created by Mateusz Zacharski on 10/08/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import UIKit

class ChooseWinnerController: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var previousPlayerButton: UIButton!
    @IBOutlet var nextPlayerButton: UIButton!
    @IBOutlet var playerNameLabel: UILabel!
    
    @IBOutlet var potChipsLabel: CountingPotLabel!
    @IBOutlet var playerChipsLabel: CountingPlayerChipsLabel!
    
    
    @IBOutlet var OKButton: RoundedButton!
    
    var tableData = TableData.shared
    
    var winnerPlayer = PlayerData(playerName: String(), playerChips: Int(), playerBet: Int(), playerBetInThisState: Int())
    
    var playerIndex = 0
    
    var playersAccountableForWin = [PlayerData]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        displayLink1ForPlayerChipsLabel = CADisplayLink(target: self, selector: #selector(handleUpdateForPlayerChipsLabel))
//        displayLink2ForPotChipsLabel = CADisplayLink(target: self, selector: #selector(handleUpdateForPotChipsLabel))
//        displayLink1ForPlayerChipsLabel.add(to: .main, forMode: .default)
//        displayLink2ForPotChipsLabel.add(to: .main, forMode: .default)

        changeFontToPixel()
        
        setUpPlayersAccountableForWin()
        
        setUpLabelsAndButtons()
       
        OKButton.setTitle("OK", for: .normal)
                
        for eachPlayer in tableData.activePlayers {
            print("\(eachPlayer.playerName) BET: \(eachPlayer.playerBet)")
            print("\(eachPlayer.playerName) BET IN THIS STATE: \(eachPlayer.playerBetInThisState)")
            print("\(eachPlayer.playerName) CHIPS: \(eachPlayer.playerChips)")
        }
        print("POT: \(tableData.potChips)")
        
    }
    
    
    @IBAction func tapPreviousPlayerButton(_ sender: Any) {
        let playersCount = playersAccountableForWin.count
        
        playerIndex -= 1
        if playerIndex < 0 {
            playerIndex = playersCount - 1
        }
        playerNameLabel.text = playersAccountableForWin[playerIndex].playerName
        chooseTemporaryWinnerPlayer()
        print(winnerPlayer.playerName)
    }
    
    @IBAction func tapNextPlayerButton(_ sender: Any) {
        let playersCount = playersAccountableForWin.count
        
        playerIndex += 1
        if playerIndex > playersCount - 1 {
            playerIndex = 0
        }
        playerNameLabel.text = playersAccountableForWin[playerIndex].playerName
        chooseTemporaryWinnerPlayer()
        print(winnerPlayer.playerName)
    }
    
    @IBAction func tapOKButton(_ sender: UIButton) {
        confirmWinnerPlayer()
        // uncomment the code below to have a fully playable version of the app (you lose the counting label animation, but once you choose the winner the app goes back to the PokerTableViewController and the game continues:
//        if tableData.potChips == 0 {
//            removeLosers()
//
//            if tableData.activePlayers.count == 1 {
//                let ac = UIAlertController(title: "\(tableData.activePlayers[0].playerName) wins!", message: nil, preferredStyle: .alert)
//                ac.addAction(UIAlertAction(title: "OK", style: .default))
//                present(ac, animated: true)
//                print("GAME FINISHED, ONLY 1 PLAYER LEFT")
//            } else {
//                performSegue(withIdentifier: "UnwindToPokerTableSegue", sender: sender)
//            }
//        }
    }
    
    func setUpPlayersAccountableForWin() {
        playersAccountableForWin = tableData.activePlayers.filter { ($0.playerActiveInHand || $0.playerWentAllIn) && !$0.playerFolded }
    }
    
    func setUpLabelsAndButtons() {
        playerNameLabel.text = playersAccountableForWin[0].playerName
        playerNameLabel.layer.borderWidth = 2
        playerNameLabel.layer.borderColor = UIColor.black.cgColor
        playerNameLabel.backgroundColor = .clear
        playerNameLabel.clipsToBounds = true
        playerNameLabel.backgroundColor = .systemYellow
        chooseTemporaryWinnerPlayer()
        
        potChipsLabel.text = "POT: \(tableData.potChips)"
        potChipsLabel.backgroundColor = .clear
        potChipsLabel.clipsToBounds = true
        
        previousPlayerButton.layer.borderColor = UIColor.clear.cgColor
        previousPlayerButton.layer.borderWidth = 0
        previousPlayerButton.backgroundColor = .clear
        nextPlayerButton.layer.borderColor = UIColor.clear.cgColor
        nextPlayerButton.layer.borderWidth = 0
        nextPlayerButton.backgroundColor = .clear
    }
    
    func chooseTemporaryWinnerPlayer() {
        let filteredWinners = tableData.activePlayers.filter { $0.playerName == playerNameLabel.text }
        winnerPlayer = filteredWinners[0]
        playerChipsLabel.text = "\(winnerPlayer.playerName)'S CHIPS: \(winnerPlayer.playerChips)"
    }
    
    func confirmWinnerPlayer() {
        if winnerPlayer.playerWentAllInForSidePot == true {
            let playersActiveInHand = tableData.activePlayers.filter { $0.playerActiveInHand == true }
            let playersWhoWentAllIn = tableData.activePlayers.filter { $0.playerWentAllIn == true }
            let playersWhoCanWinCount = playersActiveInHand.count + playersWhoWentAllIn.count
            
            tableData.winnerPlayer = winnerPlayer
            let sidePotWin = tableData.winnerPlayer.playerBet * playersWhoCanWinCount
            
            if sidePotWin < tableData.potChips {
                tableData.winnerPlayer.playerChips += sidePotWin
                tableData.potChips -= sidePotWin
            } else {
                tableData.winnerPlayer.playerChips += tableData.potChips
                tableData.potChips -= tableData.potChips
            }
            // decide what to do with the rest of the chips (tableData.potChips). 1 "all in" player won his bet multiplied by the number of "all in" and "active in hand" players. If his bet was less than the minimum bet was, there are some chips left - decide where they should go now.
            
            //Now that the side pot has been created, in the title label, inform that the side pot has been created and you want the players to pick the player with next best cards
            let sidePotInfo = "Side pot has been created, choose player with next best cards"
            titleLabel.text = sidePotInfo.uppercased()
            potChipsLabel.text = "POT: \(tableData.potChips)"
            
            let winnerPlayerIndex = playersAccountableForWin.firstIndex(of: winnerPlayer)
            if let winnerPlayerIndex = winnerPlayerIndex {
                playersAccountableForWin.remove(at: winnerPlayerIndex)
                
                playerNameLabel.text = playersAccountableForWin[0].playerName
                chooseTemporaryWinnerPlayer()
            }
        } else {
            tableData.winnerPlayer = winnerPlayer
            playerChipsLabel.count(fromValue: Float(tableData.winnerPlayer.playerChips), to: Float(tableData.winnerPlayer.playerChips + tableData.potChips), withDuration: 3, andAnimationType: .EaseOut, andCounterType: .Int)
            potChipsLabel.count(fromValue: Float(tableData.potChips), to: 0, withDuration: 3, andAnimationType: .EaseOut, andCounterType: .Int)
            
            tableData.winnerPlayer.playerChips += tableData.potChips
            tableData.potChips -= tableData.potChips
        }
    }
    
    func removeLosers() {
        let losers = tableData.activePlayers.filter { $0.playerChips == 0 }

        for eachPlayer in losers {
            if let index = tableData.activePlayers.firstIndex(of: eachPlayer) {
                tableData.activePlayers.remove(at: index)
            }
        }
    }
    
    func changeSmallBlindPlayer() {
    //        tableData.activePlayers.forEach { $0.isPlayerSmallBlind = false }
    //        tableData.activePlayers.forEach { $0.isPlayerBigBlind = false }

        nextSmallBlindPlayerIndex()
            
        if tableData.activePlayers[tableData.smallBlindPlayerIndex].isPlayerSmallBlind == true {
            tableData.activePlayers[tableData.smallBlindPlayerIndex].isPlayerSmallBlind = false
            nextSmallBlindPlayerIndex()
        }
    }
        
    func nextSmallBlindPlayerIndex() {
        tableData.smallBlindPlayerIndex += 1
                   
        if tableData.smallBlindPlayerIndex > tableData.activePlayers.count - 1 {
            tableData.smallBlindPlayerIndex = 0
        }
    }
    
    func changeFontToPixel() {
        let biggerLabels = [potChipsLabel, playerChipsLabel, playerNameLabel]
        let buttons = [previousPlayerButton, nextPlayerButton, OKButton]
        
        for eachLabel in biggerLabels {
            eachLabel?.font = UIFont(name: "Pixel Emulator", size: 25)
        }
        
        for eachButton in buttons {
            eachButton?.titleLabel?.font = UIFont(name: "Pixel Emulator", size: 17)
        }
        
        titleLabel.font = UIFont(name: "Pixel Emulator", size: 22)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        changeSmallBlindPlayer()
        
        tableData.winningScreenAlreadyShown = false
        tableData.newHandNeeded = true
        
        let destVC = segue.destination as! PokerTableViewController
        destVC.newHand()
        destVC.hideAllLabelsAndButtons()
        print("fired newHand() from prepareForSegue")
    }

}

extension Double {
    func toInt() -> Int? {
        guard (self <= Double(Int.max).nextDown) && (self >= Double(Int.min).nextUp) else {
            return nil
        }

        return Int(self)
    }
}
