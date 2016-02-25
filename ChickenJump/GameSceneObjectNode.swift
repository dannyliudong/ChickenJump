//
//  GameSceneObjectNode.swift
//  ChickenJump
//
//  Created by liudong on 16/2/24.
//  Copyright © 2016年 liudong. All rights reserved.
//

import SpriteKit

/**
 踩踏台 拼接方式
 - 类型 LongSection: 长段
 - 类型 ShortSection: 短段
 - 类型 Gradient: 台阶样式
 */
enum PlatformContactType:UInt32 {
    case Long_Section = 0       // 一长段
    case Down_Section           // 踩踏 掉落
    case Door_Section           // 开关门
    case Spring_Section         // 弹簧
    case BridgeMovingInX_Section
    case BridgeMovingInY_Section  // 上下移动
}

class GameSceneObjectNode: SKNode {
    
}

class FloorNode:SKSpriteNode {
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.texture = texture
        self.color = color
        self.colorBlendFactor = 1
            
        self.physicsBody = SKPhysicsBody(rectangleOfSize: (texture?.size())!)
        self.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Normal_Floor
        
        self.physicsBody?.friction = 0
        self.physicsBody?.charge = 0
        self.physicsBody?.restitution = 0
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.angularDamping = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SpringNode: SKSpriteNode {
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.texture = texture
        self.color = color
        self.colorBlendFactor = 0
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: (texture?.size())!)
        self.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Spring
        
        self.physicsBody?.friction = 0
        self.physicsBody?.charge = 0
        self.physicsBody?.restitution = 0
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.angularDamping = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class WallNode: SKSpriteNode {
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.texture = texture
        self.color = color
        self.colorBlendFactor = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class WallTopNode: SKSpriteNode {
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.texture = texture
        self.color = color
        self.colorBlendFactor = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class KnifeNode: SKSpriteNode {
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.texture = texture
        self.color = color
        self.colorBlendFactor = 1
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: (texture?.size())!)
        self.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Enemy
        
        self.physicsBody?.friction = 0
        self.physicsBody?.charge = 0
        self.physicsBody?.restitution = 0
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.angularDamping = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class PlatformNode: SKNode {
    
    let platfromAtlats = PlatfromTextureAlats()
    
    init(texture: SKTexture, color: SKColor, size:CGSize) {
        super.init()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func getFloorTextureWith(type:SceneLandType) -> SKTexture {
        switch type {
        case .Amazon:
            switch arc4random() % 4 {
            case 0: return platfromAtlats.AmazonFloor1()
            case 1: return platfromAtlats.AmazonFloor2()
            case 2: return platfromAtlats.AmazonFloor3()
            case 3: return platfromAtlats.AmazonFloor4()
                
            default :return platfromAtlats.AmazonFloor1()
            }
            
            
        case .Grove:
            switch arc4random() % 4 {
            case 0: return platfromAtlats.GroveFloor1()
            case 1: return platfromAtlats.GroveFloor2()
            case 2: return platfromAtlats.GroveFloor3()
            case 3: return platfromAtlats.GroveFloor4()
                
            default :return platfromAtlats.GroveFloor1()
            }
        case .Volcanic:
            switch arc4random() % 4 {
            case 0: return platfromAtlats.VolcanicFloor1()
            case 1: return platfromAtlats.VolcanicFloor2()
            case 2: return platfromAtlats.VolcanicFloor3()
            case 3: return platfromAtlats.VolcanicFloor4()
                
            default :return platfromAtlats.VolcanicFloor1()
            }
        case .LahontanValley:
            switch arc4random() % 4 {
            case 0: return platfromAtlats.LahontanValleyFloor1()
            case 1: return platfromAtlats.LahontanValleyFloor2()
            case 2: return platfromAtlats.LahontanValleyFloor3()
            case 3: return platfromAtlats.LahontanValleyFloor4()
                
            default :return platfromAtlats.LahontanValleyFloor1()
            }
        case .SnowMountain:
            switch arc4random() % 4 {
            case 0: return platfromAtlats.SnowMountainFloor1()
            case 1: return platfromAtlats.SnowMountainFloor2()
            case 2: return platfromAtlats.SnowMountainFloor3()
            case 3: return platfromAtlats.SnowMountainFloor4()
                
            default :return platfromAtlats.SnowMountainFloor1()
            }
        case .MayaPyramid:
            switch arc4random() % 4 {
            case 0: return platfromAtlats.MayaPyramidFloor1()
            case 1: return platfromAtlats.MayaPyramidFloor2()
            case 2: return platfromAtlats.MayaPyramidFloor3()
            case 3: return platfromAtlats.MayaPyramidFloor4()
                
            default :return platfromAtlats.MayaPyramidFloor1()
            }
        case .Iceberg:
            switch arc4random() % 4 {
            case 0: return platfromAtlats.IcebergFloor1()
            case 1: return platfromAtlats.IcebergFloor2()
            case 2: return platfromAtlats.IcebergFloor3()
            case 3: return platfromAtlats.IcebergFloor4()
                
            default :return platfromAtlats.IcebergFloor1()
            }
        case .BuildingShenshe:
            switch arc4random() % 4 {
            case 0: return platfromAtlats.ShensheFloor1()
            case 1: return platfromAtlats.ShensheFloor2()
            case 2: return platfromAtlats.ShensheFloor3()
            case 3: return platfromAtlats.ShensheFloor4()
                
            default :return platfromAtlats.ShensheFloor1()
            }
        case .Cemetery:
            switch arc4random() % 4 {
            case 0: return platfromAtlats.CemeteryFloor1()
            case 1: return platfromAtlats.CemeteryFloor2()
            case 2: return platfromAtlats.CemeteryFloor3()
            case 3: return platfromAtlats.CemeteryFloor4()
                
            default :return platfromAtlats.CemeteryFloor1()
            }
        case .Nightsky:
            switch arc4random() % 4 {
            case 0: return platfromAtlats.NightskyFloor1()
            case 1: return platfromAtlats.NightskyFloor2()
            case 2: return platfromAtlats.NightskyFloor3()
            case 3: return platfromAtlats.NightskyFloor4()
                
            default :return platfromAtlats.NightskyFloor1()
            }
        }
    }
    
    //MARK: Platform Create Method
    
    /**
     踩踏台:
     - 类型: LongSection
     */
    func createPlatformLongSectionWith(type:SceneLandType) -> SKNode {
        // 根据SceneLandType 得到对应纹理 对应颜色
        let node = SKNode()
        
        let wallTexture = getFloorTextureWith(type)
        let wall = WallTopNode(texture: wallTexture, color: getWallColorWith(type), size: wallTexture.size())
        
        let walltopTexture = getFloorTextureWith(type)
        let walltop = WallTopNode(texture: walltopTexture, color: getWallColorWith(type), size: walltopTexture.size())
        
        let floorTexture = getFloorTextureWith(type)
        let floor = FloorNode(texture: floorTexture, color:SKColor.whiteColor(), size: floorTexture.size())
        
        walltop.position = CGPointMake(0, wall.size.height + walltop.size.height * 0.5)
        floor.position = CGPointMake(0, wall.size.height + walltop.size.height + floor.size.height)
        
        node.addChild(wall)
        node.addChild(walltop)
        node.addChild(floor)
        
        return node
    }
    
    /**
     踩踏台: 上下移动的尖刺
     - 类型: KnifeSection
     */
    func createPlatformKnifeSectionWith(texutre:SKTexture, color:SKColor, size:CGSize) -> SKNode {
        let node = SKNode()
        
        return node
    }
    
    /**
     踩踏台: 门机关
     - 类型: DoorSection
     */
    func createPlatformDoorSectionWith(texutre:SKTexture, color:SKColor, size:CGSize) -> SKNode {
        let node = SKNode()
        
        return node
    }
    
    /**
     踩踏台: 踩踏掉落
     - 类型: DownSection
     */
    func createPlatformDownSectionWith(texutre:SKTexture, color:SKColor, size:CGSize) -> SKNode {
        let node = SKNode()
        
        return node
    }
    
    /**
     踩踏台: 在X方向移动的平台
     - 类型: BridgeMovingInX_Section
     */
    func createPlatformBridgeMovingInXWith(texutre:SKTexture, color:SKColor, size:CGSize) -> SKNode {
        let node = SKNode()
        
        return node
    }
    
    /**
     踩踏台: 在Y方向移动的平台
     - 类型: BridgeMovingInY_Section
     */
    func createPlatformBridgeMovingInYWith(texutre:SKTexture, color:SKColor, size:CGSize) -> SKNode {
        let node = SKNode()
        
        return node
    }
    
    /**
     踩踏台: 弹簧装置
     - 类型: SpringSection
     */
    func createPlatformSpringWith(texutre:SKTexture, color:SKColor, size:CGSize) -> SKNode {
        let node = SKNode()
        
        return node
    }
}





