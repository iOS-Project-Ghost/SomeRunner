//
//  Player.swift
//  Cowboy Runner
//
//  Created by Ryan Stoppler on 2017-03-30.
//  Copyright © 2017 stoppler. All rights reserved.
//

import SpriteKit

//set collision types for each node
struct ColliderType{
    static let Player: UInt32 = 1
    static let Ground: UInt32 = 2
    static let Obstacle: UInt32 = 3
}

class Player: SKSpriteNode{
    
    //initialize the player
    func initialize(){
        
        var walk = [SKTexture]();
        
        for i in 1...8 {
            
            let name = "CapDude \(i)"
            walk.append(SKTexture(imageNamed: name))
            
        }
        
        let walkAnimation = SKAction.animate(with: walk, timePerFrame: TimeInterval(0.08), resize: true, restore: true)
        self.name = "Player"
        //needs to be greater than position of the background
        self.zPosition = 2
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.setScale(0.5)
        //physics body the size of the player
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width - 20, height: self.size.height))
        //player will be affected by gravity
        self.physicsBody?.affectedByGravity = true
        //dont allow rotation, prevents player rotating when in contact with other nodes
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = ColliderType.Player
        self.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Obstacle
        self.physicsBody?.contactTestBitMask = ColliderType.Ground | ColliderType.Obstacle
        self.run(SKAction.repeatForever(walkAnimation))
        
    }
    
    
    //make the player jump
    func jump(){
        
        //normalize velocity so player doesnt speed up when impulse is applied 
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        //apply impulse so player jumps, increase dy to increase jump
        self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 240))
        
    }
    
  

    
}

































