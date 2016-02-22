//
//  GameSpriteNode.swift
//  Space2001
//
//  Created by liudong on 15/12/15.
//  Copyright © 2015年 liudong. All rights reserved.
//

//import Foundation
import SpriteKit


//MARK: 模拟水
func GameSpriteNodeWithWaterBackgroud(clolor:UIColor) ->SKSpriteNode {
    
    let wather = SKSpriteNode(texture: SKTexture(imageNamed: "waterBg"), color: clolor, size: CGSizeMake(980, Screen_Height * 0.2))
    wather.zPosition = -30
    wather.colorBlendFactor = 1.0
    wather.alpha = 1
    
    wather.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(wather.size.width, wather.size.height))
    wather.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Wather
    wather.physicsBody?.collisionBitMask = CollisionCategoryBitmask.None
    wather.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.None
    
    wather.physicsBody?.dynamic = false
    wather.physicsBody?.allowsRotation = false
    
    wather.physicsBody?.friction = 0
    wather.physicsBody?.restitution = 0
    
    wather.physicsBody?.linearDamping = 0
    wather.physicsBody?.angularDamping = 0
    
    wather.physicsBody?.charge = 0
    
//        wather.lightingBitMask = 1
//        wather.shadowCastBitMask = 1
//        let up = SKAction.moveToY(10, duration: 1.5)
//        let down = SKAction.moveToY(0, duration: 1.5)
//
//        wather.runAction(SKAction.repeatActionForever(SKAction.sequence([up, down])))
    
    return wather
    
}

//MARK: 金币
func GameSpriteNodeWithGold(texture:SKTexture) ->SKSpriteNode {
    
    let node = SKSpriteNode(texture: texture)
    node.zPosition = 100
    
    node.physicsBody = SKPhysicsBody(rectangleOfSize: node.size)
    node.physicsBody?.dynamic = false
    
    node.physicsBody?.friction = 0
    node.physicsBody?.charge = 0
    node.physicsBody?.restitution = 0
    node.physicsBody?.linearDamping = 0
    node.physicsBody?.angularDamping = 0
    
    node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Gold
    node.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.None
    node.physicsBody?.collisionBitMask = CollisionCategoryBitmask.Player
    
    return node
}

//MARK: 角色
func GameSpriteNodeWithPlayerNode(texture:SKTexture) ->SKSpriteNode{
    
    let node = SKSpriteNode(imageNamed: "pixelMan")//SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(64, 64))
//    node.setScale(0.9)
//    node.shadowCastBitMask = ShadowCastBitMask.MainShadow
    node.zPosition = 60
    node.colorBlendFactor = 0
    node.color = randomColor()
    
//    let physicsSize: CGSize = CGSizeMake(40, 70)
    node.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(28, 64))//SKPhysicsBody(rectangleOfSize: texture.size())
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
        
    return node
}




