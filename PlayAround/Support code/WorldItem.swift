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
    var currentUnlockedText:String = ""
    var openAnimation:String = ""
    var openImage:String = ""
    var rewardDictionary = [String:Any]()
    
    var neverRewardAgain:Bool = false
    var neverShowAgain:Bool = false
    var deleteBody:Bool = false
    var deleteFromLevel:Bool = false
    
    func setUp() {
        
        
    }
    
    func setUpWithDict( theDict : [String : Any ]) {
        
        
        
        for (key, value) in theDict {
            
            print("setUpWithDict: key = \(key)")
            
            if (key == "Requires") {
                
                isOpen = false
                
                if (value is [String:Any]) {
            
                    sortRequirements(theDict: value as! [String:Any])
             
                }
                
            } else if (key == "Rewards") {
                
                if (value is [String:Any]) {
                    
                    sortRewards(theDict: value as! [String:Any])
                }
                
            } else if (key == "Text") {
                
                if (value is [String:Any]) {
                    
                    sortText(theDict: value as! [String:Any])
                }
                
            } else if (key == "AfterContact") {
                
                if (value is [String:Any]) {
                    
                    sortAfterContact(theDict: value as! [String:Any])
                }
                
            } else if (key == "PortalTo") {
                
                if (value is [String:Any]) {
                    
                    sortPortalTo(theDict: value as! [String:Any])
                    
                }
                
            } else if (key == "Appearance") {
                
                if (value is [String:Any]) {
                    
                    sortAppearance(theDict:value as! [String:Any])
                    
                }
                
            }
        }
        
        self.physicsBody?.categoryBitMask = BodyType.item.rawValue
        self.physicsBody?.collisionBitMask = BodyType.player.rawValue
        self.physicsBody?.contactTestBitMask = BodyType.player.rawValue
        
        checkRequirements()
        
    }
    
    func checkRequirements() {
    
        if (defaults.integer(forKey: requiredThing) >= requiredAmount) {
            
            open()
            
            print ("\(self.name!) is open")
            
        } else {
            
            isOpen = false
            print ("\(self.name!) is NOT open")
            
        }
        
        
    }
    
    func afterOpenContact() {
        
        if (isOpen) {
            if(deleteBody) {
                self.physicsBody = nil
            } else if (deleteFromLevel) {
                self.removeFromParent()
            }
            
            if(deductOnEntry) {
                if(defaults.integer(forKey: requiredThing) != 0) {
                    
                    let currentAmount:Int = defaults.integer(forKey: requiredThing)
                    let newAmount:Int = currentAmount - requiredAmount
                    defaults.set(newAmount, forKey: requiredThing)
                    
                    
                }
            }
        }
        
    }
    
    func sortRewards( theDict: [String:Any]) {
      
        for (key, value) in theDict {
            
            rewardDictionary[key] = value
            
        }
        
    }
    
    func sortAppearance( theDict: [String:Any]) {
        
        for (key, value) in theDict {
            if (key == "OpenImage") {
                
                if (value is String) {
                    openImage = value as! String
           
                }
                
            } else if (key == "OpenAnimation") {
                
                if (value is String) {
                    openAnimation = value as! String
                 
                }
                
            }
        }
        
    }
    
    
    func sortPortalTo( theDict: [String:Any]) {
        
        for (key, value) in theDict {
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
    
    func sortAfterContact (theDict: [String:Any]) {
        
        for (key,value) in theDict {
            
            switch key {
            case "NeverRewardAgain":
                if (value is Bool) {
                    neverRewardAgain = value as! Bool
                }
            case "NeverShowAgain":
                if (value is Bool) {
                    neverShowAgain = value as! Bool
                }
            case "DeleteFromLevel":
                if (value is Bool) {
                    deleteFromLevel = value as! Bool
                }
            case "DeleteBody":
                if (value is Bool) {
                    deleteBody  = value as! Bool
                }
            default:
                continue
            }
        }
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
            
            if (!isOpen && lockedTextArray.count > 0) {
                
                let randomLine:UInt32 = arc4random_uniform(UInt32( lockedTextArray.count))
                currentInfo = lockedTextArray[ Int(randomLine)]
                
            } else {
                
                if(openTextArray.count > 0) {
                    let randomLine:UInt32 = arc4random_uniform(UInt32( openTextArray.count))
                    currentInfo = openTextArray[ Int(randomLine)]
                }
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
        
        
    }
    
    func open() {
        
        isOpen = true
        
        if (openAnimation != "" ) {
            
            self.run(SKAction(named: openAnimation)!)
            
        } else if (openImage != "") {
            
            self.texture = SKTexture(imageNamed: openImage)
            
        }
        
        
    }
    
    func getUnlockedInfo() -> String {
        
        if (currentUnlockedText == "") {
            
            let randomLine:UInt32 = arc4random_uniform(UInt32( unlockedTextArray.count))
            currentUnlockedText = unlockedTextArray[ Int(randomLine)]
 
            let wait:SKAction = SKAction.wait(forDuration: 3)
            let run:SKAction = SKAction.run {
                self.currentUnlockedText = ""
            }
            
            self.run(SKAction.sequence([wait,run]))
        }
        
        return currentUnlockedText
        
    }
    
    
    
    
    
}