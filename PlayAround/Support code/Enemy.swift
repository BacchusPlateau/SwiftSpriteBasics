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
    
    var waitTimeForRandomWalking:TimeInterval = -1
    var randomWaitTimeRange:UInt32 = 3
    var walkTime:TimeInterval = 1
    var walkDistance:CGFloat = 50
    
    //ranged attack
    
    
    //melee attack
    
    //animation
    var frontWalk:String = ""
    var frontIdle:String = ""
    var frontMelee:String = ""
    var frontRanged:String = ""
    var frontHurt:String = ""
    
    var backWalk:String = ""
    var backIdle:String = ""
    var backMelee:String = ""
    var backRanged:String = ""
    var backHurt:String = ""
    
    var leftWalk:String = ""
    var leftIdle:String = ""
    var leftMelee:String = ""
    var leftRanged:String = ""
    var leftHurt:String = ""
    
    var rightWalk:String = ""
    var rightIdle:String = ""
    var rightMelee:String = ""
    var rightRanged:String = ""
    var rightHurt:String = ""
    
    var rightDying:String = ""
    var leftDying:String = ""
    var backDying:String = ""
    var frontDying:String = ""

    var hasIdleAnimation:Bool = false
    
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
                
            case "Animation":
                
                if (value is [String:Any]) {
                    
                    sortAnimationDict(theDict: value as! [String:Any])
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
                
                
                
            } else if (movementType == .random) {
                
                if (allowMovement) {
                    
                    if (self.action(forKey: "Movement") == nil
                        && self.action(forKey: "Hurt") == nil
                        && self.action(forKey: "Attack") == nil) {
           
                        walkRandom()
                        
                    }
                }
                
            }

        }
        
    }
    
    func walkRandom() {
        
        self.removeAction(forKey: "Idle")
        var wait:SKAction = SKAction()
        
        if (waitTimeForRandomWalking > -1)  {
            
            wait = SKAction.wait(forDuration: waitTimeForRandomWalking)
            
        } else {
            
            let waitTime = arc4random_uniform(randomWaitTimeRange)
            wait = SKAction.wait(forDuration: TimeInterval(waitTime))
            
        }
        
        let endMove:SKAction = SKAction.run {
            
            self.removeAction(forKey: "WalkAnimation")
            
        }
        
        print("walkDistance = " + String(format: "%.2f",walkDistance))
        print("walkTime = " + String(walkTime))
        
        let randomNum = arc4random_uniform(4)
        //print (randomNum)
        switch randomNum {
        case 0:
            print ("frontWalk = " + frontWalk)
            if let walk = SKAction(named: frontWalk) {
                let repeatWalk:SKAction = SKAction.repeatForever(walk)
                self.run(repeatWalk, withKey: "WalkAnimation")
            }
            
            let move:SKAction = SKAction.moveBy(x: 0, y: -walkDistance, duration: walkTime)
            self.run(SKAction.sequence([ move, endMove, wait ]), withKey: "WalkAnimation")
        case 1:
            print ("backWalk = " + backWalk)
            if let walk = SKAction(named: backWalk) {
                let repeatWalk:SKAction = SKAction.repeatForever(walk)
                self.run(repeatWalk, withKey: "WalkAnimation")
            }
            
            let move:SKAction = SKAction.moveBy(x: 0, y: walkDistance, duration: walkTime)
            self.run(SKAction.sequence([ move, endMove, wait ]), withKey: "WalkAnimation")
        case 2:
            print("leftWalk = " + leftWalk)
            if let walk = SKAction(named: leftWalk) {
                let repeatWalk:SKAction = SKAction.repeatForever(walk)
                self.run(repeatWalk, withKey: "WalkAnimation")
            }
            
            let move:SKAction = SKAction.moveBy(x: -walkDistance, y:0, duration: walkTime)
            self.run(SKAction.sequence([ move, endMove, wait ]), withKey: "WalkAnimation")
        case 3:
            print("rightWalk = " + rightWalk)
            if let walk = SKAction(named: rightWalk) {
                let repeatWalk:SKAction = SKAction.repeatForever(walk)
                self.run(repeatWalk, withKey: "WalkAnimation")
            }
            
            let move:SKAction = SKAction.moveBy(x: walkDistance, y: 0, duration: walkTime)
            self.run(SKAction.sequence([ move, endMove, wait ]), withKey: "WalkAnimation")
        default:
            break
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
    
    func sortAnimationDict(theDict: [String:Any]) {
        
        for (key,value) in theDict {
            print ("key = " + key)
            switch key {
            case "Back":
                if let backDict:[String:Any] = value as? [String:Any] {
                    for (backKey, backValue) in backDict {
                        print ("backKey = " + backKey)
                        print ("backValue = " + (backValue as! String))
                        switch backKey {
                        case "Walk":
                            backWalk = backValue as! String
                        case "Idle":
                            backIdle = backValue as! String
                        case "Melee":
                            backMelee = backValue as! String
                        case "Ranged":
                            backRanged = backValue as! String
                        case "Hurt":
                            backHurt = backValue as! String
                        case "Dying":
                            backDying = backValue as! String
                        default:
                            continue
                        }
                    }
                }
            case "Front":
                if let frontDict:[String:Any] = value as? [String:Any] {
                    for (frontKey, frontValue) in frontDict {
                        switch frontKey {
                        case "Walk":
                            frontWalk = frontValue as! String
                        case "Idle":
                            frontIdle = frontValue as! String
                            hasIdleAnimation = true
                        case "Melee":
                            frontMelee = frontValue as! String
                        case "Ranged":
                            frontRanged = frontValue as! String
                        case "Hurt":
                            frontHurt = frontValue as! String
                        case "Dying":
                            frontDying = frontValue as! String
                        default:
                            continue
                        }
                    }
                }
            case "Left":
                if let leftDict:[String:Any] = value as? [String:Any] {
                    for (leftKey, leftValue) in leftDict {
                        switch leftKey {
                        case "Walk":
                            leftWalk = leftValue as! String
                        case "Idle":
                            leftIdle = leftValue as! String
                        case "Melee":
                            leftMelee = leftValue as! String
                        case "Ranged":
                            leftRanged = leftValue as! String
                        case "Hurt":
                            leftHurt = leftValue as! String
                        case "Dying":
                            leftDying = leftValue as! String
                        default:
                            continue
                        }
                    }
                }
            case "Right":
                if let rightDict:[String:Any] = value as? [String:Any] {
                    for (rightKey, rightValue) in rightDict {
                        switch  rightKey {
                        case "Walk":
                            rightWalk = rightValue as! String
                        case "Idle":
                            rightIdle = rightValue as! String
                        case "Melee":
                            rightMelee = rightValue as! String
                        case "Ranged":
                            rightRanged = rightValue as! String
                        case "Hurt":
                            rightHurt = rightValue as! String
                        case "Dying":
                            rightDying = rightValue as! String
                        default:
                            continue
                        }
                    }
                }
            default:
                continue
            }
            
        }
        
    }
    
    
    
    
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
                
            case "WalkRandomly":
                
                if (value is Bool) {
                    
                    if (value as! Bool == true) {
                        
                        movementType = .random
                        
                    }
                }
            case "WaitTime":
                
                if (value is TimeInterval) {
                    
                    waitTimeForRandomWalking = value as! TimeInterval
                }
                
            case "WalkTime":
                
                if (value is TimeInterval) {
                    
                    walkTime = value as! TimeInterval
                    
                }
                
            case "WalkDistance":
                
                if (value is CGFloat) {
                    
                    walkDistance = value as! CGFloat
                }
                
            case "RandomWaitTime":
                
                if (value is UInt32) {
                    
                    randomWaitTimeRange = value as! UInt32
                }
                
            default:
                continue
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    

}
