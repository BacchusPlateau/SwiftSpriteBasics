//
//  SharedHelpers.swift
//  PlayAround
//
//  Created by Bret Williams on 1/20/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

class SharedHelpers {
    
    
    static func checkIfSKSExists( baseSKSName:String) -> String {
        
        var fullSKSNameToLoad:String = baseSKSName
        
        if( UIDevice.current.userInterfaceIdiom == .pad) {
            
            if let _ = GameScene(fileNamed: baseSKSName + "Pad") {
                fullSKSNameToLoad = baseSKSName + "Pad"
            }
            
        } else if (UIDevice.current.userInterfaceIdiom == .phone ) {
            if let _ = GameScene(fileNamed: baseSKSName + "Phone") {
                fullSKSNameToLoad = baseSKSName + "Phone"
            }
        }
        
        return fullSKSNameToLoad
    }
    
    
}
