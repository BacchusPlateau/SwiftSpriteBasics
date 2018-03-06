//
//  Player.swift
//  PlayAround
//
//  Created by Bret Williams on 3/5/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

class Player : SKSpriteNode {

    var frontWalk: String = ""
    var frontIdle: String = ""
    var frontMelee: String = ""
    
    var backWalk: String = ""
    var backIdle: String = ""
    var backMelee: String = ""
    
    var leftWalk: String = ""
    var leftIdle: String = ""
    var leftMelee: String = ""
    
    var rightWalk: String = ""
    var rightIdle: String = ""
    var rightMelee: String = ""
    
    var meleeAnimationFXName:String = "Attacking"
    var meleeScaleSize:CGFloat = 2
    var meleeAnimationSize:CGSize = CGSize(width: 100, height:100)
    
    var walkSpeed:TimeInterval = .5
    var health:Int = 20
    var armor:Int = 20
    var immunity:TimeInterval = 1
    
    func setUpWithDict( theDict: [String:Any]) {
        
        for (key,value) in theDict {
            
            switch key {
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
        
    }
        
    func sortAnimationDict(theDict:[String:Any]) {
        
        for (key,value) in theDict {
            
            switch key {
                
            case "Back":
                if let backDict:[String:Any] = value as? [String:Any] {
                    
                    for (key, value) in backDict {
                        
                        switch key {
                            
                        case "Walk":
                            backWalk = value as! String
                        case "Idle":
                            backIdle = value as! String
                        case "Melee":
                            backMelee = value as! String
                        default:
                            continue
                            
                        }
                    }
                }
            case "Front":
                if let backDict:[String:Any] = value as? [String:Any] {
                    
                    for (key, value) in backDict {
                        
                        switch key {
                            
                        case "Walk":
                            frontWalk = value as! String
                        case "Idle":
                            frontIdle = value as! String
                        case "Melee":
                            frontMelee = value as! String
                        default:
                            continue
                            
                        }
                    }
                }
            case "Left":
                if let backDict:[String:Any] = value as? [String:Any] {
                    
                    for (key, value) in backDict {
                        
                        switch key {
                            
                        case "Walk":
                            leftWalk = value as! String
                        case "Idle":
                            leftIdle = value as! String
                        case "Melee":
                            leftMelee = value as! String
                        default:
                            continue
                            
                        }
                    }
                }
            case "Right":
                if let backDict:[String:Any] = value as? [String:Any] {
                    
                    for (key, value) in backDict {
                        
                        switch key {
                            
                        case "Walk":
                            rightWalk = value as! String
                        case "Idle":
                            rightIdle = value as! String
                        case "Melee":
                            rightMelee = value as! String
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
    
    func sortMeleeDict(theDict:[String:Any]) {
        
        for (key, value) in theDict {
            
            switch key {
                
            case "Damage":
                if (value is Int) {
                    
                    
                }
            case "Size":
                if (value is String) {
                    
                    meleeAnimationSize = CGSizeFromString(value as! String)
                }
            case "Animation":
                if (value is String) {
                    
                    meleeAnimationFXName = value as! String
                }
            case "ScaleTo":
                if (value is CGFloat) {
                    
                    meleeScaleSize = value as! CGFloat
                    
                }
            case "TimeBetweenUse":
                if (value is TimeInterval) {
                    
                    
                }
                
            default:
                continue
            }
        }
    }
        
    



}
