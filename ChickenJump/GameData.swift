//
//  GameData.swift
//  ChickenJump
//
//  Created by liudong on 16/3/17.
//  Copyright © 2016年 liudong. All rights reserved.
//

import Foundation
import UIKit

func setSceneSkyColor_Day(type:SceneLandType) ->UIColor{
    
    switch type {
    case .Amazon:
        switch arc4random() % 3 {
        case 0: return SkyColor_Amazon_A
        case 1: return SkyColor_Amazon_B
        case 2: return SkyColor_Amazon_C
        default: return SkyColor_Amazon_A
        }
        
    case .Grove:
        switch arc4random() % 3 {
        case 0: return SkyColor_Grove_A
        case 1: return SkyColor_Grove_B
        case 2: return SkyColor_Grove_C
        default: return SkyColor_Grove_A
        }
        
    case .Volcanic:
        switch arc4random() % 3 {
        case 0: return SkyColor_Volcanic_A
        case 1: return SkyColor_Volcanic_B
        case 2: return SkyColor_Volcanic_C
        default: return SkyColor_Volcanic_A
        }
        
    case .LahontanValley:
        switch arc4random() % 3 {
        case 0: return SkyColor_LahontanValley_A
        case 1: return SkyColor_LahontanValley_B
        case 2: return SkyColor_LahontanValley_C
        default: return SkyColor_LahontanValley_A
        }
        
    case .SnowMountain:
        switch arc4random() % 3 {
        case 0: return SkyColor_SnowMountain_A
        case 1: return SkyColor_SnowMountain_B
        case 2: return SkyColor_SnowMountain_C
        default: return SkyColor_SnowMountain_A
        }
        
    case .MayaPyramid:
        switch arc4random() % 3 {
        case 0: return SkyColor_MayaPyramid_A
        case 1: return SkyColor_MayaPyramid_B
        case 2: return SkyColor_MayaPyramid_C
        default: return SkyColor_MayaPyramid_A
        }
        
    case .Iceberg:
        switch arc4random() % 3 {
        case 0: return SkyColor_Iceberg_A
        case 1: return SkyColor_Iceberg_B
        case 2: return SkyColor_Iceberg_C
        default: return SkyColor_Iceberg_A
        }
        
    case .BuildingShenshe:
        switch arc4random() % 3 {
        case 0: return SkyColor_BuildingShenshe_A
        case 1: return SkyColor_BuildingShenshe_B
        case 2: return SkyColor_BuildingShenshe_C
        default: return SkyColor_BuildingShenshe_A
        }
        
    case .Cemetery:
        switch arc4random() % 3 {
        case 0: return SkyColor_Cemetery_A
        case 1: return SkyColor_Cemetery_B
        case 2: return SkyColor_Cemetery_C
        default: return SkyColor_Cemetery_A
        }
        
    case .Nightsky:
        switch arc4random() % 3 {
        case 0: return SkyColor_Nightsky_A
        case 1: return SkyColor_Nightsky_B
        case 2: return SkyColor_Nightsky_C
        default: return SkyColor_Nightsky_A
        }
    }
}


func setSceneSkyColor_Night(type:SceneLandType) ->UIColor{
    
    switch type {
    case .Amazon:
        switch arc4random() % 3 {
        case 0: return SkyColor_Amazon_Night_A
        case 1: return SkyColor_Amazon_Night_B
        case 2: return SkyColor_Amazon_Night_C
        default: return SkyColor_Amazon_Night_A
        }
        
    case .Grove:
        switch arc4random() % 3 {
        case 0: return SkyColor_Grove_Night_A
        case 1: return SkyColor_Grove_Night_B
        case 2: return SkyColor_Grove_Night_C
        default: return SkyColor_Grove_Night_A
        }
        
    case .Volcanic:
        switch arc4random() % 3 {
        case 0: return SkyColor_Volcanic_Night_A
        case 1: return SkyColor_Volcanic_Night_B
        case 2: return SkyColor_Volcanic_Night_C
        default: return SkyColor_Volcanic_Night_A
        }
        
    case .LahontanValley:
        switch arc4random() % 3 {
        case 0: return SkyColor_LahontanValley_Night_A
        case 1: return SkyColor_LahontanValley_Night_B
        case 2: return SkyColor_LahontanValley_Night_C
        default: return SkyColor_LahontanValley_Night_A
        }
        
    case .SnowMountain:
        switch arc4random() % 3 {
        case 0: return SkyColor_SnowMountain_Night_A
        case 1: return SkyColor_SnowMountain_Night_B
        case 2: return SkyColor_SnowMountain_Night_C
        default: return SkyColor_SnowMountain_Night_A
        }
        
    case .MayaPyramid:
        switch arc4random() % 3 {
        case 0: return SkyColor_MayaPyramid_Night_A
        case 1: return SkyColor_MayaPyramid_Night_B
        case 2: return SkyColor_MayaPyramid_Night_C
        default: return SkyColor_MayaPyramid_Night_A
        }
        
    case .Iceberg:
        switch arc4random() % 3 {
        case 0: return SkyColor_Iceberg_Night_A
        case 1: return SkyColor_Iceberg_Night_B
        case 2: return SkyColor_Iceberg_Night_C
        default: return SkyColor_Iceberg_Night_A
        }
        
    case .BuildingShenshe:
        switch arc4random() % 3 {
        case 0: return SkyColor_BuildingShenshe_Night_A
        case 1: return SkyColor_BuildingShenshe_Night_B
        case 2: return SkyColor_BuildingShenshe_Night_C
        default: return SkyColor_BuildingShenshe_Night_A
        }
        
    case .Cemetery:
        switch arc4random() % 3 {
        case 0: return SkyColor_Cemetery_Night_A
        case 1: return SkyColor_Cemetery_Night_B
        case 2: return SkyColor_Cemetery_Night_C
        default: return SkyColor_Cemetery_Night_A
        }
        
    case .Nightsky:
        switch arc4random() % 3 {
        case 0: return SkyColor_Nightsky_Night_A
        case 1: return SkyColor_Nightsky_Night_B
        case 2: return SkyColor_Nightsky_Night_C
        default: return SkyColor_Nightsky_Night_A
        }
    }
}

