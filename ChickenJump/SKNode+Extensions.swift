//
//  SKNode+Extensions.swift
//  ChickenJump
//
//  Created by liudong on 16/3/7.
//  Copyright © 2016年 liudong. All rights reserved.
//

import SpriteKit

extension SKNode {
    // 只更改关卡位置 动画 不设置纹理
    func setAnimiation(platfromNode:SKNode)  {
        
        // 左右移动的平台
        if let nodes = platfromNode.childNodeWithName("floorMoveXNodes") {
            
            for node in nodes.children {
                
                let _node = node as! SKSpriteNode
                
                _node.physicsBody?.restitution = 0
                
                //                _node.physicsBody?.friction = 0
                //                _node.physicsBody?.charge = 0
                //                _node.physicsBody?.linearDamping = 0
                //                _node.physicsBody?.angularDamping = 0
                
                let wait = SKAction.waitForDuration(NSTimeInterval(CGFloat.random(min: 1.0, max: 2.0)))
                let sequence = SKAction.sequence([wait, SKAction.moveToX_Cycle(128 , time: NSTimeInterval(CGFloat.random(min: 1.0, max: 1.5)))])
                
                _node.runAction(sequence)
                
            }
        }
        
        // 上下移动的平台
        
        if let nodes = platfromNode.childNodeWithName("floorMoveYNodes") {
            
            for node in nodes.children {
                
                let _node = node as! SKSpriteNode
                
                _node.physicsBody?.restitution = 0
                
                //                _node.physicsBody?.friction = 0
                //                _node.physicsBody?.charge = 0
                //                _node.physicsBody?.linearDamping = 0
                //                _node.physicsBody?.angularDamping = 0
                
                let wait = SKAction.waitForDuration(NSTimeInterval(CGFloat.random(min: 1.0, max: 2.0)))
                let sequence = SKAction.sequence([wait, SKAction.moveToY_Cycle(64 * 5, time: NSTimeInterval(CGFloat.random(min: 1.5, max: 2.5)))])
                
                _node.runAction(sequence)
                
            }
        }
        
        // 设置钥匙的 随机高度
        if let node = platfromNode.childNodeWithName("door") {
            
            if let keyNode = node.childNodeWithName("doorkeynode") {
                
                keyNode.physicsBody?.friction = 0
                keyNode.physicsBody?.charge = 0
                keyNode.physicsBody?.restitution = 0
                keyNode.physicsBody?.linearDamping = 0
                keyNode.physicsBody?.angularDamping = 0
                
                let ketX:CGFloat = {
                    switch arc4random() % 2 {
                    case 0 :
                        return -64.0
                    case 1:
                        return -128.0
                    default :
                        return 0.0
                    }
                }()
                
                let ketY = CGFloat.random(min: -100, max: 50)
                
                keyNode.position = CGPointMake(ketX, ketY)//CGFloat.random(min: -100, max: 50)
            }
            print("finde child doorkeynode ")
        }
        
        if let nodes = platfromNode.childNodeWithName("knifeNodes") {
            
            for node in nodes.children {
                
                let _node = node as! SKSpriteNode
                
                _node.physicsBody?.restitution = 0
                
                //                _node.physicsBody?.friction = 0
                //                _node.physicsBody?.charge = 0
                //                _node.physicsBody?.linearDamping = 0
                //                _node.physicsBody?.angularDamping = 0
                
                let wait = SKAction.waitForDuration(NSTimeInterval(CGFloat.random(min: 0.0, max: 2.0)))
                let sequence = SKAction.sequence([wait, SKAction.moveToY_Cycle(380, time: NSTimeInterval(CGFloat.random(min: 2.5, max: 4.0)))])
                _node.runAction(sequence)
                
            }
        }
        
    }

}