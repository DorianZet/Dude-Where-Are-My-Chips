//
//  PlayerData.swift
//  ChipsProject
//
//  Created by Mateusz Zacharski on 03/08/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import UIKit

class PlayerData: NSObject {
    var playerName: String
    var playerChips: Int
    var playerBet = 0
    var playerBetInThisState = 0
    var playerActiveInHand = true
    var playerWentAllIn = false
    var playerWentAllInForSidePot = false
    var playerChecked = false
    var playerFolded = false
    var playerMadeAMove = false
    var isPlayerSmallBlind = false
    var isPlayerBigBlind = false
    var playerTappedRaise = false
    
    init (playerName: String, playerChips: Int, playerBet: Int, playerBetInThisState: Int) {
        self.playerName = playerName
        self.playerChips = playerChips
        self.playerBet = playerBet
        self.playerBetInThisState = playerBetInThisState
    }
    
}
