//
//  GameScene_PropertyList.swift
//  PlayAround
//
//  Created by Bret Williams on 1/20/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene {

    //MARK: Parse PList
    
    func parsePropertyList() {
        
        let path = Bundle.main.path(forResource:"GameData", ofType: "plist")
        let dict:NSDictionary = NSDictionary(contentsOfFile: path!)!
        if(dict.object(forKey: "Levels") != nil) {
            
            if let levelDict:[String : Any] = dict.object(forKey: "Levels") as? [String: Any]
            {
                for(key, value) in levelDict {
                    
                    if(key == currentLevel) {
                        
                        if let levelData:[String:Any] = value as? [String:Any] {
                            
                            for(key,value) in levelData {
                                if (key == "NPC") {
                                    
                                    createNPCwithDict(theDict:value as! [String:Any])
                                }
                                
                                if (key == "Properties") {
                                    
                                    parseLevelSpecificProperties(theDict:value as! [String:Any])
                                }
                                
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    func parseLevelSpecificProperties ( theDict: [String:Any]) {
        
        for(key, value) in theDict {
         //   print (key)
            switch key {
            case "CameraFollowsPlayer":
                if(value is Bool) {
                    cameraFollowsPlayer = value as! Bool
                }
            case "CameraOffset":
                if(value is String) {
                    let somePoint:CGPoint = CGPointFromString(value as! String)
                    cameraXOffset = somePoint.x
                    cameraYOffset = somePoint.y
                }
            case "ContinuePoint":
             //   print ("here")
                if(value is Bool) {
                    if(value as! Bool == true) {
                        defaults.set(currentLevel, forKey: key)
                //        print(currentLevel + " " + key)
                    }
                }
                
            case "DisableAttack":
                if(value is Bool) {
                    if(value as! Bool == true) {
                        disableAttack = value as! Bool
                    }
                }
            default:
                continue
            }
        }
        
    }
    
    func createNPCwithDict( theDict: [String:Any]) {
        
        for(key, value) in theDict {
            
            var theBaseImage : String = ""
            var theRange : String = ""
            let nickName: String = key
            
            var alreadyFoundNPCinScene:Bool = false
            
            for node in self.children {
                
                if(node.name == key) {
                    
                    if (node is NonPlayerCharacter) {
                        
                        useDictWithNPC(theDict: value as! [String:Any], theNPC: node as! NonPlayerCharacter)
                        alreadyFoundNPCinScene = true
                        
                    }
                }
            }
            
            if(!alreadyFoundNPCinScene) {
                
                if let NPCData:[String:Any] = value as? [String:Any] {
                    for (key,value) in NPCData {
                        if(key == "BaseImage") {
                            theBaseImage = value as! String
                        } else if (key == "Range") {
                            theRange = value as! String
                        }
                    }
                }
            
            
                if let NPCData:[String : Any] = value as? [String : Any] {
                    
                    for (key, value) in NPCData {
                        
                        if (key == "BaseImage") {
                            
                            theBaseImage = value as! String
            
                        } else  if (key == "Range") {
                            
                            theRange = value as! String
                        }
                    }
                }
                
                let newNPC:NonPlayerCharacter = NonPlayerCharacter(imageNamed: theBaseImage)
                newNPC.name = nickName
                newNPC.baseFrame = theBaseImage
                newNPC.setUpWithDict(theDict: value as! [String: Any])
                self.addChild(newNPC)
                newNPC.zPosition = thePlayer.zPosition - 1
                newNPC.position = putWithinRange(nodeName: theRange)
                newNPC.alreadyContacted = defaults.bool(forKey: currentLevel + nickName + "alreadyContacted")
            }
        }
    }
    
    func useDictWithNPC(theDict:[String:Any], theNPC:NonPlayerCharacter) {
        
        theNPC.setUpWithDict(theDict: theDict)
        
        for (key,value) in theDict {
            
            if (key == "Range") {
                
                theNPC.position = putWithinRange(nodeName: value as! String)
                
            }
        }
        
        theNPC.alreadyContacted = defaults.bool(forKey: currentLevel + theNPC.name! + "alreadyContacted")
        
    }
    
    func setUpItem(theItem:WorldItem) {
        
        let path = Bundle.main.path(forResource:"GameData", ofType: "plist")
        let dict:NSDictionary = NSDictionary(contentsOfFile: path!)!
        var foundItemInLevel:Bool = false
        
        if(dict.object(forKey: "Levels") != nil) {
            
            if let levelDict:[String : Any] = dict.object(forKey: "Levels") as? [String: Any]
            {
                for(key, value) in levelDict {
                    
                    if(key == currentLevel) {
                        
                        if let levelData:[String:Any] = value as? [String:Any] {
                            
                            for(key,value) in levelData {
                                if (key == "Items")  {
                                    
                                    if let itemsData:[String:Any] = value as? [String:Any] {
                                        for(key,value) in itemsData {
                                            
                                            if(key==theItem.name) {
                                                foundItemInLevel = true
                                                
                                                useDictWithWorldItem(theDict: value as! [String:Any], theItem: theItem)
                                                
                                                print ("found \(key) to setup with propertylist data")
                                                break
                                            }
                                            
                                        }
                                    }
                                }
                                break
                            }
                        }
                        break
                    }
                    
                }
                
            }
        }
        
        if(foundItemInLevel == false) {
            
            if(dict.object(forKey: "Items") != nil) {
                
                if let itemsData:[String : Any] = dict.object(forKey: "Items") as? [String: Any]
                {
                    
                    for(key,value) in itemsData {

                        if(key==theItem.name) {
                            
                            useDictWithWorldItem(theDict: value as! [String:Any], theItem: theItem)
                            
                         //   print ("found \(key) to setup with propertylist data in Root")
                            break
                        }
                        
  
                    }
                }
            }
        }
    }
    
    func useDictWithWorldItem( theDict:[String:Any], theItem:WorldItem)     {
        
        theItem.setUpWithDict(theDict: theDict)
        
        
        
    }
    
}