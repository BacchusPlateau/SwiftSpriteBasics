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
    
    @objc func tappedView() {
        
        attack()
        
        
    }
    
    @objc func rotatedView(_ sender:UIRotationGestureRecognizer) {
        
        if(sender.state == .began) {
            
            print("rotation began")
        }
        
        if(sender.state == .changed ) {
            
            print("rotation changed")
            print(sender.rotation)
        }
        
        if(sender.state == .ended) {
            
            print("rotation ended")
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
