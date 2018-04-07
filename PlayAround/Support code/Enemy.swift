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
    var walkSpeed:CGFloat = 1
    
    var facing:Facing = .none
    
    //ranged attack
    
    
    //melee attack
    var hasMeleeAttack:Bool = false
    var meleeIfPlayerWithin:CGFloat = -1  //radius for melee
    var meleeDamage:Int = 0
    var allowMeleeAttack:Bool = true
    
    var meleeSize:CGSize = CGSize(width:100, height:100)
    var meleeScaleTo:CGFloat = 2
    var meleeScaleTime:TimeInterval = 1
    var meleeAnimation:String = ""
    var meleeTimeBetweenUse:TimeInterval = 1
    var justDidMeleeAttack:Bool = false
    var meleeRemoveOnContact:Bool = false
    
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
                
            case "Melee":
                
                if (value is [String:Any]) {
                    
                    sortMeleeDict(theDict: value as! [String:Any])
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
                        
                    } else if (hasIdleAnimation) {
                        
                        if(self.action(forKey: "Movement") == nil
                            && self.action(forKey: "Hurt") == nil
                            && self.action(forKey: "Idle") == nil) {
                            
                            runIdleAnimation(playerPos: playerPos)
                            
                        }
                        
                    }
                    
                }
                
            } else if (movementType == .follow) {
                
                if (allowMovement) {
                    
                    if (self.action(forKey: "Hurt") == nil) {
                        
                        orientEnemy(playerPos:playerPos)
                        moveEnemy()
                        animateWalk()
                        
                    } else if (hasIdleAnimation) {
                        
                        if(self.action(forKey: "Hurt") == nil
                            && self.action(forKey: "Idle") == nil) {
                            
                            self.removeAction(forKey: "WalkAnimation")
                            runIdleAnimation(playerPos: playerPos)
                            
                        }
                        
                    }
                    
                }
                
            } else if (movementType == .none) {
                
                
                
            } else if (movementType == .random) {
                
                if (allowMovement) {
                    
                    if (self.action(forKey: "Movement") == nil
                        && self.action(forKey: "Hurt") == nil
                        && self.action(forKey: "Attack") == nil) {
           
                        walkRandom()
                        
                    }
                    
                } else if (hasIdleAnimation) {
                    
                    if(self.action(forKey: "Hurt") == nil
                        && self.action(forKey: "Idle") == nil) {
                        
                        stopWalking()
                        runIdleAnimation(playerPos: playerPos)
                        
                    }
                    
                }
                
            }

            if (!justDidMeleeAttack && allowMeleeAttack) {
                
                orientEnemy(playerPos: playerPos)
                meleeAttack()
                
            }
            
            
        }
        
    }
    
    func stopWalking() {
        
        if (self.movementType != .actions) {
            
            self.removeAction(forKey: "Movement")
            self.removeAction(forKey: "WalkAnimation")
            
        }
        
    }
    
    func animateWalk() {
        
        if (self.action(forKey: "Attack") == nil && self.action(forKey: "WalkAnimation") == nil) {
            
            var theAnimation:String = ""
            
            switch facing {
            case .right:
                theAnimation = rightWalk
            case .left:
                theAnimation = leftWalk
            case .back:
                theAnimation = backWalk
            case .front:
                theAnimation = frontWalk
            case .none:
                break
            }
            
            if (theAnimation != "") {
                
                self.removeAction(forKey: "Idle")

                if let walkAnimation:SKAction = SKAction(named:theAnimation) {
                    
                    self.run(walkAnimation, withKey: "WalkAnination")
                    
                }

            }
            
        }
        
    }
    
    func moveEnemy() {
        
        switch facing {
        case .right:
            self.position = CGPoint(x: self.position.x + walkSpeed, y: self.position.y)
        case .left:
            self.position = CGPoint(x: self.position.x - walkSpeed, y: self.position.y)
        case .back:
            self.position = CGPoint(x: self.position.x, y: self.position.y + walkSpeed)
        case .front:
            self.position = CGPoint(x: self.position.x, y: self.position.y - walkSpeed)
        case .none:
            break
        }
        
    }
    
    func orientEnemy(playerPos: CGPoint) {
        
        if (abs(playerPos.x - self.position.x) > (abs(playerPos.y - self.position.y))) {
            
            //greater movement on the X
            
            if (playerPos.x > self.position.x) {
                
                self.facing = .right
                
            } else {
                
                self.facing = .left
                
            }
            
        } else {
            
            //greater movement on the Y
         
            if (playerPos.y > self.position.y) {
                
                self.facing = .back
                
            } else {
                
                self.facing = .front
                
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
            
            if let walk = SKAction(named: frontWalk) {
                print ("frontWalk = " + frontWalk)
                let repeatWalk:SKAction = SKAction.repeatForever(walk)
                self.run(repeatWalk, withKey: "WalkAnimation")
            }
            
            let move:SKAction = SKAction.moveBy(x: 0, y: -walkDistance, duration: walkTime)
            self.run(SKAction.sequence([ move, endMove, wait ]), withKey: "Movement")
        case 1:
            
            if let walk = SKAction(named: backWalk) {
                print ("backWalk = " + backWalk)
                let repeatWalk:SKAction = SKAction.repeatForever(walk)
                self.run(repeatWalk, withKey: "WalkAnimation")
            }
            
            let move:SKAction = SKAction.moveBy(x: 0, y: walkDistance, duration: walkTime)
            self.run(SKAction.sequence([ move, endMove, wait ]), withKey: "Movement")
        case 2:
            
            if let walk = SKAction(named: leftWalk) {
                print("leftWalk = " + leftWalk)
                let repeatWalk:SKAction = SKAction.repeatForever(walk)
                self.run(repeatWalk, withKey: "WalkAnimation")
            }
            
            let move:SKAction = SKAction.moveBy(x: -walkDistance, y:0, duration: walkTime)
            self.run(SKAction.sequence([ move, endMove, wait ]), withKey: "Movement")
        case 3:
            
            if let walk = SKAction(named: rightWalk) {
                print("rightWalk = " + rightWalk)
                let repeatWalk:SKAction = SKAction.repeatForever(walk)
                self.run(repeatWalk, withKey: "WalkAnimation")
            }
            
            let move:SKAction = SKAction.moveBy(x: walkDistance, y: 0, duration: walkTime)
            self.run(SKAction.sequence([ move, endMove, wait ]), withKey: "Movement")
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
    
    
    func sortMeleeDict(theDict: [String:Any]) {
        
        hasMeleeAttack = true
        
        for (key,value) in theDict {
            
            switch key {
            case "Damage":
                if (value is Int) {
                    meleeDamage = value as! Int
                }
            case "Size":
                if (value is String) {
                    meleeSize = CGSizeFromString(value as! String)
                }
            case "ScaleTo":
                if (value is CGFloat) {
                    meleeScaleTo = value as! CGFloat
                }
            case "ScaleTime":
                if (value is TimeInterval) {
                    meleeScaleTime = value as! TimeInterval
                }
            case "Animation":
                if (value is String) {
                    meleeAnimation = value as! String
                }
            case "TimeBetweenUse":
                if (value is TimeInterval) {
                    meleeTimeBetweenUse = value as! TimeInterval
                }
            case "Within":
                if (value is CGFloat) {
                    meleeIfPlayerWithin = value as! CGFloat
                }
            case "RemoveOnContact":
                if (value is Bool) {
                    meleeRemoveOnContact = value as! Bool
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
                
            case "Speed":
                
                if (value is CGFloat) {
                    
                    walkSpeed = value as! CGFloat
                    
                }
                
            case "FollowPlayer":
                
                if (value is Bool) {
                    
                    if (value as! Bool == true) {
                        
                        movementType = .follow
                        
                    }
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
    
    func runIdleAnimation(playerPos:CGPoint) {
        
        if (self.action(forKey: "Attack") == nil) {
            
            if (playerPos != CGPoint.zero)  {
                
                orientEnemy(playerPos: playerPos)
                
            }
            
            var animationName:String = ""
            
            switch facing {
            case .right:
                animationName = rightIdle
            case .left:
                animationName = leftIdle
            case .back:
                animationName = backIdle
            case .front, .none:
                animationName = frontIdle
            }
            
            if (animationName != "")  {
                
                if let idleAnimation:SKAction = SKAction(named: animationName) {
                    
                    self.run(idleAnimation, withKey: "Idle")
                }
            }
            
            
        }
        
        
    }
    
    
    func meleeAttack() {
        
        justDidMeleeAttack = true
        
        let wait:SKAction = SKAction.wait(forDuration: meleeTimeBetweenUse)
        let finishWait:SKAction = SKAction.run {
            self.justDidMeleeAttack = false
        }
        self.run(SKAction.sequence([ wait, finishWait ]))
        
        //set up enemy attack area
        let newAttack:EnemyAttackArea = EnemyAttackArea(color:  SKColor.clear, size: meleeSize)
        
        newAttack.scaleSize = meleeScaleTo
        newAttack.scaleTime = meleeScaleTime
        newAttack.damage = meleeDamage
        newAttack.removeOnContact = meleeRemoveOnContact
        newAttack.animationName = meleeAnimation
        
        newAttack.setUp()
        self.addChild(newAttack)
        newAttack.zPosition = self.zPosition - 1
        newAttack.upAndAway()
        
        if (movementType == .actions) {
            
            if (self.action(forKey: "Movement") != nil) {
                self.action(forKey: "Movement")?.speed = 0
            }
        }
        
        var animationName:String = ""
        
        switch facing {
        case .front:
            animationName = frontMelee
        case .back:
            newAttack.xScale = -1
            newAttack.yScale = -1
            animationName = backMelee
        case .right:
            animationName = rightMelee
        case .left:
            newAttack.xScale = -1
            animationName = leftMelee
        default:
            break
        }
        
        if (animationName != "") {
            
            if let attackAnimation:SKAction = SKAction(named: animationName) {
                
                stopWalking()
                
                let finish:SKAction = SKAction.run {
                    
                    if (self.movementType == .actions) {
                        
                        if (self.action(forKey: "Movement") != nil) {
                            
                            self.action(forKey: "Movement")?.speed = 1
                        }
                    }
                }
                
                let seq:SKAction = SKAction.sequence([ attackAnimation, finish ])
                self.run(seq, withKey:"Attack")
                
            }
            
        }
    }
    
    
    
    
    
    

}
