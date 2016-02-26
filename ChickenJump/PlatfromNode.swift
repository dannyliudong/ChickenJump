//
//  PlatfromNode.swift
//  ChickenJump
//
//  Created by liudong on 16/2/26.
//  Copyright © 2016年 liudong. All rights reserved.
//

import SpriteKit

class PlatfromNode: SKNode {
    var nodeSize:CGSize!
    
    init(size:CGSize) {
        self.nodeSize = size
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
