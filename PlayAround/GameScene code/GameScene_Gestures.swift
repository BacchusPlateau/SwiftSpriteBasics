//
//  GameScene_Gestures.swift
//  PlayAround
//
//  Created by Bret Williams on 1/20/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene {
    
    
    func cleanUp() {
        
        for gesture in (self.view?.gestureRecognizers)! {
            self.view?.removeGestureRecognizer(gesture)
        }
    }
    
    @objc func tappedView(_ sender:UITapGestureRecognizer) {
        
        let point:CGPoint = sender.location(in: self.view)
        //print(point)
        
        if(!disableAttack) {
            if(attackAnywhere) {
                
                attack()
                
            } else {
                
                if(point.x > self.view!.bounds.width / 2)  { //to the right
                
                    attack()
                }
                
            }
        }
      
    }
    
    @objc func tappedViewDouble(_ sender:UITapGestureRecognizer) {
        
        print("tappedViewDouble")
        
        let point:CGPoint = sender.location(in: self.view)
        var proceedToAttack:Bool = false
        
        if(!disableAttack) {
            if(attackAnywhere) {
                
                proceedToAttack = true
                
            } else {
                
                if(point.x > self.view!.bounds.width / 2)  { //to the right
                    
                    proceedToAttack = true
                }
                
            }
        }
        
        if(proceedToAttack) {
            
            if(thePlayer.currentProjectile != "") {
                
                if(prevPlayerProjectileName == thePlayer.currentProjectile) {
                    
                    //create ranged attack
                    print ("reusing existing projectile")
                    rangedAttack(withDict: prevPlayerProjectileDict)
                    
                } else {
                    
                    for (key, value) in projectilesDict {
                        
                        switch key {
                            
                        case thePlayer.currentProjectile:
                            print("found projectile data")
                            prevPlayerProjectileName = key
                            prevPlayerProjectileDict = value as! [String : Any]
                            
                            for (k,v) in prevPlayerProjectileDict {
                                
                                if (k == "Image") {
                                    
                                    if (v is String) {
                                        
                                        prevPlayerProjectileImageName = v as! String
                                        
                                    }
                                    break
                                }
                            }
                            
                        default:
                            continue
                        }
                        
                        //create ranged attack
                        rangedAttack(withDict: prevPlayerProjectileDict)
                        break
                        
                    }
                    
                }
            }
            
        }
       
    }
    
    @objc func rotatedView(_ sender:UIRotationGestureRecognizer) {
        
        if(sender.state == .began) {
            
        }
        
        if(sender.state == .changed ) {
            
        
        }
        
        if(sender.state == .ended) {
      
        }
        
    }
    
    @objc func swipedDown() {
        
        move(theXAmount: 0, theYAmount: -100, theAnimation: "WalkForward")
        
    }
    
    
    @objc func swipedUp() {
        
        move(theXAmount: 0, theYAmount: 100, theAnimation: "WalkBackward")
        
    }
    
    @objc func swipedRight() {
        
        move(theXAmount: 100, theYAmount: 0, theAnimation: "WalkRight")
        
    }
    
    @objc func swipedLeft() {
        
        move(theXAmount: -100, theYAmount: 0, theAnimation: "WalkLeft")
        
    }
    
    
}
