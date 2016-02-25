//
//  LongSectionNode.swift
//  ChickenJump
//
//  Created by liudong on 16/2/24.
//  Copyright © 2016年 liudong. All rights reserved.
//

import SpriteKit

class LongSectionNode: SKNode {
    
    init(wallTexture:SKTexture, walltopTexture:SKTexture, floorTexture:SKTexture, color:SKColor) {
        
//        let wallTexture = getFloorTextureWith(type)
        let wall = WallTopNode(texture: wallTexture, color: color, size: CGSizeMake(64, wallTexture.size().height))
        
//        let walltopTexture = getFloorTextureWith(type)
        let walltop = WallTopNode(texture: walltopTexture, color: color, size: CGSizeMake(64, walltopTexture.size().height))
//
////        let floorTexture = getFloorTextureWith(type)
//        let floor = FloorNode(texture: floorTexture, color:SKColor.whiteColor(), size: CGSizeMake(64, floorTexture.size().height))
//
        walltop.position = CGPointMake(0, wall.size.height + walltop.size.height * 0.5)
//        floor.position = CGPointMake(0, wall.size.height + walltop.size.height + floor.size.height)
        
        super.init()
        
        self.addChild(wall)
        self.addChild(walltop)
//        self.addChild(floor)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
