//
//  Enemy.swift
//  PlayAround
//
//  Created by Bret Williams on 4/1/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

enum MoveType: Int {
    
    case actions, follow, random, none
}


class Enemy : SKSpriteNode {

    var movementType:MoveType = .none
    var isDead:Bool = false
    

    func setUpEnemy(theDict:[String:Any]) {
        
        print(self.name!)
        
        self.physicsBody?.categoryBitMask = BodyType.enemy.rawValue
        self.physicsBody?.collisionBitMask = BodyType.player.rawValue | BodyType.item.rawValue | BodyType.projectile.rawValue |
            BodyType.enemy.rawValue | BodyType.npc.rawValue
        self.physicsBody?.contactTestBitMask = BodyType.player.rawValue | BodyType.projectile.rawValue | BodyType.attackArea.rawValue
        
        
        
    }
    
    func update(playerPos:CGPoint) {
        
        if (!isDead) {
            
            if (movementType == .actions) {
                
                
                
            } else if (movementType == .follow) {
                
                
                
            } else if (movementType == .none) {
                
                
                
            }
            
            
            
        }
        
    }

}
