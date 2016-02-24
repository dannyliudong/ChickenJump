//
//  KnifeSectionNode.swift
//  ChickenJump
//
//  Created by liudong on 16/2/24.
//  Copyright © 2016年 liudong. All rights reserved.
//

import SpriteKit

class KnifeSectionNode: SKNode {
    
    init(wallTexture:SKTexture, walltopTexture:SKTexture, floorTexture:SKTexture, knifeTexture:SKTexture, color:SKColor) {
        
        super.init()
        
        let wall = WallTopNode(texture: wallTexture, color: color, size: wallTexture.size())
        
        let walltop = WallTopNode(texture: walltopTexture, color: color, size: walltopTexture.size())
        
        let floor = FloorNode(texture: floorTexture, color:SKColor.whiteColor(), size: floorTexture.size())
        
        let knife = KnifeNode(texture: knifeTexture, color: UIColor.whiteColor(), size: knifeTexture.size())
        
        walltop.position = CGPointMake(0, wall.size.height + walltop.size.height * 0.5)
        floor.position = CGPointMake(0, wall.size.height + walltop.size.height + floor.size.height)
        
        self.addChild(wall)
        self.addChild(walltop)
        self.addChild(floor)
        self.addChild(knife)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//    func moveByY(<#parameters#>) -> <#return type#> {
//        <#function body#>
//    }
    
}
