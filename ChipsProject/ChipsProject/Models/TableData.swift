//
//  TableData.swift
//  ChipsProject
//
//  Created by Mateusz Zacharski on 03/08/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import UIKit

enum GameState {
    case preFlop
    case theFlop
    case theTurn
    case TheRiver
    case finishHand
}

class TableData {
    var playerNames = ["PLAYER 1", "PLAYER 2", "PLAYER 3", "PLAYER 4", "PLAYER 5", "PLAYER 6", "PLAYER 7", "PLAYER 8", "PLAYER 9"]
    var numberOfPlayers = Int()
    var activePlayers = [PlayerData]()
    var startingChips = Int()
    var smallBlind = Int()
    var currentPlayer = PlayerData(playerName: String(), playerChips: Int(), playerBet: Int(), playerBetInThisState: Int())
    var currentPlayerIndex = 0
    var potChips = 0
    var smallBlindPlayerIndex = 0
    var bigBlindPlayerIndex = 0
    var currentBet = Int()
    var allPlayersFolded = Bool()
    var winnerPlayer = PlayerData(playerName: String(), playerChips: Int(), playerBet: Int(), playerBetInThisState: Int())
    var gameState = GameState.preFlop
    var minimumBet = Int()
    var nextStateNeeded = false
    var isNewHand = false
    var sliderChips = Int()
    var newHandNeeded = false
    var winningScreenAlreadyShown = false
    var onePlayerLeftWithRestWentAllIn = false
    var isNewGame = true
    var numberOfHandsPlayed = 0
    
    func chooseBlindPlayers() {
        activePlayers.forEach { $0.isPlayerSmallBlind = false }
        activePlayers.forEach { $0.isPlayerBigBlind = false }
        
        if isNewGame == true {
            smallBlindPlayerIndex = Int.random(in: 0...activePlayers.count - 1)
            isNewGame = false
        }
        activePlayers[smallBlindPlayerIndex].isPlayerSmallBlind = true
        
        bigBlindPlayerIndex = smallBlindPlayerIndex + 1
        if bigBlindPlayerIndex > activePlayers.count - 1 {
            bigBlindPlayerIndex = 0
        }
        
        activePlayers[bigBlindPlayerIndex].isPlayerBigBlind = true

        
        print("Small blind for activePlayers index: \(smallBlindPlayerIndex)")
        print("Big blind for active Players index: \(bigBlindPlayerIndex)")
    }
    
    func configureBlindsBeforeNewHand() {
        // See if the small blind player can afford a small blind:
        let smallBlindPlayer = activePlayers[smallBlindPlayerIndex]
        if smallBlindPlayer.playerChips > smallBlind {
            smallBlindPlayer.playerBetInThisState = smallBlind
            smallBlindPlayer.playerBet += smallBlind
            smallBlindPlayer.playerChips -= smallBlind
            potChips += smallBlind
        } else {
            print("Small blind player couldn't afford the small blind or didn't have more than small blind, entered with \(smallBlindPlayer.playerChips) small blind")
            smallBlindPlayer.playerBetInThisState = smallBlindPlayer.playerChips
            smallBlindPlayer.playerBet += smallBlindPlayer.playerChips
            potChips += smallBlindPlayer.playerChips
            smallBlindPlayer.playerChips -= smallBlindPlayer.playerChips
            
            smallBlindPlayer.playerWentAllIn = true
            smallBlindPlayer.playerActiveInHand = false
        }
        
        // See if the big blind player can afford a big blind:
        let bigBlindPlayer = activePlayers[bigBlindPlayerIndex]
        if bigBlindPlayer.playerChips > smallBlind * 2 {
            activePlayers[bigBlindPlayerIndex].playerBetInThisState = smallBlind * 2
            activePlayers[bigBlindPlayerIndex].playerBet += smallBlind * 2
            activePlayers[bigBlindPlayerIndex].playerChips -= smallBlind * 2
            potChips += smallBlind * 2
        } else {
            print("Big blind player couldn't afford the big blind or didn't have more than big blind, entered with \(bigBlindPlayer.playerChips) big blind")
            bigBlindPlayer.playerBetInThisState = bigBlindPlayer.playerChips
            bigBlindPlayer.playerBet += bigBlindPlayer.playerChips
            potChips += bigBlindPlayer.playerChips
            bigBlindPlayer.playerChips -= bigBlindPlayer.playerChips
            
            bigBlindPlayer.playerWentAllIn = true
            bigBlindPlayer.playerActiveInHand = false
        }
        
    }
    
    func createPlayers() {
        var nameIndex = 0
        for _ in 0 ..< numberOfPlayers {
            let player = PlayerData(playerName: playerNames[nameIndex], playerChips: startingChips, playerBet: 0, playerBetInThisState: Int())
            activePlayers.append(player)
            nameIndex += 1
        }
        
        print("Created \(activePlayers.count) players with names:")
        for each in activePlayers {
            print(each.playerName)
        }
        print("Starting chips: \(startingChips)")
        print("Small blind: \(smallBlind)")
    }
    
    func checkForFoldedPlayers() {
        let playersFoldedCount = activePlayers.filter { $0.playerFolded }.count
        if playersFoldedCount == activePlayers.count - 1 {
            let playersNotFolded = activePlayers.filter { $0.playerActiveInHand || $0.playerWentAllIn }
            winnerPlayer = playersNotFolded[0]  // we have the winner with all info about him (name, chips, etc.)
            allPlayersFolded = true
        }
    }
    
    func currentGameState() -> String {
        if gameState == .preFlop {
            return "PRE-FLOP (NO CARDS ON THE TABLE)\n\n"
        } else if gameState == .theFlop {
            return "THE FLOP (3 CARDS ON THE TABLE)\n\n"
        } else if gameState == .theTurn {
            return "THE TURN (4 CARDS ON THE TABLE)\n\n"
        } else if gameState == .TheRiver {
            return "THE RIVER (5 CARDS ON THE TABLE)\n\n"
        } else {
            return "?\n\n"
        }
    }
    
    func currentBetIsBelowOrEqualToMinimumBetOrRaiseBet(currentBet: Int) -> Bool {
        if currentPlayer.playerTappedRaise == true {
            if currentBet <= minimumBet * 2 {
                return true
            } else {
                return false
            }
        } else {
            if currentBet <= minimumBet {
                return true
            } else {
                return false
            }
        }
    }
    
    func goToNextState() {
        if gameState == GameState.preFlop {
            gameState = GameState.theFlop
            nextStateNeeded = true
            print("All bets are the same, next state needed")
        } else if gameState == GameState.theFlop {
            gameState = GameState.theTurn
            nextStateNeeded = true
            print("All bets are the same, next state needed")
        } else if gameState == GameState.theTurn {
            gameState = GameState.TheRiver
            nextStateNeeded = true
            print("All bets are the same, next state needed")
        } else if gameState == GameState.TheRiver {
            gameState = GameState.finishHand
            nextStateNeeded = true
            print("All bets are the same, next state needed")
        }
    }
    
    func decideWhoStartsWhenNewHand() {
        let playingPlayers = activePlayers.filter { $0.playerActiveInHand }
        let noOneHasMovedYet = playingPlayers.allSatisfy { ($0.playerMadeAMove == false) }
        
        if gameState == .preFlop && playingPlayers.count == 2 && noOneHasMovedYet {
            currentPlayer = activePlayers[smallBlindPlayerIndex]
            currentPlayerIndex = smallBlindPlayerIndex
        } else {
            var afterBigBlindPlayerIndex = bigBlindPlayerIndex + 1
            if afterBigBlindPlayerIndex > activePlayers.count - 1 {
                afterBigBlindPlayerIndex = 0
            }
            currentPlayer = activePlayers[afterBigBlindPlayerIndex]
            currentPlayerIndex = afterBigBlindPlayerIndex
        }
    }
    
    func resetPlayerPropertiesForNewHand() {
        activePlayers.forEach {$0.playerBet = 0}
        activePlayers.forEach { $0.playerBetInThisState = 0 }
        activePlayers.forEach { $0.playerChipsToWinInDraw = 0 }

        activePlayers.forEach { $0.playerActiveInHand = true }
        activePlayers.forEach { $0.playerMadeAMove = false }
        activePlayers.forEach { $0.playerChecked = false }
        activePlayers.forEach { $0.playerWentAllIn = false }
        activePlayers.forEach { $0.playerWentAllInForSidePot = false }
        activePlayers.forEach { $0.playerFolded = false }
        activePlayers.forEach { $0.playerTappedRaise = false }
    }
    
    func resetTablePropertiesForNewHand() {
        potChips = 0
        currentBet = 0
        allPlayersFolded = false
        nextStateNeeded = false
        winnerPlayer = PlayerData(playerName: String(), playerChips: Int(), playerBet: Int(), playerBetInThisState: Int())
        gameState = .preFlop
        minimumBet = smallBlind * 2
        onePlayerLeftWithRestWentAllIn = false
    }
    
    func allBetsAreZero() -> Bool {
        let playingPlayers = activePlayers
        
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
    
    func changeSmallBlindPlayer() {
        nextSmallBlindPlayerIndex()
            
        if activePlayers[smallBlindPlayerIndex].isPlayerSmallBlind == true {
            activePlayers[smallBlindPlayerIndex].isPlayerSmallBlind = false
            nextSmallBlindPlayerIndex()
        }
    }
        
    func nextSmallBlindPlayerIndex() {
        smallBlindPlayerIndex += 1
                   
        if smallBlindPlayerIndex > activePlayers.count - 1 {
            smallBlindPlayerIndex = 0
        }
    }

}
