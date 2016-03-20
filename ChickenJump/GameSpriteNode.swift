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
    
    let wather = SKSpriteNode(texture: SKTexture(imageNamed:"waterBg"),
                              color: clolor,
                              size: CGSizeMake(Screen_Width * 1.01, Screen_Height * 0.3))
    wather.zPosition = -30
    wather.position = CGPointMake(Screen_Width * 0.5, Screen_Height * 0.3)
    wather.anchorPoint = CGPointMake(0.5, 1)
    wather.colorBlendFactor = 1.0
    wather.alpha = 1
    
    wather.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(wather.size.width, wather.size.height) , center: CGPointMake(0, -wather.size.height * 0.5))
    wather.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Wather
    wather.physicsBody?.collisionBitMask = CollisionCategoryBitmask.None
    
//    wather.physicsBody?.collisionBitMask = CollisionCategoryBitmask.None
//    wather.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.None
    
    wather.physicsBody?.dynamic = false
    wather.physicsBody?.allowsRotation = false
    
    wather.physicsBody?.restitution = 0
    
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
func GameSpriteNodeWithPlayerNode(texture:SKTexture) ->SKNode {
    
//    let node = SKNode()
    
    // 脚部分 , 用于站在地面上，包括角色的所有碰撞。
    let foot = SKSpriteNode(color: UIColor.clearColor(), size: CGSizeMake(30, 25))//SKSpriteNode(imageNamed: "pixelMan")
//    node.shadowCastBitMask = ShadowCastBitMask.MainShadow
    foot.zPosition = 60
//    foot.colorBlendFactor = 0
    
    foot.physicsBody = SKPhysicsBody(rectangleOfSize: foot.size) //CGSizeMake(28, 64)
    foot.physicsBody?.dynamic = true
    foot.physicsBody?.allowsRotation = false
    
    foot.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Player
    
    //  碰撞事件通知
    foot.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Normal_Floor |
                                            CollisionCategoryBitmask.Down_Floor |
                                            CollisionCategoryBitmask.Wather |
                                            CollisionCategoryBitmask.Enemy |
                                            CollisionCategoryBitmask.DoorKey_Button |
                                            CollisionCategoryBitmask.Spring |
                                            CollisionCategoryBitmask.Gold
    //  碰撞位置影响
    
//    node.physicsBody?.collisionBitMask = CollisionCategoryBitmask.None
    
    foot.physicsBody?.collisionBitMask = CollisionCategoryBitmask.Normal_Floor |
                                            CollisionCategoryBitmask.Down_Floor |
                                            CollisionCategoryBitmask.Wather |
                                            CollisionCategoryBitmask.Spring
    
    foot.physicsBody?.restitution = 0

    
    // 身体部分, 仅用于与障碍物金币等发生碰撞， 不用于站在地面上
//    let body = SKSpriteNode(color: UIColor.clearColor(), size: CGSizeMake(30, 40))//SKSpriteNode(imageNamed: "pixelMan")
//    //    node.shadowCastBitMask = ShadowCastBitMask.MainShadow
//    body.zPosition = 60
////    body.colorBlendFactor = 0
////    body.position = CGPointMake(0, body.size.height * 0.5 - foot.size.height * 0.5)
//    
//    body.physicsBody = SKPhysicsBody(rectangleOfSize: body.size) //CGSizeMake(28, 64)
//    body.physicsBody?.dynamic = true
//    body.physicsBody?.allowsRotation = false
//    
//    body.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Player
//    
//    //  碰撞事件通知
//    body.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Enemy |
//                                            CollisionCategoryBitmask.DoorKey_Button |
//                                            CollisionCategoryBitmask.Gold
//    //  碰撞位置影响
//    
//        body.physicsBody?.collisionBitMask = CollisionCategoryBitmask.None
//    
////    body.physicsBody?.collisionBitMask = CollisionCategoryBitmask.Normal_Floor |
////        CollisionCategoryBitmask.Down_Floor |
////        CollisionCategoryBitmask.Wather |
////        CollisionCategoryBitmask.Spring
//    
//    body.physicsBody?.restitution = 0
//    
//    foot.addChild(body)
    
    
    let sprite = SKSpriteNode(imageNamed: "pixelMan")
    sprite.position = CGPointMake(0, sprite.size.height * 0.5 - foot.size.height * 0.5)
    foot.addChild(sprite)
    
    return foot
}




