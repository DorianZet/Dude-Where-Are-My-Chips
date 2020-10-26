//
//  CountingLabel.swift
//  ChipsProject
//
//  Created by Mateusz Zacharski on 26/08/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import UIKit

class CountingPlayerChipsLabel: UILabel {
    var tableData = TableData()
    let counterVelocity: Float = 3.0
    
    enum CounterAnimationType {
        case Linear // f(x) = x
        case EaseIn // f(x) = x^3
        case EaseOut // f(x) = (1-x)^3
    }
    
    enum CounterType {
        case Int
        case Float
    }
    
    var startNumber: Float = 0.0
    var endNumber: Float = 0.0
    
    var progress: TimeInterval!
    var duration: TimeInterval!
    var lastUpdate: TimeInterval!
    
    var timer: Timer?
    
    var counterType: CounterType!
    var counterAnimationType: CounterAnimationType!
    
    var currentCounterValue: Float {
        if progress >= duration {
            return endNumber
        }
        
        let percentage = Float(progress / duration)
        let update = updateCounter(counterValue: percentage)
        
        return startNumber + (update * (endNumber - startNumber))
    }
    
    func count(fromValue: Float, to toValue: Float, withDuration duration: TimeInterval, andAnimationType animationType: CounterAnimationType, andCounterType counterType: CounterType) {
        
        self.startNumber = fromValue
        self.endNumber = toValue
        self.duration = duration
        self.counterType = counterType
        self.counterAnimationType = animationType
        self.progress = 0
        self.lastUpdate = Date.timeIntervalSinceReferenceDate
        
        invalidateTimer()
        
        
        
        if duration == 0 {
            updateText(value: toValue)
            return
        }
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(CountingPlayerChipsLabel.updateValue), userInfo: nil, repeats: true)
    }
    
    @objc func updateValue() {
        DispatchQueue.global().async {
            let now = Date.timeIntervalSinceReferenceDate
            self.progress = self.progress + (now - self.lastUpdate)
            self.lastUpdate = now
            
            if self.progress >= self.duration {
                self.invalidateTimer()
                self.progress = self.duration
            }
            
            DispatchQueue.main.async {
                self.updateText(value: self.currentCounterValue)
            }
        }
        
        
        
        
    }
    
    
    func updateText(value: Float) {
        
        switch counterType! {
        case .Int:
            self.text = "\(tableData.winnerPlayer.playerName)'S CHIPS: \(Int(value))"
        case .Float:
            self.text = String(format: "%.2f", value)
        }
    }
    
    
    func updateCounter(counterValue: Float) -> Float {
        switch counterAnimationType! {
        case .Linear:
            return counterValue
        case .EaseIn:
            return powf(counterValue, counterVelocity)
        case .EaseOut:
            return 1.0 - powf(1.0 - counterValue, counterVelocity)
        }
    }
    
    
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }

}
