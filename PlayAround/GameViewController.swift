//
//  GameViewController.swift
//  PlayAround
//
//  Created by Bret Williams on 12/27/17.
//  Copyright © 2017 Bret Williams. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    
    let defaults:UserDefaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var initialLevel:String = "Grassland"
        var initialEntryNode:String = ""
        
        if(defaults.object(forKey: "ContinuePoint") != nil) {
            initialLevel = defaults.string(forKey: "ContinuePoint")!
            
            if(defaults.object(forKey: "ContinueWhere") != nil) {
                initialEntryNode = defaults.string(forKey: "ContinueWhere")!
            }
        }
        
        
        let fullSKSNameToLoad:String = SharedHelpers.checkIfSKSExists(baseSKSName: initialLevel)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed: fullSKSNameToLoad) {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                scene.currentLevel = initialLevel
                scene.entryNode = initialEntryNode
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            view.showsPhysics = false
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
