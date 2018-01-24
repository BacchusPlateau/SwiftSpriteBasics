//
//  GameScene_Helpers.swift
//  PlayAround
//
//  Created by Bret Williams on 1/20/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//
import Foundation
import SpriteKit

extension GameScene {

    func putWithinRange(nodeName: String) -> CGPoint {
        
        var somePoint = CGPoint.zero
        
        for node in self.children {
            
            if(node.name == nodeName) {
                
                if let rangeNode:SKSpriteNode = node as? SKSpriteNode {
                    
                    let widthVar:UInt32 = UInt32(rangeNode.frame.size.width)
                    let heightVar:UInt32 = UInt32(rangeNode.frame.size.height)
                    let randomX = arc4random_uniform( widthVar )
                    let randomY = arc4random_uniform( heightVar )
                    let frameStartX = rangeNode.position.x - (rangeNode.size.width / 2)
                    let frameStartY = rangeNode.position.y - (rangeNode.size.height / 2)
                    
                    somePoint = CGPoint(x: frameStartX + CGFloat(randomX), y:frameStartY + CGFloat(randomY))
                }
                break
            }
        }
        
        return somePoint
        
    }
    
    
    func splitTextIntoFields(theText:String) {
        
        let maxInOneLine:Int = 25
        var i:Int = 0
        var line1:String = ""
        var line2:String = ""
        var useLine2:Bool = false
        
        
        
        for char in theText {
            
            if( i > maxInOneLine && String(char) == " ") {
                useLine2 = true
            }
            
            if(useLine2 == false) {
                line1 = line1 + String(char)
            } else {
                line2 = line2 + String(char)
            }
            
            i+=1
            
        }
        
        
        print ("i = " + String(i))
        
        
        infoLabel1.text = line1
        infoLabel2.text = line2
    }
    
    
    func loadLevel(theLevel:String) {
        
        if(transitionInProgress == false) {
            
            transitionInProgress = true
            
            let fullSKSNameToLoad:String = SharedHelpers.checkIfSKSExists(baseSKSName: theLevel)
            
            
            if let scene = GameScene(fileNamed: fullSKSNameToLoad) {
                
                //cleanUpScene()
                
                scene.currentLevel = theLevel
                scene.scaleMode = .aspectFill
                
                let transition:SKTransition = SKTransition.fade(with:SKColor.black, duration:2)
                
                self.view?.presentScene(scene, transition:transition)
                
            }
            else {
                print("Couldnt find " + theLevel)
            }
        }
        
    }
    
    func rememberThis(withThing:String, remember:String) {
        
        defaults.set(true, forKey: currentLevel + withThing + remember)
        
        //"GrasslandVillager1alreadyContacted
        
    }

}
