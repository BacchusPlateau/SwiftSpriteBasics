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
    public var currentLevel:String = "Grassland"
    
    override func didMove(to view: SKView) {
        
        parsePropertyList()
        self.physicsWorld.contactDelegate = self
        
       // self.physicsWorld.gravity = CGVector(dx: 1, dy: 0)
        /*
        rotateRec.addTarget(self, action: #selector(GameScene.rotatedView (_:)))
        self.view!.addGestureRecognizer(rotateRec)
        */
        
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
    
    //MARK: Parse PList
    
    func parsePropertyList() {
        
        let path = Bundle.main.path(forResource:"GameData", ofType: "plist")
        let dict:NSDictionary = NSDictionary(contentsOfFile: path!)!
        if(dict.object(forKey: "Levels") != nil) {
            
            if let levelDict:[String : Any] = dict.object(forKey: "Levels") as? [String: Any]
            {
                for(key, value) in levelDict {
                    
                    if(key == currentLevel) {
                        
                        if let levelData:[String:Any] = value as? [String:Any] {
                            
                            for(key,value) in levelData {
                                if (key == "NPC") {
                                    
                                    createNPCwithDict(theDict:value as! [String:Any])
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    func createNPCwithDict( theDict: [String:Any]) {
        
        for(key, value) in theDict {
            
            var theBaseImage : String = ""
            var theRange : String = ""
            let nickName: String = key
            
            if let NPCData:[String : Any] = value as? [String : Any] {
                
                for (key, value) in NPCData {
                    
                    if (key == "BaseImage") {
                        
                        theBaseImage = value as! String
                        print (theBaseImage)
                    } else  if (key == "Range") {
                        
                        theRange = value as! String
                    }
                }
            }
            
            let newNPC:NonPlayerCharacter = NonPlayerCharacter(imageNamed: theBaseImage)
            newNPC.name = nickName
            newNPC.baseFrame = theBaseImage
            newNPC.setUpWithDict(theDict: value as! [String: Any])
            self.addChild(newNPC)
            newNPC.zPosition = thePlayer.zPosition - 1
            newNPC.position = putWithinRange(nodeName: theRange)
        }
    }

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
    
    
    // MARK: Attack
    func attack() {
        
        print ("attacking")
        
        let newAttack:AttackArea = AttackArea(imageNamed: "AttackCircle")
        newAttack.position = thePlayer.position
        newAttack.setUp()
        self.addChild(newAttack)
        newAttack.zPosition = thePlayer.zPosition - 1
        
        thePlayer.run(SKAction(named: "FrontAttack")!)
        
    }
    
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
       
    }
    
    func move(theXAmount:CGFloat, theYAmount:CGFloat, theAnimation:String) {
        
        let walkAction:SKAction = SKAction(named: theAnimation)!
        let moveAction:SKAction = SKAction.moveBy(x: theXAmount, y:theYAmount, duration: 1)
      
        let group:SKAction = SKAction.group([walkAction, moveAction])
        
        thePlayer.run(group)
        
        print (theAnimation)
    }
    
    func ZmoveDown() {
        
       // thePlayer.physicsBody?.isDynamic = true
       // thePlayer.physicsBody?.affectedByGravity = false
        
        let walkAction:SKAction = SKAction(named: "WalkForward")!
        let moveAction:SKAction = SKAction.moveBy(x: 0, y:-100, duration: 1)
        let wait:SKAction = SKAction.wait(forDuration: 0.05)
        
        let group:SKAction = SKAction.group([walkAction, moveAction])
        let finish:SKAction = SKAction.run {
            print("finish")
            self.thePlayer.physicsBody?.isDynamic = false
            self.thePlayer.physicsBody?.affectedByGravity = false
        }
        
        let seq:SKAction = SKAction.sequence( [wait,group, finish])
        
        thePlayer.run(seq)
    }
    
    func touchDown(atPoint pos : CGPoint) {
       
        print ("(\(pos.x),\(pos.y))")
        
        if ( pos.y > 0) {
            
            if (pos.x > 0) {
                print ("quadrant 1")
            } else {
                print ("quadrant 2")
            }
            
        } else {
            // y < 0
            if (pos.x > 0) {
                print ("quadrant 4")
            } else {
                print ("quadrant 3")
            }
        }
        
     // swipedRight()
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
      //  swipedRight()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            
            self.touchDown(atPoint: t.location(in: self))
            break
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    //MARK: Physics contacts
    
    func didBegin(_ contact: SKPhysicsContact) {
      
        if(contact.bodyA.categoryBitMask == BodyType.player.rawValue && contact.bodyB.categoryBitMask == BodyType.building.rawValue)
        {
            //print ("touched a building")
        } else if(contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.building.rawValue)
        {
          //  print ("touched a building")
        }else if(contact.bodyA.categoryBitMask == BodyType.player.rawValue && contact.bodyB.categoryBitMask == BodyType.castle.rawValue)
        {
           // print ("touched a castle")
        }else if(contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.castle.rawValue)
        {
           // print ("touched a castle")
        }
        else if(contact.bodyA.categoryBitMask == BodyType.player.rawValue && contact.bodyB.categoryBitMask == BodyType.npc.rawValue)
        {
            if let theNPC:NonPlayerCharacter = contact.bodyB.node as? NonPlayerCharacter {
                theNPC.contactPlayer()
            }
        }else if(contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.npc.rawValue)
        {
            if let theNPC:NonPlayerCharacter = contact.bodyA.node as? NonPlayerCharacter {
                theNPC.contactPlayer()
            }
        }
        
        /////
        
        if(contact.bodyA.categoryBitMask == BodyType.attackArea.rawValue && contact.bodyB.categoryBitMask == BodyType.castle.rawValue) {
            
            contact.bodyB.node?.removeFromParent()
            
        } else if(contact.bodyA.categoryBitMask == BodyType.castle.rawValue && contact.bodyB.categoryBitMask == BodyType.attackArea.rawValue) {
        
            contact.bodyA.node?.removeFromParent()
        }
    }
    
    
    func didEnd(_ contact: SKPhysicsContact) {
        if(contact.bodyA.categoryBitMask == BodyType.player.rawValue && contact.bodyB.categoryBitMask == BodyType.npc.rawValue)
        {
            if let theNPC:NonPlayerCharacter = contact.bodyB.node as? NonPlayerCharacter {
                theNPC.endContactPlayer()
            }
        }else if(contact.bodyB.categoryBitMask == BodyType.player.rawValue && contact.bodyA.categoryBitMask == BodyType.npc.rawValue)
        {
            if let theNPC:NonPlayerCharacter = contact.bodyA.node as? NonPlayerCharacter {
                theNPC.endContactPlayer()
            }
        }
    }
    
    
    
    
    
    
    
}
