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
                splitTextIntoFields(theText: theNPC.speak())
                theNPC.contactPlayer()
                rememberThis(withThing: theNPC.name!, remember: "alreadyContacted")
                speechIcon.isHidden = false
                speechIcon.texture = SKTexture(imageNamed: theNPC.speechIcon)
            }
        }else if(contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.npc.rawValue)
        {
            if let theNPC:NonPlayerCharacter = contact.bodyA.node as? NonPlayerCharacter {
                splitTextIntoFields(theText: theNPC.speak())
                theNPC.contactPlayer()
                rememberThis(withThing: theNPC.name!, remember: "alreadyContacted")
                speechIcon.isHidden = false
                speechIcon.texture = SKTexture(imageNamed: theNPC.speechIcon)
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
                theNPC.endContactPlayer()
                infoLabel1.text = ""
                infoLabel2.text = ""
                speechIcon.isHidden = true
            }
        }else if(contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.npc.rawValue)
        {
            if let theNPC:NonPlayerCharacter = contact.bodyA.node as? NonPlayerCharacter {
                theNPC.endContactPlayer()
                infoLabel1.text = ""
                infoLabel2.text = ""
                speechIcon.isHidden = true
            }
        }
    }
    
    func contactWithItem (theItem:WorldItem) {
        
        if(theItem.isPortal) {
            if(theItem.portalToLevel != "") {
                //go other level
                
                if(theItem.portalToWhere != "") {
                    
                    loadLevel(theLevel: theItem.portalToLevel, toWhere: theItem.portalToWhere)
                    defaults.set(theItem.portalToWhere, forKey: "ContinueWhere")
                    
                    
                } else {
                    
                    loadLevel(theLevel: theItem.portalToLevel, toWhere: "")
                }
                
            } else if(theItem.portalToWhere != ""){
                //somewhere else in level
                if(self.childNode(withName: theItem.portalToWhere) != nil) {
                    thePlayer.removeAllActions()
                    let newLocation:CGPoint = (self.childNode(withName: theItem.portalToWhere)?.position)!
                    thePlayer.run(SKAction.move(to: newLocation, duration: 0.0))
           
                    
                }
            }
        }
        
    }


}
