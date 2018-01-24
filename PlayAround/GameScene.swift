//
//  GameScene.swift
//  PlayAround
//
//  Created by Bret Williams on 12/27/17.
//  Copyright © 2017 Bret Williams. All rights reserved.
//

import SpriteKit
import GameplayKit

enum BodyType:UInt32 {
    case player = 1
    case building = 2
    case castle = 4
    case attackArea = 8
    case npc = 16
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var thePlayer:SKSpriteNode = SKSpriteNode()
    var moveSpeed:TimeInterval = 1
    let swipeRightRec = UISwipeGestureRecognizer()
    let swipeLeftRec = UISwipeGestureRecognizer()
    let swipeUpRec = UISwipeGestureRecognizer()
    let swipeDownRec = UISwipeGestureRecognizer()
    let rotateRec = UIRotationGestureRecognizer()
    let tapRec = UITapGestureRecognizer()
    public var currentLevel:String = ""
    
    var infoLabel1:SKLabelNode = SKLabelNode()
    var infoLabel2:SKLabelNode = SKLabelNode()
    var speechIcon:SKSpriteNode = SKSpriteNode()
    var isCollidable:Bool = false
    var transitionInProgress:Bool = false
    
    let defaults:UserDefaults = UserDefaults.standard
    
    override func didMove(to view: SKView) {
        
        parsePropertyList()
        self.physicsWorld.contactDelegate = self
    
        self.enumerateChildNodes(withName: "//*") {
            node, stop in
        
            if let theCamera:SKCameraNode = node as? SKCameraNode {
      
                self.camera = theCamera
                
                if(theCamera.childNode(withName: "InfoLabel1") is SKLabelNode) {
                    self.infoLabel1 = theCamera.childNode(withName: "InfoLabel1") as! SKLabelNode
                    self.infoLabel1.text = ""
                }
                if(theCamera.childNode(withName: "InfoLabel2") is SKLabelNode) {
                    self.infoLabel2 = theCamera.childNode(withName: "InfoLabel2") as! SKLabelNode
                    self.infoLabel2.text = ""
                }
                if(theCamera.childNode(withName: "VillagerIcon") is SKSpriteNode) {
                    self.speechIcon = theCamera.childNode(withName: "VillagerIcon") as! SKSpriteNode
                    self.speechIcon.isHidden = true
                }
                
                stop.pointee = true  //halt transversal of node tree
            }
        }
        
        tapRec.addTarget(self, action: #selector(GameScene.tappedView))
        tapRec.numberOfTapsRequired = 1
        tapRec.numberOfTouchesRequired = 1
        self.view!.addGestureRecognizer(tapRec)
 
        swipeRightRec.addTarget(self, action: #selector(GameScene.swipedRight))
        swipeRightRec.direction = .right
        self.view!.addGestureRecognizer(swipeRightRec)
        
        swipeLeftRec.addTarget(self, action: #selector(GameScene.swipedLeft))
        swipeLeftRec.direction = .left
        self.view!.addGestureRecognizer(swipeLeftRec)
        
        swipeDownRec.addTarget(self, action: #selector(GameScene.swipedDown))
        swipeDownRec.direction = .down
        self.view!.addGestureRecognizer(swipeDownRec)
        
        swipeUpRec.addTarget(self, action: #selector(GameScene.swipedUp))
        swipeUpRec.direction = .up
        self.view!.addGestureRecognizer(swipeUpRec)
        
        
        if let somePlayer:SKSpriteNode = self.childNode(withName: "Player") as? SKSpriteNode  {
            thePlayer = somePlayer
            thePlayer.physicsBody?.isDynamic = true
            thePlayer.physicsBody?.affectedByGravity = false
            thePlayer.physicsBody?.categoryBitMask = BodyType.player.rawValue
            thePlayer.physicsBody?.collisionBitMask = BodyType.castle.rawValue
            thePlayer.physicsBody?.contactTestBitMask = BodyType.castle.rawValue | BodyType.building.rawValue
        }
        
        for node in self.children {
            if(node.name == "Barrier") {
                if(node is SKSpriteNode) {
                    node.physicsBody?.categoryBitMask = BodyType.building.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    print ("found a barrier")
                }
            }
            
            if let aCastle:Castle = node as? Castle {
                aCastle.setUpCastle()
                break
            }
        }
    }
    

    override func update(_ currentTime: TimeInterval) {
        
        for node in self.children {
            if(node.name == "Barrier") {
               
                if(node.position.y > thePlayer.position.y) {
                    node.zPosition = -100
                } else {
                    node.zPosition = 100
                }
            }
        }
        
        self.camera?.position = thePlayer.position
       
    }

}
