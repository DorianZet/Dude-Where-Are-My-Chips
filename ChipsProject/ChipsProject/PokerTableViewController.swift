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
    @IBOutlet var playerBetLabel: UILabel!
    @IBOutlet var betSlider: UISlider!
    @IBOutlet var minusButton: RoundedButton!
    @IBOutlet var OKButton: RoundedButton!
    @IBOutlet var plusButton: RoundedButton!
    @IBOutlet var foldButton: RoundedButton!
    @IBOutlet var callCheckButton: RoundedButton!
    @IBOutlet var raiseBetButton: RoundedButton!

    
    override func viewDidAppear(_ animated: Bool) {
        // animating the "pre-flop" animation every time the view appears:
        animateHandStateLabel(for: "PRE-FLOP")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideAllLabelsAndButtons()

        changeFontToPixel()

        if let thumbImage = UIImage(named: "yellowThumb") {
            let smallThumb = thumbImage.resize(size: CGSize(width: 40, height: 40))
            
            betSlider.setThumbImage(smallThumb, for: .application)
            betSlider.setThumbImage(smallThumb, for: .disabled)
            betSlider.setThumbImage(smallThumb, for: .focused)
            betSlider.setThumbImage(smallThumb, for: .highlighted)
            betSlider.setThumbImage(smallThumb, for: .normal)
            betSlider.setThumbImage(smallThumb, for: .reserved)
            betSlider.setThumbImage(smallThumb, for: .selected)
        }

        hideSliderAndButtons()
//        playerChips = tableData.currentPlayer.playerChips
//        sliderChips = tableData.currentPlayer.playerChips
//        potChips = tableData.potChips
//        currentBet = tableData.currentBet
                
        tableData.newHandNeeded = true
        newHand()
    }
    
    @IBAction func tapFoldButton(_ sender: UIButton) {
        tableData.currentPlayer.playerActiveInHand = false
        tableData.currentPlayer.playerFolded = true
        tableData.currentPlayer.playerMadeAMove = true
        
        print("\(tableData.currentPlayer.playerName) has folded, setting playerActiveInHand = false...")
        
        tableData.checkForFoldedPlayers()
        if tableData.allPlayersFolded == true {
            // show the winner and move to a new hand
            print("All players folded, \(tableData.winnerPlayer.playerName) WINS!")
            safelyShowChooseWinnerController()
             // rather than that, I should just present a controller with information in the winning player (as there is only 1 player left, we already know the winner, so we don't need to choose him manually).
            tableData.gameState = .finishHand
        } else {
            checkIfAllPlayersWentAllIn()
            checkForNextState()
            newTurn()
        }
    }
    
    @IBAction func tapCallCheckButton(_ sender: UIButton) {
        tableData.currentPlayer.playerMadeAMove = true
        
        if tableData.gameState == GameState.preFlop {
            // "ALL IN" button behavior:
            if sender.title(for: .normal) == "ALL IN" {
                configureAllInButton()
            } else { // "CALL" button behavior:
                configureCallButton()
            }
        } else {
            if sender.title(for: .normal) == "ALL IN" { // "ALL IN" button behavior:
                configureAllInButton()
            } else if (sender.titleLabel?.text?.contains("CALL"))! { // "CALL" button behavior:
                configureCallButton()
            } else { // "CHECK" button behavior:
                checkForNextState()
                newTurn()
            }
        }
    }
    
    @IBAction func tapRaiseBetButton(_ sender: UIButton) {
        if sender.titleLabel?.text == "ALL IN" {
            configureAllInButton()
        } else if sender.titleLabel?.text == "BET" {
            configureBetButton()
        } else { // if button's title is "RAISE":
            configureRaiseButton()
        }
    }
    @IBAction func betSliderAction(_ sender: UIButton) {
//        currentBetLabel.text = "BET: \(Int(betSlider.value))"
        currentBet = Int(betSlider.value)
        sliderChips = Int(betSlider.maximumValue) - Int(betSlider.value)
    }
    
    @IBAction func tapMinusButton(_ sender: UIButton) {
        if sliderChips >= tableData.currentPlayer.playerChips || currentBetIsBelowOrEqualToMinimumBetOrRaiseBet() {
            return
        } else {
            sliderChips += 1
            currentBet -= 1
        }
    }
    
    func currentBetIsBelowOrEqualToMinimumBetOrRaiseBet() -> Bool {
        if tableData.currentPlayer.playerTappedRaise == true {
            if currentBet <= tableData.minimumBet * 2 {
                return true
            } else {
                return false
            }
        } else {
            if currentBet <= tableData.minimumBet {
                return true
            } else {
                return false
            }
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
                tableData.currentPlayer.playerActiveInHand = false
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
    
    func configureAllInButton() {
        tableData.potChips += playerChips
        tableData.currentPlayer.playerBet += playerChips
        tableData.currentPlayer.playerBetInThisState += playerChips
        
        if tableData.currentPlayer.playerBetInThisState >= tableData.minimumBet {
            tableData.minimumBet = tableData.currentPlayer.playerBetInThisState
        } else {
            tableData.currentPlayer.playerWentAllInForSidePot = true
        }
        
        playerChips -= playerChips
        tableData.currentPlayer.playerChips = playerChips
        tableData.currentPlayer.playerWentAllIn = true
        tableData.currentPlayer.playerActiveInHand = false
        checkIfAllPlayersWentAllIn()
        checkForNextState()
        newTurn()
    }
    
    func configureCallButton() {
        let chipsToMatchBet = tableData.minimumBet - tableData.currentPlayer.playerBetInThisState
        tableData.potChips += chipsToMatchBet
        playerChips -= chipsToMatchBet
        tableData.currentPlayer.playerChips = playerChips
        tableData.currentPlayer.playerBet += chipsToMatchBet
        tableData.currentPlayer.playerBetInThisState += chipsToMatchBet
        checkForNextState()
        newTurn()
    }
    
    func configureBetButton() {
        if betSlider.isHidden == false {
            return
        } else {
            betSlider.isHidden = false
            minusButton.isHidden = false
            OKButton.isHidden = false
            plusButton.isHidden = false
            
            betSlider.isUserInteractionEnabled = true
            betSlider.minimumValue = Float(tableData.minimumBet)
            betSlider.maximumValue = Float(sliderChips)
            betSlider.setValue(betSlider.minimumValue, animated: true)
            currentBet = tableData.minimumBet
            sliderChips -= tableData.minimumBet
        }
    }
    
    func configureRaiseButton() {
        if betSlider.isHidden == false {
            return
        } else {
            betSlider.isHidden = false
            minusButton.isHidden = false
            OKButton.isHidden = false
            plusButton.isHidden = false
            
            tableData.currentPlayer.playerTappedRaise = true
             
            betSlider.isUserInteractionEnabled = true
            betSlider.minimumValue = Float(tableData.minimumBet * 2)
            betSlider.maximumValue = Float(sliderChips)
            betSlider.setValue(betSlider.minimumValue, animated: true)
            currentBet = tableData.minimumBet * 2
            sliderChips -= tableData.minimumBet * 2
        }
    }
    
    func newHand() {
        resetPlayerPropertiesForNewHand()
        resetTablePropertiesForNewHand()
        tableData.chooseBlindPlayers()
        tableData.isNewHand = true
        
        newTurn()
    }
    
    func newTurn() {
        // change the button titles appropriately to the game state:
        if tableData.gameState == GameState.preFlop {
            callCheckButton.setTitle("CALL", for: .normal)
            raiseBetButton.setTitle("BET", for: .normal)
            if tableData.isNewHand == true {
                // show pre-flop animation
                print("PRE-FLOP")
                tableData.isNewHand = false
            } else {
                configureTurn()
            }
        } else if tableData.gameState == GameState.theFlop {
            callCheckButton.setTitle("CHECK", for: .normal)
            raiseBetButton.setTitle("BET", for: .normal)
            if tableData.nextStateNeeded == true {
                animateHandStateLabel(for: "THE FLOP")
                print("THE FLOP")
            } else {
                configureTurn()
            }
        } else if tableData.gameState == GameState.theTurn {
            callCheckButton.setTitle("CHECK", for: .normal)
            raiseBetButton.setTitle("BET", for: .normal)
            if tableData.nextStateNeeded == true {
                animateHandStateLabel(for: "THE TURN")
                print("THE TURN")
            } else {
                configureTurn()
            }
        } else if tableData.gameState == GameState.TheRiver {
            callCheckButton.setTitle("CHECK", for: .normal)
            raiseBetButton.setTitle("BET", for: .normal)
            if tableData.nextStateNeeded == true {
                animateHandStateLabel(for: "THE RIVER")
                print("THE RIVER")
            } else {
                configureTurn()
            }
        } else if tableData.gameState == GameState.finishHand {
            safelyShowChooseWinnerController()
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
    
    func checkForNextState() {
        let playingPlayers = tableData.activePlayers.filter { $0.playerActiveInHand }
        
        let allBetsAreEqual = playingPlayers.allSatisfy({
            $0.playerBetInThisState == tableData.minimumBet || allBetsAreZero() //
        })
        let allPlayersMoved = tableData.activePlayers.allSatisfy({ $0.playerMadeAMove == true })
        
        if allPlayersMoved {
            if playingPlayers.count == 1 && playingPlayers[0].playerBetInThisState >= tableData.minimumBet  {
                safelyShowChooseWinnerController()
                print("All players but 1 went all in, showing finish hand screen")
                tableData.gameState = .finishHand
            } else if allBetsAreEqual {
                goToNextState()
                playingPlayers.forEach { $0.playerMadeAMove = false }
            } else {
                print ("bets not equal.")
            }
        }
    }
    
    func allBetsAreZero() -> Bool {
        let playingPlayers = tableData.activePlayers.filter { $0.playerActiveInHand }
        
        var sumOfBets = 0
        
        for eachPlayer in playingPlayers {
            sumOfBets += eachPlayer.playerBetInThisState
        }
        
        if sumOfBets == 0 {
            return true
        } else {
            return false
        }
    }
    
    func configureTurn() {
        // hide the slider and its buttons only if the slider is visible:
        hideSliderAndButtons()
        
        if tableData.newHandNeeded == true {
            print("new hand was needed")
            decideWhoStartsWhenNewHand()
            
            tableData.configureBlindsBeforeNewHand()

            for eachPlayer in tableData.activePlayers {
                print("\(eachPlayer.playerName) BET: \(eachPlayer.playerBet)")
                print("\(eachPlayer.playerName) BET IN THIS STATE: \(eachPlayer.playerBetInThisState)")
                print("\(eachPlayer.playerName) CHIPS: \(eachPlayer.playerChips)")
            }
            print("POT: \(tableData.potChips)")
            
            tableData.newHandNeeded = false
        } else if tableData.nextStateNeeded == true {
            tableData.currentPlayer = tableData.activePlayers[tableData.smallBlindPlayerIndex]
            tableData.currentPlayerIndex = tableData.smallBlindPlayerIndex
            resetAllPlayersBetsForNewState()
            tableData.minimumBet = tableData.smallBlind * 2
            
            for eachPlayer in tableData.activePlayers {
                print("\(eachPlayer.playerName) BET: \(eachPlayer.playerBet)")
                print("\(eachPlayer.playerName) BET IN THIS STATE: \(eachPlayer.playerBetInThisState)")
                print("\(eachPlayer.playerName) CHIPS: \(eachPlayer.playerChips)")
            }
            print("POT: \(tableData.potChips)")
            
            tableData.nextStateNeeded = false
        } else {
            tableData.currentPlayer = tableData.activePlayers[tableData.currentPlayerIndex]
            for eachPlayer in tableData.activePlayers {
                print("\(eachPlayer.playerName) BET: \(eachPlayer.playerBet)")
                print("\(eachPlayer.playerName) BET IN THIS STATE: \(eachPlayer.playerBetInThisState)")
                print("\(eachPlayer.playerName) CHIPS: \(eachPlayer.playerChips)")
            }
            print("POT: \(tableData.potChips)")
        }
    
        if tableData.currentPlayer.playerActiveInHand == true { // accept the player in the turn only if he hasn't folded or went all-in.
        
            raiseBetButton.isEnabled = true
            raiseBetButton.alpha = 1
            if tableData.currentPlayer.isPlayerSmallBlind == true {
                playerLabel.text = "\(tableData.currentPlayer.playerName)'S TURN [SM. BL.]"
            } else if tableData.currentPlayer.isPlayerBigBlind == true {
                playerLabel.text = "\(tableData.currentPlayer.playerName)'S TURN [BIG BL.]"
            } else {
                playerLabel.text = "\(tableData.currentPlayer.playerName)'S TURN"
            }

            minimumBetLabel.text = "MINIMUM BET: \(tableData.minimumBet)"
            playerBetLabel.text = "YOUR BET: \(tableData.currentPlayer.playerBetInThisState)"
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
    
    func decideWhoStartsWhenNewHand() {
        let playingPlayers = tableData.activePlayers.filter { $0.playerActiveInHand }
        let noOneHasMovedYet = playingPlayers.allSatisfy { ($0.playerMadeAMove) }
        
        if tableData.gameState == .preFlop && playingPlayers.count == 2 && noOneHasMovedYet {
                tableData.currentPlayer = tableData.activePlayers[tableData.smallBlindPlayerIndex]
            tableData.currentPlayerIndex = tableData.smallBlindPlayerIndex
        } else {
            var afterBigBlindPlayerIndex = tableData.bigBlindPlayerIndex + 1
            if afterBigBlindPlayerIndex > tableData.activePlayers.count - 1 {
                afterBigBlindPlayerIndex = 0
            }
            tableData.currentPlayer = tableData.activePlayers[afterBigBlindPlayerIndex]
            tableData.currentPlayerIndex = afterBigBlindPlayerIndex
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
        handStateLabel.layer.borderWidth = 2
        handStateLabel.layer.borderColor = UIColor.black.cgColor
        handStateLabel.layer.masksToBounds = true
        handStateLabel.alpha = 0
        handStateLabel.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 35, options: [], animations: {
            self.handStateLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.handStateLabel.alpha = 1
        }) { _ in
            if self.tableData.gameState == .preFlop {
                self.showAllLabelsAndButtons()
            }
            self.configureTurn()
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
    
    func checkIfAllPlayersWentAllIn() {
        let playersWhoWentAllIn = tableData.activePlayers.filter { $0.playerWentAllIn == true }
        let playersWhoFolded = tableData.activePlayers.filter { $0.playerFolded == true }

        if playersWhoWentAllIn.count == tableData.activePlayers.count - playersWhoFolded.count {
            print("All players went all in, showing the finish hand screen (with a request to put all 5 cards on the table).")
            safelyShowChooseWinnerController()
            tableData.gameState = .finishHand
        }
    }
    
    func presentChooseWinnerController() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ChooseWinnerController") as! ChooseWinnerController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    func resetAllPlayersBetsForNewState() {
        let playersActive = tableData.activePlayers.filter { $0.playerActiveInHand }
        playersActive.forEach { $0.playerBetInThisState = 0 }
    }
    
    func configureButtonsForEachState() {
        if tableData.gameState != GameState.preFlop {
            
            let playersActiveInHand = tableData.activePlayers.filter { $0.playerActiveInHand }
            let noOnePutBet = playersActiveInHand.allSatisfy({$0.playerBetInThisState == 0})
            
            if tableData.minimumBet == tableData.smallBlind * 2 && noOnePutBet {
                print("no one has bet so far")
            } else {
                let chipsToMatchBet = tableData.minimumBet - tableData.currentPlayer.playerBetInThisState

                if chipsToMatchBet != 0 {
                    if  playerChips > tableData.minimumBet {
                        callCheckButton.setTitle("CALL: \(chipsToMatchBet)", for: .normal)
                        if playerChips > tableData.minimumBet * 2 {
                            raiseBetButton.setTitle("RAISE", for: .normal)
                        } else {
                            raiseBetButton.setTitle("ALL IN", for: .normal)
                        }
                        minimumBetLabel.text = "MINIMUM BET: \(tableData.minimumBet)"
                    } else {
                        callCheckButton.setTitle("ALL IN", for: .normal)
                        raiseBetButton.setTitle("RAISE", for: .normal)
                        raiseBetButton.isEnabled = false
                        raiseBetButton.alpha = 0.2
                    }
                } else {
                    callCheckButton.setTitle("CHECK", for: .normal)
                    minimumBetLabel.text = "MINIMUM BET: \(tableData.minimumBet)"
                    if playerChips <= chipsToMatchBet {
                        raiseBetButton.setTitle("ALL IN", for: .normal)
                    } else {
                        raiseBetButton.setTitle("BET", for: .normal)
                    }
                }
            }
        } else if tableData.gameState == GameState.preFlop {
            let chipsToMatchBet = tableData.minimumBet - tableData.currentPlayer.playerBetInThisState

            if  playerChips > tableData.minimumBet {
                callCheckButton.setTitle("CALL: \(chipsToMatchBet)", for: .normal)
                if playerChips > tableData.minimumBet * 2 {
                    raiseBetButton.setTitle("RAISE", for: .normal)
                } else {
                    raiseBetButton.setTitle("ALL IN", for: .normal)
                }
                minimumBetLabel.text = "MINIMUM BET: \(tableData.minimumBet)"
            } else {
                callCheckButton.setTitle("ALL IN", for: .normal)
                raiseBetButton.setTitle("RAISE", for: .normal)
                raiseBetButton.isEnabled = false
                raiseBetButton.alpha = 0.2
            }
            
            if chipsToMatchBet == 0 {
                callCheckButton.setTitle("CHECK", for: .normal)
                minimumBetLabel.text = "MINIMUM BET: \(tableData.minimumBet)"
                if playerChips <= chipsToMatchBet {
                    raiseBetButton.setTitle("ALL IN", for: .normal)
                } else {
                    raiseBetButton.setTitle("BET", for: .normal)
                }
            }
        }
    }
    
    func safelyShowChooseWinnerController() {
        if tableData.winningScreenAlreadyShown == false {
            presentChooseWinnerController()
            tableData.winningScreenAlreadyShown = true
        }
    }
    
    func resetPlayerPropertiesForNewHand() {
        tableData.activePlayers.forEach {$0.playerBet = 0}
        tableData.activePlayers.forEach { $0.playerBetInThisState = 0 }
       
        tableData.activePlayers.forEach { $0.playerActiveInHand = true }
        tableData.activePlayers.forEach { $0.playerMadeAMove = false }
        tableData.activePlayers.forEach { $0.playerChecked = false }
        tableData.activePlayers.forEach { $0.playerWentAllIn = false }
        tableData.activePlayers.forEach { $0.playerWentAllInForSidePot = false }
        tableData.activePlayers.forEach { $0.playerFolded = false }
        tableData.activePlayers.forEach { $0.playerTappedRaise = false }
    }
    
    func resetTablePropertiesForNewHand() {
        tableData.potChips = 0
        tableData.currentBet = 0
        tableData.allPlayersFolded = false
        tableData.nextStateNeeded = false
        tableData.winnerPlayer = PlayerData(playerName: String(), playerChips: Int(), playerBet: Int(), playerBetInThisState: Int())
        tableData.gameState = .preFlop
        tableData.minimumBet = tableData.smallBlind * 2
    }
    
    func changeFontToPixel() {
        let allBigLabels = [potLabel, currentBetLabel, playerChipsLabel]
        let allSmallLabels = [minimumBetLabel, playerBetLabel]
        let allButtons = [minusButton, OKButton, plusButton, foldButton, callCheckButton, raiseBetButton]
        
        for eachLabel in allBigLabels {
            eachLabel?.font = UIFont(name: "Pixel Emulator", size: 25)
        }
        
        for eachLabel in allSmallLabels {
            eachLabel?.font = UIFont(name: "Pixel Emulator", size: 14)
        }
        
        for eachButton in allButtons {
            eachButton?.titleLabel?.font = UIFont(name: "Pixel Emulator", size: 14)
        }
        
        handStateLabel.font = UIFont(name: "Pixel Emulator", size: 80)
    }
    
    func hideAllLabelsAndButtons() {
        let allLabels = [playerLabel, potLabel, currentBetLabel, playerChipsLabel, minimumBetLabel, playerBetLabel]
        let allButtons = [foldButton, raiseBetButton, callCheckButton]
        for eachLabel in allLabels {
            eachLabel?.isHidden = true
        }
        for eachButton in allButtons {
            eachButton?.isHidden = true
        }
    }
    
    func showAllLabelsAndButtons() {
        let allLabels = [playerLabel, potLabel, currentBetLabel, playerChipsLabel, minimumBetLabel, playerBetLabel]
        let allButtons = [foldButton, raiseBetButton, callCheckButton]

        for eachLabel in allLabels {
            eachLabel?.isHidden = false
        }
        for eachButton in allButtons {
            eachButton?.isHidden = false
        }
    }
   
    
    @IBAction func unwindToPokerTable(_ sender: UIStoryboardSegue) {}
}

extension UIImage {
    func resize(size: CGSize) -> UIImage {
        let widthRatio  = size.width/self.size.width
        let heightRatio = size.height/self.size.height
        var updateSize = size
        if(widthRatio > heightRatio) {
            updateSize = CGSize(width:self.size.width*heightRatio, height:self.size.height*heightRatio)
        } else if heightRatio > widthRatio {
            updateSize = CGSize(width:self.size.width*widthRatio,  height:self.size.height*widthRatio)
        }
        UIGraphicsBeginImageContextWithOptions(updateSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(origin: .zero, size: updateSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
}
