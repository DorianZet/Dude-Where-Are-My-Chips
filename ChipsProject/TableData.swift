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
    
    static let shared = TableData()
    
    private init() { }
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
    
    func chooseBlinds() {
        // take away the small blind from the player:
        activePlayers[smallBlindPlayerIndex].playerChips -= smallBlind
        potChips += smallBlind
        
        bigBlindPlayerIndex = smallBlindPlayerIndex + 1
        if bigBlindPlayerIndex > activePlayers.count - 1 {
            bigBlindPlayerIndex = 0
        }
    
        activePlayers[bigBlindPlayerIndex].playerChips -= smallBlind * 2
        potChips += smallBlind * 2
        
        print("Small blind for activePlayers index: \(smallBlindPlayerIndex)")
        print("Big blind for active Players index: \(bigBlindPlayerIndex)")
       
        smallBlindPlayerIndex += 1
        
        if smallBlindPlayerIndex > activePlayers.count - 1 {
            smallBlindPlayerIndex = 0
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
        let activePlayersInHandCount = activePlayers.filter { $0.playerActiveInHand }.count
        if activePlayersInHandCount == 1 {
            let players = activePlayers.filter { $0.playerActiveInHand }
            winnerPlayer = players[0] // we have the winner with all info about him (name, chips, etc.)
            allPlayersFolded = true
        }
    }

}
