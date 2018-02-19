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
        newAttack.setUp()
        self.addChild(newAttack)
        newAttack.zPosition = thePlayer.zPosition - 1
        
        thePlayer.run(SKAction(named: "FrontAttack")!)
        
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
        pathArray.removeAll()
        
        currentOffset = CGPoint(x: thePlayer.position.x - pos.x, y: thePlayer.position.y - pos.y)
        
        pathArray.append(getDifference(point: pos))
        
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
    
    func getDifference(point:CGPoint) -> CGPoint {
        
        let newPoint:CGPoint = CGPoint(x: point.x + currentOffset.x, y: point.y + currentOffset.y)
        
        return newPoint
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
        pathArray.append(getDifference(point: pos))
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
        for t in touches {
            
            self.touchMoved(toPoint: t.location(in: self))
            
            break
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    //    for t in touches { self.touchUp(atPoint: t.location(in: self)) }
        
        createLineWith(array:pathArray)
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
        line.alpha = 0.5
        
        self.addChild(line)
        
        let fade:SKAction = SKAction.fadeOut(withDuration: 0.3)
        let runAfter:SKAction = SKAction.run {
            
            line.removeFromParent()
            
        }
        
        line.run(SKAction.sequence([fade, runAfter]))
        
    }
    
   
}
