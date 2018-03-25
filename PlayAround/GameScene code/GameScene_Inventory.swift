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
                
                if (value is Int) {
                    addToHealth(amount: value as! Int)
                }
                
            case "Armor":
                
                if (value is Int) {
                    addToArmor(amount: value as! Int)
                }
                
            case "Projectile":
                continue
            case "XP":
                
                if (value is Int) {
                    addToXP(amount: value as! Int)
                }
                
            case "Currency":
                
                if (value is Int) {
                    addCurrency(amount: value as! Int)
                }
                
            case "Class":
                
                if (value is String) {
                    parsePropertyListForPlayerClass(name: value as! String)
                }
                
                
            default:
                if (value is Int) {
                    
                    addToInventory(newInventory: key, amount: value as! Int)
                    
                }
            }
            
        }
        
    }
    
    func addToHealth(amount:Int) {
        
        currentHealth += amount
        if (currentHealth > thePlayer.health) {
            currentHealth = thePlayer.health
        }
        setHealthLabel()
        
    }
    
    func addToArmor(amount:Int) {
        
        currentArmor += amount
        if (currentArmor > thePlayer.armor) {
            currentArmor = thePlayer.armor
        }
        setArmorLabel()
        
    }
    
    func addCurrency(amount:Int) {
        
        currency += amount
        defaults.set(currency, forKey:"Currency")
        setCurrencyLabel()
        
    }
    
    func addToXP(amount:Int) {
        
        currentXP += amount
        if (currentXP >= maxXP) {
            
            xpLevel += 1
            retrieveXPData()
            currentXP = 0
            defaults.set(xpLevel, forKey: "XPLevel")
        }
        
        defaults.set(currentXP, forKey: "CurrentXP")
        setXPLabel()
        
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

    func populateStats() {
        
        if (defaults.integer(forKey: "CurrentHealth") != 0) {
            currentHealth = defaults.integer(forKey: "CurrentHealth")
        } else {
            currentHealth = thePlayer.health
            defaults.set(currentHealth, forKey: "CurrentHealth")
        }
        
        if (defaults.integer(forKey: "CurrentArmor") != 0) {
            currentHealth = defaults.integer(forKey: "CurrentArmor")
        } else {
            currentArmor = thePlayer.armor
        }
        if (defaults.integer(forKey: "Currency") != 0) {
            currency = defaults.integer(forKey: "Currency")
        } else {
            currency = 0
        }
        if (defaults.integer(forKey: "XPLevel") != 0) {
            xpLevel = defaults.integer(forKey: "XPLevel")
        } else {
            xpLevel = 0
        }
        if (defaults.integer(forKey: "CurrentXP") != 0) {
            currentXP = defaults.integer(forKey: "CurrentXP")
        } else {
            currentXP = 0
        }
        
        retrieveXPData()
        
        setXPLabel()
        setHealthLabel()
        setArmorLabel()
        setCurrencyLabel()
        
    }
    
    func setClassLabel() {
        
        if (defaults.string(forKey: "PlayerClass") != nil) {
            classLabel.text = defaults.string(forKey: "PlayerClass")
        }
        
    }
    
    
    func setXPLabel() {
        
        xpLabel.text = String(currentXP) + "/" + String(maxXP)
    }
    
    func setCurrencyLabel()  {
        
        currencyLabel.text = String(currency)
    }
    
    
    func setArmorLabel() {
        
        armorLabel.text = String(currentArmor) + "/" + String(thePlayer.armor)
        
    }
    
    func setHealthLabel() {
        
        healthLabel.text = String(currentHealth) + "/" + String(thePlayer.health)
        
    }
    
    func retrieveXPData() {
        
        if (xpArray.count == 0 || xpLevel >= xpArray.count) {
            return
        }
        
        let xpDict:[String:Any] = xpArray[xpLevel]
        
        for (key,value) in xpDict {
            
            switch key {
            case "Name":
                if (value is String) {
                    xpLevelLabel.text = value as? String
                }
            case "Max":
                if(value is Int) {
                    maxXP = value as! Int
                }
            default:
                continue
            }
            
        }
        
    }


}
