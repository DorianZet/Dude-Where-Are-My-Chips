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
        animateHandStateLabel(for: "PRE-FLOP")
//        tutaj jest brzydka animacja, do poprawienia, reszta wyglada juz dobrze (tranzycja pomiedzy state'ami)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        callCheckButton.titleLabel!.adjustsFontSizeToFitWidth = true
        
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
             // rather than that, we should just present a controller with information in the winning player (because we already know the winner, we don't need to choose him).
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
            // zachowanie "ALL IN" button:
            if sender.title(for: .normal) == "ALL IN" {
                configureAllInButton()
            } else { // zachowanie "CALL" button:
                configureCallButton()
            }
        } else {
            if sender.title(for: .normal) == "ALL IN" { // zachowanie "ALL IN" button:
                configureAllInButton()
            } else if (sender.titleLabel?.text?.contains("CALL"))! { // zachowanie "CALL" button:
                configureCallButton()
            } else { // zachowanie "CHECK" button:

//                tableData.currentPlayer.playerChecked = true
//                let playersWhoChecked = tableData.activePlayers.filter { $0.playerChecked }
//                let playersWhoFolded = tableData.activePlayers.filter { $0.playerActiveInHand == false }
//                let playersWhoAreActive = tableData.activePlayers.filter { $0.playerActiveInHand }
//                let playersWhoWentAllIn = tableData.activePlayers.filter { $0.playerWentAllIn }
//                let playersWhoMoved = tableData.activePlayers.filter { $0.playerMadeAMove }
//
//                let allPlayersMoved = playersWhoMoved.allSatisfy({ $0.playerMadeAMove == true })
//
//                if (playersWhoChecked.count == tableData.activePlayers.count - playersWhoFolded.count && allPlayersMoved) || (playersWhoChecked.count + playersWhoWentAllIn.count == playersWhoAreActive.count && allPlayersMoved) {
//                    print("Players checked, going to the next state")
//                    goToNextState()
//                    playersWhoChecked.forEach { $0.playerChecked = false }
//                }
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
            
//            if betSlider.isHidden == false {
//                return
//            } else {
//                betSlider.isHidden = false
//                minusButton.isHidden = false
//                OKButton.isHidden = false
//                plusButton.isHidden = false
//
//                var chipsToMatchBet = 0
//
//                if tableData.minimumBet == tableData.currentPlayer.playerBetInThisState {
//                    chipsToMatchBet = tableData.minimumBet
//                } else {
//                    chipsToMatchBet = tableData.minimumBet - tableData.currentPlayer.playerBetInThisState
//                }
//                if tableData.currentPlayer.playerChips < chipsToMatchBet {
//                    betSlider.isUserInteractionEnabled = false
//                    betSlider.setValue(Float(sliderChips), animated: true)
//                    currentBet = sliderChips
//                    sliderChips -= sliderChips
//                    minusButton.isHidden = true
//                    plusButton.isHidden = true
//                    OKButton.setTitle("ALL IN", for: .normal)
//                } else {
//                    betSlider.isUserInteractionEnabled = true
//                    betSlider.minimumValue = Float(chipsToMatchBet)
//                    betSlider.maximumValue = Float(sliderChips)
//                    betSlider.setValue(betSlider.minimumValue, animated: true)
//                    currentBet = chipsToMatchBet
//                    sliderChips -= chipsToMatchBet
//                }
//            }
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
        
//        if tableData.currentPlayer.playerBetInThisState > tableData.minimumBet {
//            tableData.minimumBet = tableData.currentPlayer.playerBetInThisState
//        }
        playerChips -= playerChips
        tableData.currentPlayer.playerChips = playerChips
        tableData.currentPlayer.playerWentAllIn = true
        tableData.currentPlayer.playerActiveInHand = false
//        wprowadzilem ta linijke, sprawdz czy teraz jest ok (check loop bug):
        tableData.currentPlayer.playerMadeAMove = true
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
            //finish the hand and move to the next one
            // show winning screen, choose the player, add the pot chips to his chips, check all activePlayers - if they have 0 chips, remove them from activePlayers array, and turn on a new hand.
            
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
    
    func checkForNextState() { // everything grayed out has been left just for safety.
        let playingPlayers = tableData.activePlayers.filter { $0.playerActiveInHand }
        
        let allBetsAreEqual = playingPlayers.allSatisfy  ({
            $0.playerBetInThisState == tableData.minimumBet }) || allBetsAreZero()
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
//        w tym miejscu wydrukuj wszystko (przenies printy sprawdzajace stan graczy itd. dodatkowo wydrukuj tych graczy, ktorzy sa oznaczeni jako 'playerHasMoved = true')
        for eachPlayer in tableData.activePlayers {
            print("\(eachPlayer.playerName) BET: \(eachPlayer.playerBet)")
            print("\(eachPlayer.playerName) BET IN THIS STATE: \(eachPlayer.playerBetInThisState)")
            print("\(eachPlayer.playerName) CHIPS: \(eachPlayer.playerChips)")
        }
        print("POT: \(tableData.potChips)")
        print("allPlayersMoved = \(allPlayersMoved)")
        print("allBetsAreZero = \(allBetsAreZero())")
        print("allBetsAreEqual = \(allBetsAreEqual)")
        for eachPlayer in tableData.activePlayers {
            if eachPlayer.playerMadeAMove == true {
                print("\(eachPlayer.playerName) moved.")
            } else {
                print("\(eachPlayer.playerName) hasn't moved yet.")
            }
        }
        print("-----------")
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
            
            seeIfWeCanImmediatelyShowChooseWinnerControllerWith1PlayerLeft()
            
//            for eachPlayer in tableData.activePlayers {
//                print("\(eachPlayer.playerName) BET: \(eachPlayer.playerBet)")
//                print("\(eachPlayer.playerName) BET IN THIS STATE: \(eachPlayer.playerBetInThisState)")
//                print("\(eachPlayer.playerName) CHIPS: \(eachPlayer.playerChips)")
//            }
//            print("POT: \(tableData.potChips)")
            
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
            seeIfWeCanImmediatelyShowChooseWinnerControllerWith1PlayerLeft()

            tableData.currentPlayer = tableData.activePlayers[tableData.currentPlayerIndex]
            for eachPlayer in tableData.activePlayers {
                print("\(eachPlayer.playerName) BET: \(eachPlayer.playerBet)")
                print("\(eachPlayer.playerName) BET IN THIS STATE: \(eachPlayer.playerBetInThisState)")
                print("\(eachPlayer.playerName) CHIPS: \(eachPlayer.playerChips)")
            }
            print("POT: \(tableData.potChips)")
        }
    
        if tableData.currentPlayer.playerActiveInHand == true { // accept the player in the turn only if he hasn't folded
            
//            if tableData.currentPlayer.playerWentAllIn == true { // skip to the next player if the current one went all in
//                print("\(tableData.currentPlayer.playerName) went all in, skipping to the next player")
//                tableData.currentPlayerIndex += 1
//                if tableData.currentPlayerIndex > tableData.activePlayers.count - 1 {
//                    tableData.currentPlayerIndex = 0
//                }
//                DispatchQueue.main.async { [weak self] in
//                    self?.newTurn()
//                }
//                return
//            }
            raiseBetButton.isEnabled = true
            raiseBetButton.alpha = 1
            if tableData.currentPlayer.isPlayerSmallBlind == true {
                playerLabel.text = "\(tableData.currentPlayer.playerName)'S TURN [SM. BL.]"
            } else if tableData.currentPlayer.isPlayerBigBlind == true {
                playerLabel.text = "\(tableData.currentPlayer.playerName)'S TURN [BIG BL.]"
            } else {
                playerLabel.text = "\(tableData.currentPlayer.playerName)'S TURN"
            }
//            if tableData.currentPlayer.isPlayerSmallBlind == true && tableData.currentPlayer.playerMadeAMove == false && tableData.gameState == .preFlop {
//                tableData.currentPlayer.playerBetInThisState = tableData.smallBlind
//                tableData.currentPlayer.playerBet += tableData.smallBlind
//            } else if tableData.currentPlayer.isPlayerBigBlind == true && tableData.currentPlayer.playerMadeAMove == false && tableData.gameState == .preFlop {
//                tableData.currentPlayer.playerBetInThisState = tableData.smallBlind * 2
//                tableData.currentPlayer.playerBet += tableData.smallBlind * 2
//            }

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
    
    func seeIfWeCanImmediatelyShowChooseWinnerControllerWith1PlayerLeft() {
        // poniewaz wszystko dzieje sie bardzo szybko (gracze moga nie sprawdzic ze po wcisnieciu new hand, zostaje tylko jeden gracz, w wyniku czego natychmiast pojawia sie znowu ChooseWinnerVC), dlatego chyba warto w tym przypadku oznajmic na koncowym ekranie ze "all players but 1 went all in, choose the winner):
        let playingPlayers = tableData.activePlayers.filter { $0.playerActiveInHand }

        if playingPlayers.count == 1 && playingPlayers[0].playerBetInThisState >= tableData.minimumBet  {
            safelyShowChooseWinnerController()
            print("All players but 1 went all in, showing finish hand screen")
            tableData.gameState = .finishHand
            return
        }
    }
    
    func decideWhoStartsWhenNewHand() {
        let playingPlayers = tableData.activePlayers.filter { $0.playerActiveInHand }
        let noOneHasMovedYet = playingPlayers.allSatisfy { ($0.playerMadeAMove == false) }
        // ^^^ tutaj chyba powinno byc false (wczesniej bylo true)
        
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
//            ///
//            for each in allBigLabels {
//                each?.isHidden = false
//            }
//
//            for each in allSmallLabels {
//                each?.isHidden = false
//            }
//            ///
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
            // zrob petle, ktora przejezdza przez wszystkich aktywnych graczy i sprawdza ich bety. jesli ktorykolwiek nie rowna sie 0, check button sie zmienia w call button.
//            let playersActiveInHand = tableData.activePlayers.filter { $0.playerActiveInHand }
//            let playersActiveWithZeroBet = tableData.activePlayers.filter { $0.playerBetInThisState == 0 &&  $0.playerActiveInHand}
            
            let playersActiveInHand = tableData.activePlayers.filter { $0.playerActiveInHand }
            let noOnePutBet = playersActiveInHand.allSatisfy({ $0.playerBetInThisState == 0 })
            
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
            // NA PRÓBĘ: (SPRAWDŹ, W KTORYM GAMESTATE ZROBIŁ SIĘ POT:88, JESLI JEST TO .PREFLOP, PONIZSZY KOD MOZE BYC ROZWIAZANIEM!)
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
                if tableData.currentPlayer.isPlayerBigBlind == true && tableData.currentPlayer.playerChips <= tableData.minimumBet {
                    if playerChips <= tableData.minimumBet {
                        raiseBetButton.setTitle("ALL IN", for: .normal)
                    } else {
                        raiseBetButton.setTitle("BET", for: .normal)
                    }
                } else {
                    if playerChips <= chipsToMatchBet {
                        raiseBetButton.setTitle("ALL IN", for: .normal)
                    } else {
                        raiseBetButton.setTitle("BET", for: .normal)
                    }
                }
            }
            // TO BYŁO NA PRÓBĘ, POPRZEDNIA WERSJA PONIŻEJ (ODKOMENTUJ ABY POWRÓCIC DO POPRZEDNIEJ WERSJI):
            
            
            
            
//            let chipsToMatchBet = tableData.minimumBet - tableData.currentPlayer.playerBetInThisState
//
//            if  playerChips > tableData.minimumBet {
//                callCheckButton.setTitle("CALL: \(chipsToMatchBet)", for: .normal)
//                if playerChips > tableData.minimumBet * 2 {
//                    raiseBetButton.setTitle("RAISE", for: .normal)
//                } else {
//                    raiseBetButton.setTitle("ALL IN", for: .normal)
//                }
//                minimumBetLabel.text = "MINIMUM BET: \(tableData.minimumBet)"
//            } else {
//                callCheckButton.setTitle("ALL IN", for: .normal)
//                raiseBetButton.setTitle("RAISE", for: .normal)
//                raiseBetButton.isEnabled = false
//                raiseBetButton.alpha = 0.2
//            }
//
//            if chipsToMatchBet == 0 {
//                callCheckButton.setTitle("CHECK", for: .normal)
//                minimumBetLabel.text = "MINIMUM BET: \(tableData.minimumBet)"
//                if playerChips <= chipsToMatchBet {
//                    raiseBetButton.setTitle("ALL IN", for: .normal)
//                } else {
//                    raiseBetButton.setTitle("BET", for: .normal)
//                }
//            }
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
