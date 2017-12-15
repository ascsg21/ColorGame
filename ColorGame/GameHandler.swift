//
//  GameHandler.swift
//  ColorGame
//
//  Created by MinRiDaddy on 2017. 12. 15..
//  Copyright © 2017년 MinRiDaddy. All rights reserved.
//

import Foundation

class GameHandler {
    var score:Int
    var highScore:Int
    
    class var sharedInstance:GameHandler {
        struct Singleton {
            static let instance = GameHandler()
        }
        
        return Singleton.instance
    }
    
    init() {
        score = 0
        highScore = 0
        
        let userDefaults = UserDefaults.standard
        highScore = userDefaults.integer(forKey: "highScore")
    }
    
    func saveGameStats() {
        highScore = max(score, highScore)
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(highScore, forKey: "highScore")
        userDefaults.synchronize()
    }
}
