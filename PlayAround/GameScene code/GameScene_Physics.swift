//
//  GameScene_Physics.swift
//  PlayAround
//
//  Created by Bret Williams on 1/20/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene {


    //MARK: Physics contacts
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if(contact.bodyA.categoryBitMask == BodyType.player.rawValue && contact.bodyB.categoryBitMask == BodyType.npc.rawValue)
        {
            if let theNPC:NonPlayerCharacter = contact.bodyB.node as? NonPlayerCharacter {
                contactWithNPC(theNPC: theNPC)
            }
        }else if(contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.npc.rawValue)
        {
            if let theNPC:NonPlayerCharacter = contact.bodyA.node as? NonPlayerCharacter {
                contactWithNPC(theNPC: theNPC)
            }
        }else if(contact.bodyA.categoryBitMask == BodyType.player.rawValue && contact.bodyB.categoryBitMask == BodyType.item.rawValue)
        {
            if let theItem:WorldItem = contact.bodyB.node as? WorldItem {
                contactWithItem(theItem: theItem)
            }
        }else if(contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.item.rawValue)
        {
            if let theItem:WorldItem = contact.bodyA.node as? WorldItem {
                contactWithItem(theItem: theItem)
            }
        }
    }
    
    
    func didEnd(_ contact: SKPhysicsContact) {
        if(contact.bodyA.categoryBitMask == BodyType.player.rawValue && contact.bodyB.categoryBitMask == BodyType.npc.rawValue)
        {
            if let theNPC:NonPlayerCharacter = contact.bodyB.node as? NonPlayerCharacter {
          
                endContactWithNPC(theNPC: theNPC)
                
            }
        }else if(contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.npc.rawValue)
        {
            if let theNPC:NonPlayerCharacter = contact.bodyA.node as? NonPlayerCharacter {
                
                endContactWithNPC(theNPC: theNPC)
                
            }
        } else if(contact.bodyA.categoryBitMask == BodyType.player.rawValue && contact.bodyB.categoryBitMask == BodyType.item.rawValue)
        {
            if let theItem:WorldItem = contact.bodyB.node as? WorldItem {
                
                endContactWithItem(theItem: theItem)
                
            }
        } else if(contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.item.rawValue)
        {
            if let theItem:WorldItem = contact.bodyA.node as? WorldItem {
                
                endContactWithItem(theItem: theItem)
                
            }
        }
    }
    
    func endContactWithNPC (theNPC:NonPlayerCharacter) {
        
        theNPC.endContactPlayer()
        fadeOutInfoText(waitTime: theNPC.infoTime)
        
    }
    
    func contactWithNPC (theNPC:NonPlayerCharacter) {
        
        splitTextIntoFields(theText: theNPC.speak())
        theNPC.contactPlayer()
        rememberThis(withThing: theNPC.name!, remember: "alreadyContacted")
        
        if(theNPC.speechIcon != "") {
            
            showIcon(theTexture: theNPC.speechIcon)
            
        }
     
    }
    
    func endContactWithItem (theItem:WorldItem) {
        
        fadeOutInfoText(waitTime: theItem.infoTime)
        
        if (self.childNode(withName: theItem.name! + "Timer") == nil) {
            
            self.childNode(withName: theItem.name! + "Timer")?.removeAllActions()   
            self.childNode(withName: theItem.name! + "Timer")?.removeFromParent()
            
        }
        
    }
    
    func usePortalInCurrentLevel(toWhere:String, delay:TimeInterval) {
        
        thePlayer.isHidden = true
        
        let wait:SKAction = SKAction.wait(forDuration: delay)
        let portalAction:SKAction = SKAction.run {
            
            //somewhere else in level
            if(self.childNode(withName: toWhere) != nil) {
                
                self.thePlayer.removeAllActions()
                let newLocation:CGPoint = (self.childNode(withName: toWhere)?.position)!
                self.thePlayer.run(SKAction.move(to: newLocation, duration: delay))
                
            }
            
            self.thePlayer.isHidden = false
        }
        
        self.run(SKAction.sequence([wait, portalAction]))
        
    }
    
    func usePortalToLevel(theLevel:String, toWhere:String, delay:TimeInterval) {
        
        thePlayer.isHidden = true
        
        let wait:SKAction = SKAction.wait(forDuration: delay)
        let portalAction:SKAction = SKAction.run {
        
            if(toWhere != "") {
                
                self.loadLevel(theLevel: theLevel, toWhere: toWhere)
                self.defaults.set(toWhere, forKey: "ContinueWhere")
                
            } else {
                
                self.loadLevel(theLevel: theLevel, toWhere: "")
                
            }
        }
        
        let seq:SKAction = SKAction.sequence([wait, portalAction])
        self.run(seq)
    }
    
    
    func contactWithItem (theItem:WorldItem) {
        print ("contactWithItem: \(theItem.name!)")
        
        splitTextIntoFields(theText: theItem.getInfo())
        
        if (!theItem.isOpen) {
            
            if(theItem.lockedIcon != "") {
                
                showIcon(theTexture: theItem.lockedIcon)
                
            }
            
            if (theItem.timeToOpen > 0) {
                thePlayer.removeAllActions()
                showTimer(theAnimation: theItem.timerName, time:theItem.timeToOpen, theItem:theItem)
            }
            
        } else if(theItem.isOpen) {
            
            if(theItem.openIcon != "") {
                
                showIcon(theTexture: theItem.openIcon)
                
            }
            
            if(theItem.rewardDictionary.count > 0) {
                
                sortRewards(rewards: theItem.rewardDictionary)
                theItem.rewardDictionary.removeAll()
            
            }
            
            //portal code
            if (theItem.isPortal) {
                
                if(theItem.portalToLevel != "") {
                    
                    //go other level
                    usePortalToLevel(theLevel: theItem.portalToLevel, toWhere: theItem.portalToWhere, delay: theItem.portalDelay)
                    
                } else if(theItem.portalToWhere != "") {
                    
                    usePortalInCurrentLevel(toWhere: theItem.portalToWhere, delay: theItem.portalDelay)
                    
                }
            }//item is portal
            
            theItem.afterOpenContact()
            
        } //item is open
      
        
    }


}
