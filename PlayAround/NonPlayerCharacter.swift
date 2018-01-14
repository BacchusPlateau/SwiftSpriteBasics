//
//  NonPlayerCharacter.swift
//  PlayAround
//
//  Created by Bret Williams on 1/13/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

class NonPlayerCharacter: SKSpriteNode {
    
    var frontName:String = ""
    var backName:String = ""
    var leftName:String = ""
    var rightName:String = ""
    var baseFrame:String = ""
    
    var isWalking:Bool = false
    var initialSpeechArray = [String]()
    var reminderSpeechArray = [String]()
    var alreadyContacted:Bool = false
    
    func setUpWithDict( theDict : [String : Any ]) {
        
        let body:SKPhysicsBody = SKPhysicsBody(circleOfRadius: self.frame.size.width / 3, center:CGPoint.zero)
        self.physicsBody = body
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        
        
        self.physicsBody?.categoryBitMask = BodyType.npc.rawValue
        
        self.physicsBody?.contactTestBitMask = BodyType.player.rawValue
        
        
        for (key, value) in theDict  {
            if(key == "Front") {
                frontName = value as! String
                
            }
            else if(key == "Back") {
                backName = value as! String
                
            }
            else if(key == "Left") {
                leftName = value as! String
                
            }
            else if(key == "Right") {
                rightName = value as! String
                
            }
            else if(key == "InitialSpeech") {
                if let theValue = value as? [String] {
                    initialSpeechArray = theValue
                }
                else if let theValue = value as? String {
                    initialSpeechArray.append(theValue)
                }
            }
            else if(key == "ReminderSpeech") {
                if let theValue = value as? [String] {
                    reminderSpeechArray = theValue
                }
                else if let theValue = value as? String {
                    reminderSpeechArray.append(theValue)
                }
            }
            
        }
        walkRandom()
    }
    
    func walkRandom() {
        
        let waitTime = arc4random_uniform(3)
        let wait:SKAction = SKAction.wait(forDuration: TimeInterval(waitTime))
        let randomNum = arc4random_uniform(4)
        let endMove:SKAction = SKAction.run {
            self.walkRandom()
        }
        
        switch randomNum {
        case 0:
            self.run(SKAction(named:rightName)!)
            let move:SKAction = SKAction.moveBy(x: 50, y: 0, duration: 1)
            self.run(SKAction.sequence([move,wait,endMove]))
        case 1:
            self.run(SKAction(named:backName)!)
            let move:SKAction = SKAction.moveBy(x: 0, y: 50, duration: 1)
            self.run(SKAction.sequence([move,wait,endMove]))
        case 2:
            self.run(SKAction(named:frontName)!)
            let move:SKAction = SKAction.moveBy(x: 0, y: -50, duration: 1)
            self.run(SKAction.sequence([move,wait,endMove]))
        case 3:
            self.run(SKAction(named:leftName)!)
            let move:SKAction = SKAction.moveBy(x: -50, y: 0, duration: 1)
            self.run(SKAction.sequence([move,wait,endMove]))
        default:
            self.run(SKAction(named:rightName)!)
            let move:SKAction = SKAction.moveBy(x: 50, y: 0, duration: 1)
            self.run(SKAction.sequence([move,wait,endMove]))
        }
        
        
    }
    
    func contactPlayer() {
        isWalking = false
        self.removeAllActions()
        self.texture = SKTexture(imageNamed: baseFrame)
        if(!alreadyContacted) {
            alreadyContacted = true
        }
        
    }
    
    func endContactPlayer () {
        
        if(!isWalking) {
            isWalking = true;
            walkRandom()
        }
        
    }
    
    
    
}
