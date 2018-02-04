//
//  WorldItem.swift
//  PlayAround
//
//  Created by Bret Williams on 1/28/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

class WorldItem : SKSpriteNode {
    
    var portalToLevel :String = ""
    var portalToWhere :String = ""
    var isPortal :Bool = false
    
    var requiredThing:String = ""
    var requiredAmount:Int = 0
    var deductOnEntry:Bool = false
    var timeToOpen:TimeInterval = 0
    var isOpen:Bool = false
    let defaults:UserDefaults = UserDefaults.standard
    
    var lockedTextArray = [String]()
    var unlockedTextArray = [String]()
    var openTextArray = [String]()
    var currentInfo:String = ""
    
    func setUp() {
        
        
    }
    
    func setUpWithDict( theDict : [String : Any ]) {
        
        for (key, value) in theDict {
            
            if (key == "Requires") {
                
                if (value is [String:Any]) {
            
                    sortRequirements(theDict: value as! [String:Any])
                    sortText(theDict: value as! [String:Any])
                }
                
            } else if (key == "Text") {
                
                if (value is [String:Any]) {
                    
                    sortText(theDict: value as! [String:Any])
                }
                
            } else if (key == "PortalTo") {
                
                if let portalData:[String:Any] = value as? [String:Any] {
                    for (key, value) in portalData {
                        if (key == "Level") {
                            
                            if (value is String) {
                                portalToLevel = value as! String
                                isPortal = true
                            }
                            
                        } else if (key == "Where") {
                            
                            if (value is String) {
                                portalToWhere = value as! String
                                isPortal = true
                            }
                            
                        }
                    }
                }
                
            }
        }
        
        self.physicsBody?.categoryBitMask = BodyType.item.rawValue
        self.physicsBody?.collisionBitMask = BodyType.player.rawValue
        self.physicsBody?.contactTestBitMask = BodyType.player.rawValue
        
    }
    
    func sortText(theDict: [String:Any]) {
        
        for (key, value) in theDict {
            
            switch key {
            case "Locked":
                if let theValue = value as? [String] {
                    
                    lockedTextArray = theValue
                    
                } else if let theValue = value as? String {
                    
                    lockedTextArray.append(theValue)
                    
                }
            case "Unlocked":
                if let theValue = value as? [String] {
                    
                    unlockedTextArray = theValue
                    
                } else if let theValue = value as? String {
                    
                    unlockedTextArray.append(theValue)
                    
                }
            case "Open":
                if let theValue = value as? [String] {
                    
                    openTextArray = theValue
                    
                } else if let theValue = value as? String {
                    
                    openTextArray.append(theValue)
                    
                }
            default:
                break
            }
        
        }
    }
        
    func getInfo() -> String {
        
        if (currentInfo == "") {
            if (!isOpen) {
                let randomLine:UInt32 = arc4random_uniform(UInt32( lockedTextArray.count))
                currentInfo = lockedTextArray[ Int(randomLine)]
            } else {
                let randomLine:UInt32 = arc4random_uniform(UInt32( openTextArray.count))
                currentInfo = openTextArray[ Int(randomLine)]
            }
            
            let wait:SKAction = SKAction.wait(forDuration: 3)
            let run:SKAction = SKAction.run {
                self.currentInfo = ""
            }
            
            self.run(SKAction.sequence([wait,run]))
        }
        
        
        return currentInfo
    }
    
    func sortRequirements(theDict:[String:Any]) {
        
        for (key, value) in theDict {
            
            switch key {
            case "Inventory","Thing":
                if(value is String) {
                    requiredThing = value as! String
                }
            case "Amount":
                if(value is Int) {
                    requiredAmount = value as! Int
                }
            case "DeductOnEntry":
                if (value is Bool) {
                    deductOnEntry = value as! Bool
                }
            case "TimeToOpen":
                if (value is TimeInterval) {
                    timeToOpen = value as! TimeInterval
                }
            default:
                break
            }
            
        }
        if (defaults.integer(forKey: requiredThing) >= requiredAmount) {
            
            isOpen = true
            print ("\(self.name!) is open")
            
        } else {
            
            isOpen = false
            print ("\(self.name!) is NOT open")
            
        }
        
    }
    
}
