//
//  ChooseWinnerController.swift
//  ChipsProject
//
//  Created by Mateusz Zacharski on 10/08/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import UIKit
import AVFoundation
import StoreKit
import GoogleMobileAds

class ChooseWinnerController: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var previousPlayerButton: UIButton!
    @IBOutlet var nextPlayerButton: UIButton!
    @IBOutlet var playerNameLabel: UILabel!
    
    @IBOutlet var summaryView: UIStackView!
    @IBOutlet var newHandButton: RoundedButton!
    @IBOutlet var summaryLabel: UILabel!
    @IBOutlet var guacamoleImage: UIImageView!
    
    @IBOutlet var potChipsLabel: CountingPotLabel!
    @IBOutlet var playerChipsLabel: CountingPlayerChipsLabel!
    @IBOutlet var choosePlayerView: UIView!
    
    @IBOutlet var OKButton: RoundedButton!
    
    @IBOutlet var drawButton: UIButton!
    
    var tableData = TableData()
    
    var winnerPlayer = PlayerData(playerName: String(), playerChips: Int(), playerBet: Int(), playerBetInThisState: Int())
    
    var playerIndex = 0
    
    var playersAccountableForWin = [PlayerData]()
    
    var countAnimationDuration: Double = 3
    
    var losersArray = [PlayerData]()
    
    var isGameOver = false
    
    var audioPlayer = AVAudioPlayer()
    
    var soundOn = true
    
    var numberOfGamesPlayed = 0
    
    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910") // test ad ID
        interstitial.delegate = self
        let request = GADRequest()
        interstitial.load(request)
        
        checkNumberOfGamesPlayed()
        
        setExclusiveTouchForAllButtons()
        
        checkForSound()
        
        audioPlayer.loadSounds(forSoundNames: ["bigButton.aiff", "smallButton.aiff", "gameOver.mp3", "summary.mp3"])
        
        view.backgroundColor = .darkGray
        choosePlayerView.backgroundColor = .darkGray
        summaryView.backgroundColor = .darkGray
        summaryView.alpha = 0
        guacamoleImage.isHidden = true
        
        makeAllPlayersWhoWentAllInAndAreUnderMinBetWentAllInForSidePot()

        changeFontToPixel()
        
        setUpPlayersAccountableForWin()
        
        setUpLabelsAndButtons()
        
        chooseTemporaryWinnerPlayer()

        for eachPlayer in tableData.activePlayers {
            print("\(eachPlayer.playerName) BET: \(eachPlayer.playerBet)")
            print("\(eachPlayer.playerName) BET IN THIS STATE: \(eachPlayer.playerBetInThisState)")
            print("\(eachPlayer.playerName) CHIPS: \(eachPlayer.playerChips)")
        }
        print("POT: \(tableData.potChips)")
        
    }
    
    @IBAction func tapPreviousPlayerButton(_ sender: Any) {
        playSound(for: "smallButton.aiff")
        
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
        playSound(for: "smallButton.aiff")
        
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
        playSound(for: "bigButton.aiff")

        confirmWinnerPlayer()

        disableAndHideDrawButton()
    }
    
    func disableAndHideDrawButton() {
        drawButton.isEnabled = false
        UIView.animate(withDuration: 0.4, animations:  {
            self.drawButton.alpha = 0
        }, completion: { _ in
            self.drawButton.isHidden = true
        })
    }
    
    func exitToMainMenu(action: UIAlertAction) {
        performSegue(withIdentifier: "UnwindToTitleSegue", sender: action)
    }
    
    @IBAction func tapNewHandButton(_ sender: UIButton) {
        playSound(for: "bigButton.aiff")
        
        if sender.titleLabel?.text == "NEW HAND" {
            if interstitial.isReady && tableData.numberOfHandsPlayed == 1 {
                interstitial.present(fromRootViewController: self)
            } else {
                performSegue(withIdentifier: "UnwindToPokerTableSegue", sender: sender)
                print("Ad wasn't ready or the number of hands played wasn't 1")
            }
        } else { // when the button's label is "MAIN MENU":
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.performSegue(withIdentifier: "UnwindToTitleSegue", sender: sender)
            }
        }
    }
    @IBAction func tapDrawButton(_ sender: Any) {
        playSound(for: "bigButton.aiff")
    }
    
    func setUpPlayersAccountableForWin() {
        playersAccountableForWin = tableData.activePlayers.filter { ($0.playerActiveInHand || $0.playerWentAllIn) && !$0.playerFolded }
    }
    
    func setUpLabelsAndButtons() {
        
        playerNameLabel.text = playersAccountableForWin[0].playerName
        playerNameLabel.layer.borderColor = UIColor.black.cgColor
        playerNameLabel.clipsToBounds = true
        playerNameLabel.backgroundColor = .systemYellow
        
        potChipsLabel.text = "POT: \(tableData.potChips)"
        potChipsLabel.backgroundColor = .clear
        potChipsLabel.clipsToBounds = true
        
        previousPlayerButton.layer.borderColor = UIColor.clear.cgColor
        previousPlayerButton.layer.borderWidth = 0
        previousPlayerButton.backgroundColor = .clear
        nextPlayerButton.layer.borderColor = UIColor.clear.cgColor
        nextPlayerButton.layer.borderWidth = 0
        nextPlayerButton.backgroundColor = .clear
        OKButton.setTitle("OK", for: .normal)
        
        drawButton.setTitle("WE HAVE A DRAW HERE!", for: .normal)
        
        if tableData.allPlayersFolded == true {
            titleLabel.text = "PLAYERS FOLDED, THE WINNER IS..."
            
            playerNameLabel.text = playersAccountableForWin[0].playerName
            playerNameLabel.textColor = .systemYellow
            playerNameLabel.layer.borderColor = UIColor.clear.cgColor
            playerNameLabel.clipsToBounds = true
            playerNameLabel.backgroundColor = .clear
            
            previousPlayerButton.isHidden = true
            nextPlayerButton.isHidden = true
            drawButton.isHidden = true
        } else if tableData.onePlayerLeftWithRestWentAllIn == true {
            titleLabel.text = "ALL PLAYERS BUT ONE WENT ALL IN, CHOOSE THE WINNER"
        }
    }
    
    func chooseTemporaryWinnerPlayer() {
        let filteredWinners = tableData.activePlayers.filter { $0.playerName == playerNameLabel.text }
        print(playerNameLabel.text ?? "couldn't print playerNameLabel text")
        winnerPlayer = filteredWinners[0]
        playerChipsLabel.text = "\(winnerPlayer.playerName)'S CHIPS: \(winnerPlayer.playerChips)"
    }
    
    func confirmWinnerPlayer() {
        playSound(for: "countLabel.aiff")
        
        if winnerPlayer.playerWentAllInForSidePot == true {
            let playersActiveInHand = tableData.activePlayers.filter { $0.playerActiveInHand == true }
            let playersWhoWentAllIn = tableData.activePlayers.filter { $0.playerWentAllIn == true }
            let playersWhoCanWinCount = playersActiveInHand.count + playersWhoWentAllIn.count
            
            tableData.winnerPlayer = winnerPlayer
            let sidePotWin = tableData.winnerPlayer.playerBet * playersWhoCanWinCount
            
            if sidePotWin < tableData.potChips {
                print("Side pot win: \(sidePotWin)")
                print("Winner player bet: \(winnerPlayer.playerBet)")
                
                // first animation case
                potChipsLabel.tableData = tableData
                playerChipsLabel.tableData = tableData
                
                potChipsLabel.count(fromValue: Float(tableData.potChips), to: Float(tableData.potChips - sidePotWin), withDuration: countAnimationDuration, andAnimationType: .Linear, andCounterType: .Int)
                playerChipsLabel.count(fromValue: Float(tableData.winnerPlayer.playerChips), to: Float(tableData.winnerPlayer.playerChips + sidePotWin), withDuration: countAnimationDuration, andAnimationType: .Linear, andCounterType: .Int)
                tableData.winnerPlayer.playerChips += sidePotWin
                tableData.potChips -= sidePotWin
                
                self.view.isUserInteractionEnabled = false
                chooseNewAccountablePlayerForSidePotWinWithAnimatedLabel(withDelay: 1.3)
                
                hideCenterButtonsAndLabels()

            } else {
                // second animation case
                potChipsLabel.tableData = tableData
                playerChipsLabel.tableData = tableData
                
                playerChipsLabel.count(fromValue: Float(tableData.winnerPlayer.playerChips), to: Float(tableData.winnerPlayer.playerChips + tableData.potChips), withDuration: countAnimationDuration, andAnimationType: .Linear, andCounterType: .Int)
                potChipsLabel.count(fromValue: Float(tableData.potChips), to: 0, withDuration: countAnimationDuration, andAnimationType: .Linear, andCounterType: .Int)
    
                tableData.winnerPlayer.playerChips += tableData.potChips
                tableData.potChips -= tableData.potChips
                
                removeLosersAndAdjustSummaryLabelToShowThem()
                
                hideCenterButtonsAndLabelAndShowSummaryView()
            }
            
        } else {
            tableData.winnerPlayer = winnerPlayer
            
            potChipsLabel.tableData = tableData
            playerChipsLabel.tableData = tableData
            
            playerChipsLabel.count(fromValue: Float(tableData.winnerPlayer.playerChips), to: Float(tableData.winnerPlayer.playerChips + tableData.potChips), withDuration: countAnimationDuration, andAnimationType: .Linear, andCounterType: .Int)

            potChipsLabel.count(fromValue: Float(tableData.potChips), to: 0, withDuration: countAnimationDuration, andAnimationType: .Linear, andCounterType: .Int)
            tableData.winnerPlayer.playerChips += tableData.potChips
            tableData.potChips -= tableData.potChips
            
            removeLosersAndAdjustSummaryLabelToShowThem()
            
            hideCenterButtonsAndLabelAndShowSummaryView()
        }
    }
    
    func removeLosersAndAdjustSummaryLabelToShowThem() {
        removeLosersAndAddThemToLosersArray()
        summaryLabel.numberOfLines = tableData.activePlayers.count + 3
        if losersArray.count > 0 {
            summaryLabel.numberOfLines += 1 + losersArray.count
        }
    }
    
    func chooseNewAccountablePlayerForSidePotWinWithAnimatedLabel(withDelay delayAfterCounting: Double) {
        playerIndex = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + countAnimationDuration + delayAfterCounting) {
            let winnerPlayerIndex = self.playersAccountableForWin.firstIndex(of: self.winnerPlayer)
            if let winnerPlayerIndex = winnerPlayerIndex {
                self.playersAccountableForWin.remove(at: winnerPlayerIndex)
                
                let sidePotInfo = "Side pot has been created, choose the player with the next best cards"
                self.titleLabel.text = sidePotInfo.uppercased()
                
                UIView.animate(withDuration: 0.4, animations: {
                    self.titleLabel.alpha = 0
                    self.playerNameLabel.alpha = 0
                    self.OKButton.alpha = 0
                    self.previousPlayerButton.alpha = 0
                    self.nextPlayerButton.alpha = 0
                    self.playerChipsLabel.alpha = 0
                }, completion: { _ in
                    self.titleLabel.isHidden = false
                    self.playerNameLabel.isHidden = false
                    self.OKButton.isHidden = false
                    self.nextPlayerButton.isHidden = false
                    self.previousPlayerButton.isHidden = false
                    
                    self.playerNameLabel.text = self.playersAccountableForWin[0].playerName
                    self.chooseTemporaryWinnerPlayer()
                    
                    UIView.animate(withDuration: 0.4, animations: {
                        self.titleLabel.alpha = 1
                        self.playerNameLabel.alpha = 1
                        self.OKButton.alpha = 1
                        self.previousPlayerButton.alpha = 1
                        self.nextPlayerButton.alpha = 1
                        self.playerChipsLabel.alpha = 1
                    }, completion: { _ in
                        self.view.isUserInteractionEnabled = true
                    })
                })
            }
        }
    }
    
    func removeLosersAndAddThemToLosersArray() {
        let losers = tableData.activePlayers.filter { $0.playerChips == 0 }

        for eachPlayer in losers {
            if let index = tableData.activePlayers.firstIndex(of: eachPlayer) {
                losersArray.append(eachPlayer)
                tableData.activePlayers.remove(at: index)
            }
            for each in losersArray {
                print("LOSER: \(each.playerName)")
            }
        }
    }
    
    func changeSmallBlindPlayer() {
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
    
    func hideCenterButtonsAndLabelAndShowSummaryView() {
        if tableData.activePlayers.count > 1 {
            configureSummaryViewForSummary()
        } else {
            configureSummaryViewForGameOver()
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            self.titleLabel.alpha = 0
            self.playerNameLabel.alpha = 0
            self.OKButton.alpha = 0
            self.nextPlayerButton.alpha = 0
            self.previousPlayerButton.alpha = 0
        }, completion: { _ in
            self.titleLabel.isHidden = true
            self.playerNameLabel.isHidden = true
            self.OKButton.isHidden = true
            self.nextPlayerButton.isHidden = true
            self.previousPlayerButton.isHidden = true
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + countAnimationDuration + 1.3) { // we add 1.3sec to show the updated playerChipsLabel for a while before it disappears.
            UIView.animate(withDuration: 0.4, animations:  {
                self.playerChipsLabel.alpha = 0
                self.potChipsLabel.alpha = 0
            }, completion: { _ in
                UIView.animate(withDuration: 0.4, animations: {
                    self.summaryView.isHidden = false
                    self.summaryView.alpha = 1
                }, completion: { _ in
                    if self.isGameOver == false {
                        self.playSound(for: "summary.mp3")
                    } else {
                        self.playSound(for: "gameOver.mp3")
                        self.numberOfGamesPlayed += 1
                        
                        self.saveNumberOfGamesPlayed()
                        
                        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1.5) {
                            DispatchQueue.main.async {
                                self.showReviewRequest()
                            }
                        }
                    }
                })
            })
        }
    }
    
    func configureSummaryViewForSummary() {
        summaryLabel.text = "SUMMARY\n\n"
        for eachPlayer in tableData.activePlayers {
            summaryLabel.text! += "\(eachPlayer.playerName)'s CHIPS: \(eachPlayer.playerChips)\n"
        }
        summaryLabel.text! += "\n"

        let finalSummaryText = summaryLabel.text!.dropLast(2) // deleting the last \n from the summaryLabel.text.
        summaryLabel.text! = String(finalSummaryText)
        
        if losersArray.count > 0 {
            summaryLabel.text! += "\n\n"

            for eachLoser in losersArray {
                summaryLabel.text! += "\(eachLoser.playerName) IS OUT!\n"
            }
            
            let finalSummaryTextWithLosers = summaryLabel.text!.dropLast(1) // deleting the last \n from the summaryLabel.text.
            summaryLabel.text! = String(finalSummaryTextWithLosers)
        }
    }
    
    func configureSummaryViewForGameOver() {
        summaryLabel.numberOfLines = 1
        if UIDevice.current.userInterfaceIdiom == .phone {
            summaryLabel.font = UIFont(name: "Pixel Emulator", size: 22)
        } else {
            summaryLabel.font = UIFont(name: "Pixel Emulator", size: 33)
        }
        summaryLabel.text = "HOLY GUACAMOLE! "
        summaryLabel.text! += "\(tableData.activePlayers[0].playerName) WINS!"
        
        guacamoleImage.isHidden = false
        
        newHandButton.setTitle("MAIN MENU", for: .normal)
        
        isGameOver = true
    }
    
    func hideCenterButtonsAndLabels() {
        UIView.animate(withDuration: 0.4, animations: {
            self.titleLabel.alpha = 0
            self.playerNameLabel.alpha = 0
            self.OKButton.alpha = 0
            self.nextPlayerButton.alpha = 0
            self.previousPlayerButton.alpha = 0
            
        }, completion: { _ in
            self.titleLabel.isHidden = true
            self.playerNameLabel.isHidden = true
            self.OKButton.isHidden = true
            self.nextPlayerButton.isHidden = true
            self.previousPlayerButton.isHidden = true
        })
    }
        
//        UIView.animate(withDuration: 0.4) {
//            self.playerNameLabel.alpha = 0
//            self.playerNameLabel.isHidden = true
//            self.OKButton.alpha = 0
//            self.OKButton.isHidden = true
//            self.nextPlayerButton.alpha = 0
//            self.nextPlayerButton.isHidden = true
//            self.previousPlayerButton.alpha = 0
//            self.previousPlayerButton.isHidden = true
//
////            self.newHandButton.alpha = 1
////            self.newHandButton.isHidden = false
////            self.summaryLabel.alpha = 1
////            self.summaryLabel.isHidden = false
//
//            self.summaryView.alpha = 1
//            self.summaryView.isHidden = false
//        }
    
    func makeAllPlayersWhoWentAllInAndAreUnderMinBetWentAllInForSidePot() {
        for eachPlayer in tableData.activePlayers {
            if eachPlayer.playerWentAllIn == true && eachPlayer.playerBet < tableData.minimumBet {
                eachPlayer.playerWentAllInForSidePot = true
            }
        }
    }

    
    func changeFontToPixel() {
        let biggerLabels = [potChipsLabel, playerChipsLabel, playerNameLabel]
        let buttons = [previousPlayerButton, nextPlayerButton, OKButton, newHandButton, drawButton]
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            for eachLabel in biggerLabels {
                eachLabel?.font = UIFont(name: "Pixel Emulator", size: 25)
            }
            
            for eachButton in buttons {
                eachButton?.titleLabel?.font = UIFont(name: "Pixel Emulator", size: 17)
            }
            titleLabel.font = UIFont(name: "Pixel Emulator", size: 22)
            summaryLabel.font = UIFont(name: "Pixel Emulator", size: 18)
        } else {
            for eachLabel in biggerLabels {
                eachLabel?.font = UIFont(name: "Pixel Emulator", size: 37)
            }
            
            for eachButton in buttons {
                eachButton?.titleLabel?.font = UIFont(name: "Pixel Emulator", size: 25)
            }
            titleLabel.font = UIFont(name: "Pixel Emulator", size: 33)
            summaryLabel.font = UIFont(name: "Pixel Emulator", size: 27)
        }
        
        
        
        
        
        potChipsLabel.textColor = .systemYellow
        playerChipsLabel.textColor = .systemYellow
        titleLabel.textColor = .systemYellow
        summaryLabel.textColor = .systemYellow
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
                print("path couldnt be found")
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
    
    func checkNumberOfGamesPlayed() {
        let defaults = UserDefaults.standard
        
        let numberOfGamesSaved = defaults.integer(forKey: "numberOfGamesPlayed")
        
        numberOfGamesPlayed = numberOfGamesSaved
    }
    
    func saveNumberOfGamesPlayed() {
        let defaults = UserDefaults.standard
        defaults.set(self.numberOfGamesPlayed, forKey: "numberOfGamesPlayed")
    }
    
    func showReviewRequest() {
        if numberOfGamesPlayed == 1 || numberOfGamesPlayed == 4 || numberOfGamesPlayed == 8 {
            SKStoreReviewController.requestReview()
        }
        
        // resetting the counter:
        if numberOfGamesPlayed == 8 {
            numberOfGamesPlayed = 0
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UnwindToPokerTableSegue" {
            changeSmallBlindPlayer()
            
            tableData.winningScreenAlreadyShown = false
            tableData.newHandNeeded = true
            
            let destVC = segue.destination as! PokerTableViewController
            destVC.tableData = tableData
            destVC.newHand()
            destVC.hideAllLabelsAndButtons()
            destVC.hideSliderAndButtons()
            print("fired newHand() from prepareForSegue")
        } else if segue.identifier == "UnwindToTitleSegue" {
//            TableData.resetTableData()
//            print("TableData reset.")
        } else if segue.identifier == "ShowDrawViewControllerSegue" {
            let destVC = segue.destination as! DrawViewController
            destVC.tableData = tableData
        }
    }

    @IBAction func unwindToChooseWinner(_ sender: UIStoryboardSegue) {}
}


extension ChooseWinnerController: GADInterstitialDelegate {
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        performSegue(withIdentifier: "UnwindToPokerTableSegue", sender: self)
        print("Ad dismissed, unwinding to PokerTableVC...")
    }
}


