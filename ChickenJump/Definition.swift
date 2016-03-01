//
//  ConstantDefinition.swift
//  Space2001
//
//  Created by liudong on 15/11/30.
//  Copyright © 2015年 liudong. All rights reserved.
//

import UIKit
import SpriteKit

//MARK: Defined 单位
var Screen_Width:CGFloat = 1136 // 宽
var Screen_Height:CGFloat = 640 // 高

let Screen_Size:CGSize = CGSizeMake(Screen_Width, Screen_Height)
let Screen_Center:CGPoint = CGPointMake(Screen_Width/2, Screen_Height/2)

let Button_CornerRadius:CGFloat = 5 // 按钮圆角值

//MARK: 碰撞位
/**
 - parameter input: An Int number
 
 - returns: The string represents the input number
 */
struct CollisionCategoryBitmask {
    
    static let None:       UInt32 = 0
    static let All :       UInt32 = UInt32.max
    static let Player:     UInt32 = 0b1   // 1
    static let Gold:       UInt32 = 0b10  // 2
    static let Enemy:      UInt32 = 0b100 // 4
    
    static let Normal_Floor:UInt32 =    0b1000 // 8
    static let Down_Floor:UInt32 =      0b10000 // 16
    static let DoorKey_Button:UInt32 =  0b100000 // 32
    static let Shadow:UInt32 =          0b1000000 // 64
    static let Wather:UInt32 =          0b10000000 // 128
    static let Invisible:UInt32 =       0b100000000 // 256
    static let Spring:UInt32 =          0b1000000000 // 512
    static let Pinned:UInt32 =          0b10000000000 // 1024
    
}

//MARK: 场景类别
/**
场景类别
- parameter input: An Int number

- returns: The string represents the input number
*/
enum SceneLandType: Int {
    case Amazon = 0         // 普通山
    case Grove              // 树林
    case Volcanic           // 火山
    case LahontanValley     // 大峡谷
    case SnowMountain       // 积雪覆盖
    case MayaPyramid        // 玛雅金字塔
    case Iceberg            // 冰山
    case BuildingShenshe    // 神社建筑
    case Cemetery           // 墓地
    case Nightsky           // 空寂夜晚
}

//MARK: 昼夜
enum DayType: Int {
    case Day = 0
    case Night
}

//MARK: 天气
enum WeatherType: Int {
    case Sunny = 0
    case Rain
    case Sandstorm
    case Snow
}

//MARK: 场景组件
enum PlaygroundComponents:Int {
    case Platform = 0
    case Pillar
    case AA
    case BB
}




enum GameBGSongAudioName: String {
    case NormalAudioName = "bg_country.mp3"
    case RainAudioName = "RainSound.mp3"
}


/**
 角色 类型
 */
enum PlayerType:UInt32 {
    case A = 0
    case B
    case C
}

/**
 背景层
 */
enum BGDetphType:UInt32 {
    case LayerA = 0 // 近层
    case LayerB     // 远层
}


//MARK: game configuration

//MARK: node 宽度

let Long_SectionWidth:CGFloat = 64.0
let Door_SectionWidth:CGFloat = 64.0 * 4
let Down_SectionWidth:CGFloat = 64.0 * 2
let BridgeMovingInX_SectionWidth:CGFloat = 64.0 * 5
let BridgeMovingInY_SectionWidth:CGFloat = 64.0 * 3
let Spring_SectionWidth:CGFloat = 64.0 * 5

//MARK: 自定义天空颜色

//MARK: 游戏控制
//let Player_Move_Speed:CGFloat = 5.0
let BG_Cycle_Width_Ratio: CGFloat = 1.0

let Player_Jump_Width:CGFloat = 64
let Player_Jump_Hight:CGFloat = 64

//let Player_Jump_HightAdd:CGFloat = 65
let Scene_Gravity:CGFloat = -60.0

let BG_hight:CGFloat = Screen_Height * 0.2
let PlatformHight:CGFloat = -Screen_Height * 0.2//Screen_Height * 0.1

//MARK: Custom UIView
let Blur_ViewAlpha:CGFloat = 0.0
let View_MaskAlpha:CGFloat = 0.5

let Game_NameString = "Mr.J"
let GameBGSong = "bg_country.mp3"


let Font_Name:String = "HelveticaNeue"

let FloorPhybodyWidth:CGFloat = 48
let FloorPhybodyHight:CGFloat = 10

//MARK: Game Center leaderboardIdentifier
let Leader_Board_Identifier:String = "frank"

//MARK: light color
let Light_AmbientColor_Day:UIColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
let Light_AmbientColor_Night:UIColor = UIColor(red: 255/255, green: 255/255, blue: 27/255, alpha: 0.9)

let Light_ShadowColor:UIColor = UIColor(red: 0.0/255, green: 0.0/255, blue: 0.0/255, alpha: 0.1)


//MARK: 
let SceneSprite_ColorBlendFactor_Mountain:CGFloat = 1.0
let SceneSprite_ColorBlendFactor_Platform:CGFloat = 0.0

struct LightingBitMask {
    static let MainLight:UInt32 = 1
    static let BGLight:UInt32 = 10
    static let FlashLight:UInt32 = 20
    
}

struct ShadowCastBitMask {
    static let MainShadow:UInt32 = 10
}

//MARK: GCD
func GCDSwift(){
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
        //这里写需要大量时间的代码
        print("这里写需要大量时间的代码")
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            //这里返回主线程，写需要主线程执行的代码
            print("这里返回主线程，写需要主线程执行的代码")
            
            
        })
    })
}

//MARK: 随机颜色


//MARK: 随机纹理
func randomPlayerTexture() ->SKTexture
{
    switch arc4random() % 9 {
    case 0: return SKTexture(imageNamed: "playerModel_01")
    case 1: return SKTexture(imageNamed: "playerModel_02")
    case 2: return SKTexture(imageNamed: "playerModel_03")
    case 3: return SKTexture(imageNamed: "playerModel_04")
    case 4: return SKTexture(imageNamed: "playerModel_05")
    case 5: return SKTexture(imageNamed: "playerModel_06")
    case 6: return SKTexture(imageNamed: "playerModel_07")
    case 7: return SKTexture(imageNamed: "playerModel_08")
    case 8: return SKTexture(imageNamed: "playerModel_09")
        
    default :return SKTexture(imageNamed: "floorA")
    }
}


func randomchaterType() ->PlayerType{
    switch arc4random() % 3 {
    case 0: return PlayerType.A
    case 1: return PlayerType.B
    case 2: return PlayerType.C
    default :return PlayerType.A
    }
}

func randomFloorTexture() ->SKTexture
{
    switch arc4random() % 5 {
    case 0: return SKTexture(imageNamed: "floorA")
    case 1: return SKTexture(imageNamed: "floorB")
    case 2: return SKTexture(imageNamed: "floorC")
    case 3: return SKTexture(imageNamed: "floorD")
    case 4: return SKTexture(imageNamed: "floorE")
    default :return SKTexture(imageNamed: "floorA")
    }
}

func randomFlashTexture() ->SKTexture {
    switch arc4random() % 5 {
    case 0: return SKTexture(imageNamed: "flashA")
    case 1: return SKTexture(imageNamed: "flashB")
    case 2: return SKTexture(imageNamed: "flashC")
    case 3: return SKTexture(imageNamed: "flashD")
    case 4: return SKTexture(imageNamed: "flashE")
    default: return SKTexture(imageNamed: "flashA")
    }
}


func randomCloudTexture() ->SKTexture {
    switch arc4random() % 4 {
    case 0: return SKTexture(imageNamed: "cloud1")
    case 1: return SKTexture(imageNamed: "cloud2")
    case 2: return SKTexture(imageNamed: "cloud3")
    case 3: return SKTexture(imageNamed: "cloud4")
    default :return SKTexture(imageNamed: "cloud1")
    }
}

func randomGoldTexture() ->SKTexture {
    switch arc4random() % 5 {
    case 0: return SKTexture(imageNamed: "goldA")
    case 1: return SKTexture(imageNamed: "goldB")
    case 2: return SKTexture(imageNamed: "goldC")
    case 3: return SKTexture(imageNamed: "goldD")
    case 4: return SKTexture(imageNamed: "goldE")
    default :return SKTexture(imageNamed: "goldA")
    }
}

func randomPlatformContactType() ->PlatformContactType {
    switch arc4random() % 6 {
    case 0: return PlatformContactType.Long_Section
    case 1: return PlatformContactType.Spring_Section
    case 2: return PlatformContactType.Door_Section
    case 3: return PlatformContactType.Down_Section
    case 4: return PlatformContactType.BridgeMovingInX_Section
    case 5: return PlatformContactType.BridgeMovingInY_Section
    default: return PlatformContactType.Long_Section
    }
}


func randomPlatformHight() ->CGFloat {
    switch arc4random() % 2 {
    case 0: return CGFloat(80)
    case 1: return CGFloat(100)
    default :return CGFloat(0)
    }
}

// 求角色移动所需的时间
func playMovingTime(p1:CGPoint, p2:CGPoint, speed:CGFloat) ->CGFloat{
    var time:CGFloat = 0
    
    // 移动时间 = 距离/速度
    // 距离 = sqrt( (p1.x - p0.x) * (p1.x - p0.x) +  (p1.y - p0.y) * (p1.y - p0.y) )
    
    let juli:CGFloat! = sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))
    let moveSpeed:CGFloat! = speed
    
    time = juli / moveSpeed
    
    return time
}

