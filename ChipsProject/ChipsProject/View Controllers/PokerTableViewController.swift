//
//  PokerTableViewController.swift
//  ChipsProject
//
//  Created by Mateusz Zacharski on 04/08/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//
import AVFoundation
import UIKit

class PokerTableViewController: UIViewController {
    
    var tableData = TableData()
    
    var potChips = 0
    
    var playerChips = 0
    
    var sliderChips = 0 {
        didSet {
            if blockDidSet == false {
                playerChipsLabel.text = "YOUR CHIPS: \(sliderChips)"
            }
        }
    }
    
    var currentBet = 0 {
        didSet {
            if blockDidSet == false {
                currentBetLabel.text = "BET: \(currentBet)"
            }
        }
    }
    
    var blockDidSet = false // we use blockDidSet to, well, block all didSets when needed. Particularly, we need to block those right before the animation of switching a player, to prevent the immediate change of values in 'playerChipsLabel' and 'currentBetLabel' prior to the "swish" animation.
    
    var audioPlayer = AVAudioPlayer()
    
    var soundOn = true
    
    var isNewGame = true
        
    @IBOutlet var playerLabel: UILabel!
    @IBOutlet var homeButton: RoundedButton!
    @IBOutlet var infoButton: UIButton!
    @IBOutlet var soundButton: RoundedButton!
    @IBOutlet var potLabel: UILabel!
    @IBOutlet var handStateView: UIView!
    @IBOutlet var handStateLabel: UILabel!
    @IBOutlet var cardsStackView: UIStackView!
    @IBOutlet var card1: UIImageView!
    @IBOutlet var card2: UIImageView!
    @IBOutlet var card3: UIImageView!
    @IBOutlet var card4: UIImageView!
    @IBOutlet var card5: UIImageView!

    @IBOutlet var currentBetLabel: UILabel!
    @IBOutlet var playerChipsLabel: UILabel!
    @IBOutlet var minimumBetLabel: UILabel!
    @IBOutlet var playerBetLabel: UILabel!
    @IBOutlet var betSlider: UISlider!
    @IBOutlet var minusButton: PlusMinusButton!
    @IBOutlet var OKButton: RoundedButton!
    @IBOutlet var plusButton: PlusMinusButton!
    @IBOutlet var foldButton: RoundedButton!
    @IBOutlet var callCheckButton: RoundedButton!
    @IBOutlet var raiseBetButton: RoundedButton!

    
    override func viewDidAppear(_ animated: Bool) {
        if tableData.gameState == .preFlop { // we give a condition that the animation (with the data changes along) will go only if the game state is in pre-flop. The reason for this is that there was a crash when we went back to main menu when the game was won by one player. on its way to the root screen, the code tried to initialize animateHandStateLabel(for:) in PokerTableVC with the code inside, particularly configureTurn(), which tried to operate on tableData which could have wrong data, e.g. 1 player left in game. We ensure then that the code will be executed ONLY at the beginning of a hand.
            cardsStackView.isHidden = true
            animateHandStateView(for: "PRE-FLOP")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global(qos: .userInitiated).async {
            self.audioPlayer.loadSounds(forSoundNames: ["betRaise.mp3", "allIn.mp3", "call.mp3", "nextState.mp3", "check.aiff", "preFlop.mp3"])
        }
        
        betSlider.accessibilityIdentifier = "betSlider"
        setExclusiveTouchForAllButtons()
        
        checkForSound()
        
        view.backgroundColor = .darkGray
                
        callCheckButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        configureTopButtons()
        
        setCardsImage()
        
        hideAllLabelsAndButtons()
        handStateLabel.adjustsFontSizeToFitWidth = true
        handStateLabel.sizeToFit()
        changeFontToPixel()
        setThumbImage()

        hideSliderAndButtons()
                              
        tableData.newHandNeeded = true
        newHand()
    }
    @IBAction func tapHomeIcon(_ sender: UIButton) {
        playSound(for: "smallButton.aiff")
        
        UIView.animate(withDuration: 0.2) {
            self.view.alpha = 0.8
        }
        let pm = PMAlertController(title: "EXIT TO MAIN MENU?", description: nil, image: nil, style: .alert)
        if #available(iOS 13.0, *) {
            pm.overrideUserInterfaceStyle = .dark
        }
        pm.alertActionStackView.axis = .horizontal
        pm.alertView.backgroundColor = .darkGray
        pm.alertView.layer.cornerRadius = 0
        pm.alertView.layer.borderWidth = 4
        pm.alertView.layer.shadowColor = UIColor.clear.cgColor
        pm.alertView.layer.borderColor = UIColor.black.cgColor
        pm.alertView.layer.masksToBounds = true
        
        pm.alertTitle.font = UIFont(name: "Pixel Emulator", size: 15)
        pm.alertTitle.textColor = .systemYellow
        
        pm.alertDescription.font = UIFont(name: "Pixel Emulator", size: 10)
        pm.alertDescription.textColor = .systemYellow
        pm.alertActionStackView.axis = .horizontal
        
        let okAct = PMAlertAction(title: "OK", style: .default) { [weak self] in
            UIView.animate(withDuration: 0.2) {
                self?.view.alpha = 1
                self?.performSegue(withIdentifier: "UnwindToTitleSegue", sender: nil)
            }
        }
        let cancelAct = PMAlertAction(title: "CANCEL", style: .default) { [weak self] in
            UIView.animate(withDuration: 0.2) {
                self?.view.alpha = 1
            }
        }
    
        okAct.titleLabel?.font = UIFont(name: "Pixel Emulator", size: 15)
        okAct.setTitleColor(.systemYellow, for: .normal)
        cancelAct.titleLabel?.font = UIFont(name: "Pixel Emulator", size: 15)
        cancelAct.setTitleColor(.systemYellow, for: .normal)
       
        pm.addAction(cancelAct)
        pm.addAction(okAct)
        
        pm.gravityDismissAnimation = false
        
        self.present(pm, animated: true)
    }
    
    func exitToMainMenu(action: UIAlertAction) {
        performSegue(withIdentifier: "UnwindToTitleSegue", sender: action)
    }
    
    @IBAction func tapSoundButton(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        
        if soundOn == true {
            if let image = UIImage(named:"speakerButton 2silent.png") {
                sender.setImage(image, for: .normal)
            }
            defaults.set("soundOff", forKey: "sound")
            soundOn = false
        } else {
            if let image = UIImage(named:"speakerButton 2.png") {
                sender.setImage(image, for: .normal)
            }
            defaults.set("soundOn", forKey: "sound")
            soundOn = true
            playSound(for: "smallButton.aiff")
        }
    }
    
    @IBAction func tapInfoButton(_ sender: Any) {
        playSound(for: "smallButton.aiff")
        
        var tableInfoMessage = tableData.currentGameState()
        
        for eachPlayer in tableData.activePlayers {
            if eachPlayer.isPlayerSmallBlind == true && tableData.gameState == .preFlop {
                tableInfoMessage += "\(eachPlayer.playerName) (SM. BL.) | CHIPS: \(eachPlayer.playerChips) | BET: \(eachPlayer.playerBetInThisState)\n"
            } else if eachPlayer.isPlayerBigBlind == true && tableData.gameState == .preFlop {
                tableInfoMessage += "\(eachPlayer.playerName) (BIG BL.) | CHIPS: \(eachPlayer.playerChips) | BET: \(eachPlayer.playerBetInThisState)\n"
            } else {
                tableInfoMessage += "\(eachPlayer.playerName) | CHIPS: \(eachPlayer.playerChips) | BET: \(eachPlayer.playerBetInThisState)\n"
            }
        }
        
        let finalTableInfoMessage = tableInfoMessage.dropLast()
        tableInfoMessage = String(finalTableInfoMessage)

        UIView.animate(withDuration: 0.2) {
            self.view.alpha = 0.8
        }
        
        let pm = PMAlertController(title: "TABLE INFO", description: tableInfoMessage, image: nil, style: .walkthrough)
        if #available(iOS 13.0, *) {
            pm.overrideUserInterfaceStyle = .dark
        }
        pm.alertView.backgroundColor = .darkGray
        pm.alertView.layer.cornerRadius = 0
        pm.alertView.layer.borderWidth = 4
        pm.alertView.layer.shadowColor = UIColor.clear.cgColor
        pm.alertView.layer.borderColor = UIColor.black.cgColor
        pm.alertView.layer.masksToBounds = true
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            pm.alertTitle.font = UIFont(name: "Pixel Emulator", size: 15)
            pm.alertDescription.font = UIFont(name: "Pixel Emulator", size: 10)
        } else {
            pm.alertTitle.font = UIFont(name: "Pixel Emulator", size: 22)
            pm.alertDescription.font = UIFont(name: "Pixel Emulator", size: 15)
        }
        
        pm.alertTitle.textColor = .systemYellow
        pm.alertDescription.textColor = .systemYellow

        let okAct = PMAlertAction(title: "OK", style: .default) { [weak self] in
            UIView.animate(withDuration: 0.2) {
                self?.view.alpha = 1
            }
        }
    
        okAct.titleLabel?.font = UIFont(name: "Pixel Emulator", size: 15)
        okAct.setTitleColor(.systemYellow, for: .normal)
        
        pm.addAction(okAct)

        pm.gravityDismissAnimation = false
        
        self.present(pm, animated: true)
    }
    
    
    @IBAction func tapFoldButton(_ sender: UIButton) {
        playSound(for: "fold.mp3")
        
        tableData.currentPlayer.playerActiveInHand = false
        tableData.currentPlayer.playerFolded = true
        tableData.currentPlayer.playerMadeAMove = true
        
        print("\(tableData.currentPlayer.playerName) has folded, setting playerActiveInHand = false...")
        
        tableData.checkForFoldedPlayers()
        if tableData.allPlayersFolded == true {
            print("All players folded, \(tableData.winnerPlayer.playerName) WINS!")
            safelyShowChooseWinnerController()
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
            // "ALL IN" button:
            if sender.title(for: .normal) == "ALL IN" {
                configureAllInButton()
            } else { // "CALL" button:
                if sender.titleLabel?.text == "CHECK" {
                    playSound(for: "check.aiff")
                } else {
                    playSound(for: "call.mp3")
                }
                configureCallButton()
            }
        } else {
            if sender.title(for: .normal) == "ALL IN" { // "ALL IN" button:
                configureAllInButton()
            } else if (sender.titleLabel?.text?.contains("CALL"))! { // "CALL" button:
                playSound(for: "call.mp3")
                configureCallButton()
            } else { // "CHECK" button:
                playSound(for: "check.aiff")
                
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
        currentBet = Int(betSlider.value)
        sliderChips = Int(betSlider.maximumValue) - Int(betSlider.value)
    }
    
    @IBAction func tapMinusButton(_ sender: UIButton) {
        playSound(for: "smallButton.aiff")
        
        if sliderChips >= tableData.currentPlayer.playerChips || tableData.currentBetIsBelowOrEqualToMinimumBetOrRaiseBet(currentBet: currentBet) {
            return
        } else {
            sliderChips += 1
            currentBet -= 1
        }
    }
    
    @IBAction func tapOKButton(_ sender: UIButton) {
        playSound(for: "ok.mp3")
        
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
        playSound(for: "smallButton.aiff")
        
        if sliderChips <= 0 {
            return
        } else {
            sliderChips -= 1
            currentBet += 1
        }
    }
    
    func configureAllInButton() {
        playSound(for: "allIn.mp3")
        
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
        playSound(for: "betRaise.mp3")
        
        if betSlider.isHidden == false {
            return
        } else {
            showSliderAndButtons()
            
            betSlider.isUserInteractionEnabled = true
            betSlider.minimumValue = Float(tableData.minimumBet)
            betSlider.maximumValue = Float(sliderChips)
            betSlider.setValue(betSlider.minimumValue, animated: false)
            currentBet = tableData.minimumBet
            sliderChips -= tableData.minimumBet
        }
    }
    
    func configureRaiseButton() {
        playSound(for: "betRaise.mp3")
        
        if betSlider.isHidden == false {
            return
        } else {
            showSliderAndButtons()
            
            tableData.currentPlayer.playerTappedRaise = true
             
            betSlider.isUserInteractionEnabled = true
            betSlider.minimumValue = Float(tableData.minimumBet * 2)
            betSlider.maximumValue = Float(sliderChips)
            betSlider.setValue(betSlider.minimumValue, animated: false)
            currentBet = tableData.minimumBet * 2
            sliderChips -= tableData.minimumBet * 2
        }
    }
    
    func newHand() {
        tableData.resetPlayerPropertiesForNewHand()
        tableData.resetTablePropertiesForNewHand()
        tableData.chooseBlindPlayers()
        tableData.isNewHand = true
        tableData.numberOfHandsPlayed += 1
        if tableData.numberOfHandsPlayed > 2 {
            tableData.numberOfHandsPlayed = 1
        }
        
        newTurn()
    }
    
    func newTurn() {
        // changing the button titles appropriately to the game state:
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
                cardsStackView.isHidden = false
                card5.isHidden = true
                card4.isHidden = true
                
                animateHandStateView(for: "THE FLOP")
                print("THE FLOP")
            } else {
                configureTurn()
            }
        } else if tableData.gameState == GameState.theTurn {
            callCheckButton.setTitle("CHECK", for: .normal)
            raiseBetButton.setTitle("BET", for: .normal)
            if tableData.nextStateNeeded == true {
                cardsStackView.isHidden = false
                card5.isHidden = true
                card4.isHidden = false
                animateHandStateView(for: "THE TURN")
                print("THE TURN")
            } else {
                configureTurn()
            }
        } else if tableData.gameState == GameState.TheRiver {
            callCheckButton.setTitle("CHECK", for: .normal)
            raiseBetButton.setTitle("BET", for: .normal)
            if tableData.nextStateNeeded == true {
                card5.isHidden = false
                animateHandStateView(for: "THE RIVER")
                print("THE RIVER")
            } else {
                configureTurn()
            }
        } else if tableData.gameState == GameState.finishHand {
            // finish the hand and move to the next one
            safelyShowChooseWinnerController()
            print("SHOWING THE HAND FINISH SCREEN")
        }
    }
    
    func hideSliderAndButtons() {
        if betSlider.isHidden == false {
            
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                self.betSlider.alpha = 0
                self.minusButton.alpha = 0
                self.OKButton.alpha = 0
                self.plusButton.alpha = 0
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.betSlider.isHidden = true
                    self.minusButton.isHidden = true
                    self.OKButton.isHidden = true
                    self.plusButton.isHidden = true
                }
            })
        }
    }
    
    func showSliderAndButtons() {
        self.betSlider.isHidden = false
        self.minusButton.isHidden = false
        self.OKButton.isHidden = false
        self.plusButton.isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.betSlider.alpha = 1
            self.minusButton.alpha = 1
            self.OKButton.alpha = 1
            self.plusButton.alpha = 1
        })
    }
    
    func checkForNextState() {
        let playingPlayers = tableData.activePlayers.filter { $0.playerActiveInHand }
        
        let allBetsAreEqual = playingPlayers.allSatisfy ({ $0.playerBetInThisState == tableData.minimumBet })
            || tableData.allBetsAreZero()
        let allPlayersMoved = tableData.activePlayers.allSatisfy({ $0.playerMadeAMove == true })
        
        if allPlayersMoved {
            if playingPlayers.count == 1 && playingPlayers[0].playerBetInThisState >= tableData.minimumBet  {
                safelyShowChooseWinnerController()
                print("All players but 1 went all in, showing finish hand screen")
                tableData.gameState = .finishHand
            } else if allBetsAreEqual {
                tableData.goToNextState()
                playingPlayers.forEach { $0.playerMadeAMove = false }
            } else {
                print ("bets not equal.")
            }
        }

        printCurrentGameState(allPlayersMoved: allPlayersMoved, allBetsAreEqual: allBetsAreEqual)
    }
    
    func printCurrentGameState(allPlayersMoved: Bool, allBetsAreEqual: Bool) {
        for eachPlayer in tableData.activePlayers {
            print("\(eachPlayer.playerName) BET: \(eachPlayer.playerBet)")
            print("\(eachPlayer.playerName) BET IN THIS STATE: \(eachPlayer.playerBetInThisState)")
            print("\(eachPlayer.playerName) CHIPS: \(eachPlayer.playerChips)")
        }
        
        print("POT: \(tableData.potChips)")
        print("allPlayersMoved = \(allPlayersMoved)")
        print("allBetsAreZero = \(tableData.allBetsAreZero())")
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
    
    func configureTurn() {
        // hide the slider and its buttons only if the slider is visible:
        hideSliderAndButtons()
        
        if tableData.newHandNeeded == true {
            print("new hand was needed")
            tableData.decideWhoStartsWhenNewHand()
            
            tableData.configureBlindsBeforeNewHand()
            
            seeIfWeCanImmediatelyShowChooseWinnerControllerWith1PlayerLeft() // in case there are 2 players active in hand and one of them can't afford their blind.
            
        } else if tableData.nextStateNeeded == true {
            let smallBlindPlayer = tableData.activePlayers[tableData.smallBlindPlayerIndex]
            if smallBlindPlayer.playerActiveInHand == true {
                tableData.currentPlayer = smallBlindPlayer
                tableData.currentPlayerIndex = tableData.smallBlindPlayerIndex
            } else {
                var nextAvailablePlayerIndex = tableData.smallBlindPlayerIndex + 1
                var nextAvailablePlayer = tableData.activePlayers[nextAvailablePlayerIndex]
                while !nextAvailablePlayer.playerActiveInHand {
                    nextAvailablePlayerIndex += 1
                    if nextAvailablePlayerIndex > tableData.activePlayers.count - 1 {
                        nextAvailablePlayerIndex = 0
                    }
                    nextAvailablePlayer = tableData.activePlayers[nextAvailablePlayerIndex]
                }
                tableData.currentPlayer = nextAvailablePlayer
                tableData.currentPlayerIndex = nextAvailablePlayerIndex
            }

            resetAllPlayersBetsForNewState()
            tableData.minimumBet = tableData.smallBlind * 2
            
            for eachPlayer in tableData.activePlayers {
                print("\(eachPlayer.playerName) BET: \(eachPlayer.playerBet)")
                print("\(eachPlayer.playerName) BET IN THIS STATE: \(eachPlayer.playerBetInThisState)")
                print("\(eachPlayer.playerName) CHIPS: \(eachPlayer.playerChips)")
            }
            print("POT: \(tableData.potChips)")
            
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
            
            let chipsToMatchBet = tableData.minimumBet - tableData.currentPlayer.playerBetInThisState
            print("Chips to match bet: \(chipsToMatchBet)")
            
            raiseBetButton.isEnabled = true
            raiseBetButton.alpha = 1
            
            blockDidSet = true
            currentBet = 0
            potChips = tableData.potChips
            playerChips = tableData.currentPlayer.playerChips
            tableData.sliderChips = playerChips
            sliderChips = playerChips
            blockDidSet = false
            
            if tableData.newHandNeeded == true { // changes in interface with no animations:
                changeInterfaceNoAnimations()
                
                tableData.newHandNeeded = false
            } else if tableData.nextStateNeeded == true {
                changeInterfaceNoAnimations()
                                
                tableData.nextStateNeeded = false
            } else {
                swishAllLabelsAnimation()
            }

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
    
    func changeInterfaceNoAnimations() {
        if tableData.gameState == .preFlop {
            if tableData.currentPlayer.isPlayerSmallBlind == true {
                playerLabel.text = "\(tableData.currentPlayer.playerName)'S TURN (SM. BL.)"
            } else if tableData.currentPlayer.isPlayerBigBlind == true {
                self.playerLabel.text = "\(tableData.currentPlayer.playerName)'S TURN (BIG BL.)"
            } else {
                playerLabel.text = "\(tableData.currentPlayer.playerName)'S TURN"
            }
        } else {
            playerLabel.text = "\(tableData.currentPlayer.playerName)'S TURN"
        }

        playerChipsLabel.text = "YOUR CHIPS: \(sliderChips)"
        playerBetLabel.text = "YOUR BET: \(tableData.currentPlayer.playerBetInThisState)"
        potLabel.text = "POT: \(potChips)"
        currentBetLabel.text = "BET: \(currentBet)"
        minimumBetLabel.text = "MINIMUM BET: \(tableData.minimumBet)"
    }
    
    func seeIfWeCanImmediatelyShowChooseWinnerControllerWith1PlayerLeft() {
        let playingPlayers = tableData.activePlayers.filter { $0.playerActiveInHand }

        if playingPlayers.count == 1 && playingPlayers[0].playerBetInThisState >= tableData.minimumBet  {
            tableData.onePlayerLeftWithRestWentAllIn = true
            safelyShowChooseWinnerController()
            print("All players but 1 went all in in pre-flop, immediately showing finish hand screen")
            tableData.gameState = .finishHand
            return
        }
    }
    
    func animateHandStateView(for state: String) {
        view.isUserInteractionEnabled = false
        
        handStateView.isHidden = false
        handStateView.backgroundColor = .darkGray
        handStateView.layer.borderWidth = 4
        handStateView.layer.borderColor = UIColor.black.cgColor
        handStateView.layer.masksToBounds = true
        handStateView.alpha = 0
        handStateView.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        handStateLabel.text = state

        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 35, options: [], animations: {
            self.handStateView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.handStateView.alpha = 1
        }) { _ in
            if self.tableData.gameState == .preFlop {
                self.showLabelsAndButtons()
                self.playSound(for: "preFlop.mp3")
            } else {
                self.playSound(for: "nextState.mp3")
            }
            self.configureTurn()
            self.currentBetLabel.isHidden = false
        }
        
        UIView.animate(withDuration: 0.3, delay: 2.0, usingSpringWithDamping: 10, initialSpringVelocity: 12, options: [], animations: {
            self.handStateView.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
            self.handStateView.alpha = 0
        }) { _ in
            self.handStateView.isHidden = true
            self.view.isUserInteractionEnabled = true
        }
    }
    
    func checkIfAllPlayersWentAllIn() {
        let playersWhoWentAllIn = tableData.activePlayers.filter { $0.playerWentAllIn == true }
        let playersWhoFolded = tableData.activePlayers.filter { $0.playerFolded == true }

        if playersWhoWentAllIn.count == tableData.activePlayers.count - playersWhoFolded.count {
            print("All players went all in, showing the finish hand screen.")
            safelyShowChooseWinnerController()
            tableData.gameState = .finishHand
        }
    }
    
    func presentChooseWinnerController() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ChooseWinnerController") as! ChooseWinnerController
        nextViewController.tableData = tableData
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    func resetAllPlayersBetsForNewState() {
        let playersActive = tableData.activePlayers
        playersActive.forEach { $0.playerBetInThisState = 0 }
    }
    
    func configureButtonsForEachState() {
        if tableData.gameState != GameState.preFlop {
            
            let playingPlayers = tableData.activePlayers
            let playersActiveInHand = playingPlayers.filter { $0.playerActiveInHand == true }
            let noOnePutBet = playingPlayers.allSatisfy({ $0.playerBetInThisState == 0 })
            
            if tableData.minimumBet == tableData.smallBlind * 2 && noOnePutBet {
                print("no one has bet so far")
            }
            let chipsToMatchBet = tableData.minimumBet - tableData.currentPlayer.playerBetInThisState

            if chipsToMatchBet != 0 && !noOnePutBet {
                if  playerChips > chipsToMatchBet {
                    callCheckButton.setTitle("CALL: \(chipsToMatchBet)", for: .normal)
                    
                    if playerChips > tableData.minimumBet * 2 {
                        raiseBetButton.setTitle("RAISE", for: .normal)
                    } else {
                        raiseBetButton.setTitle("ALL IN", for: .normal)
                    }
                    
                    if playersActiveInHand.count == 1 {
                        raiseBetButton.setTitle("RAISE", for: .normal)
                        raiseBetButton.isEnabled = false
                        raiseBetButton.alpha = 0.2
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
        } else if tableData.gameState == GameState.preFlop {
            
            let chipsToMatchBet = tableData.minimumBet - tableData.currentPlayer.playerBetInThisState
            let playingPlayers = tableData.activePlayers
            let playersActiveInHand = playingPlayers.filter { $0.playerActiveInHand == true }

            if chipsToMatchBet != 0 {
                if  playerChips > chipsToMatchBet {
                    callCheckButton.setTitle("CALL: \(chipsToMatchBet)", for: .normal)
                    callCheckButton.contentHorizontalAlignment = .center
                    callCheckButton.titleLabel?.textAlignment = .center
                    if playerChips > tableData.minimumBet * 2 {
                        raiseBetButton.setTitle("RAISE", for: .normal)
                    } else {
                        raiseBetButton.setTitle("ALL IN", for: .normal)
                    }
                    
                    if playersActiveInHand.count == 1 {
                        raiseBetButton.setTitle("RAISE", for: .normal)
                        raiseBetButton.isEnabled = false
                        raiseBetButton.alpha = 0.2
                    }
                    //
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

                if tableData.currentPlayer.isPlayerBigBlind == true && tableData.currentPlayer.playerChips <= chipsToMatchBet {
                    if playerChips <= chipsToMatchBet {
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
        }
    }
    
    func safelyShowChooseWinnerController() {
        if tableData.winningScreenAlreadyShown == false {
            presentChooseWinnerController()
            tableData.winningScreenAlreadyShown = true
        }
    }
    
    func changeFontToPixel() {
        let allBigLabels = [potLabel, currentBetLabel, playerChipsLabel, playerLabel]
        let allSmallLabels = [minimumBetLabel, playerBetLabel]
        let allButtons = [minusButton, OKButton, plusButton, foldButton, callCheckButton, raiseBetButton]
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            for eachLabel in allBigLabels {
                eachLabel?.font = UIFont(name: "Pixel Emulator", size: 25)
                eachLabel?.textColor = .systemYellow
            }
            
            for eachLabel in allSmallLabels {
                eachLabel?.font = UIFont(name: "Pixel Emulator", size: 14)
                eachLabel?.textColor = .systemYellow
            }
           
            for eachButton in allButtons {
                eachButton?.titleLabel?.font = UIFont(name: "Pixel Emulator", size: 14)
            }
            
            handStateLabel.font = UIFont(name: "Pixel Emulator", size: 64)
            handStateLabel.textColor = .systemYellow
        } else {
            for eachLabel in allBigLabels {
                eachLabel?.font = UIFont(name: "Pixel Emulator", size: 37)
                eachLabel?.textColor = .systemYellow
            }
            
            for eachLabel in allSmallLabels {
                eachLabel?.font = UIFont(name: "Pixel Emulator", size: 21)
                eachLabel?.textColor = .systemYellow
            }
           
            for eachButton in allButtons {
                eachButton?.titleLabel?.font = UIFont(name: "Pixel Emulator", size: 18)
            }
            
            handStateLabel.font = UIFont(name: "Pixel Emulator", size: 100)
            handStateLabel.textColor = .systemYellow
        }
        
    }
    
    func hideAllLabelsAndButtons() {
        let allLabels = [playerLabel, potLabel, currentBetLabel, playerChipsLabel, minimumBetLabel, playerBetLabel]
        let allButtons = [foldButton, raiseBetButton, callCheckButton, homeButton, soundButton, infoButton]
        for eachLabel in allLabels {
            eachLabel?.isHidden = true
        }
        for eachButton in allButtons {
            eachButton?.isHidden = true
        }
    }
    
    func showLabelsAndButtons() {
        let allLabels = [playerLabel, potLabel, currentBetLabel, playerChipsLabel, minimumBetLabel, playerBetLabel]
        let allButtons = [foldButton, raiseBetButton, callCheckButton, homeButton, soundButton, infoButton]

        for eachLabel in allLabels {
            eachLabel?.isHidden = false
        }
        for eachButton in allButtons {
            eachButton?.isHidden = false
        }
    }
    
    func setThumbImage() {
        let defaults = UserDefaults.standard
        let version = defaults.string(forKey: "version")
        
        if version == "ukChips" {
            if let ukThumbImage = UIImage(named: "chipUK") {
                let smallThumb = ukThumbImage.resize(size: CGSize(width: 50, height: 50))
                
                setImageForAllThumbStates(thumbImage: smallThumb)
            }
        } else if version == "usChips" {
            if let usThumbImage = UIImage(named: "chipUS") {
                let smallThumb = usThumbImage.resize(size: CGSize(width: 53, height: 40))
                
                setImageForAllThumbStates(thumbImage: smallThumb)
            }
        } else {
            if let usThumbImage = UIImage(named: "chipUS") {
                let smallThumb = usThumbImage.resize(size: CGSize(width: 53, height: 40))
                
                setImageForAllThumbStates(thumbImage: smallThumb)
            }
        }
    }
    
    func setImageForAllThumbStates(thumbImage: UIImage) {
        let states: [UIControl.State] = [.application, .disabled, .focused, .highlighted, .normal, .reserved, .selected]
        
        for eachState in states {
            betSlider.setThumbImage(thumbImage, for: eachState)
        }
    }
    
    func swishAllLabelsAnimation() {
        let labels = [playerLabel, playerChipsLabel, playerBetLabel, potLabel, currentBetLabel, minimumBetLabel]
        let buttons = [homeButton, soundButton, infoButton]
        
        for eachLabel in labels {
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                eachLabel?.alpha = 0
                eachLabel?.transform = CGAffineTransform(translationX: -150, y: 0)
            }, completion: { _ in
                if eachLabel == self.playerLabel {
                    if self.tableData.gameState == .preFlop {
                        if self.tableData.currentPlayer.isPlayerSmallBlind == true {
                            self.playerLabel.text = "\(self.tableData.currentPlayer.playerName)'S TURN (SM. BL.)"
                        } else if self.tableData.currentPlayer.isPlayerBigBlind == true {
                            self.playerLabel.text = "\(self.tableData.currentPlayer.playerName)'S TURN (BIG BL.)"
                        } else {
                            self.playerLabel.text = "\(self.tableData.currentPlayer.playerName)'S TURN"
                        }
                    } else {
                        self.playerLabel.text = "\(self.tableData.currentPlayer.playerName)'S TURN"
                    }
                } else if eachLabel == self.playerChipsLabel {
                    self.playerChipsLabel.text = "YOUR CHIPS: \(self.sliderChips)"
                } else if eachLabel == self.playerBetLabel {
                    self.playerBetLabel.text = "YOUR BET: \(self.tableData.currentPlayer.playerBetInThisState)"
                } else if eachLabel == self.potLabel {
                    self.potLabel.text = "POT: \(self.potChips)"
                } else if eachLabel == self.currentBetLabel {
                    self.currentBetLabel.text = "BET: \(self.currentBet)"
                } else if eachLabel == self.minimumBetLabel  {
                    self.minimumBetLabel.text = "MINIMUM BET: \(self.tableData.minimumBet)"
                }
                
                eachLabel?.transform = CGAffineTransform.identity
                eachLabel?.transform = CGAffineTransform(translationX: 150, y: 0)
                
                UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                    eachLabel?.transform = CGAffineTransform.identity
                    eachLabel?.alpha = 1
                })
            })
        }
        
        for eachButton in buttons {
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                eachButton?.alpha = 0
                eachButton?.transform = CGAffineTransform(translationX: -150, y: 0)
            }, completion: { _ in
                eachButton?.transform = CGAffineTransform.identity
                eachButton?.transform = CGAffineTransform(translationX: 150, y: 0)
                
                UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                    eachButton?.transform = CGAffineTransform.identity
                    eachButton?.alpha = 1
                })
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UnwindToTitleSegue" {
            
            let destVC = segue.destination as! ViewController
            if soundOn == true {
                destVC.soundOn = true
            } else {
                destVC.soundOn = false
            }
        }
    }
    
    func configureTopButtons() {
        homeButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        homeButton.accessibilityIdentifier = "homeButton"
        infoButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        soundButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        if let imageSoundOn = UIImage(named:"speakerButton 2.png") {
            if let imageSoundOff = UIImage(named: "speakerButton 2silent.png") {
                if soundOn == true {
                    soundButton.setImage(imageSoundOn, for: .normal)
                } else {
                    soundButton.setImage(imageSoundOff, for: .normal)
                }
            }
        }
    }
    
    func setCardsImage() {
        let defaults = UserDefaults.standard
        let version = defaults.string(forKey: "version")
        let allCards = [card1, card2, card3, card4, card5]
        
        if version == "ukChips" {
            if let cardImage = UIImage(named: "chipCardUK") {
                for card in allCards {
                    card?.image = cardImage
                }
            }
        } else if version == "usChips" {
            if let cardImage = UIImage(named: "chipCardUS") {
                for card in allCards {
                    card?.image = cardImage
                }
            }
        } else {
            if let cardImage = UIImage(named: "chipCardUS") {
                for card in allCards {
                    card?.image = cardImage
                }
            }
        }
    }
    
    func playSound(for fileString: String) {
        if soundOn == true {
            let path = Bundle.main.path(forResource: fileString, ofType: nil)
            if let path = path {
                let url = URL(fileURLWithPath: path)
                
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer.play()
                    audioPlayer.volume = 0.09
                } catch {
                    print("couldn't load the file \(fileString)")
                }
            } else {
                print("\(fileString) path couldn't be found")
            }
        }
    }
    
    func checkForSound() {
        let defaults = UserDefaults.standard
        let sound = defaults.string(forKey: "sound")
        
        if sound == "soundOn" {
            soundOn = true
        } else if sound == "soundOff" {
            soundOn = false
        } else {
            defaults.set("soundOn", forKey: "sound")
            soundOn = true
        }
    }
    
    func setExclusiveTouchForAllButtons() {
        for subview in self.view.subviews {
            if subview is UIButton {
                let button = subview as! UIButton
                button.isExclusiveTouch = true
            }
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

