//
//  GameScene_Inventory.swift
//  PlayAround
//
//  Created by Bret Williams on 2/10/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene {

    func sortRewards( rewards: [String:Any]) {
        
        for (key, value) in rewards {
            
            switch key {
            case "Health":
                continue
            case "Weapon":
                continue
            case "Currency":
                continue
            case "Class":
                continue
            default:
                if (value is Int) {
                    
                    addToInventory(newInventory: key, amount: value as! Int)
                    
                }
            }
            
        }
        
    }
    
    
    func addToInventory (newInventory:String, amount:Int) {
        
        if(defaults.integer(forKey: newInventory) != 0) {
            
            let currentAmount:Int = defaults.integer(forKey:newInventory)
            let newAmount:Int = currentAmount + amount
            
            print ("set \(newAmount) for \(newInventory)")
            
            defaults.set(newAmount, forKey:newInventory)
            checkForItemThatMightOpen(newInventory: newInventory, amount: newAmount)
            
        } else {
            
            print ("set \(amount) for \(newInventory)")
            
            defaults.set(amount, forKey:newInventory)
            checkForItemThatMightOpen(newInventory: newInventory, amount: amount)
            
        }
        
    }
    
    func checkForItemThatMightOpen( newInventory:String, amount:Int) {
        
        for node in self.children {
            
            if let theItem:WorldItem = node as? WorldItem {
                
                if (!theItem.isOpen) {
                    
                    if (newInventory == theItem.requiredThing) {
                        
                        if (amount >= theItem.requiredAmount) {
                            
                            if (theItem.unlockedTextArray.count > 0) {
                                
                                splitTextIntoFields(theText: theItem.getUnlockedInfo())
                                theItem.open()
                                
                                if(theItem.unlockedIcon != "") {
                                    
                                    showIcon(theTexture: theItem.unlockedIcon)
                                    
                                }
                            }
                            
                        }
                    }
                }
            }
        }
        
        
    }




}
