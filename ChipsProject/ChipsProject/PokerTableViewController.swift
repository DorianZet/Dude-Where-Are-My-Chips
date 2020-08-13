//
//  PokerTableViewController.swift
//  ChipsProject
//
//  Created by Mateusz Zacharski on 04/08/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import UIKit

class PokerTableViewController: UIViewController {
    
    var tableData = TableData.shared
    
    var potChips = 0 {
        didSet {
            potLabel.text = "POT: \(potChips)"
        }
    }
    
    var playerChips = 0
    
    var sliderChips = 0 {
        didSet {
            playerChipsLabel.text = "YOUR CHIPS: \(sliderChips)"
        }
    }
    
    var currentBet = 0 {
        didSet {
            currentBetLabel.text = "BET: \(currentBet)"
        }
    }
        
    @IBOutlet var playerLabel: UILabel!
    @IBOutlet var potLabel: UILabel!
    @IBOutlet var handStateLabel: UILabel!
    @IBOutlet var currentBetLabel: UILabel!
    @IBOutlet var playerChipsLabel: UILabel!
    @IBOutlet var minimumBetLabel: UILabel!
    @IBOutlet var betSlider: UISlider!
    @IBOutlet var minusButton: RoundedButton!
    @IBOutlet var OKButton: RoundedButton!
    @IBOutlet var plusButton: RoundedButton!
    @IBOutlet var foldButton: RoundedButton!
    @IBOutlet var callCheckButton: RoundedButton!
    @IBOutlet var raiseBetButton: RoundedButton!

    
    override func viewDidAppear(_ animated: Bool) {
        animateHandStateLabel(for: "PRE-FLOP")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideSliderAndButtons()
        
        playerChips = tableData.currentPlayer.playerChips
        sliderChips = tableData.currentPlayer.playerChips
        potChips = tableData.potChips
        currentBet = tableData.currentBet
        
        newHand()

        print("CREATED POT CHIPS IN VIEWDIDLOAD: \(potChips)")
    }
    
    @IBAction func tapFoldButton(_ sender: UIButton) {
        tableData.currentPlayer.playerActiveInHand = false
        print("\(tableData.currentPlayer.playerName) has folded, setting playerActiveInHand = false...")
        
        tableData.checkForFoldedPlayers()
        if tableData.allPlayersFolded == true {
            // show the winner and move to a new hand
            print("All players folded, \(tableData.winnerPlayer.playerName) WINS!")
        } else {
            checkIfAllPlayersWentAllIn()
            checkForNextState()
            newTurn()
        }
        
    }
    
    @IBAction func tapCallCheckButton(_ sender: UIButton) {
        tableData.currentPlayer.playerMadeAMove = true
        
        if tableData.gameState == GameState.preFlop {
            // zachowanie "ALL IN" button:
            if sender.title(for: .normal) == "ALL IN" {
                tableData.potChips += playerChips
                tableData.currentPlayer.playerBet += playerChips
                tableData.currentPlayer.playerBetInThisState += playerChips
                playerChips -= playerChips
                tableData.currentPlayer.playerChips = playerChips
                tableData.currentPlayer.playerWentAllIn = true
                checkIfAllPlayersWentAllIn()
                checkForNextState()
                newTurn()
            } else { // zachowanie "CALL" button:
                let chipsToMatchBet = tableData.minimumBet - tableData.currentPlayer.playerBetInThisState
                tableData.potChips += chipsToMatchBet
                playerChips -= chipsToMatchBet
                tableData.currentPlayer.playerChips = playerChips
                tableData.currentPlayer.playerBet += chipsToMatchBet
                tableData.currentPlayer.playerBetInThisState += chipsToMatchBet
                checkForNextState()
                newTurn()
            }
        } else {
            if sender.title(for: .normal) == "ALL IN" { // zachowanie "ALL IN" button:
                tableData.potChips += playerChips
                tableData.currentPlayer.playerBet += playerChips
                tableData.currentPlayer.playerBetInThisState += playerChips
                playerChips -= playerChips
                tableData.currentPlayer.playerChips = playerChips
                tableData.currentPlayer.playerWentAllIn = true
                checkIfAllPlayersWentAllIn()
                checkForNextState()
                newTurn()
            } else if (sender.titleLabel?.text?.contains("CALL"))! { // zachowanie "CALL" button:
                let chipsToMatchBet = tableData.minimumBet - tableData.currentPlayer.playerBetInThisState
                tableData.potChips += chipsToMatchBet
                playerChips -= chipsToMatchBet
                tableData.currentPlayer.playerChips = playerChips
                tableData.currentPlayer.playerBet += chipsToMatchBet
                tableData.currentPlayer.playerBetInThisState += chipsToMatchBet
                checkForNextState()
                newTurn()
            } else {
                // zachowanie "CHECK" button:
                tableData.currentPlayer.playerChecked = true
                let playersWhoChecked = tableData.activePlayers.filter { $0.playerChecked }
                let playersWhoFolded = tableData.activePlayers.filter { $0.playerActiveInHand == false }
                let playersWhoAreActive = tableData.activePlayers.filter { $0.playerActiveInHand }
                let playersWhoWentAllIn = tableData.activePlayers.filter { $0.playerWentAllIn }
                let playersWhoMoved = tableData.activePlayers.filter { $0.playerMadeAMove }
                
                let allPlayersMoved = playersWhoMoved.allSatisfy({ $0.playerMadeAMove == true })
                
                if (playersWhoChecked.count == tableData.activePlayers.count - playersWhoFolded.count && allPlayersMoved) || (playersWhoChecked.count + playersWhoWentAllIn.count == playersWhoAreActive.count && allPlayersMoved) {
                    print("Players checked, going to the next state")
                    goToNextState()
                    playersWhoChecked.forEach { $0.playerChecked = false }
                }
                newTurn()
            }
        }
    }
    
    @IBAction func tapRaiseBetButton(_ sender: UIButton) {
        if betSlider.isHidden == false {
            return
        } else {
            betSlider.isHidden = false
            minusButton.isHidden = false
            OKButton.isHidden = false
            plusButton.isHidden = false
            
            var chipsToMatchBet = 0
           
            if tableData.minimumBet == tableData.currentPlayer.playerBetInThisState {
                chipsToMatchBet = tableData.minimumBet
            } else {
                chipsToMatchBet = tableData.minimumBet - tableData.currentPlayer.playerBetInThisState
            }
            if tableData.currentPlayer.playerChips < chipsToMatchBet {
                betSlider.isUserInteractionEnabled = false
                betSlider.setValue(Float(sliderChips), animated: true)
                currentBet = sliderChips
                sliderChips -= sliderChips
                minusButton.isHidden = true
                plusButton.isHidden = true
                OKButton.setTitle("ALL IN", for: .normal)
            } else {
                betSlider.isUserInteractionEnabled = true
                betSlider.minimumValue = Float(chipsToMatchBet)
                betSlider.maximumValue = Float(sliderChips)
                betSlider.setValue(betSlider.minimumValue, animated: true)
                currentBet = chipsToMatchBet
                sliderChips -= chipsToMatchBet
            }
            
        }
    }
    @IBAction func betSliderAction(_ sender: UIButton) {
//        currentBetLabel.text = "BET: \(Int(betSlider.value))"
        currentBet = Int(betSlider.value)
        sliderChips = Int(betSlider.maximumValue) - Int(betSlider.value)
    }
    @IBAction func tapMinusButton(_ sender: UIButton) {
        if sliderChips >= tableData.currentPlayer.playerChips || currentBet <= tableData.minimumBet {
            return
        } else {
            sliderChips += 1
            currentBet -= 1
        }
    }
    @IBAction func tapOKButton(_ sender: UIButton) {
        if currentBet == 0 {
            return
        } else {
            tableData.currentPlayer.playerMadeAMove = true

            tableData.potChips += currentBet
            tableData.currentPlayer.playerChips = sliderChips
            tableData.currentPlayer.playerBet += currentBet
            tableData.currentPlayer.playerBetInThisState += currentBet
            
            if tableData.currentPlayer.playerBetInThisState > tableData.minimumBet {
                tableData.minimumBet = tableData.currentPlayer.playerBetInThisState
            }
            
            if sliderChips == 0 {
                checkIfAllPlayersWentAllIn()
                tableData.currentPlayer.playerWentAllIn = true
            }
            checkForNextState()
            newTurn()
        }
    }
    @IBAction func tapPlusButton(_ sender: UIButton) {
        if sliderChips <= 0 {
            return
        } else {
            sliderChips -= 1
            currentBet += 1
        }
    }
    
    func newHand() {
        resetAllPlayersBetsForNewState()
        resetTablePropertiesForNewHand()
        tableData.chooseBlinds()
        tableData.isNewHand = true
        
        newTurn()
    }
    
    func newTurn() {
        // change the button titles appropriately to the game state:
        if tableData.gameState == GameState.preFlop {
            callCheckButton.setTitle("CALL", for: .normal)
            raiseBetButton.setTitle("RAISE/BET", for: .normal)
            if tableData.isNewHand == true {
                // show pre-flop animation
                print("PRE-FLOP")
                
                configureTurn()
                tableData.isNewHand = false
            } else {
                configureTurn()
            }
        } else if tableData.gameState == GameState.theFlop {
            callCheckButton.setTitle("CHECK", for: .normal)
            if tableData.nextStateNeeded == true {
                animateHandStateLabel(for: "THE FLOP")
                print("THE FLOP")
                configureTurn()
                tableData.nextStateNeeded = false
            } else {
                configureTurn()
            }
        } else if tableData.gameState == GameState.theTurn {
            callCheckButton.setTitle("CHECK", for: .normal)
            if tableData.nextStateNeeded == true {
                animateHandStateLabel(for: "THE TURN")
                print("THE TURN")
                configureTurn()
                tableData.nextStateNeeded = false
            } else {
                configureTurn()
            }
        } else if tableData.gameState == GameState.TheRiver {
            callCheckButton.setTitle("CHECK", for: .normal)
            if tableData.nextStateNeeded == true {
                animateHandStateLabel(for: "THE RIVER")
                print("THE RIVER")
                configureTurn()
                tableData.nextStateNeeded = false
            } else {
                configureTurn()
            }
        } else if tableData.gameState == GameState.finishHand {
            //finish the hand and move to the next one
            // show winning screen, choose the player, add the pot chips to his chips, check all activePlayers - if they have 0 chips, remove them from activePlayers array, and turn on a new hand.
            presentChooseWinnerController()
            print("SHOWING THE HAND FINISH SCREEN")
        }
    }
    
    func hideSliderAndButtons() {
        if betSlider.isHidden == false {
            betSlider.isHidden = true
            minusButton.isHidden = true
            OKButton.isHidden = true
            plusButton.isHidden = true
        }
    }
    
    func checkForNextState() { // everything grayed out has been left just for safety.
        let allInPlayers = tableData.activePlayers.filter { $0.playerWentAllIn }
        let players = tableData.activePlayers.filter { $0.playerActiveInHand && $0.playerWentAllIn == false && $0.playerMadeAMove == true }
        let playersWhoMoved = tableData.activePlayers.filter { $0.playerMadeAMove }
        let playingPlayers = tableData.activePlayers.filter { $0.playerActiveInHand }
        let playersWhoWentAllIn = tableData.activePlayers.filter { $0.playerWentAllIn }
        
        let allBetsAreEqual = players.allSatisfy({ $0.playerBet == players.first?.playerBet })
        let noOneHasZeroBet = playingPlayers.allSatisfy({ $0.playerBetInThisState != 0})
        
        if (allBetsAreEqual && allInPlayers.count == 0 && playersWhoMoved.count == playingPlayers.count) || (allBetsAreEqual && allInPlayers.count == tableData.activePlayers.count - players.count && playersWhoMoved.count == playingPlayers.count && noOneHasZeroBet) {
            playingPlayers.forEach { $0.playerMadeAMove = false
            }
            goToNextState()
        } else {
            print("Bets not equal.")
        }
    }
    

    
    // i dont think we need this function for now, but let's let it stay here for a while, we might need it later:
//    func checkForGameEnd() {
//        let players = tableData.activePlayers.filter { $0.playerActiveInHand}
//
//        if let firstElem = players.first {
//            for eachPlayer in players {
//                if eachPlayer.playerBet != firstElem.playerBet || eachPlayer.playerChips == 0 { // albo po prostu: 'if eachPlayer.playerBet != tableData.minimumBet { } (chyba)
//                    print("Game finished, draw a winner")
//                }
//            }
//        }
//    }
    
    func decideIfCheckForGameStateAfterFold() {
        let players = tableData.activePlayers.filter { $0.playerBet == 0 && $0.playerActiveInHand == true }
    
        if players.count != tableData.activePlayers.count {
            print("Checking not needed, all players' bets are 0")
        } else {
            checkForNextState()
        }
    }
    
    func configureTurn() {
        // hide the slider and its buttons only if the slider is visible:
        hideSliderAndButtons()
        
        // set the minimum bet label:
        minimumBetLabel.text = "MINIMUM BET: \(tableData.minimumBet)"
        
        if tableData.nextStateNeeded == true {
            resetAllPlayersBetsForNewState()
        }
        
        if tableData.newHandNeeded == true {
            print("new hand was needed")
            tableData.currentPlayer = tableData.activePlayers[tableData.smallBlindPlayerIndex]
            tableData.currentPlayerIndex = tableData.smallBlindPlayerIndex
            tableData.newHandNeeded = false
        } else {
            tableData.currentPlayer = tableData.activePlayers[tableData.currentPlayerIndex]
        }
    
        if tableData.currentPlayer.playerActiveInHand == true { // accept the player in the turn only if he hasn't folded
            
            if tableData.currentPlayer.playerWentAllIn == true { // skip to the next player if the current one went all in
                print("\(tableData.currentPlayer.playerName) went all in, skipping to the next player")
                tableData.currentPlayerIndex += 1
                if tableData.currentPlayerIndex > tableData.activePlayers.count - 1 {
                    tableData.currentPlayerIndex = 0
                }
                DispatchQueue.main.async { [weak self] in
                    self?.newTurn()
                }
                return
            }
            
            raiseBetButton.isEnabled = true
            raiseBetButton.backgroundColor = .systemYellow
            
            playerLabel.text = "\(tableData.currentPlayer.playerName)'S TURN"
            currentBet = 0
            potChips = tableData.potChips
            playerChips = tableData.currentPlayer.playerChips
            tableData.sliderChips = playerChips
            sliderChips = playerChips
            
            configureButtonsForEachState()
                        
            tableData.currentPlayerIndex += 1
            if tableData.currentPlayerIndex > tableData.activePlayers.count - 1 {
                tableData.currentPlayerIndex = 0
            }
        } else { // if the current player has folded, we move to the next one and call the whole function again:
            tableData.currentPlayerIndex += 1
            if tableData.currentPlayerIndex > tableData.activePlayers.count - 1 {
                tableData.currentPlayerIndex = 0
            }
            DispatchQueue.main.async { [weak self] in
                self?.newTurn()
            }
        }
    }
    
    func goToNextState() {
        if tableData.gameState == GameState.preFlop {
            tableData.gameState = GameState.theFlop
            tableData.nextStateNeeded = true
            print("All bets are the same, next state needed")
        } else if tableData.gameState == GameState.theFlop {
            tableData.gameState = GameState.theTurn
            tableData.nextStateNeeded = true
            print("All bets are the same, next state needed")
        } else if tableData.gameState == GameState.theTurn {
            tableData.gameState = GameState.TheRiver
            tableData.nextStateNeeded = true
            print("All bets are the same, next state needed")
        } else if tableData.gameState == GameState.TheRiver {
            tableData.gameState = GameState.finishHand
            tableData.nextStateNeeded = true
            print("All bets are the same, next state needed")
        }
    }
    
    func animateHandStateLabel(for state: String) {
        view.isUserInteractionEnabled = false
        
        handStateLabel.isHidden = false
        handStateLabel.text = state
        handStateLabel.backgroundColor = .white
        handStateLabel.layer.cornerRadius = 10
        handStateLabel.layer.borderWidth = 2
        handStateLabel.layer.borderColor = UIColor.black.cgColor
        handStateLabel.layer.masksToBounds = true
        handStateLabel.alpha = 0
        handStateLabel.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 35, options: [], animations: {
            self.handStateLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.handStateLabel.alpha = 1
        }) { _ in
            self.currentBetLabel.isHidden = false
        }
        UIView.animate(withDuration: 0.3, delay: 2.0, usingSpringWithDamping: 10, initialSpringVelocity: 12, options: [], animations: {
            self.handStateLabel.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
            self.handStateLabel.alpha = 0
        }) { _ in
            self.handStateLabel.isHidden = true
            self.view.isUserInteractionEnabled = true
        }
    }
    
    // funkcja, którą tworzymy po to, żeby ewentualnie przyspieszyc rozgrywke do koncowego ekranu jesli wszyscy gracze juz weszli all in (nie ma sensu przechodzic przez takie stage jak flop, turn itd. jesli gracze nie mają już nic do roboty):
    func checkIfAllPlayersWentAllIn() {
        let playersWhoWentAllIn = tableData.activePlayers.filter { $0.playerChips == 0 }
        let playersActiveInHand = tableData.activePlayers.filter { $0.playerActiveInHand }
        if playersWhoWentAllIn.count == playersActiveInHand.count {
            print("All players went all in, showing the finish hand screen (with a request to put all 5 cards on the table).")
            presentChooseWinnerController()
            tableData.gameState = .finishHand
        }
    }
    
    func presentChooseWinnerController() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ChooseWinnerController") as! ChooseWinnerController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    func resetAllPlayersBetsForNewState() {
        tableData.activePlayers.forEach { $0.playerBetInThisState = 0 }
    }
    
    func configureButtonsForEachState() {
        if tableData.gameState != GameState.preFlop {
            // zrob petle, ktora przejezdza przez wszystkich aktywnych graczy i sprawdza ich bety. jesli ktorykolwiek nie rowna sie 0, check button sie zmienia w call button.
            let playersActiveInHand = tableData.activePlayers.filter { $0.playerActiveInHand }
            let playersActiveWithZeroBet = tableData.activePlayers.filter { $0.playerBetInThisState == 0 &&  $0.playerActiveInHand}
        //  let playersWhoChecked = tableData.activePlayers.filter { $0.playerChecked }
                        
            if playersActiveInHand.count == playersActiveWithZeroBet.count {
                print("no one has bet so far")
            } else {
                let chipsToMatchBet = tableData.minimumBet - tableData.currentPlayer.playerBetInThisState

                if chipsToMatchBet != 0 {
                    if  playerChips > tableData.minimumBet {
                        callCheckButton.setTitle("CALL: \(chipsToMatchBet)", for: .normal)
                        minimumBetLabel.text = "MINIMUM BET: \(tableData.minimumBet)"
                    } else {
                        callCheckButton.setTitle("ALL IN", for: .normal)
                        raiseBetButton.isEnabled = false
                        raiseBetButton.backgroundColor = .lightGray
                    }
                }
            }
        } else if tableData.gameState == GameState.preFlop {
            let chipsToMatchBet = tableData.minimumBet - tableData.currentPlayer.playerBetInThisState

            if  playerChips > tableData.minimumBet {
                callCheckButton.setTitle("CALL: \(chipsToMatchBet)", for: .normal)
                minimumBetLabel.text = "MINIMUM BET: \(tableData.minimumBet)"
            } else {
                callCheckButton.setTitle("ALL IN", for: .normal)
                raiseBetButton.isEnabled = false
                raiseBetButton.backgroundColor = .lightGray
            }
        }
    }
    
    func resetPlayerPropertiesForNewHand() {
        tableData.activePlayers.forEach { $0.playerMadeAMove = false }
        tableData.activePlayers.forEach { $0.playerBetInThisState = 0 }
        tableData.activePlayers.forEach { $0.playerActiveInHand = true }
        tableData.activePlayers.forEach { $0.playerChecked = false }
        tableData.activePlayers.forEach { $0.playerBetInThisState = 0 }
        tableData.activePlayers.forEach { $0.playerWentAllIn = false }
    }
    
    func resetTablePropertiesForNewHand() {
        tableData.potChips = 0
        tableData.currentBet = 0
        tableData.allPlayersFolded = false
        tableData.winnerPlayer = PlayerData(playerName: String(), playerChips: Int(), playerBet: Int(), playerBetInThisState: Int())
        tableData.gameState = .preFlop
        tableData.minimumBet = tableData.smallBlind * 4
        tableData.nextStateNeeded = false
    }
   
    
    @IBAction func unwindToPokerTable(_ sender: UIStoryboardSegue) {}
}
