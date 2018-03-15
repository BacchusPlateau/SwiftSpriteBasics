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
    case item = 2
    case attackArea = 4
    case npc = 8
}

enum Facing:Int {
    
    case front, back, left, right
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var thePlayer:Player = Player()
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
    
    var cameraFollowsPlayer:Bool = true
    var cameraXOffset:CGFloat = 0
    var cameraYOffset:CGFloat = 0
    var disableAttack:Bool = false
    
    var entryNode:String = ""
    
    var rewardDict = [String:Any]()
    var clearArray = [String]()
    
    var playerUsingPortal:Bool = false
    
    var pathArray = [CGPoint]()
    var currentOffset:CGPoint = CGPoint.zero
    
    var playerFacing:Facing = .front
    var playerLastLocation:CGPoint = CGPoint.zero
    
    var walkTime:TimeInterval = 0
    
    var attackAnywhere:Bool = false
    var pathAlpha:CGFloat = 0.3
    var walkWithPath:Bool = false
    var touchingDown:Bool = false
    var touchDownSprite:SKSpriteNode = SKSpriteNode()
    var touchFollowSprite:SKSpriteNode = SKSpriteNode()
    var offsetFromTouchDownToPlayer:CGPoint = CGPoint.zero
    
    var hasCustomPadScene:Bool = false
    
    override func didMove(to view: SKView) {
        
        parsePropertyList()
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx:0, dy:0)
        
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
                if(UIDevice.current.userInterfaceIdiom == .pad && !self.hasCustomPadScene) {
                    
                    print("no custom iPad SKS file, do our own adjustments")
                    theCamera.xScale = 1.5
                    theCamera.yScale = 1.5
                 
                    for node in theCamera.children {
                        
                        if (node.position.y > 0) {
                            node.position.y -= 100
                        } else {
                            node.position.y += 100
                        }
                    }
                }
                
                
                stop.pointee = true  //halt transversal of node tree
            }
        }
        
        tapRec.addTarget(self, action: #selector(GameScene.tappedView))
        tapRec.numberOfTapsRequired = 1
        tapRec.numberOfTouchesRequired = 1
        self.view!.addGestureRecognizer(tapRec)
 
        /*
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
        */
        
        if let somePlayer:Player = self.childNode(withName: "Player") as? Player  {
            thePlayer = somePlayer
            thePlayer.physicsBody?.isDynamic = true
            thePlayer.physicsBody?.affectedByGravity = false
            thePlayer.physicsBody?.categoryBitMask = BodyType.player.rawValue
            thePlayer.physicsBody?.collisionBitMask = BodyType.item.rawValue
            thePlayer.physicsBody?.contactTestBitMask = BodyType.item.rawValue
            thePlayer.zPosition = 0
            
            if(defaults.string(forKey: "PlayerClass") == nil) {
                
                defaults.set("Starting", forKey:"PlayerClass")
                parsePropertyListForPlayerClass(name:"Starting")
                
            } else {
                
                parsePropertyListForPlayerClass(name: defaults.string(forKey: "PlayerClass")!)
            }
            
            if (entryNode != "") {
                
                if(self.childNode(withName: entryNode) != nil) {
                    
                    thePlayer.position = (self.childNode(withName: entryNode)?.position)!
                    
                }
            }
        }
        
        for node in self.children {
         
            if let someItem:WorldItem = node as? WorldItem {
                setUpItem(theItem:someItem)
            }
        }
        
        clearStuff(theArray:clearArray)
        
        sortRewards(rewards:rewardDict)
    }
    

    override func update(_ currentTime: TimeInterval) {
        
        
        if (cameraFollowsPlayer) {
            
            self.camera?.position = CGPoint(x: thePlayer.position.x + cameraXOffset, y: thePlayer.position.y + cameraYOffset)
        }
        
        for node in self.children {
            
            if (node is AttackArea) {
                
                node.position = thePlayer.position
            }
            
            else if (node is SKSpriteNode) {
                
                if(node.physicsBody == nil) {
                   
                    if(node.position.y > thePlayer.position.y) {
                        node.zPosition = -100
                    } else {
                        node.zPosition = 100
                    }
                }
                
            }
        }
        
        if (walkWithPath) {
            playerUpdate()
        } else {
            playerUpdateSansPath()
        }
        
    }

}
