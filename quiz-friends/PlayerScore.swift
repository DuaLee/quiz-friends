//
//  Player.swift
//  quiz-friends
//
//  Created by Cony Lee on 5/3/22.
//

import Foundation

class PlayerScore {
    var displayName: String
    var score: Double
    
    public var description: String { return "\(displayName) | \(score)" }
    
    init() {
        self.displayName = ""
        self.score = 0
    }
    
    init(displayName: String) {
        self.displayName = displayName
        self.score = 0
    }
    
    init(displayName: String, score: Double) {
        self.displayName = displayName
        self.score = score
    }
}
