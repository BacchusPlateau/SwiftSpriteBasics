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
    
    func setUp() {
        
        
    }
    
    func setUpWithDict( theDict : [String : Any ]) {
        
        for (key, value) in theDict {
            
            if (key == "PortalTo") {
                
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
    
}
