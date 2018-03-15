//
//  GameScene_Player.swift
//  PlayAround
//
//  Created by Bret Williams on 1/20/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene {

    func move(theXAmount:CGFloat, theYAmount:CGFloat, theAnimation:String) {
        
        let walkAction:SKAction = SKAction(named: theAnimation)!
        let moveAction:SKAction = SKAction.moveBy(x: theXAmount, y:theYAmount, duration: 1)
        
        let group:SKAction = SKAction.group([walkAction, moveAction])
        
        thePlayer.run(group)
        
        print (theAnimation)
    }

    
    
    // MARK: Attack
    func attack() {
        
     //   print ("attacking")
        
        let newAttack:AttackArea = AttackArea(imageNamed: "AttackCircle")
        newAttack.position = thePlayer.position
        newAttack.scaleSize = thePlayer.meleeScaleSize
        newAttack.animationName = thePlayer.meleeAnimationFXName
        
        newAttack.setUp()
        self.addChild(newAttack)
        newAttack.zPosition = thePlayer.zPosition - 1
        
        var animationName : String = ""
        
        switch playerFacing {
            case .front :
                animationName = thePlayer.frontMelee
            case .back :
                animationName = thePlayer.backMelee
                newAttack.xScale = -1
                newAttack.yScale = -1
            case .left :
                animationName = thePlayer.leftMelee
                newAttack.xScale = -1
            case .right :
                animationName = thePlayer.rightMelee
        }
        
        let attackAnimation:SKAction = SKAction(named: animationName)!
        
        let finish:SKAction = SKAction.run {
            self.runIdleAnimation()
        }
        
        let seq:SKAction = SKAction.sequence( [attackAnimation, finish])
        
        thePlayer.run(seq, withKey: "Attack")
        
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
      //  if (thePlayer.action(forKey: "PlayerMoving") != nil) {
            
      //      thePlayer.removeAction(forKey: "PlayerMoving")
      //  }
        
        pathArray.removeAll()
        
        currentOffset = CGPoint(x: thePlayer.position.x - pos.x, y: thePlayer.position.y - pos.y)
        
        pathArray.append(getDifference(point: pos))
        
        walkTime = 0
        
      /*
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
        */
    }
    
    func touchDownSansPath(atPoint pos : CGPoint) {
        
        if (pos.x < thePlayer.position.x) {
            
            // to the left of the player
            
            touchingDown = true
            thePlayer.removeAction(forKey: "Idle")
            offsetFromTouchDownToPlayer = CGPoint(x: thePlayer.position.x - pos.x, y: thePlayer.position.y - pos.y)
            
            if(touchDownSprite.parent == nil) {
                touchDownSprite = SKSpriteNode(imageNamed: "TouchDown")
                self.addChild(touchDownSprite)
                touchDownSprite.position = pos
            } else {
                touchDownSprite.position = pos
            }
            
            if(touchFollowSprite.parent == nil) {
                touchFollowSprite = SKSpriteNode(imageNamed: "TouchDown")
                self.addChild(touchFollowSprite)
                touchFollowSprite.position = pos
            } else {
                touchFollowSprite.position = pos
            }
            
        }
        
        
    }
    
    func getDifference(point:CGPoint) -> CGPoint {
        
        let newPoint:CGPoint = CGPoint(x: point.x + currentOffset.x, y: point.y + currentOffset.y)
        
        return newPoint
    }
    
    func touchMovedSansPath(toPoint pos : CGPoint) {
        
        if(touchingDown) {
            
            orientCharacter(pos:pos)
            touchFollowSprite.position = pos
        }
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
        if (thePlayer.action(forKey: "PlayerMoving") != nil && pathArray.count > 4) {
        
           thePlayer.removeAction(forKey: "PlayerMoving")
        }
        
        walkTime += thePlayer.walkSpeedOnPath
        
        pathArray.append(getDifference(point: pos))
    }
    
    func touchUp(atPoint pos : CGPoint) {
        //  swipedRight()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            
            if (walkWithPath) {
                self.touchDown(atPoint: t.location(in: self))
            } else {
                self.touchDownSansPath(atPoint: t.location(in: self))
            }
            break
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            
            if (walkWithPath) {
                self.touchMoved(toPoint: t.location(in: self))
            } else {
                self.touchMovedSansPath(toPoint: t.location(in: self))
            }
            break
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (walkWithPath) {
            createLineWith(array:pathArray)
            pathArray.removeAll()
            
            currentOffset = CGPoint.zero
        } else {
            if(touchingDown) {
                thePlayer.removeAllActions()
                touchingDown = false
                touchFollowSprite.removeFromParent()
                touchDownSprite.removeFromParent()
                
                runIdleAnimation()
            }
        }
    }
    
    func createLineWith(array:[CGPoint])  {
        
        let path = CGMutablePath()
        path.move(to:pathArray[0])
        
        for point in pathArray {
            
            path.addLine(to:point)
            
        }
        
        let line = SKShapeNode()
        line.path = path
        line.lineWidth = 10
        line.strokeColor = UIColor.white
        line.alpha = pathAlpha
        
        self.addChild(line)
        
        let fade:SKAction = SKAction.fadeOut(withDuration: 0.3)
        let runAfter:SKAction = SKAction.run {
            
            line.removeFromParent()
            
        }
        
        line.run(SKAction.sequence([fade, runAfter]))
        
        makePlayerFollowPath(path: path)
        
    }
    
    func playerUpdateSansPath() {
        
        touchDownSprite.position = CGPoint(x:thePlayer.position.x - offsetFromTouchDownToPlayer.x, y:thePlayer.position.y - offsetFromTouchDownToPlayer.y)
        
        if (touchingDown) {
            
            let walkSpeed = thePlayer.walkSpeed
            
            switch playerFacing {
            case .front:
                thePlayer.position = CGPoint(x:thePlayer.position.x, y:thePlayer.position.y - walkSpeed)
            case .back:
                thePlayer.position = CGPoint(x:thePlayer.position.x, y:thePlayer.position.y + walkSpeed)
            case .left:
                thePlayer.position = CGPoint(x:thePlayer.position.x - walkSpeed, y:thePlayer.position.y)
            case .right:
                thePlayer.position = CGPoint(x:thePlayer.position.x + walkSpeed, y:thePlayer.position.y)
            }
         
            animateWalkSansPath()
        }
        
    }
    
    func playerUpdate() {
        
        //runs at the same frame rate as the game (called by the update statement)
        
        if (thePlayer.action(forKey: "PlayerMoving") != nil && thePlayer.action(forKey: "Attack") == nil) {
        
            if (playerLastLocation != CGPoint.zero) {
                
                if (thePlayer.action(forKey: "PlayerMoving") != nil) {
                
                    if (abs(thePlayer.position.x - playerLastLocation.x) > abs(thePlayer.position.y - playerLastLocation.y)) {
                        //greater movement x
                        
                        if (thePlayer.position.x > playerLastLocation.x) {
                            //right
                            playerFacing = .right
                            
                            if (thePlayer.action(forKey: thePlayer.rightWalk) == nil) {
                                
                                animateWalk()
                            }
                            
                        } else {
                            //left
                            playerFacing = .left
                            
                            if (thePlayer.action(forKey: thePlayer.leftWalk) == nil) {
                                
                                animateWalk()
                            }
                        }
                        
                    } else {
                        //greater movement y
                        
                        if (thePlayer.position.y > playerLastLocation.y) {
                            //up / back
                            
                            playerFacing = .back
                            
                            if (thePlayer.action(forKey: thePlayer.backWalk) == nil) {
                                
                                animateWalk()
                            }
                            
                        } else {
                            //down / forward
                            
                            playerFacing = .front
                            
                            if (thePlayer.action(forKey: thePlayer.frontWalk) == nil) {
                                
                                animateWalk()
                            }
                            
                        }
                        
                    }
                
                }
                
            }
            
        }
        
        playerLastLocation = thePlayer.position
    }
    
    func orientCharacter(pos:CGPoint) {
                    
        if (abs(touchDownSprite.position.x - pos.x) > abs(touchDownSprite.position.y - pos.y)) {
            //greater movement x
            
            if (touchDownSprite.position.x < pos.x) {
                
                //right
                playerFacing = .right
              
            } else {
                
                //left
                playerFacing = .left
                
            }
            
        } else {
            //greater movement y
            
            if (touchDownSprite.position.y < pos.y) {
                //up / back
                
                playerFacing = .back
                
                
            } else {
                //down / forward
                
                playerFacing = .front
                
            }
            
        }

    }
    
    func animateWalk() {
        
        var theAnimation:String = ""
        
        switch playerFacing {
        case .right:
            theAnimation = thePlayer.rightWalk
        case .left:
            theAnimation = thePlayer.leftWalk
        case .front:
            theAnimation = thePlayer.frontWalk
        case .back:
            theAnimation = thePlayer.backWalk
        }
        
        let walkAnimation:SKAction = SKAction.init(named: theAnimation, duration: 0.25)!
        thePlayer.run(walkAnimation, withKey: theAnimation)
    }
    
    func animateWalkSansPath() {
        
        var theAnimation:String = ""
        
        switch playerFacing {
        case .right:
            theAnimation = thePlayer.rightWalk
        case .left:
            theAnimation = thePlayer.leftWalk
        case .front:
            theAnimation = thePlayer.frontWalk
        case .back:
            theAnimation = thePlayer.backWalk
        }
        
        if (theAnimation != "") {
        
            thePlayer.removeAction(forKey: thePlayer.rightWalk)
            thePlayer.removeAction(forKey: thePlayer.leftWalk)
            thePlayer.removeAction(forKey: thePlayer.frontWalk)
            thePlayer.removeAction(forKey: thePlayer.backWalk)
            
            let walkAnimation:SKAction = SKAction.init(named: theAnimation, duration: 0.25)!
            let repeatAction:SKAction = SKAction.repeatForever(walkAnimation)
            thePlayer.run(repeatAction, withKey: theAnimation)
            
        }
    }
    
    func makePlayerFollowPath(path:CGMutablePath) {
        
        let followAction:SKAction = SKAction.follow(path, asOffset: false, orientToPath: false, duration: walkTime)
        
        let finish:SKAction = SKAction.run {
            
            self.runIdleAnimation()
            
        }
        
        let seq:SKAction = SKAction.sequence([followAction, finish])
        
        thePlayer.run(seq, withKey: "PlayerMoving")
        
    }
    
    func runIdleAnimation() {
        
        var animationName:String = ""
        
        switch playerFacing {
            
            case .front:
                animationName = thePlayer.frontIdle
            case .back:
                animationName = thePlayer.backIdle
            case .left:
                animationName = thePlayer.leftIdle
            case .right:
                animationName = thePlayer.rightIdle
        }
        
        if (animationName != "") {
            let idleAnimation:SKAction = SKAction(named: animationName, duration:1)!
            thePlayer.run(idleAnimation, withKey: "Idle")
        }
    }
   
}
