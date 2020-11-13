//
//  DrawViewController.swift
//  ChipsProject
//
//  Created by Mateusz Zacharski on 14/09/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import AVFoundation
import UIKit
import GoogleMobileAds

class DrawViewController: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var potChipsLabel: CountingPotLabel!
    
    @IBOutlet var choosePlayerView: UIView!
    @IBOutlet var previousPlayerButton: UIButton!
    @IBOutlet var nextPlayerButton: UIButton!
    @IBOutlet var playerNameLabel: RoundedLabel!
    @IBOutlet var addNextPlayerButton: RoundedButton!
    @IBOutlet var doneButton: RoundedButton!

    @IBOutlet var summaryView: UIView!
    @IBOutlet var summaryLabel: UILabel!
    @IBOutlet var newHandButton: UIButton!
    
    @IBOutlet var playersChipsLabel: CountingPlayerChipsLabel!
    
    @IBOutlet var cancelButton: RoundedButton!
    
    var tableData = TableData()
    
    var playersAccountableForDraw = [PlayerData]()
    
    var drawWinners = [PlayerData]()
    
    var drawWinner = PlayerData(playerName: String(), playerChips: Int(), playerBet: Int(), playerBetInThisState: Int())
    
    var numberOfDrawWinners = 0
    
    var titleText = ""
    
    var playersAccountableForDrawCountAtBeginning = 0
    
    var playerIndex = 0
    
    var potChips = 0
        
    var normalWinnersCount = 0
    
    var allInWinnersCount = 0
    
    var losersArray = [PlayerData]()
    
    var playersAccountableForDrawWhoAreNotAllInCount = 0
    
    var audioPlayer = AVAudioPlayer()
    
    var soundOn = true
    
    var interstitial: GADInterstitial!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadAd()
        
        setExclusiveTouchForAllButtons()
        
        checkForSound()
        
        audioPlayer.loadSounds(forSoundNames: ["bigButton.aiff", "smallButton.aiff", "summary.mp3"])
        
        view.backgroundColor = .darkGray
        choosePlayerView.backgroundColor = .darkGray
        summaryView.backgroundColor = .darkGray

        changeFontToPixel()
        
        setUpPlayersAccountableForDraw()
        
        setUpLabelsAndButtons()
                
        chooseTemporaryDrawWinner()

        doneButton.isHidden = true
        doneButton.alpha = 0
        summaryView.alpha = 0
        
        addNextPlayerButton.contentHorizontalAlignment = .center
        addNextPlayerButton.titleLabel?.textAlignment = .center
    
        potChips = tableData.potChips
        
    }
    
    @IBAction func tapPreviousPlayerButton(_ sender: Any) {
        playSound(for: "smallButton.aiff")
        
        let playersCount = playersAccountableForDraw.count
        
        playerIndex -= 1
        if playerIndex < 0 {
            playerIndex = playersCount - 1
        }
        playerNameLabel.text = playersAccountableForDraw[playerIndex].playerName
        chooseTemporaryDrawWinner()
        print(drawWinner.playerName)
    }
    @IBAction func tapNextPlayerButton(_ sender: Any) {
        playSound(for: "smallButton.aiff")

        let playersCount = playersAccountableForDraw.count

        playerIndex += 1
        if playerIndex > playersCount - 1 {
            playerIndex = 0
        }
        playerNameLabel.text = playersAccountableForDraw[playerIndex].playerName
        chooseTemporaryDrawWinner()
        print(drawWinner.playerName)
    }
    @IBAction func tapAddNextPlayerButton(_ sender: Any) {
        playSound(for: "bigButton.aiff")

        numberOfDrawWinners += 1
        drawWinners.append(drawWinner)
        
        if numberOfDrawWinners == playersAccountableForDrawCountAtBeginning {
            distributeTheChips()
        } else {
            chooseNewAccountableDrawWinnerWithAnimations()
        }
    }
    @IBAction func tapDoneButton(_ sender: Any) {
        playSound(for: "bigButton.aiff")
        
        distributeTheChips()
    }
        
    @IBAction func tapNewHandButton(_ sender: Any) {
        playSound(for: "bigButton.aiff")
        
        if interstitial.isReady && tableData.numberOfHandsPlayed == 1 {
            interstitial.present(fromRootViewController: self)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.performSegue(withIdentifier: "UnwindToPokerTableSegue", sender: sender)
            }
            print("Ad wasn't ready or the number of hands played wasn't 1")
        }
    }
    
    @IBAction func tapCancelButton(_ sender: Any) {
        playSound(for: "bigButton.aiff")
        
        tableData.activePlayers.forEach { $0.playerChipsToWinInDraw = 0 } // reset all players draw wins on tapping the cancel button.
    }
    
    func distributeTheChips() {
        view.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.4, animations: {
            self.titleLabel.alpha = 0
            self.choosePlayerView.alpha = 0
            self.cancelButton.alpha = 0
        }, completion: { _ in
            self.titleLabel.isHidden = true
            self.choosePlayerView.isHidden = true
            self.cancelButton.isHidden = true
        })
        
        let remainder = potChips % drawWinners.count
        let potChipsWithNoRemainder = potChips - remainder
        print("The remainder is \(remainder).")
        
        for eachPlayer in drawWinners {
            eachPlayer.playerChipsToWinInDraw = potChipsWithNoRemainder / drawWinners.count
            potChips -= eachPlayer.playerChipsToWinInDraw
        }
        
        // now decide to whom goes the remainder (it goes to the first available player after the dealer):
        let smallBlindPlayer = tableData.activePlayers[tableData.smallBlindPlayerIndex]
        
        if drawWinners.contains(smallBlindPlayer) {
            smallBlindPlayer.playerChipsToWinInDraw += remainder
            potChips -= remainder
        } else {
            var nextAvailablePlayerIndex = tableData.smallBlindPlayerIndex + 1
            if nextAvailablePlayerIndex > tableData.activePlayers.count - 1 {
                nextAvailablePlayerIndex = 0
            }
            var nextAvailablePlayer = tableData.activePlayers[nextAvailablePlayerIndex]
            while !drawWinners.contains(nextAvailablePlayer) {
                nextAvailablePlayerIndex += 1
                if nextAvailablePlayerIndex > tableData.activePlayers.count - 1 {
                    nextAvailablePlayerIndex = 0
                }
                nextAvailablePlayer = tableData.activePlayers[nextAvailablePlayerIndex]
            }
            nextAvailablePlayer.playerChipsToWinInDraw += remainder
            print("\(nextAvailablePlayer.playerName) gets the \(remainder) remainder.")
            potChips -= remainder
            print("There are \(potChips) pot chips.")
        }
        
        for eachPlayer in drawWinners {
            eachPlayer.playerChips += eachPlayer.playerChipsToWinInDraw
            print("\(eachPlayer.playerName) chips to win in draw: \(eachPlayer.playerChipsToWinInDraw)")
        }
        
        for eachDrawPlayer in drawWinners {
            for eachPlayer in tableData.activePlayers {
                if eachPlayer.playerName == eachDrawPlayer.playerName {
                    eachPlayer.playerChips = eachDrawPlayer.playerChips
                }
            }
        }

        print("Now there are \(potChips) pot chips.")
        
        // after distributing the chips, we can get rid of the players that have 0 chips:
        removeLosersAndAddThemToLosersArray()
        
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
        
        UIView.animate(withDuration: 0.4, animations:  {
            self.playersChipsLabel.alpha = 0
            self.potChipsLabel.alpha = 0
        }, completion: { _ in
            UIView.animate(withDuration: 0.4, animations: {
                self.summaryView.isHidden = false
                self.summaryView.alpha = 1
                self.view.isUserInteractionEnabled = true
            }, completion: { _ in
                self.playSound(for: "summary.mp3")
            })
        })

    }
    
    func changeTheTitleText() {
        if numberOfDrawWinners == 1 {
            titleText = "ADD THE 2ND DRAW WINNER"
        } else if numberOfDrawWinners == 2 {
            titleText = "ADD THE 3RD DRAW WINNER OR TAP \"DONE\" TO DISTRIBUTE THE CHIPS"
        } else if numberOfDrawWinners == 3 {
            titleText = "ADD THE 4TH DRAW WINNER OR TAP \"DONE\" TO DISTRIBUTE THE CHIPS"
        } else if numberOfDrawWinners == 4 {
            titleText = "ADD THE 5TH DRAW WINNER OR TAP \"DONE\" TO DISTRIBUTE THE CHIPS"
        } else if numberOfDrawWinners == 5 {
            titleText = "ADD THE 6TH DRAW WINNER OR TAP \"DONE\" TO DISTRIBUTE THE CHIPS"
        } else if numberOfDrawWinners == 6 {
            titleText = "ADD THE 7TH DRAW WINNER OR TAP \"DONE\" TO DISTRIBUTE THE CHIPS"
        } else if numberOfDrawWinners == 7 {
            titleText = "ADD THE 8TH DRAW WINNER OR TAP \"DONE\" TO DISTRIBUTE THE CHIPS"
        } else if numberOfDrawWinners == 8 {
            titleText = "ADD THE 9TH DRAW WINNER OR TAP \"DONE\" TO DISTRIBUTE THE CHIPS"
        }
    }
    
    func removeLosersAndAddThemToLosersArray() {
        let losers = tableData.activePlayers.filter { $0.playerChips == 0 && !drawWinners.contains($0) }

        for eachPlayer in losers {
            if let index = tableData.activePlayers.firstIndex(of: eachPlayer) {
                losersArray.append(eachPlayer)
                tableData.activePlayers.remove(at: index)
            }
        }
        for each in losersArray {
            print("LOSER: \(each.playerName)")
        }
        
        summaryLabel.numberOfLines = tableData.activePlayers.count + 3
        if losersArray.count > 0 {
            summaryLabel.numberOfLines += 1 + losersArray.count
        }
    }
    
    func chooseNewAccountableDrawWinnerWithAnimations() {
        playerIndex = 0
        
        let drawWinnerIndex = self.playersAccountableForDraw.firstIndex(of: self.drawWinner)
        if let drawWinnerIndex = drawWinnerIndex {
            self.playersAccountableForDraw.remove(at: drawWinnerIndex)
            
            
            if doneButton.isHidden == true && drawWinners.count == 2 {
                UIView.animate(withDuration: 0.4, animations: {
                    self.addNextPlayerButton.alpha = 0
                }, completion: { _ in
                    self.doneButton.isHidden = false
                    UIView.animate(withDuration: 0.4, animations: {
                        self.addNextPlayerButton.alpha = 1
                        self.doneButton.alpha = 1
                    })
                })
            }

            UIView.animate(withDuration: 0.4, animations: {
                self.titleLabel.alpha = 0
            }, completion: { _ in
                self.changeTheTitleText()
                self.titleLabel.text = self.titleText.uppercased()
                UIView.animate(withDuration: 0.4) {
                    self.titleLabel.alpha = 1
                }
            })
            
            UIView.animate(withDuration: 0.4, animations: {
                self.playerNameLabel.alpha = 0
                self.previousPlayerButton.alpha = 0
                self.nextPlayerButton.alpha = 0
                self.playersChipsLabel.alpha = 0
            }, completion: { _ in
                self.playerNameLabel.text = self.playersAccountableForDraw[0].playerName
                self.chooseTemporaryDrawWinner()
                UIView.animate(withDuration: 0.4, animations: {
                    self.playerNameLabel.alpha = 1
                    self.previousPlayerButton.alpha = 1
                    self.nextPlayerButton.alpha = 1
                    self.playersChipsLabel.alpha = 1
                })
            })
        }
    }
    
    
    func changeFontToPixel() {
        let biggerLabels = [potChipsLabel, playersChipsLabel, playerNameLabel]
        let buttons = [previousPlayerButton, nextPlayerButton, newHandButton, cancelButton, addNextPlayerButton, doneButton]
        
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
        
        titleLabel.textColor = .systemYellow
        summaryLabel.textColor = .systemYellow
        potChipsLabel.textColor = .systemYellow
        playersChipsLabel.textColor = .systemYellow
    }
    
    func setUpLabelsAndButtons() {
        titleLabel.text = "ADD THE 1ST DRAW WINNER"
        
        playerNameLabel.text = playersAccountableForDraw[0].playerName
        playerNameLabel.layer.borderWidth = 4
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
        addNextPlayerButton.setTitle("ADD THIS PLAYER", for: .normal)
        doneButton.setTitle("DONE", for: .normal)
        
        cancelButton.setTitle("CANCEL", for: .normal)
    }
    
    func setUpPlayersAccountableForDraw() {
        playersAccountableForDraw = tableData.activePlayers.filter { ($0.playerActiveInHand || $0.playerWentAllIn || $0.playerWentAllInForSidePot) && !$0.playerFolded }
        playersAccountableForDrawCountAtBeginning = playersAccountableForDraw.count
    }
    
    func chooseTemporaryDrawWinner() {
        let filteredDrawers = tableData.activePlayers.filter { $0.playerName == playerNameLabel.text }
        drawWinner = filteredDrawers[0]
        playersChipsLabel.text = "\(drawWinner.playerName)'S CHIPS: \(drawWinner.playerChips)"
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
    
    func loadAd() {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910") // test ad ID
        interstitial.delegate = self
        let request = GADRequest()
        interstitial.load(request)
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
                print("path couldn't be found")
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
        }
    }

}

extension DrawViewController: GADInterstitialDelegate {
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        performSegue(withIdentifier: "UnwindToPokerTableSegue", sender: self)
        print("Ad dismissed, unwinding to PokerTableVC...")
    }
}
