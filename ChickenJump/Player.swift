//
//  PlayerSprite.swift
//  ChickenJump
//
//  Created by liudong on 16/2/24.
//  Copyright © 2016年 liudong. All rights reserved.
//

import SpriteKit

class Player: SKNode {
    
//    let player:SKNode!
    let size:CGSize!
    
    init(texture:SKTexture, color:SKColor) {
        
        self.size = texture.size()

        let node = SKSpriteNode(texture: texture, color: color, size: texture.size())
        node.zPosition = 60
        node.colorBlendFactor = 0
        
        node.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(28, 64))
        node.physicsBody?.dynamic = true
        node.physicsBody?.allowsRotation = false
        
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Player
        node.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Normal_Floor |
            CollisionCategoryBitmask.Down_Floor |
            CollisionCategoryBitmask.Invisible |
            CollisionCategoryBitmask.Wather |
            CollisionCategoryBitmask.Enemy |
            CollisionCategoryBitmask.DoorKey_Button |
            CollisionCategoryBitmask.Spring |
            CollisionCategoryBitmask.Pinned |
            CollisionCategoryBitmask.Gold
        
        node.physicsBody?.collisionBitMask = CollisionCategoryBitmask.Normal_Floor |
            CollisionCategoryBitmask.Down_Floor |
            CollisionCategoryBitmask.Invisible |
            CollisionCategoryBitmask.Pinned
        
        node.physicsBody?.friction = 0
        node.physicsBody?.charge = 0
        node.physicsBody?.restitution = 0
        node.physicsBody?.linearDamping = 0
        node.physicsBody?.angularDamping = 0
        
//        self.player.addChild(node)
        
        super.init()
        
        self.addChild(node)

    }
    
    func doStayAnimation() {
        print("待机动画")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}