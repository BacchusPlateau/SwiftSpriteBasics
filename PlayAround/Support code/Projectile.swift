//
//  Projectile.swift
//  PlayAround
//
//  Created by Bret Williams on 3/17/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

class Projectile: SKSpriteNode {
    
    var travelTime:TimeInterval = 1
    var rotationTime:TimeInterval = 0
    var distance:CGFloat = 0
    var removeAfterThrow:Bool = true
    var offset:CGFloat = 0
    
    func setUpWithDict(theDict:[String:Any]) {
        
        let body:SKPhysicsBody = SKPhysicsBody(texture: self.texture!, size: (self.texture?.size())!)
        self.physicsBody = body
        
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        
        self.physicsBody?.categoryBitMask = BodyType.projectile.rawValue
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = BodyType.enemy.rawValue | BodyType.player.rawValue
        
        for (key,value) in theDict {
            
            switch key {
            case "TravelTime":
                if(value is TimeInterval) {
                    travelTime = value as! TimeInterval
                }
            case "RotationTime":
                if(value is TimeInterval) {
                    rotationTime = value as! TimeInterval
                }
            case "Distance":
                if(value is CGFloat) {
                    distance = value as! CGFloat
                }
            case "Remove":
                if(value is Bool) {
                    removeAfterThrow = value as! Bool
                }
            case "ZPosition":
                if(value is CGFloat) {
                    self.zPosition = value as! CGFloat
                }
            case "Offset":
                if(value is CGFloat) {
                    offset = value as! CGFloat
                }
            default:
                continue
            }
        }
    }
    
    
    
    
    
}
