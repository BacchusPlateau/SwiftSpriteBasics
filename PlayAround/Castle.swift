//
//  Castle.swift
//  PlayAround
//
//  Created by Bret Williams on 12/31/17.
//  Copyright © 2017 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

class Castle : SKSpriteNode {
    
    var dudesInCastle : Int = 0
    
    
    func setUpCastle() {
        
        self.physicsBody?.categoryBitMask = BodyType.castle.rawValue
        self.physicsBody?.collisionBitMask = BodyType.player.rawValue
        self.physicsBody?.contactTestBitMask = BodyType.player.rawValue
        
     //   print ("Setup Castle")
    }
    
    
}
