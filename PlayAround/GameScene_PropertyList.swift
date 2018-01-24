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
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    func createNPCwithDict( theDict: [String:Any]) {
        
        for(key, value) in theDict {
            
            var theBaseImage : String = ""
            var theRange : String = ""
            let nickName: String = key
            
            if let NPCData:[String : Any] = value as? [String : Any] {
                
                for (key, value) in NPCData {
                    
                    if (key == "BaseImage") {
                        
                        theBaseImage = value as! String
                        print (theBaseImage)
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
