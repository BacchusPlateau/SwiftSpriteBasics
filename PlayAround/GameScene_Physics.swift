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
        
        if(contact.bodyA.categoryBitMask == BodyType.player.rawValue && contact.bodyB.categoryBitMask == BodyType.building.rawValue)
        {
            //print ("touched a building")
        } else if(contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.building.rawValue)
        {
            //  print ("touched a building")
        }else if(contact.bodyA.categoryBitMask == BodyType.player.rawValue && contact.bodyB.categoryBitMask == BodyType.castle.rawValue)
        {
            // print ("touched a castle")
            
                loadLevel(theLevel: "Dungeon")
       
            
        }else if(contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.castle.rawValue)
        {
            // print ("touched a castle")
           
                loadLevel(theLevel: "Dungeon")
         
        }
        else if(contact.bodyA.categoryBitMask == BodyType.player.rawValue && contact.bodyB.categoryBitMask == BodyType.npc.rawValue)
        {
            if let theNPC:NonPlayerCharacter = contact.bodyB.node as? NonPlayerCharacter {
                splitTextIntoFields(theText: theNPC.speak())
                theNPC.contactPlayer()
                speechIcon.isHidden = false
                speechIcon.texture = SKTexture(imageNamed: theNPC.speechIcon)
            }
        }else if(contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.npc.rawValue)
        {
            if let theNPC:NonPlayerCharacter = contact.bodyA.node as? NonPlayerCharacter {
                splitTextIntoFields(theText: theNPC.speak())
                theNPC.contactPlayer()
                speechIcon.isHidden = false
                speechIcon.texture = SKTexture(imageNamed: theNPC.speechIcon)
            }
        }
        
        /////
        
        if(contact.bodyA.categoryBitMask == BodyType.attackArea.rawValue && contact.bodyB.categoryBitMask == BodyType.castle.rawValue) {
            
            contact.bodyB.node?.removeFromParent()
            
        } else if(contact.bodyA.categoryBitMask == BodyType.castle.rawValue && contact.bodyB.categoryBitMask == BodyType.attackArea.rawValue) {
            
            contact.bodyA.node?.removeFromParent()
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
    
   


}
