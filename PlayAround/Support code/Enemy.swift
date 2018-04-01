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

    
    var isDead:Bool = false
    
    //movement
    var movementType:MoveType = .none
    var moveIfPlayerWithin:CGFloat = -1  //determines whether to pause enemy if player goes out of range
    var allowMovement:Bool = false
    var movementActions = [String]()
    
    //ranged attack
    
    
    //melee attack
    

    func setUpEnemy(theDict:[String:Any]) {
        
        print(self.name!)
        
        self.physicsBody?.categoryBitMask = BodyType.enemy.rawValue
        self.physicsBody?.collisionBitMask = BodyType.player.rawValue | BodyType.item.rawValue | BodyType.projectile.rawValue |
            BodyType.enemy.rawValue | BodyType.npc.rawValue
        self.physicsBody?.contactTestBitMask = BodyType.player.rawValue | BodyType.projectile.rawValue | BodyType.attackArea.rawValue
        
        for (key,value) in theDict {
            
            switch key {
            case "Movement":
                
                if (value is [String:Any]) {
                    
                    sortMovementDict(theDict: value as! [String:Any])
                    
                }
                
                
            default:
                continue
            }
        }
        
        postSetUp()
        
    }
    
    func postSetUp() {
        
        if (moveIfPlayerWithin == -1 && movementType == .actions) {
            
            allowMovement = true
            
            //start movement from actions array
            startMovementFromArray()
            
        }
        
        
        
    }
    
    func update(playerPos:CGPoint) {
        
        if (!isDead) {
            
            if (movementType == .actions) {
                
                if (allowMovement) {
                    
                    if (self.action(forKey: "Movement") == nil && self.action(forKey: "Hurt") == nil) {
                        
                        startMovementFromArray()
                        
                    }
                    
                }
                
            } else if (movementType == .follow) {
                
                
                
            } else if (movementType == .none) {
                
                
                
            }
            
            
            
        }
        
    }
    
    func startMovementFromArray() {
        
        self.removeAction(forKey: "Idle")
        
        var actionArray = [SKAction]()
        
        for name in movementActions {
            
            if let someAction:SKAction = SKAction(named: name) {
                
                actionArray.append(someAction)
                
            }
        }
        
        let finishLoop:SKAction = SKAction.run {
            
            if (self.allowMovement == false)  {
                
                self.removeAction(forKey: "Movement")
            }
            
        }
        
        actionArray.append(finishLoop)
        
        let seq:SKAction = SKAction.sequence(actionArray)
        let loop:SKAction = SKAction.repeatForever(seq)
        
        self.run(loop, withKey: "Movement")
        
    }
    
    //MARK:  Sorting stuff
    
    func sortMovementDict(theDict: [String:Any]) {
        
        for (key,value) in theDict {
            
            switch key {
            case "Actions":
                
                if let someArray:[String] = value as? [String] {
                    
                    movementActions = someArray
                    movementType = .actions
                }
                
            case "Within":
                
                if (value is CGFloat) {
                    
                    moveIfPlayerWithin = value as! CGFloat
                    
                }
                
            default:
                continue
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    

}
