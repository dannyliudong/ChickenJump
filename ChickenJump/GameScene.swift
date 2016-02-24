//
//  GameScene.swift
//  Space2001
//
//  Created by liudong on 15/10/28.
//  Copyright (c) 2015年 liudong. All rights reserved.
//

import SpriteKit
//import AVFoundation

@objc protocol GameSceneDelegate {
    func updateHUD(score: Int)
    func updateGold(gold:Int)
    func updateLifeTime(time:Float)
}

class GameScene: SKScene, SKPhysicsContactDelegate, UIGestureRecognizerDelegate {
    //MARK: SpriteTextureAlats
    let bgSheet = BGSpriteTextureAltas()
    let platfromAtlats = PlatfromTextureAlats()

    let sheet = PlayerAnimationTextureAlats()
    let poc = POCRunTextureAlats()

    weak var gameSceneDelegate: GameSceneDelegate?
    
    // MARK: Properties let
    private var currentLevel: Int = 0
    
    private let playerOffset:CGFloat = 64 * 4 + 32 // 角色在屏幕中的偏移位置
    
    // MARK: private game data
    private var gameScore: CGFloat = 0 // 分数
    private var hillLevelScore:Int = 0
//    private var playing:Bool = false
//    private var canJump:Bool = true
    
    private var playertype:PlayerType!
    
    private var day = DayType.Day
    private var land = SceneLandType.Amazon
    private var weather = WeatherType.Sunny
    
    //MARK: 场景node
    private var guideFigerNode: SKNode! // 指引手指
    
    private var skyColor:    UIColor!
    private var treesColor:  UIColor!
    private var floorColor:   UIColor!
    private var kfinfColor:   UIColor!
    
    private var cloudLayerA_node: SKNode!
    private var cloudLayerB_node: SKNode!
    
    private var fogLayerA_node:SKNode!
    private var fogLayerB_node:SKNode!
    
    var flashLightNode:SKNode!
    
    // 最远层
    private var bg_HillDepth0_node: SKNode!
    //  近层
    private var bg_HillDepth1_A_node: SKNode!
    private var bg_HillDepth1_B_node: SKNode!
    //  远层
    private var bg_HillDepth2_A_node: SKNode!
    private var bg_HillDepth2_B_node: SKNode!
    
    private var screenNodeA:SKNode!
    private var screenNodeB:SKNode!
    
    private var platfromArray = [SKNode]()
    
//    private var playergroundNode:SKNode!
    
    private var playerNode: Player!
    private var magicNode: SKEmitterNode!
    
    var walkAction:SKAction!
    var pocruning:SKAction!
    
    var rainstormSceneRainSP: SKNode!
    
    //MARK: 从sks场景文件获取node
    let long_SectionNode:SKNode = {
        let scene = SKScene(fileNamed: "Long_Section.sks")!
        let node = scene.childNodeWithName("longSection")!
        
        return node
    }()
    
    let long_KnifeSectionNode:SKNode = {
        let scene = SKScene(fileNamed: "Long_KnifeSection.sks")!
        let node = scene.childNodeWithName("long_KnifeSection")!
        
        return node
    }()
    
    let door_SectionNode:SKNode = {
        let scene = SKScene(fileNamed: "Door_Section.sks")!
        let node = scene.childNodeWithName("doorSection")!
        
        return node
    }()
    
    let down_SectionNode:SKNode = {
        let scene = SKScene(fileNamed: "Down_Section.sks")!
        let node = scene.childNodeWithName("downSection")!
        
        return node
    }()
    
    let movingBridgeX_SectionNode:SKNode = {
        let scene = SKScene(fileNamed: "BridgeMovingInX_Section.sks")!
        let node = scene.childNodeWithName("movingBrdgeX")!
        
        return node
    }()
    
    let spring_Section:SKNode = {
        let scene = SKScene(fileNamed: "Spring_Section.sks")!
        let node = scene.childNodeWithName("springNode")!
        
        return node
    }()
    
    let bridgeMovingInY_Section:SKNode = {
        let scene = SKScene(fileNamed: "BridgeMovingInY_Section.sks")!
        let node = scene.childNodeWithName("bridgeMovingInYNode")!
        
        return node
    }()
    
    //MARK: SKAction

    let getGoldAction:SKAction = {
        let rotegetGold = SKAction.rotateByAngle(CGFloat.toAngle(360), duration: 0.5)
        let scalegetGold = SKAction.scaleTo(2, duration: 0.5)
        let alphtgetGold = SKAction.fadeAlphaTo(0, duration: 0.5)
        let done = SKAction.removeFromParent()
        let starAnmiationgetGold = SKAction.group([rotegetGold, scalegetGold, alphtgetGold])
        
        return SKAction.sequence([starAnmiationgetGold, done])
        
    }()
    
    let doorKeyAction:SKAction = {
        let rotegetGold = SKAction.rotateByAngle(CGFloat.toAngle(360), duration: 0.2)
        let scalegetGold = SKAction.scaleTo(2, duration: 0.2)
        let alphtgetGold = SKAction.fadeAlphaTo(0, duration: 0.2)
        let donegetGold = SKAction.removeFromParent()
        let starAnmiationgetGold = SKAction.group([rotegetGold, scalegetGold, alphtgetGold])
        
        return SKAction.sequence([starAnmiationgetGold, donegetGold])
    }()
    
    let doorOpenAction:SKAction = {
        let moveDoorKey = SKAction.moveToY(Screen_Height * 2, duration: 1.0)
        let alphtDoorKey = SKAction.fadeAlphaTo(0, duration: 0.5)
        let starAnmiationDoorKey = SKAction.group([moveDoorKey, alphtDoorKey])
        
        return SKAction.sequence([starAnmiationDoorKey])
    }()
    
    //MARK: Sound Action
    let jumpSoundAction = SKAction.playSoundFileNamed("inGame_action_jump.mp3", waitForCompletion: false)
    let getGlodSoundAction = SKAction.playSoundFileNamed("inGame_function_star.mp3", waitForCompletion: false)
    let getdoorKeySoundAction = SKAction.playSoundFileNamed("inGame_event_relayReach.mp3", waitForCompletion: false)
    
    let enemySoundAction = SKAction.playSoundFileNamed("dieSound.mp3", waitForCompletion: false)
    let waterSoundAction = SKAction.playSoundFileNamed("luoshui.mp3", waitForCompletion: false)
    let downSoundAction = SKAction.playSoundFileNamed("inGame_event_deathMonster_1.mp3", waitForCompletion: false)
    let springSoundAction = SKAction.playSoundFileNamed("springSound.mp3", waitForCompletion: false)
    
//    let rainSoundAction = SKAction.playSoundFileNamed("RainSound.mp3", waitForCompletion: false)
    let thunderSoundAction = SKAction.playSoundFileNamed("ThunderSound.mp3", waitForCompletion: false)
    
    //MARK: 场景UI 手势
    private var longPressGestureLeve1:UILongPressGestureRecognizer! // 长按手势 0.1秒

    //MARK: Did Move To View
    override func didMoveToView(view: SKView) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameScene.restartGame), name: "restartGameNotification", object:nil)
        
        // 监测天气变化
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameScene.sunnyNotificationFunc), name: "SunnyNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameScene.rainNotificationFunc), name: "RainNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameScene.snowNotificationFunc), name: "SnowNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameScene.sandstormNotificationFunc), name: "SandstormNotification", object: nil)
        
        self.physicsWorld.gravity = CGVectorMake( 0.0, Scene_Gravity)
        self.physicsWorld.contactDelegate = self
        
        self.userInteractionEnabled = true
        
        self.addGesture()
        self.setupGame()
        
    }
    
    //MARK: 手势
    func addGesture(){
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(GameScene.handleTap(_:)))
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.handleSwipes(_:)))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        
        view!.addGestureRecognizer(tap)
        view!.addGestureRecognizer(leftSwipe)
        view!.addGestureRecognizer(rightSwipe)
        
    }
    
    func handleTap(sender:UITapGestureRecognizer){
        print("handle Tap")
        touchControll(CGVectorMake(Player_Jump_Width, Player_Jump_Hight))

    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if sender.direction == .Left {
            print("Swipe Left")
            touchControll(CGVectorMake(-Player_Jump_Width, Player_Jump_Hight))

        } else if (sender.direction == .Right) {
            print("Swipe Right")
            touchControll(CGVectorMake(Player_Jump_Width, Player_Jump_Hight))

        } else if (sender.direction == .Up) {
            print("Swipe Up")
            touchControll(CGVectorMake(Player_Jump_Width, Player_Jump_Hight))

        } else if (sender.direction == .Down) {
            print("Swipe Down")
            touchControll(CGVectorMake(Player_Jump_Width, Player_Jump_Hight))
        }
        
    }
    
    
    func touchControll(vector:CGVector) {
        
        // 加载完成 才可点击屏幕
        if GameState.sharedInstance.isLoadingDone {
            
            if !GameState.sharedInstance.gameOver {
                
                if GameState.sharedInstance.canJump {
                    
                    GameState.sharedInstance.canJump = false
                    GameState.sharedInstance.lifeTimeCount = 1.2
                    
                    self.playerMoveAnimation(vector)
                    
                    //update分数
                    updateGameScore()
                }
                
            } else if GameState.sharedInstance.gameOver {
                self.startGame()
            }
        }
    }
    
    //MARK:-----------------------------  SetupGame
    func setupGame() {
        
        self.gameScore = 0
        
        self.platfromArray.removeAll()
        
//        self.playergroundNode = SKNode()
//        self.addChild(playergroundNode)
        
        self.setupColorsAndSceneLandAndWeather() // 设置颜色 天气
        
        self.initBackgroud()
        
        self.initPlaygroud()
        
        self.setupPlatfroms()
        
//        self.sceneEdgeBottom()
        
        self.waterBackgroud()
        
        self.playertype = PlayerType.B//randomchaterType()
        
        self.createPlayer()
        self.figerNode()
        
//        walkAction = SKAction.repeatActionForever(SKAction.animateWithTextures(choseChaterAnimation(playertype), timePerFrame: 0.03))
//        pocruning = SKAction.repeatActionForever(SKAction.animateWithTextures(choseChaterAnimation(playertype), timePerFrame: 0.02))
        //        customLongPressGesture()
        //        createSceneMainLights()

        GameState.sharedInstance.gameOver = true
        GameState.sharedInstance.isLoadingDone = true
        
        GameState.sharedInstance.lifeTimeCount = 1.2

        
        // 2. 游戏开始后的音乐
        let music = GameState.sharedInstance.musicState
        if music {
            // 播放音乐
            SKTAudio.sharedInstance().playBackgroundMusic(GameBGSongAudioName.NormalAudioName.rawValue)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("loadingisDoneNotification", object: nil)

    }
    
    //MARK: 重新游戏
    func restartGame() {
        
        self.removeAllChildren()
        self.removeAllActions()
        
        setupGame()

    }
    
    //MARK: 设置天气
    func setupColorsAndSceneLandAndWeather() {
//        self.day = {
//            switch arc4random() % 2 {
//            case 0: return .Day
//            case 1: return .Night
//            default: return .Day
//            }
//            }()
        
        self.day = .Night
        
        self.land = {
            switch arc4random() % 10 {
            case 0: return .Amazon
            case 1: return .Grove
            case 2: return .Volcanic
            case 3: return .LahontanValley
            case 4: return .SnowMountain
            case 5: return .MayaPyramid
            case 6: return .Iceberg
            case 7: return .BuildingShenshe
            case 8: return .Cemetery
            case 9: return .Nightsky
            default: return .Amazon
            }
            }()
        
        print("self.land : \(self.land)")

        
        self.weather = {
            switch arc4random() % 4 {
            case 0: return .Sunny
            case 1: return .Rain
            case 2: return .Snow
            case 3: return .Sandstorm
            default: return .Sunny
            }
            }()
        
        
        
        // 设置颜色
        switch self.day {
            // 白天
            
        case .Day:
            print("白天")
            
        case .Night :
            print("夜晚")
        }
        
        ////////////////
//        self.day = .Day
//        self.land = .Nightsky
        print("self.land : \(self.land)")

        
        switch self.land {
        case .Amazon:
            
            //                switch arc4random() % 5 {
            //                case 0: skyColor = SkyColor_Amazon
            //                case 1: skyColor = SkyColor_Blue_A
            //                case 2: skyColor = SkyColor_Blue_B
            //                case 3: skyColor = SkyColor_Blue_C
            //                case 4: skyColor = SkyColor_Blue_D
            //                default: skyColor = SkyColor_Amazon
            //                }
            
            skyColor = SkyColor_Amazon
            
        case .Grove:
            //                switch arc4random() % 5 {
            //                case 0: skyColor = SkyColor_Grove
            //                case 1: skyColor = SkyColor_Green_A
            //                case 2: skyColor = SkyColor_Green_B
            //                case 3: skyColor = SkyColor_Green_C
            //                case 4: skyColor = SkyColor_Green_D
            //                default: skyColor = SkyColor_Grove
            //                }
            skyColor = SkyColor_Grove
            
        case .Volcanic:
            //                switch arc4random() % 5 {
            //                case 0: skyColor = SkyColor_Volcanic
            //                case 1: skyColor = SkyColor_Orange_A
            //                case 2: skyColor = SkyColor_Orange_B
            //                case 3: skyColor = SkyColor_Orange_C
            //                case 4: skyColor = SkyColor_Orange_D
            //                default: skyColor = SkyColor_Volcanic
            //                }
            
            skyColor = SkyColor_Volcanic
            
            
        case .LahontanValley:
            //                switch arc4random() % 5 {
            //                case 0: skyColor = SkyColor_Volcanic
            //                case 1: skyColor = SkyColor_Orange_A
            //                case 2: skyColor = SkyColor_Orange_B
            //                case 3: skyColor = SkyColor_Orange_C
            //                case 4: skyColor = SkyColor_Orange_D
            //                default: skyColor = SkyColor_Volcanic
            //                }
            
            skyColor = SkyColor_LahontanValley
            
            
        case .SnowMountain:
            //                switch arc4random() % 2 {
            //                case 0: skyColor = randomColor(Hue.Blue, luminosity: Luminosity.Light)
            //                case 1: skyColor = randomSkyColorsDay()
            //                default: skyColor = randomColor(Hue.Blue, luminosity: Luminosity.Light)
            //
            //                }
            skyColor = SkyColor_SnowMountain
            
            
        case .MayaPyramid:
            
            skyColor = SkyColor_MayaPyramid
            
        case .Iceberg:
            skyColor = SkyColor_Iceberg
            
        case .BuildingShenshe:
            skyColor = SkyColor_BuildingShenshe
            
        case .Cemetery:
            skyColor = SkyColor_Cemetery
            
        case .Nightsky:
            skyColor = SkyColor_Nightsky
        }


        self.backgroundColor = skyColor
        
        observerWeather()
    }
    
    /**
     获取纹理1
     - type: 根据类型返回所需类型
     */
    func getSceneLandTexutreWithDepth1(type:SceneLandType) ->SKTexture {
        switch type {
        case .Amazon:
            return bgSheet.BG_shanA1()
        case .Grove:
            switch arc4random() % 3 {
            case 0 :return bgSheet.BG_treeA1()
            case 1 :return bgSheet.BG_treeB1()
            case 2 :return bgSheet.BG_treeC1()
            default:return bgSheet.BG_treeA1()
            }
            
        case .Volcanic:
            return bgSheet.BG_huoshanA1()
            
        case .LahontanValley:
            switch arc4random() % 4 {
            case 0 :return bgSheet.BG_xiaguA1()
            case 1 :return bgSheet.BG_xiaguB1()
            case 2 :return bgSheet.BG_xiaguC1()
            case 3 :return bgSheet.BG_xiaguD1()
            default:return bgSheet.BG_xiaguA1()
            }
        case .SnowMountain:
            return bgSheet.BG_shanA1()
        case .MayaPyramid:
            return bgSheet.BG_mayaA1()
        case .Iceberg:
            switch arc4random() % 3 {
            case 0 :return bgSheet.BG_binshanA1()
            case 1 :return bgSheet.BG_binshanB1()
            case 2 :return bgSheet.BG_binshanC1()
            default:return bgSheet.BG_binshanA1()
            }
        case .BuildingShenshe:
            return bgSheet.birdDoorA1()
        case .Cemetery:
            switch arc4random() % 3 {
            case 0 :return bgSheet.BG_mudiA1()
            case 1 :return bgSheet.BG_mudiB1()
            case 2 :return bgSheet.BG_mudiC1()
            default:return bgSheet.BG_mudiA1()
            }
            
        case .Nightsky:
            return bgSheet.BG_shanA1()
        }
    }
    
    /**
     获取纹理2
     - type: 根据类型返回所需类型
     */
    func getSceneLandTexutreWithDepth2(type:SceneLandType) ->SKTexture {
        switch type {
        case .Amazon:
            return bgSheet.BG_shanA2()
        case .Grove:
            switch arc4random() % 3 {
            case 0 :return bgSheet.BG_treeA2()
            case 1 :return bgSheet.BG_treeB2()
            case 2 :return bgSheet.BG_treeC2()
            default:return bgSheet.BG_treeA2()
            }
        case .Volcanic:
            return bgSheet.BG_huoshanA2()
            
        case .LahontanValley:
            switch arc4random() % 3 {
            case 0 :return bgSheet.BG_xiaguA2()
            case 1 :return bgSheet.BG_xiaguB2()
            case 2 :return bgSheet.BG_xiaguC2()
            case 3 :return bgSheet.BG_xiaguD2()
            default:return bgSheet.BG_xiaguA2()
            }
        case .SnowMountain:
            return bgSheet.BG_shanA2()
            
        case .MayaPyramid:
            return bgSheet.BG_mayaA2()
            
        case .Iceberg:
            switch arc4random() % 3 {
            case 0 :return bgSheet.BG_binshanA2()
            case 1 :return bgSheet.BG_binshanB2()
            case 2 :return bgSheet.BG_binshanC1()
            default:return bgSheet.BG_binshanC2()
            }
        case .BuildingShenshe:
            return bgSheet.birdDoorA2()
            
        case .Cemetery:
            switch arc4random() % 3 {
            case 0 :return bgSheet.BG_mudiA2()
            case 1 :return bgSheet.BG_mudiB2()
            case 2 :return bgSheet.BG_mudiC2()
            default:return bgSheet.BG_mudiA2()
            }
            
        case .Nightsky:
            return bgSheet.BG_shanA2()
        }
    }
    
    
    // 背景
    func initBackgroud() {
        createBG_layer()
        
        if self.land == .Amazon || self.land == .Volcanic || self.land == .SnowMountain || self.land == .Iceberg || self.land == .Nightsky {
            createBG_HillDepth0_Layer()
//            sceneWithSunMoon()
        }
        
        // 近层
        self.bg_HillDepth1_A_node = createBG_Hill_Layer(BGDetphType.LayerA, zPosition: -50)
        self.bg_HillDepth1_A_node.position = CGPointMake(0, BG_hight)
        addChild(self.bg_HillDepth1_A_node)
        
        self.bg_HillDepth1_B_node = createBG_Hill_Layer(BGDetphType.LayerA, zPosition: -50)
        self.bg_HillDepth1_B_node.position = CGPointMake(Screen_Width, BG_hight)
        addChild(bg_HillDepth1_B_node)
        
        // 远层
        self.bg_HillDepth2_A_node = createBG_Hill_Layer(BGDetphType.LayerB, zPosition: -80)
        self.bg_HillDepth2_A_node.position = CGPointMake(0, BG_hight)
        addChild(bg_HillDepth2_A_node)
        
        self.bg_HillDepth2_B_node = createBG_Hill_Layer(BGDetphType.LayerB, zPosition: -80)
        self.bg_HillDepth2_B_node.position = CGPointMake(Screen_Width, BG_hight)
        addChild(bg_HillDepth2_B_node)
        
        
//        if land == .Amazon  && self.weather != .Rain {
//            createBG_CloudLayerA(Int(CGFloat.random(min: 3, max: 8)), position: CGPointMake(0, 0))
//            createBG_CloudLayerB(Int(CGFloat.random(min: 3, max: 8)), position: CGPointMake(Screen_Width, 0))
//        }
        print("BG_hight \(BG_hight)")
        
    }
    
    
    // 前层
    func initPlaygroud() {
        
        let nodeLong_Section = createPlatfromNodeWithSKS(self.long_SectionNode)
        self.platfromArray.append(nodeLong_Section)
        
        let nodeLong_KnifeSection = createPlatfromNodeWithSKS(self.long_KnifeSectionNode)
        self.platfromArray.append(nodeLong_KnifeSection)

        let nodeDoor_Section = createPlatfromNodeWithSKS(self.door_SectionNode)
        self.platfromArray.append(nodeDoor_Section)
        
        let nodeDown_Section = createPlatfromNodeWithSKS(self.down_SectionNode)
        self.platfromArray.append(nodeDown_Section)
        
        let nodeMovingBridgeX_Section = createPlatfromNodeWithSKS(self.movingBridgeX_SectionNode)
        self.platfromArray.append(nodeMovingBridgeX_Section)
        
        let nodeSpring_Section = createPlatfromNodeWithSKS(self.spring_Section)
        self.platfromArray.append(nodeSpring_Section)
        
        let nodeBridgeMovingInY_Section = createPlatfromNodeWithSKS(self.bridgeMovingInY_Section)
        self.platfromArray.append(nodeBridgeMovingInY_Section)
        
        print("selfplatfromArray \(self.platfromArray.count) ")

    }
    
    func setupPlatfroms() {
        
        self.screenNodeA = platfromArray[0].copy() as! SKNode
        self.screenNodeA.position =  CGPointMake(0, PlatformHight)
        addChild(screenNodeA)

        self.screenNodeB = platfromArray[5].copy() as! SKNode
        self.screenNodeB.position =  CGPointMake(Screen_Width,PlatformHight)
        addChild(screenNodeB)

    }
    
    //MARK: 天气场景
    func observerWeather() {
        
        switch self.weather {
        case .Sunny:
            print("晴天......")
            NSNotificationCenter.defaultCenter().postNotificationName("SunnyNotification", object: nil)
        case .Rain:
            print("雨......")
            NSNotificationCenter.defaultCenter().postNotificationName("RainNotification", object: nil)
        case .Snow:
            if self.land != .LahontanValley {
                print("雪......")
//                NSNotificationCenter.defaultCenter().postNotificationName("SnowNotification", object: nil)
            }
            
        case .Sandstorm:
            print("沙尘......")
//            NSNotificationCenter.defaultCenter().postNotificationName("SandstormNotification", object: nil) //Sandstorm
        }
        
    }
    
    
    //MARK: 随机创建平台
    func createPlatfromByRandom() -> SKNode {
        switch arc4random() % 7 {
        case 0:
            let longSectionNode = LongSectionNode(wallTexture: SKTexture(imageNamed:""), walltopTexture: SKTexture(imageNamed:""), floorTexture: SKTexture(imageNamed:""), color: getWallColorWith(SceneLandType.Amazon))
            
            return longSectionNode
        default:
            return SKNode()
        }
    }
    
    //MARK: 从SKS文件创建场景
    func createPlatfromNodeWithSKS(node:SKNode) ->SKNode {
        
        let platfromNode = node.copy() as! SKNode
        
        if let nodes = platfromNode.childNodeWithName("floorNodes") {

            for node in nodes.children {
                
                let _node = node as! SKSpriteNode
                _node.texture = setPlatformTextureWithFloor(self.land)
                
                _node.physicsBody?.friction = 0
                _node.physicsBody?.charge = 0
                _node.physicsBody?.restitution = 0
                _node.physicsBody?.linearDamping = 0
                _node.physicsBody?.angularDamping = 0
            }
        }
        
        // 左右移动的平台
        if let nodes = platfromNode.childNodeWithName("floorMoveXNodes") {
            
            for node in nodes.children {
                
                let _node = node as! SKSpriteNode
                _node.texture = setPlatformTextureWithFloor(self.land)
                
                _node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Normal_Floor
                _node.physicsBody?.friction = 0
                _node.physicsBody?.charge = 0
                _node.physicsBody?.restitution = 0
                _node.physicsBody?.linearDamping = 0
                _node.physicsBody?.angularDamping = 0
                
                
                let wait = SKAction.waitForDuration(NSTimeInterval(CGFloat.random(min: 1.0, max: 2.0)))
                let sequence = SKAction.sequence([wait, SKAction.moveToX_Cycle(64 , time: NSTimeInterval(CGFloat.random(min: 1.0, max: 1.5)))])
                
                _node.runAction(sequence)
            }
        }
        
        // 上下移动的平台
        
        if let nodes = platfromNode.childNodeWithName("floorMoveYNodes") {
            
            for node in nodes.children {
                
                let _node = node as! SKSpriteNode
                _node.texture = setPlatformTextureWithFloor(self.land)
                
                _node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Normal_Floor
                _node.physicsBody?.friction = 0
                _node.physicsBody?.charge = 0
                _node.physicsBody?.restitution = 0
                _node.physicsBody?.linearDamping = 0
                _node.physicsBody?.angularDamping = 0
                
                let wait = SKAction.waitForDuration(NSTimeInterval(CGFloat.random(min: 1.0, max: 2.0)))
                let sequence = SKAction.sequence([wait, SKAction.moveToY_Cycle(64 * 6, time: NSTimeInterval(CGFloat.random(min: 2.0, max: 4.0)))])
                
                _node.runAction(sequence)
            }
        }
        
        if let nodes = platfromNode.childNodeWithName("wallNodes") {
            for node in nodes.children {
                
                let _node = node as! SKSpriteNode
                _node.texture = setPlatformTextureWithWall(self.land)
            }
        }
        
        if let nodes = platfromNode.childNodeWithName("knifeNodes") {
            
            for node in nodes.children {
                
                let _node = node as! SKSpriteNode
//                _node.s
                _node.texture = platfromAtlats.kifne()
                
                let wait = SKAction.waitForDuration(NSTimeInterval(CGFloat.random(min: 0.0, max: 2.0)))
                let sequence = SKAction.sequence([wait, SKAction.moveToY_Cycle(380, time: NSTimeInterval(CGFloat.random(min: 2.5, max: 4.0)))])
                _node.runAction(sequence)
                
            }
        }
        
        if let nodes = platfromNode.childNodeWithName("knifeOffNodes") {
            
            for node in nodes.children {
                
                let _node = node as! SKSpriteNode
                _node.texture = platfromAtlats.kifne()
            }
        }
        
        
        if let nodes = platfromNode.childNodeWithName("downFloorNodes") {
            
            for node in nodes.children {
                
                let _node = node as! SKSpriteNode
                _node.texture = setPlatformTextureWithDownFloor(self.land)
                
                _node.physicsBody?.friction = 0
                _node.physicsBody?.charge = 0
                _node.physicsBody?.restitution = 0
                _node.physicsBody?.linearDamping = 0
                _node.physicsBody?.angularDamping = 0
            }
        }
        
        if let nodes = platfromNode.childNodeWithName("hiddenNodes") {
            
            for node in nodes.children {
                
                let _node = node as! SKSpriteNode
                _node.texture = setPlatformTextureWithFloor(self.land)
                
                _node.hidden = true
                _node.physicsBody?.friction = 0
                _node.physicsBody?.charge = 0
                _node.physicsBody?.restitution = 0
                _node.physicsBody?.linearDamping = 0
                _node.physicsBody?.angularDamping = 0

            }
        }
        
        if let nodes = platfromNode.childNodeWithName("spingNodes") {
   
            for node in nodes.children {
                
                let _node = node as! SKSpriteNode
                _node.texture = setPlatformTextureWithSpring(self.land)
                
                _node.physicsBody?.friction = 0
                _node.physicsBody?.charge = 0
                _node.physicsBody?.restitution = 0
                _node.physicsBody?.linearDamping = 0
                _node.physicsBody?.angularDamping = 0
            }
        }
        
        if let nodes = platfromNode.childNodeWithName("skphyNodes") {
            
            for node in nodes.children {
                
                node.physicsBody?.friction = 0
                node.physicsBody?.restitution = 0
                node.physicsBody?.linearDamping = 0
                node.physicsBody?.angularDamping = 0
                node.physicsBody?.charge = 0
            }
        }
        return platfromNode
    }

    
    //MARK: 场景边缘
    func sceneEdgeBottom() {
        
        let edgeBottom = SKSpriteNode(color: UIColor.clearColor(), size: CGSizeMake(Screen_Width, 10))
        edgeBottom.position = CGPointMake(Screen_Width * 0.5, 0)
        edgeBottom.physicsBody = SKPhysicsBody(rectangleOfSize: edgeBottom.size)
        edgeBottom.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Enemy
        edgeBottom.physicsBody?.collisionBitMask = CollisionCategoryBitmask.None
        edgeBottom.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.None
        
        edgeBottom.physicsBody?.dynamic = false
        edgeBottom.physicsBody?.allowsRotation = false
        
        edgeBottom.physicsBody?.friction = 0
        edgeBottom.physicsBody?.restitution = 0
        
        edgeBottom.physicsBody?.linearDamping = 0
        edgeBottom.physicsBody?.angularDamping = 0
        
        edgeBottom.physicsBody?.charge = 0
        
        addChild(edgeBottom)
        
        let edgeLeft = SKSpriteNode(color: UIColor.clearColor(), size: CGSizeMake(10, Screen_Height))
        edgeLeft.position = CGPointMake(0, Screen_Height * 0.5)
        edgeLeft.physicsBody = SKPhysicsBody(rectangleOfSize: edgeLeft.size)
        edgeLeft.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Enemy
        edgeLeft.physicsBody?.collisionBitMask = CollisionCategoryBitmask.None
        edgeLeft.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.None
        
        edgeLeft.physicsBody?.dynamic = false
        edgeLeft.physicsBody?.allowsRotation = false
        
        edgeLeft.physicsBody?.friction = 0
        edgeLeft.physicsBody?.restitution = 0
        
        edgeLeft.physicsBody?.linearDamping = 0
        edgeLeft.physicsBody?.angularDamping = 0
        
        edgeLeft.physicsBody?.charge = 0
        
        addChild(edgeLeft)
        
    }
    
    //MARK: 构建场景相关
    //MARL:  水
    func waterBackgroud() {
        
        let waterColor: UIColor = {
            switch self.land {
                
            case .Amazon:
                return SKColorWithRGB(66, g: 185, b: 254)
            case .Grove:
                return SKColorWithRGB(79, g: 178, b: 35)
            case .Volcanic:
                return SKColorWithRGB(255, g: 185, b: 51)
            case .LahontanValley:
                return SKColorWithRGB(255, g: 199, b: 69)
            case .SnowMountain:
                return SKColorWithRGB(239, g: 252, b: 255)
            case .MayaPyramid:
                return SKColorWithRGB(9, g: 132, b: 130)
            case .Iceberg:
                return SKColorWithRGB(179, g: 242, b: 253)
            case .BuildingShenshe:
                return SKColorWithRGB(12, g: 155, b: 206)
            case .Cemetery:
                return SKColorWithRGB(88, g: 118, b: 144)
            case .Nightsky:
                return SKColorWithRGB(105, g: 10, b: 188)
            }
        }()
        
        let water = GameSpriteNodeWithWaterBackgroud(waterColor)
        water.position = CGPointMake(Screen_Width * 0.5, water.size.height * 0.5)
        
        addChild(water)
    }
    
    // 背景颜色层
    func createBG_layer() {
        
        let texture = SKTexture(imageNamed: "BGLayer")
        let bg = SKSpriteNode(texture: texture, color: self.skyColor, size: Screen_Size)
        bg.position = CGPointMake(Screen_Width * 0.5, Screen_Height * 0.5)
        bg.zPosition = -300
        bg.colorBlendFactor = SceneSprite_ColorBlendFactor_Mountain
        
//        bg.lightingBitMask = LightingBitMask.BGLight | LightingBitMask.FlashLight
        
        addChild(bg)
    }
    
    //最远景层
    func createBG_HillDepth0_Layer() {
        
        self.bg_HillDepth0_node = SKNode()
        self.bg_HillDepth0_node.setScale(1.0)
        self.bg_HillDepth0_node.position = CGPointMake(Screen_Width * 0.5, Screen_Height * 0.4)
        addChild(self.bg_HillDepth0_node)
        
        let image = SKTexture(imageNamed: "hillA")
        let hill = SKSpriteNode(texture:image , color: skyColor, size: image.size())
        hill.zPosition = -200
        hill.colorBlendFactor = SceneSprite_ColorBlendFactor_Mountain
        
//        hill.lightingBitMask = LightingBitMask.BGLight | LightingBitMask.FlashLight
        
        self.bg_HillDepth0_node.addChild(hill)
        
        //        let hillLighting = SKSpriteNode(imageNamed: "hillLight")
        //        hillLighting.anchorPoint = CGPointMake(0.5, 1)
        //        hillLighting.position = CGPointMake(hill.width * 0.5, hill.height)
        //        hillLighting.zPosition = -60
        //        hillLighting.alpha = 0.6
        //        bg_HillDepth0_node.addChild(hillLighting)
        
        //        let halo = SKSpriteNode(imageNamed: "hillLighthalo")
        //        halo.position = CGPointMake(hill.width * 0.5, hill.height)
        //        halo.setScale(0.7)
        //        halo.zPosition = -80
        //        halo.alpha = 0.6
        //        bg_HillDepth0_node.addChild(halo)
        
        
    }
    
    //MARK: 背景移动层
    func createBG_Hill_Layer(depth:BGDetphType, zPosition:CGFloat) ->SKNode {
        let node = SKNode()
        
        var count:Int!
        var dt:CGFloat!
        
        var ScaleRadio:CGFloat! = 1
        
        switch self.land {
        case .Amazon:
            switch depth {
            case .LayerA:
                count = Int(CGFloat.random(min: 1, max: 2))
                dt = CGFloat.random(min:100, max: 200)
                ScaleRadio = CGFloat.random(min: 1.6, max: 1.8)

            case .LayerB:
                count =  Int(CGFloat.random(min: 2, max: 3))
                dt = CGFloat.random(min: 50, max: 100)
                ScaleRadio = CGFloat.random(min: 1, max: 1.4)
            }

        case .Grove:
            switch depth {
            case .LayerA:
                count = Int(CGFloat.random(min: 2, max: 4))
                dt = CGFloat.random(min: 100, max: 200)
                ScaleRadio = CGFloat.random(min: 1.0, max: 1.2)
                
            case .LayerB:
                count =  Int(CGFloat.random(min: 4, max: 6))
                dt = CGFloat.random(min: 50, max: 80)
                ScaleRadio = CGFloat.random(min: 0.8, max: 1.0)
            }
            
        case .Volcanic:
            switch depth {
            case .LayerA:
                count = Int(CGFloat.random(min: 2, max: 3))
                dt = CGFloat.random(min:100, max: 200)
                ScaleRadio = CGFloat.random(min: 1.4, max: 1.6)
            case .LayerB:
                count =  Int(CGFloat.random(min: 3, max: 4))
                dt = CGFloat.random(min: 50, max: 100)
                ScaleRadio = CGFloat.random(min: 1.0, max: 1.2)
            }
        case .LahontanValley:
            switch depth {
            case .LayerA:
                count = Int(CGFloat.random(min: 2, max: 3))
                dt = CGFloat.random(min:100, max: 150)
                ScaleRadio = CGFloat.random(min: 1.0, max: 1.2)
            case .LayerB:
                count =  Int(CGFloat.random(min: 3, max: 4))
                dt = CGFloat.random(min: 50, max: 100)
                ScaleRadio = CGFloat.random(min: 0.6, max: 0.8)
            }
        case .SnowMountain:
            switch depth {
            case .LayerA:
                count = Int(CGFloat.random(min: 1, max: 2))
                dt = CGFloat.random(min:100, max: 200)
                ScaleRadio = CGFloat.random(min: 1.4, max: 1.6)
            case .LayerB:
                count =  Int(CGFloat.random(min: 2, max: 4))
                dt = CGFloat.random(min: 50, max: 100)
                ScaleRadio = CGFloat.random(min: 1.0, max: 1.2)
            }
        case .MayaPyramid:
            switch depth {
            case .LayerA:
                count = Int(CGFloat.random(min: 2, max: 3))
                dt = CGFloat.random(min:100, max: 200)
                ScaleRadio = CGFloat.random(min: 1.4, max: 1.6)
            case .LayerB:
                count =  Int(CGFloat.random(min: 2, max: 4))
                dt = CGFloat.random(min: 50, max: 100)
                ScaleRadio = CGFloat.random(min: 1.0, max: 1.2)
            }
        case .Iceberg:
            switch depth {
            case .LayerA:
                count = Int(CGFloat.random(min: 2, max: 3))
                dt = CGFloat.random(min:100, max: 200)
                ScaleRadio = CGFloat.random(min: 1.2, max: 1.4)
            case .LayerB:
                count =  Int(CGFloat.random(min: 3, max: 5))
                dt = CGFloat.random(min: 50, max: 100)
                ScaleRadio = CGFloat.random(min: 0.8, max: 1.0)
            }
        case .BuildingShenshe:
            switch depth {
            case .LayerA:
                count = Int(CGFloat.random(min: 2, max: 3))
                dt = CGFloat.random(min: 100, max: 200)
                ScaleRadio = CGFloat.random(min: 0.6, max: 0.8)
            case .LayerB:
                count =  Int(CGFloat.random(min: 2, max: 4))
                dt = CGFloat.random(min: 50, max: 80)
                ScaleRadio = CGFloat.random(min: 0.4, max: 0.6)
            }
        case .Cemetery:
            switch depth {
            case .LayerA:
                count = Int(CGFloat.random(min: 3, max: 4))
                dt = CGFloat.random(min: 100, max: 200)
                ScaleRadio = CGFloat.random(min: 0.6, max: 0.8)
            case .LayerB:
                count =  Int(CGFloat.random(min: 4, max: 5))
                dt = CGFloat.random(min: 50, max: 100)
                ScaleRadio = CGFloat.random(min: 0.4, max: 0.5)
            }
            

        case .Nightsky:
            
            switch depth {
            case .LayerA:
                count = Int(CGFloat.random(min: 1, max: 2))
                dt = CGFloat.random(min:100, max: 200)
                ScaleRadio = CGFloat.random(min: 1.2, max: 1.4)
            case .LayerB:
                count =  Int(CGFloat.random(min: 2, max: 3))
                dt = CGFloat.random(min: 50, max: 100)
                ScaleRadio = CGFloat.random(min: 1, max: 1.2)
            }
        }
        
        var lastHill_NodeX:CGFloat = -100
        
        for _ in 0 ..< count {
            
            var texture:SKTexture!
            
            switch depth {
            case .LayerA :
                texture = getSceneLandTexutreWithDepth1(land)
                
            case .LayerB :
                texture = getSceneLandTexutreWithDepth2(land)
            }
            
            let hill = SKSpriteNode(texture: texture, color: skyColor, size: texture.size())
            hill.setScale(ScaleRadio)
            hill.position = CGPointMake(lastHill_NodeX + texture.size().width * 0.5 + dt , 0)
            hill.anchorPoint = CGPointMake(0.5, 0)
            hill.zPosition = zPosition + CGFloat.random(min: -50, max: -30)
            hill.colorBlendFactor = SceneSprite_ColorBlendFactor_Mountain
            
            if self.land == .Cemetery {
                hill.zRotation = CGFloat.toAngle(Double(CGFloat.random(min: -10, max: 10)))
            }
            
            node.addChild(hill)
            lastHill_NodeX = hill.position.x
            
            //            hill.lightingBitMask = LightingBitMask.MainLight
            //            hill.lightingBitMask = LightingBitMask.BGLight | LightingBitMask.FlashLight
            
            
            //            let imagedoor = SKTexture(imageNamed: "birdDoor")
            //            let birdDoor = SKSpriteNode(texture: imagedoor, color: skyColor, size: imagedoor.size())
            //            birdDoor.position = CGPointMake(0, hill.height)
            //            birdDoor.anchorPoint = CGPointMake(0.5, 0)
            //            birdDoor.zPosition = -45
            //            birdDoor.colorBlendFactor = 1
            //
            //            node.addChild(birdDoor)
            
        }
        return node
    }
    
    //MARK: 设置纹理 : 根据指定的类型 设置纹理
    func setPlatformTextureWithFloor(type: SceneLandType) ->SKTexture {
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
    
    func setPlatformTextureWithWall(type: SceneLandType) ->SKTexture{
        switch type {
        case .Amazon:
            switch arc4random() % 12 {
            case 0: return platfromAtlats.AmazonWall1()
            case 1: return platfromAtlats.AmazonWall2()
            case 2: return platfromAtlats.AmazonWall3()
            case 3: return platfromAtlats.AmazonWall4()
            case 4: return platfromAtlats.AmazonWall5()
            case 5: return platfromAtlats.AmazonWall6()
            case 6: return platfromAtlats.AmazonWall7()
            case 7: return platfromAtlats.AmazonWall8()
            case 8: return platfromAtlats.AmazonWall9()
            case 9: return platfromAtlats.AmazonWall10()
            case 10: return platfromAtlats.AmazonWall11()
            case 11: return platfromAtlats.AmazonWall12()
            default :return platfromAtlats.AmazonWall1()
            }
        case .Grove:
            switch arc4random() % 12 {
            case 0: return platfromAtlats.GroveWall1()
            case 1: return platfromAtlats.GroveWall2()
            case 2: return platfromAtlats.GroveWall3()
            case 3: return platfromAtlats.GroveWall4()
            case 4: return platfromAtlats.GroveWall5()
            case 5: return platfromAtlats.GroveWall6()
            case 6: return platfromAtlats.GroveWall7()
            case 7: return platfromAtlats.GroveWall8()
            case 8: return platfromAtlats.GroveWall9()
            case 9: return platfromAtlats.GroveWall10()
            case 10: return platfromAtlats.GroveWall11()
            case 11: return platfromAtlats.GroveWall12()
            default :return platfromAtlats.GroveWall1()
            }
        case .Volcanic:
            switch arc4random() % 12 {
            case 0: return platfromAtlats.VolcanicWall1()
            case 1: return platfromAtlats.VolcanicWall2()
            case 2: return platfromAtlats.VolcanicWall3()
            case 3: return platfromAtlats.VolcanicWall4()
            case 4: return platfromAtlats.VolcanicWall5()
            case 5: return platfromAtlats.VolcanicWall6()
            case 6: return platfromAtlats.VolcanicWall7()
            case 7: return platfromAtlats.VolcanicWall8()
            case 8: return platfromAtlats.VolcanicWall9()
            case 9: return platfromAtlats.VolcanicWall10()
            case 10: return platfromAtlats.VolcanicWall11()
            case 11: return platfromAtlats.VolcanicWall12()
            default :return platfromAtlats.VolcanicWall1()
            }
        case .LahontanValley:
            switch arc4random() % 12 {
            case 0: return platfromAtlats.LahontanValleyWall1()
            case 1: return platfromAtlats.LahontanValleyWall2()
            case 2: return platfromAtlats.LahontanValleyWall3()
            case 3: return platfromAtlats.LahontanValleyWall4()
            case 4: return platfromAtlats.LahontanValleyWall5()
            case 5: return platfromAtlats.LahontanValleyWall6()
            case 6: return platfromAtlats.LahontanValleyWall7()
            case 7: return platfromAtlats.LahontanValleyWall8()
            case 8: return platfromAtlats.LahontanValleyWall9()
            case 9: return platfromAtlats.LahontanValleyWall10()
            case 10: return platfromAtlats.LahontanValleyWall11()
            case 11: return platfromAtlats.LahontanValleyWall12()
            default :return platfromAtlats.LahontanValleyWall1()
            }
        case .SnowMountain:
            switch arc4random() % 12 {
            case 0: return platfromAtlats.SnowMountainWall1()
            case 1: return platfromAtlats.SnowMountainWall2()
            case 2: return platfromAtlats.SnowMountainWall3()
            case 3: return platfromAtlats.SnowMountainWall4()
            case 4: return platfromAtlats.SnowMountainWall5()
            case 5: return platfromAtlats.SnowMountainWall6()
            case 6: return platfromAtlats.SnowMountainWall7()
            case 7: return platfromAtlats.SnowMountainWall8()
            case 8: return platfromAtlats.SnowMountainWall9()
            case 9: return platfromAtlats.SnowMountainWall10()
            case 10: return platfromAtlats.SnowMountainWall11()
            case 11: return platfromAtlats.SnowMountainWall12()
            default :return platfromAtlats.SnowMountainWall1()
            }
        case .MayaPyramid:
            switch arc4random() % 12 {
            case 0: return platfromAtlats.MayaPyramidWall1()
            case 1: return platfromAtlats.MayaPyramidWall2()
            case 2: return platfromAtlats.MayaPyramidWall3()
            case 3: return platfromAtlats.MayaPyramidWall4()
            case 4: return platfromAtlats.MayaPyramidWall5()
            case 5: return platfromAtlats.MayaPyramidWall6()
            case 6: return platfromAtlats.MayaPyramidWall7()
            case 7: return platfromAtlats.MayaPyramidWall8()
            case 8: return platfromAtlats.MayaPyramidWall9()
            case 9: return platfromAtlats.MayaPyramidWall10()
            case 10: return platfromAtlats.MayaPyramidWall11()
            case 11: return platfromAtlats.MayaPyramidWall12()
            default :return platfromAtlats.MayaPyramidWall1()
            }
        case .Iceberg:
            switch arc4random() % 12 {
            case 0: return platfromAtlats.IcebergWall1()
            case 1: return platfromAtlats.IcebergWall2()
            case 2: return platfromAtlats.IcebergWall3()
            case 3: return platfromAtlats.IcebergWall4()
            case 4: return platfromAtlats.IcebergWall5()
            case 5: return platfromAtlats.IcebergWall6()
            case 6: return platfromAtlats.IcebergWall7()
            case 7: return platfromAtlats.IcebergWall8()
            case 8: return platfromAtlats.IcebergWall9()
            case 9: return platfromAtlats.IcebergWall10()
            case 10: return platfromAtlats.IcebergWall11()
            case 11: return platfromAtlats.IcebergWall12()
            default :return platfromAtlats.IcebergWall1()
            }
        case .BuildingShenshe:
            switch arc4random() % 12 {
            case 0: return platfromAtlats.ShensheWall1()
            case 1: return platfromAtlats.ShensheWall2()
            case 2: return platfromAtlats.ShensheWall3()
            case 3: return platfromAtlats.ShensheWall4()
            case 4: return platfromAtlats.ShensheWall5()
            case 5: return platfromAtlats.ShensheWall6()
            case 6: return platfromAtlats.ShensheWall7()
            case 7: return platfromAtlats.ShensheWall8()
            case 8: return platfromAtlats.ShensheWall9()
            case 9: return platfromAtlats.ShensheWall10()
            case 10: return platfromAtlats.ShensheWall11()
            case 11: return platfromAtlats.ShensheWall12()
            default :return platfromAtlats.ShensheWall1()
            }
        case .Cemetery:
            switch arc4random() % 12 {
            case 0: return platfromAtlats.CemeteryWall1()
            case 1: return platfromAtlats.CemeteryWall2()
            case 2: return platfromAtlats.CemeteryWall3()
            case 3: return platfromAtlats.CemeteryWall4()
            case 4: return platfromAtlats.CemeteryWall5()
            case 5: return platfromAtlats.CemeteryWall6()
            case 6: return platfromAtlats.CemeteryWall7()
            case 7: return platfromAtlats.CemeteryWall8()
            case 8: return platfromAtlats.CemeteryWall9()
            case 9: return platfromAtlats.CemeteryWall10()
            case 10: return platfromAtlats.CemeteryWall11()
            case 11: return platfromAtlats.CemeteryWall12()
            default :return platfromAtlats.CemeteryWall1()
            }
        case .Nightsky:
            switch arc4random() % 12 {
            case 0: return platfromAtlats.NightskyWall1()
            case 1: return platfromAtlats.NightskyWall2()
            case 2: return platfromAtlats.NightskyWall3()
            case 3: return platfromAtlats.NightskyWall4()
            case 4: return platfromAtlats.NightskyWall5()
            case 5: return platfromAtlats.NightskyWall6()
            case 6: return platfromAtlats.NightskyWall7()
            case 7: return platfromAtlats.NightskyWall8()
            case 8: return platfromAtlats.NightskyWall9()
            case 9: return platfromAtlats.NightskyWall10()
            case 10: return platfromAtlats.NightskyWall11()
            case 11: return platfromAtlats.NightskyWall12()
            default :return platfromAtlats.NightskyWall1()
            }
        }
        
        
    }
    
    func setPlatformTextureWithSpring(type: SceneLandType) ->SKTexture{
        switch type {
        case .Amazon:
            return platfromAtlats.AmazonSpring()
        case .Grove:
            return platfromAtlats.GroveSpring()
        case .Volcanic:
            return platfromAtlats.VolcanicSpring()
        case .LahontanValley:
            return platfromAtlats.LahontanValleySpring()
        case .SnowMountain:
            return platfromAtlats.SnowMountainSpring()
        case .MayaPyramid:
            return platfromAtlats.MayaPyramidSpring()
        case .Iceberg:
            return platfromAtlats.IcebergSpring()
        case .BuildingShenshe:
            return platfromAtlats.ShensheSpring()
        case .Cemetery:
            return platfromAtlats.CemeterySpring()
        case .Nightsky:
            return platfromAtlats.NightskySpring()
        }
        
    }
    
    func setPlatformTextureWithDownFloor(type: SceneLandType) ->SKTexture{
        switch type {
        case .Amazon:
            switch arc4random() % 2 {
            case 0: return platfromAtlats.AmazonDownFloor1()
            case 1: return platfromAtlats.AmazonDownFloor2()
            default :return platfromAtlats.AmazonDownFloor1()
            }
        case .Grove:
            switch arc4random() % 2 {
            case 0: return platfromAtlats.GroveDownFloor1()
            case 1: return platfromAtlats.GroveDownFloor2()
            default :return platfromAtlats.GroveDownFloor1()
            }
        case .Volcanic:
            switch arc4random() % 2 {
            case 0: return platfromAtlats.VolcanicDownFloor1()
            case 1: return platfromAtlats.VolcanicDownFloor2()
            default :return platfromAtlats.VolcanicDownFloor1()
            }
        case .LahontanValley:
            switch arc4random() % 2 {
            case 0: return platfromAtlats.LahontanValleyDownFloor1()
            case 1: return platfromAtlats.LahontanValleyDownFloor2()
            default :return platfromAtlats.LahontanValleyDownFloor1()
            }
        case .SnowMountain:
            switch arc4random() % 2 {
            case 0: return platfromAtlats.SnowMountainDownFloor1()
            case 1: return platfromAtlats.SnowMountainDownFloor2()
            default :return platfromAtlats.SnowMountainDownFloor1()
            }
        case .MayaPyramid:
            switch arc4random() % 2 {
            case 0: return platfromAtlats.MayaPyramidDownFloor1()
            case 1: return platfromAtlats.MayaPyramidDownFloor2()
            default :return platfromAtlats.MayaPyramidDownFloor1()
            }
        case .Iceberg:
            switch arc4random() % 2 {
            case 0: return platfromAtlats.IcebergDownFloor1()
            case 1: return platfromAtlats.IcebergDownFloor2()
            default :return platfromAtlats.IcebergDownFloor1()
            }
        case .BuildingShenshe:
            switch arc4random() % 2 {
            case 0: return platfromAtlats.ShensheDownFloor1()
            case 1: return platfromAtlats.ShensheDownFloor2()
            default :return platfromAtlats.ShensheDownFloor1()
            }
        case .Cemetery:
            switch arc4random() % 2 {
            case 0: return platfromAtlats.CemeteryDownFloor1()
            case 1: return platfromAtlats.CemeteryDownFloor2()
            default :return platfromAtlats.CemeteryDownFloor1()
            }
        case .Nightsky:
            switch arc4random() % 2 {
            case 0: return platfromAtlats.NightskyDownFloor1()
            case 1: return platfromAtlats.NightskyDownFloor2()
            default :return platfromAtlats.NightskyDownFloor1()
            }
        }
        
    }
        
    //MARK: 云
    func createBG_CloudLayerA(count: Int, position:CGPoint) {
        cloudLayerA_node = SKNode()
        cloudLayerA_node.position = position
        addChild(cloudLayerA_node)
        
        for _ in 0 ..< count {
            
            let cloudNode = SKSpriteNode(texture: randomCloudTexture())
            cloudNode.alpha = 0.3
            cloudNode.setScale(CGFloat.random(min: 0.2, max: 0.6))
            cloudNode.zPosition = CGFloat.random(min: -200, max: -120)
            cloudNode.position = CGPointMake(CGFloat.random(min: 0, max: Screen_Width), Screen_Height * CGFloat.random(min: 0.6, max: 0.9))
            cloudLayerA_node.addChild(cloudNode)
            
        }
        
    }
    
    func createBG_CloudLayerB(count: Int, position:CGPoint) {
        cloudLayerB_node = SKNode()
        cloudLayerB_node.position = position
        addChild(cloudLayerB_node)
        
        for _ in 0 ..< count {
            let cloudNode = SKSpriteNode(texture: randomCloudTexture())
            cloudNode.alpha = 0.3
            cloudNode.setScale(CGFloat.random(min: 0.2, max: 0.6))
            cloudNode.zPosition = CGFloat.random(min: -200, max: -120)
            cloudNode.position = CGPointMake(CGFloat.random(min: 0, max: Screen_Width), Screen_Height * CGFloat.random(min: 0.6, max: 0.9))
            cloudLayerB_node.addChild(cloudNode)
            
        }
        
    }
    
    // 树
    func createTree(texture:SKTexture) ->SKSpriteNode{
        
        let tree = SKSpriteNode(texture: texture, color: treesColor, size: texture.size())
        tree.colorBlendFactor = SceneSprite_ColorBlendFactor_Mountain
        tree.zPosition = 50
        tree.anchorPoint = CGPointMake(0.5, 0)
        
        return tree
    }
    
    
    
    //MARK: ------------------------------------灯光
    func createSceneMainLights() {
        
        //        let mainLight = SKLightNode()
        //        mainLight.position = CGPointMake(Screen_Width * 0.5, Screen_Height * 0.8)
        //        mainLight.alpha = 0.8
        //        mainLight.categoryBitMask = 1
        //        mainLight.falloff = 1.0
        //        mainLight.ambientColor = skyColor
        //        mainLight.lightColor = UIColor(red: 1.0/255, green: 1.0/255, blue: 0.0/255, alpha: 0.5)
        //        mainLight.shadowColor = Light_ShadowColor//UIColor(red: 0.0/255, green: 0.0/255, blue: 0.0/255, alpha: 0.3)
        //        addChild(mainLight)
        
        
        let BGLight = SKLightNode()
        BGLight.position = CGPointMake(Screen_Width * 0.5, Screen_Height * 0.8)
        BGLight.alpha = 0.8
        BGLight.categoryBitMask = LightingBitMask.BGLight
        BGLight.falloff = 0.1
        BGLight.ambientColor = UIColor.whiteColor()
        BGLight.lightColor = UIColor(red: 1.0/255, green: 1.0/255, blue: 0.0/255, alpha: 0.5)
        BGLight.shadowColor = Light_ShadowColor//UIColor(red: 0.0/255, green: 0.0/255, blue: 0.0/255, alpha: 0.3)
        addChild(BGLight)
        
        
    }
    
    func flashLight() {
        let flashLight = SKLightNode()
        flashLight.position = CGPointMake(Screen_Width * 0.5, Screen_Height * 0.8)
        flashLight.alpha = 0.8
        flashLight.categoryBitMask = LightingBitMask.BGLight
        flashLight.falloff = 1
        flashLight.ambientColor = UIColor.whiteColor()//skyColor
        flashLight.lightColor = UIColor(red: 1.0/255, green: 1.0/255, blue: 0.0/255, alpha: 0.5)
        flashLight.shadowColor = Light_ShadowColor//UIColor(red: 0.0/255, green: 0.0/255, blue: 0.0/255, alpha: 0.3)
        addChild(flashLight)
        
        
        flashLight.runAction(SKAction.removeFromParentAfterDelay(1))
    }
    
    
    
    //MARK:天气 监听
    //    var sunNode: SKSpriteNode!
    
    func sunnyNotificationFunc() {
        // 晴天
//        sceneWithSunMoon()
        
    }
    
    func rainNotificationFunc() {
        // 雨
        sceneWithRain()
        SKTAudio.sharedInstance().playBackgroundMusic(GameBGSongAudioName.RainAudioName.rawValue)

//        sceneWithSunMoon()
    }
    
    func snowNotificationFunc() {
        // 雪
//        sceneWithSnow()
//        sceneWithSunMoon()
    }
    
    func sandstormNotificationFunc() {
        
        // 飘叶
        
//        sceneWithSunMoon()
        
//        if day == .Day { sceneWithSandstorm() }
    }
    
    //MARK: 太阳 月亮
    //太阳 月亮
    func sceneWithSunMoon() {
        if self.day == .Day {
            let sunNode = SKSpriteNode(imageNamed: "sunSprite")
            sunNode.setScale(0.6)
            sunNode.position = CGPointMake(CGFloat.random(min: Screen_Width * 0.2, max: Screen_Width * 0.5), Screen_Height * 0.8)
            sunNode.zPosition = -90
            addChild(sunNode)
            
            let move = SKAction.moveToX(Screen_Width * 1.2, duration: 500)
            let done = SKAction.removeFromParent()
            
            sunNode.runAction(SKAction.sequence([move, done]))
            
        } else if self.day == .Night && weather != .Rain {
            let sunNode = SKSpriteNode(imageNamed: "moonSprite")
            sunNode.setScale(0.6)
            sunNode.position = CGPointMake(CGFloat.random(min: Screen_Width * 0.2, max: Screen_Width * 0.5), Screen_Height * 0.8)
            sunNode.zPosition = -90
            addChild(sunNode)
            
            let move = SKAction.moveToX(Screen_Width * 1.2, duration: 500)
            let done = SKAction.removeFromParent()
            
            sunNode.runAction(SKAction.sequence([move, done]))
        }
        
    }
    
    
    // 雨
    func sceneWithRain() {
        rainstormSceneRainSP = SKNode()
        rainstormSceneRainSP.zPosition = 50
        rainstormSceneRainSP.alpha = 0.3
        rainstormSceneRainSP.zRotation = CGFloat(-15 * M_PI / 180)
        rainstormSceneRainSP.position = CGPointMake(Screen_Width/2, Screen_Height)
        addChild(rainstormSceneRainSP)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            //这里写需要大量时间的代码
            
            let rainEmitter = SKEmitterNode.emitterNamed("Rain")
            rainEmitter.position = CGPointMake(0, Screen_Height * 3)
            rainEmitter.alpha = 0.5
            self.rainstormSceneRainSP.addChild(rainEmitter)
            
//            SKTAudio.sharedInstance().playSoundEffect("RainSound.mp3")
            
            self.runAction(SKAction.playSoundFileNamed("RainSound.mp3", waitForCompletion: false))
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                //这里返回主线程，写需要主线程执行的代码
            })
        })
        
        
        
    }
    
    // 雪
    func sceneWithSnow() {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            //这里写需要大量时间的代码
            
            let snow = SKEmitterNode.emitterNamed("Snow")
            snow.position = CGPointMake(Screen_Width/2, Screen_Height * 1.2)
            snow.alpha = 0.7
            snow.zRotation = CGFloat(-5 * M_PI / 180)

            self.addChild(snow)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                //这里返回主线程，写需要主线程执行的代码
            })
        })
        
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
//            //这里写需要大量时间的代码
//            
//            if let snow = SKEmitterNode(fileNamed: "Snow") {
//                snow.zPosition = 0
//                snow.alpha = 0.7
//                
//                snow.zRotation = CGFloat(-5 * M_PI / 180)
//                snow.position = CGPointMake(Screen_Width/2, Screen_Height * 1.2)
//                
//                self.addChild(snow)
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                //这里返回主线程，写需要主线程执行的代码
//            })
//        })
    
        
    }
    
    // 飘叶
    func sceneWithSandstorm() {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            //这里写需要大量时间的代码
            
            let rainEmitter = SKEmitterNode.emitterNamed("Sandstorm")
            rainEmitter.position = CGPointMake(Screen_Width, Screen_Height)
            rainEmitter.alpha = 1.0
            self.addChild(rainEmitter)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                //这里返回主线程，写需要主线程执行的代码
            })
        })
        
        
//        if let sand = SKEmitterNode(fileNamed: "Sandstorm") {
//            sand.zPosition = 200
//            sand.alpha = 0.7
//            
//            //            snow.zRotation = CGFloat(-5 * M_PI / 180)
//            sand.position = CGPointMake(Screen_Width, Screen_Height / 2)
//            
//            addChild(sand)
//        }
    }
    

    
    func createLightning() {
        
        flashLightNode = SKNode()
        addChild(flashLightNode)
        //        flashLightNode.hidden = true
        
        //        let flashX = CGFloat.random(min: 20, max: Screen_Width)
        let flashscale = CGFloat.random(min: 0.4, max: 0.6)
        
        let flash = SKSpriteNode(texture: randomFlashTexture())
        flash.setScale(flashscale)
        flash.anchorPoint = CGPointMake(0.5, 0)
        let angle = Double(CGFloat.random(min: -25, max: 35))
        flash.zRotation = CGFloat( angle * M_PI / 180)
        flash.zPosition = -100
        flash.position = CGPointMake(Screen_Width/2, Screen_Height - flash.size.height)
        flashLightNode.addChild(flash)
        
        let halo = SKSpriteNode(imageNamed: "flashhalo")
        halo.alpha = 1.0
        halo.setScale(flashscale * 1.5)
        halo.anchorPoint = CGPointMake(0.5, 1)
        halo.zPosition = -100
        halo.position = CGPointMake(Screen_Width/2, Screen_Height)
        flashLightNode.addChild(halo)
        
        let alpha = SKAction.fadeAlphaTo(0, duration: 1.0)
        let remove = SKAction.removeFromParentAfterDelay(0.5)
        
        flashLightNode.runAction(SKAction.sequence([alpha, remove]))
        
        
        
        
    }
    
    // 金币
    func createGold(){
        
        let randomGoldY = CGFloat.random(min: Screen_Height * 0.3 , max: Screen_Height * 0.8)
        
        let gold = GameSpriteNodeWithGold(SKTexture(imageNamed: "Gold"))   //SKSpriteNode(imageNamed: "Gold")
        gold.name = "Gold"
        gold.position = CGPointMake(Screen_Width + 50, randomGoldY)
        gold.zPosition = 50
        
        addChild(gold)

        let moveDonw = SKAction.moveToX(-100, duration: 2.0)
        let done = SKAction.removeFromParent()
        
        let seuqueAction = SKAction.sequence([moveDonw,done])
        
        gold.runAction(SKAction.repeatActionForever(seuqueAction))
        
    }
    
    
    
    //MARK:随机障碍物
    
    // 构建怪物 1 弹射怪物
    func createBarrier(){
        let randomEnemyX = CGFloat.random(min: 20, max: CGFloat(Screen_Width))
        
        let bow = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(30, 30))
        bow.name = "enemy"
        bow.position = CGPointMake(randomEnemyX, 0)
        bow.zPosition = 50
        
        addChild(bow)
        
        bow.physicsBody = SKPhysicsBody(rectangleOfSize: bow.size)
        bow.physicsBody?.dynamic = true
//        bow.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Enemy
        bow.physicsBody?.collisionBitMask = 0
        bow.physicsBody?.contactTestBitMask = 0
        
        
        bow.physicsBody?.applyImpulse(CGVectorMake(50, 0))
        bow.runAction(SKAction.removeFromParentAfterDelay(1.5))

        
//        let moveDonw = SKAction.moveToY(Screen_Height * 1.2, duration: 2.0)
//        let done = SKAction.removeFromParentAfterDelay(1.5)
//        
//        let seuqueAction = SKAction.sequence([moveDonw,done])
//        
//        bow.runAction(SKAction.repeatActionForever(seuqueAction))
        
    }
    
    // 移动的火球
    func createFireBallActivity() {
        
        let spcolor = UIColor.whiteColor()
        let texture = SKTexture(imageNamed: "star")
        let fireBall = SKSpriteNode(texture: texture, color: spcolor, size: texture.size())//SKSpriteNode(imageNamed: "pixe")
        fireBall.position = CGPointMake(Screen_Width * 1.2, CGFloat.random(min: 100, max: Screen_Height))
        fireBall.zRotation = CGFloat.toAngle(270)
        fireBall.zPosition = 150
        fireBall.setScale(1.3)
        fireBall.colorBlendFactor = 1
        fireBall.physicsBody = SKPhysicsBody(rectangleOfSize: fireBall.size)
        fireBall.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Enemy
        fireBall.physicsBody?.dynamic = false
        addChild(fireBall)
        
        //        let emitter = SKEmitterNode(fileNamed: "FireBall")
        //        emitter?.targetNode = self
        //        emitter?.particleColor = spcolor
        //        emitter?.particleColorBlendFactor = 0
        //        fireBall.addChild(emitter!)
        
        //        let moveUp1 = SKAction.moveTo(CGPointMake(Screen_Width * 0.7, fireBall.position.y * 1.2), duration: 1)
        //        let moveDonw1 = SKAction.moveTo(CGPointMake(Screen_Width * 0.7, fireBall.position.y * 0.8), duration: 1)
        //
        //        let moveUp2 = SKAction.moveTo(CGPointMake(Screen_Width * 0.4, fireBall.position.y * 1.2), duration: 1)
        //        let moveDonw2 = SKAction.moveTo(CGPointMake(Screen_Width * 0.4, fireBall.position.y * 0.8), duration: 1)
        //
        //        let moveUp3 = SKAction.moveTo(CGPointMake(Screen_Width * 0.1, fireBall.position.y * 1.2), duration: 1)
        //        let moveDonw3 = SKAction.moveTo(CGPointMake(Screen_Width * 0.1, fireBall.position.y * 0.8), duration: 1)
        //
        //        let moveUp4 = SKAction.moveTo(CGPointMake(-Screen_Width * 0.2, fireBall.position.y * 1.2), duration: 1)
        //        let moveDonw4 = SKAction.moveTo(CGPointMake(-Screen_Width * 0.2, fireBall.position.y * 0.8), duration: 1)
        
        
        let movex = SKAction.moveToY(Screen_Height * 1.2, duration: 2.0)
        let done = SKAction.removeFromParentAfterDelay(0.5)
        
        fireBall.runAction(SKAction.sequence([movex, done]))
    }
    
    func createJumpEmeny() {
        
        let spcolor = UIColor.whiteColor()
        let texture = SKTexture(imageNamed: "pixe")
        let fireBall = SKSpriteNode(texture: texture, color: spcolor, size: texture.size())//SKSpriteNode(imageNamed: "pixe")
        fireBall.position = CGPointMake(Screen_Width * 1.2, CGFloat.random(min: 0, max: Screen_Height))
        fireBall.zRotation = CGFloat.toAngle(270)
        fireBall.zPosition = 150
        fireBall.setScale(1.3)
        fireBall.colorBlendFactor = 1
        fireBall.physicsBody = SKPhysicsBody(rectangleOfSize: fireBall.size)
        fireBall.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Enemy
        fireBall.physicsBody?.dynamic = false
        addChild(fireBall)
        
        let emitter = SKEmitterNode(fileNamed: "FireBall")
        emitter?.targetNode = self
        emitter?.particleColor = spcolor
        emitter?.particleColorBlendFactor = 0
        fireBall.addChild(emitter!)
        
        let moveUp1 = SKAction.moveTo(CGPointMake(Screen_Width * 0.7, fireBall.position.y * 1.2), duration: 1)
        let moveDonw1 = SKAction.moveTo(CGPointMake(Screen_Width * 0.7, fireBall.position.y * 0.8), duration: 1)
        
        let moveUp2 = SKAction.moveTo(CGPointMake(Screen_Width * 0.4, fireBall.position.y * 1.2), duration: 1)
        let moveDonw2 = SKAction.moveTo(CGPointMake(Screen_Width * 0.4, fireBall.position.y * 0.8), duration: 1)
        
        let moveUp3 = SKAction.moveTo(CGPointMake(Screen_Width * 0.1, fireBall.position.y * 1.2), duration: 1)
        let moveDonw3 = SKAction.moveTo(CGPointMake(Screen_Width * 0.1, fireBall.position.y * 0.8), duration: 1)
        
        let moveUp4 = SKAction.moveTo(CGPointMake(-Screen_Width * 0.2, fireBall.position.y * 1.2), duration: 1)
        let moveDonw4 = SKAction.moveTo(CGPointMake(-Screen_Width * 0.2, fireBall.position.y * 0.8), duration: 1)
        
        
        //        let movex = SKAction.moveToX(-Screen_Width * 0.5, duration: 1.5)
        let done = SKAction.removeFromParentAfterDelay(0.5)
        
        fireBall.runAction(SKAction.sequence([moveUp1, moveDonw1, moveUp2, moveDonw2, moveUp3, moveDonw3, moveUp4, moveDonw4,done]))
    }
    
    
    //MARK: --------------------构建player
    var sizePower:CGFloat = 20
    var powerBox:SKSpriteNode!
    let lifeLineLength:CGFloat = 300
    
    func createPlayer(){        
        self.playerNode = Player(texture: SKTexture(imageNamed:"pixelMan"), color: SKColor.whiteColor())
        self.playerNode.position = CGPointMake(playerOffset, 400 )
        self.playerNode.zPosition = 220
        
        self.addChild(playerNode)
        
    }
    
//    var playershadow:SKSpriteNode!
    
    func choseChaterName(type:PlayerType) ->SKTexture{
        switch type {
        case .A: return sheet.katoonA01()
        case .B: return poc.PocRuning1()
        case .C: return sheet.katoonA01()
            
        }
    }
    
    func choseChaterAnimation(type:PlayerType) ->[SKTexture] {
        switch type {
        case .A: return sheet.katoonA()
        case .B: return poc.PocRuning()
        case .C: return sheet.katoonA()
        }
    }
    
    func playerLocus(count: Int, length:CGFloat) {
        for _ in 0 ..< count {
            let bullet =  SKSpriteNode(texture: SKTexture(imageNamed: "pixe"), color: skyColor, size: CGSizeMake(20, 20))
            bullet.position = CGPointMake(Screen_Width * 0.2, playerNode.position.y)
            bullet.zPosition = 200
            bullet.anchorPoint = CGPointMake(1, 0.5)
            bullet.alpha = 0.6
            bullet.colorBlendFactor = 1
            bullet.blendMode = SKBlendMode.Add
            //            bullet.zRotation = CGFloat.toAngle(-25)
            
            //            bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.size)
            //            bullet.physicsBody?.dynamic = false
            //            bullet.physicsBody?.allowsRotation = false
            //
            //            bullet.physicsBody?.categoryBitMask = CollisionCategoryBitmask.FireGun
            //            bullet.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.None
            //            bullet.physicsBody?.collisionBitMask = CollisionCategoryBitmask.Enemy//CollisionCategoryBitmask.All
            
            addChild(bullet)
            
            // playerOffset
            
            let shot = SKAction.moveTo(CGPointMake(playerOffset - length, playerNode.position.y), duration: 0.2)
            let done = SKAction.removeFromParent()
            
            bullet.runAction(SKAction.sequence([shot, done]))
        }
        
    }

    
    //MARK: 刷新金币动画
    func updateLeveFloorCount() {
        
        let levelCountLabel = SKLabelNode(fontNamed: Font_Name)
        levelCountLabel.position = CGPointMake(Screen_Width/2, Screen_Height/2)
        levelCountLabel.fontSize = 30
        hillLevelScore += 1
        levelCountLabel.text = "Land \(hillLevelScore)"
        addChild(levelCountLabel)
        
        let scaleIn = SKAction.scaleTo(3, duration: 1.5)
        let scaleOut = SKAction.scaleTo(1, duration: 0.5)
        let location = CGPointMake(20, Screen_Height)
        let move = SKAction.moveTo(location, duration: 0.5)
        let done = SKAction.removeFromParent()
        
        levelCountLabel.runAction(SKAction.sequence([scaleIn, scaleOut, move, done])) { () -> Void in
            
        }
        
    }
    

    
    //MARK: 魔法飘带
    func playerMagic(node:SKNode) {
        print("playerMagic")
        self.magicNode = SKEmitterNode(fileNamed: "playerMagic.sks") //EngineFire
        self.magicNode.particleTexture!.filteringMode = .Nearest
        self.magicNode.position = CGPointMake(-playerNode.size.width * 0.5, -playerNode.size.height * 0.5)
        self.magicNode.zPosition = 0
        self.magicNode.targetNode = self
        
        self.playerNode.addChild(self.magicNode)
        
        magicNode.runAction(SKAction.removeFromParentAfterDelay(1.5))
       
    }
    
    
    //MARK: 长按手势
    func customLongPressGesture() {
        // 长按手势操作
        longPressGestureLeve1 = UILongPressGestureRecognizer(target: self, action: #selector(GameScene.longPressGestureLeve1Action(_:)))
        longPressGestureLeve1.minimumPressDuration = 0.2
        //longPressGesture.allowableMovement = CGFloat(10)
        
        self.view?.addGestureRecognizer(longPressGestureLeve1)
        
    }
    
    //    var isLongPress:Bool = false // 是否在长按屏幕
    func longPressGestureLeve1Action(sender:UILongPressGestureRecognizer) {
        
        print("长按屏幕Leve1")
        if sender.state == UIGestureRecognizerState.Began {
            
            //            playerNode.physicsBody?.applyImpulse(CGVectorMake(0, 300))
            //
            //            if GameState.sharedInstance.musicState { self.runAction(jumpSoundAction) }
            //            contactFloorEvent()
        }
        
        if sender.state == UIGestureRecognizerState.Ended {
            
        }
    }
    
    //  引导手指
    func figerNode() {
        guideFigerNode = SKNode()
        
        guideFigerNode.zPosition = 300
        guideFigerNode.position = CGPoint(x: Screen_Width/2, y: Screen_Height/8)
        addChild(guideFigerNode)
        
        let fingerSprite = SKSpriteNode(imageNamed: "touch01")
        guideFigerNode.addChild(fingerSprite)
        
        var fingersps = [SKTexture]()
        fingersps.append(SKTexture(imageNamed: "touch01"))
        fingersps.append(SKTexture(imageNamed: "touch02"))
        
        let fingerTouch = SKAction.animateWithTextures(fingersps, timePerFrame: 0.3)
        let fingerTouchAni = SKAction.repeatAction(fingerTouch, count: 2)
        let fingerTouchSequence = SKAction.repeatActionForever(SKAction.sequence([fingerTouchAni]))
        fingerSprite.runAction(fingerTouchSequence)
    }
    
    
    func createStarStar() {
        // 在屏幕上随机生成100-200个星星
        // 星星自身闪烁
        // 跟随背景移动
        
        let width = CGFloat(arc4random_uniform(3) + 3)
        let star = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(width, width))
        let rotation = CGFloat(Double(CGFloat.random(min: -35, max: 35) + 35) * M_PI / 180)
        var zpo:CGFloat = 0// -30 - 10
        
        switch arc4random() % 2 {
        case 0: zpo = -220
        case 1: zpo = -260
        default :zpo = -200
        }
        
        star.zPosition = zpo
        star.zRotation = rotation
        star.alpha = 0
        // CGPointMake(CGFloat(arc4random() % UInt32 (Screen_Width)), CGFloat(arc4random() % UInt32 (Screen_Height)))
        star.position = CGPointMake(CGFloat(arc4random() % UInt32 (Screen_Width)), CGFloat.random(min: Screen_Height/2, max: Screen_Height))
        self.addChild(star)
        
        let dt = NSTimeInterval(arc4random_uniform(10))
        let wait = SKAction.waitForDuration(dt)
        
        let aphla0 = SKAction.fadeAlphaTo(0, duration: 1.5)
        let aphla1 = SKAction.fadeAlphaTo(1, duration: 1.5)
        
        let remove = SKAction.removeFromParent()
        
        star.runAction(SKAction.repeatActionForever(SKAction.sequence([aphla1, wait, aphla0,remove])))
        
    }
    
    // 流星
    func createMeteor() {
        
        let emitter = SKEmitterNode.emitterNamed("Meteor")
        emitter.advanceSimulationTime(NSTimeInterval(10))
        emitter.position = CGPointMake(0, Screen_Height * 1.5)
        emitter.zRotation = CGFloat(60 * M_PI / 180)
        emitter.zPosition = -150
        emitter.alpha = 0.5
        addChild(emitter)
        
        emitter.runAction(SKAction.removeFromParentAfterDelay(2.8))
        
    }
    
    
    //MARK: 踩踏地面
    func contactFloorEvent(node:SKNode) {
        
        print("contactFloorEvent")
        
        GameState.sharedInstance.canJump = true
        
        playerNode.removeFromParent()
        playerNode.position = CGPointMake(0, 32)
        node.addChild(playerNode)
    }
    
    
    var lastContactNode:SKPhysicsBody?
    // MARK:碰撞委托方法 protocol Method
    // 碰撞开始
    func didBeginContact(contact: SKPhysicsContact) {
        
        if !GameState.sharedInstance.gameOver {
            
            let otherA = (contact.bodyA.categoryBitMask == CollisionCategoryBitmask.Player ? contact.bodyB : contact.bodyA)

            if let node = otherA.node {
                
                if otherA == lastContactNode {
                    print("contact body is equal ")
                    return
                } else {

                    switch otherA.categoryBitMask {
                        
                    case CollisionCategoryBitmask.Normal_Floor :
                        print("Contact Floor")
                        
                        contactFloorEvent(node)
                        playerMagic(node)
                        
                        self.playerNode.doStayAnimation()
                        
                    case CollisionCategoryBitmask.Gold :
                        print("Contact Gold")
                        
                        if GameState.sharedInstance.musicState { runAction(getGlodSoundAction) }
                        
                        node.runAction(getGoldAction)
                        
                        GameState.sharedInstance.gold += 1
                        self.gameSceneDelegate?.updateGold(Int(GameState.sharedInstance.gold))
                        
                    case CollisionCategoryBitmask.Enemy :
                        print("Contact Enemy")
                        
                        self.shakeCarema() //  震屏
                        self.showParticlesForEnemy(self.playerNode.position) // 爆炸特效
                        if GameState.sharedInstance.musicState { self.runAction(self.enemySoundAction) }
                        
                        self.gameEnd()
                        
                        //                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                        //
                        //                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        //                        })
                        //                    })
                        
                    case CollisionCategoryBitmask.Wather :
                        print("Contact Wather")
                        
                        self.shakeCarema() //  震屏
                        self.showParticlesForEnemy(self.playerNode.position) // 爆炸特效
                        
                        if GameState.sharedInstance.musicState { runAction(waterSoundAction) }
                        
                        self.gameEnd()
                        
                        
                        //                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                        //                        self.showParticlesForEnemy(self.playerNode) // 爆炸特效
                        //
                        //                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        //                            self.gameEnd()
                        //                        })
                        //                    })
                        
                    case CollisionCategoryBitmask.DoorKey_Button:
                        print("Contact 开关门")
                        
                        node.runAction(doorKeyAction)
                        
                        if GameState.sharedInstance.musicState { self.runAction(getdoorKeySoundAction)}
                        
                        let door = node.parent as! SKSpriteNode
                        door.runAction(doorOpenAction)
                        
                    case CollisionCategoryBitmask.Down_Floor:
                        print("Contact 踩踏 下落")
                        contactFloorEvent(node)
                        
                        playerMagic(node)
                        
                        if GameState.sharedInstance.musicState { self.runAction(downSoundAction) }
                        
                        let delay:Double = 0.2
                        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
                        
                        dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
                            if !node.children.isEmpty {
                                for i in node.children {
                                    i.physicsBody?.dynamic = true
                                }
                            }
                            node.physicsBody?.dynamic = true
                        }
                        
                    case CollisionCategoryBitmask.Invisible:
                        print("Contact 隐形的")
                        contactFloorEvent(node)
                        playerMagic(node)
                        
                        node.hidden = false
                        
                    case CollisionCategoryBitmask.Spring:
                        print("Contact 弹簧")
//                        contactFloorEvent(node)
//                        playerMagic(node)
                        
                        self.playerNode.physicsBody?.applyImpulse(CGVectorMake(0, 200))

                        self.playerNode.runAction(SKAction.moveBy(CGVectorMake(64*3, Player_Jump_Hight), duration: 0.1))
                        
                        if GameState.sharedInstance.musicState { self.runAction(springSoundAction) }
                        
                    case CollisionCategoryBitmask.Pinned:
                        print("Contact胶水")
                        
                        contactFloorEvent(node)
                        playerMagic(node)
                        
                    default:
                        break
                    }
                    
                    lastContactNode = otherA

                }
                
            }
            
        }
        
    }
    
    //MARK: 粒子特效
    
    func lightsUpAnimation() {
        let maskView = SKSpriteNode(color: UIColor.blackColor(), size: self.size)
        maskView.alpha = 0
        self.addChild(maskView)
        
        UIView.animateWithDuration(1.0, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { 
            maskView.alpha = 1
            }) { (done) in
                //
        }
        
    }
    
    //  撞击震屏
    func shakeCarema() {
        let sceneView = self.view
        if let view = sceneView {
            view.shakeC(5, delta: 8, interval: 0.02, shakeDirection: ShakeDirection.ShakeDirectionVertical)
        }
    }
    
    // 爆炸特效
    func showParticlesForEnemy(position: CGPoint) {
        
        let emitter = SKEmitterNode.emitterNamed("Bomb")
        emitter.particleTexture!.filteringMode = .Nearest
        emitter.position = position//CGPointMake(playerNode.position.x + self.playerNode.size.width, playerNode.position.y + 50)
        emitter.zPosition = 300
        
        addChild(emitter)
        
        emitter.runAction(SKAction.removeFromParentAfterDelay(1.8))
        
    }
    
    // 踩踏地面特效
    func showParticlesForTreadFloor(node: SKNode) {
        
        let emitter = SKEmitterNode.emitterNamed("treadFloor")
        emitter.particleTexture!.filteringMode = .Nearest
        emitter.position = CGPointMake(node.position.x, node.position.y - 30)
        emitter.zPosition = 300
        
        self.playerNode.addChild(emitter)
        
        emitter.runAction(SKAction.removeFromParentAfterDelay(0.5))
        
    }
    
    
    // 点击特效
    func tapEffectsForTouchAtLocation(location: CGPoint) {
        showTapAtLocation(location)
    }
    
    func showTapAtLocation(point: CGPoint) {
        let shapeNode = SKShapeNode()
        
        let path = UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: 10, height: 10))
        shapeNode.path = path.CGPath
        
        shapeNode.position = point
        shapeNode.strokeColor = SKColorWithRGBA(255, g: 255, b: 255, a: 196)
        shapeNode.lineWidth = 1
        shapeNode.antialiased = false
        shapeNode.zPosition = 100
        addChild(shapeNode)
        // 3
        let duration = 1.0
        let scaleAction = SKAction.scaleTo(20.0, duration: duration)
        scaleAction.timingMode = .EaseOut
        shapeNode.runAction(SKAction.sequence(
            [scaleAction, SKAction.removeFromParent()]))
        // 4
        let fadeAction = SKAction.fadeOutWithDuration(duration)
        fadeAction.timingMode = .EaseOut
        shapeNode.runAction(fadeAction)
        
    }
    
    //MARK: 开始游戏
    func startGame() {
        print("startGame()")
        NSNotificationCenter.defaultCenter().postNotificationName("startGameAnimationNotification", object: nil)
        
        self.guideFigerNode.removeFromParent()
        
        self.playerNode.physicsBody?.dynamic = true
        
        self.playerMoveAnimation(CGVectorMake(Player_Jump_Width, Player_Jump_Hight))
        
        GameState.sharedInstance.gameOver = false
//        GameState.sharedInstance.isLoadingDone = false
        
    }
    
    //MARK: 游戏结束
    func gameEnd() {
        
        GameState.sharedInstance.gameOver = true
        GameState.sharedInstance.canJump = false
        GameState.sharedInstance.isLoadingDone = false
        
        if longPressGestureLeve1 != nil {
            self.view?.removeGestureRecognizer(longPressGestureLeve1)
        }
                
        
        //  用dispatch_after推迟任务
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
            
            self.playerNode.physicsBody?.applyImpulse(CGVectorMake(-5, 50))
            
            self.playerNode.physicsBody?.collisionBitMask = CollisionCategoryBitmask.None
        }
        
//        SKTAudio.sharedInstance().pauseBackgroundMusic()
        
        // 保存游戏状态 分数等信息
        GameState.sharedInstance.currentScore = Int(gameScore)
        GameState.sharedInstance.saveState()
        
        self.gameSceneDelegate?.updateHUD(Int(self.gameScore))
        
        //  用dispatch_after推迟任务
        let delayInSeconds = 0.5
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            //            self.showiAd()
            
            NSNotificationCenter.defaultCenter().postNotificationName("gameOverNotification", object: nil)
        }
        
        
        
    }
    
    //MARK:  游戏结束 显示广告页， 弹出观看广告赢金币按钮
    func showiAd() {
        //  进行控制出现广告，有时候出现看广告赚金币按钮，有时候其它 参考天天过马路
        
        let iAdNode = SKNode()
        iAdNode.zPosition = 350
        iAdNode.position = CGPointMake(Screen_Width/2, Screen_Height/2)
        addChild(iAdNode)
        
        let belt = SKSpriteNode(color: UIColor.blackColor(), size: CGSize(width: Screen_Width, height: 1))
        belt.alpha = View_MaskAlpha
        iAdNode.addChild(belt)
        
        let scaleAction = SKAction.scaleYTo(80, duration: 0.2)
        belt.runAction(scaleAction)
        
        let label = SKLabelNode(fontNamed: Font_Name)
        label.text = "本次:\(GameState.sharedInstance.currentScore)"
        label.position = CGPointMake(-Screen_Width/2, 0)
        iAdNode.addChild(label)
        
        let moveAction = SKAction.moveToX(0, duration: 0.3)
        label.runAction(moveAction)
    }
    
    func playerMoveAnimation(vector:CGVector) {
        
        playerNode.moveToParent(self)
        
        //duration 大于等于 0.2 时， 出现错误
        self.playerNode.runAction(SKAction.moveBy(vector, duration: 0.1))
        
        if GameState.sharedInstance.musicState { self.runAction(self.jumpSoundAction)}

    }
    
    
    //MARK: 点击事件
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

//        // 加载完成 才可点击屏幕
//        if GameState.sharedInstance.isLoadingDone {
//            
//            if !GameState.sharedInstance.gameOver {
//                
//                if GameState.sharedInstance.canJump {
//                    
//                    GameState.sharedInstance.canJump = false
//                    GameState.sharedInstance.lifeTimeCount = 1.2
//                    
//                    self.playerMoveAnimation()
//                    
//                    //update分数
//                    updateGameScore()
//                }
//
//            } else if GameState.sharedInstance.gameOver {
//                self.startGame()
//            }
//        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {

    }
    
    //MARK: 循环滚动远处背景
    func scrollBackground() {
        
        self.bg_HillDepth1_A_node.position.x -= ScrollBG_Move_Speed * 0.2
        self.bg_HillDepth1_B_node.position.x -= ScrollBG_Move_Speed * 0.2
        
        self.bg_HillDepth2_A_node.position.x -= ScrollBG_Move_Speed * 0.1
        self.bg_HillDepth2_B_node.position.x -= ScrollBG_Move_Speed * 0.1
        
        if bg_HillDepth1_A_node.position.x <= -Screen_Width * BG_Cycle_Width_Ratio {
            self.bg_HillDepth1_A_node.removeFromParent()
            self.bg_HillDepth1_A_node = createBG_Hill_Layer(BGDetphType.LayerA, zPosition: -50)
            self.bg_HillDepth1_A_node.position = CGPointMake(Screen_Width, BG_hight)
            addChild(self.bg_HillDepth1_A_node)
        }
        
        if bg_HillDepth1_B_node.position.x <= -Screen_Width * BG_Cycle_Width_Ratio {
            self.bg_HillDepth1_B_node.removeFromParent()
            self.bg_HillDepth1_B_node = createBG_Hill_Layer(BGDetphType.LayerA, zPosition: -50)
            self.bg_HillDepth1_B_node.position = CGPointMake(Screen_Width, BG_hight)
            addChild(bg_HillDepth1_B_node)
        }
        
        if bg_HillDepth2_A_node.position.x <= -Screen_Width * BG_Cycle_Width_Ratio {
            self.bg_HillDepth2_A_node.removeFromParent()
            self.bg_HillDepth2_A_node = createBG_Hill_Layer(BGDetphType.LayerB, zPosition: -80)
            self.bg_HillDepth2_A_node.position = CGPointMake(Screen_Width, BG_hight)
            addChild(bg_HillDepth2_A_node)
        }
        
        if bg_HillDepth2_B_node.position.x <= -Screen_Width * BG_Cycle_Width_Ratio {
            self.bg_HillDepth2_B_node.removeFromParent()
            self.bg_HillDepth2_B_node = createBG_Hill_Layer(BGDetphType.LayerB, zPosition: -80)
            self.bg_HillDepth2_B_node.position = CGPointMake(Screen_Width, BG_hight)
            addChild(bg_HillDepth2_B_node)
        }
        
    }
    
    var playerLastPostionX:CGFloat = 0
    
    func scrollPlayground() {
        

        if screenNodeA != nil {
            
            if self.screenNodeA.position.x <= -Screen_Width {
                
                self.screenNodeA.removeFromParent()
                self.screenNodeA = nil
                
                if self.screenNodeA == nil {
                    self.screenNodeA = platfromArray[Int(CGFloat.random(min: 0, max: CGFloat(platfromArray.count)))] .copy() as! SKNode
                    self.screenNodeA.position = CGPointMake(Screen_Width, PlatformHight)
                    self.addChild(self.screenNodeA)
                    
//                    let randomGoldY = CGFloat.random(min: Screen_Height * 0.3 , max: Screen_Height * 0.6)
//                    
//                    let gold = GameSpriteNodeWithGold(SKTexture(imageNamed: "Gold"))
//                    gold.name = "Gold"
//                    gold.position = CGPointMake(Screen_Width + 50, randomGoldY)
//                    gold.zPosition = 50
//                    
//                    self.screenNodeA.addChild(gold)
                    
                }
                
            }

        }
        
        if screenNodeB != nil {
            
            if self.screenNodeB.position.x <= -Screen_Width {
                self.screenNodeB.position.x = Screen_Width
                
                self.screenNodeB.removeFromParent()
                self.screenNodeB = nil
                
                if self.screenNodeB == nil {
                    self.screenNodeB = platfromArray[Int(CGFloat.random(min: 0, max: CGFloat(platfromArray.count)))] .copy() as! SKNode
                    self.screenNodeB.position = CGPointMake(Screen_Width, PlatformHight)
                    self.addChild(self.screenNodeB)
                    
//                    let randomGoldY = CGFloat.random(min: Screen_Height * 0.3 , max: Screen_Height * 0.6)
//                    
//                    let gold = GameSpriteNodeWithGold(SKTexture(imageNamed: "Gold"))
//                    gold.name = "Gold"
//                    gold.position = CGPointMake(Screen_Width + 50, randomGoldY)
//                    gold.zPosition = 50
//                    
//                    self.screenNodeA.addChild(gold)
                    
                }
            }
        }
        
//        let playerViewPostion = convertPoint(playerNode.position, fromNode: playerNode)
//        print("playerx::::: \(playerViewPostion)")
        
//        let screenSize = UIScreen.mainScreen().bounds.size
//        let screenScale = UIScreen.mainScreen().scale // 屏幕scale
//        print("screenScale::::: \(screenScale)")
//        print("viewWidth::::: \(screenSize.width * screenScale)")
//        

//        print("screenWidth:: \((screenSize.width * screenScale) * 0.5)")
        self.screenNodeA.position.x -= ScrollBG_Move_Speed
        self.screenNodeB.position.x -= ScrollBG_Move_Speed
        
//        if playerViewPostion.x >= (screenSize.width * screenScale) * 0.6 {
//
//            self.screenNodeA.position.x -= ScrollBG_Move_Speed * 5.0
//            self.screenNodeB.position.x -= ScrollBG_Move_Speed * 5.0
//            
//        } else {
//
//            self.screenNodeA.position.x -= ScrollBG_Move_Speed
//            self.screenNodeB.position.x -= ScrollBG_Move_Speed
//
//        }
    }
    
//    var lastPlayerViewPostionX:CGFloat = 0
    
    //MARK: 天气
    func updateWater() {
        // 夜 没有下雨
        if self.weather != .Rain {
            let dt1 = Int(arc4random_uniform(20))
            if dt1 == 1 { createStarStar() } // 星星
            
            let dt2 = Int(arc4random_uniform(3000))
            if dt2 == 1 { createMeteor() } // 流星
        }
        // 下雨
        if self.weather == .Rain {
            let dt1 = Int(arc4random_uniform(500))
            if dt1 == 1 {
                self.createLightning()
                self.runAction(thunderSoundAction)
            } // 闪电
        }
        
        // 白天 晴天
//        if land == .Amazon && self.weather != .Rain {
//            // 飘云
//            cloudLayerA_node.position.x -= 0.2
//            cloudLayerB_node.position.x -= 0.2
//            
//            //
//            if cloudLayerA_node.position.x <= -Screen_Width {
//                cloudLayerA_node.removeFromParent()
//                createBG_CloudLayerA(Int(CGFloat.random(min: 3, max: 10)), position: CGPointMake(Screen_Width, 0))
//            }
//            
//            if cloudLayerB_node.position.x <= -Screen_Width {
//                cloudLayerB_node.removeFromParent()
//                createBG_CloudLayerB(Int(CGFloat.random(min: 3, max: 10)), position: CGPointMake(Screen_Width, 0))
//            }
//        }
    }
    
    func exceedTopScroeTip() {
        let label = SKLabelNode(fontNamed: Font_Name)
        label.text = "破纪录"
        label.fontSize = 30
        label.position = Screen_Center
        addChild(label)
        
        label.runAction(SKAction.removeFromParentAfterDelay(2.0))
    }
    
    
    //MARK: 更新 分数
    func updateGameScore() {
        self.gameScore += 1
        gameSceneDelegate?.updateHUD(Int(self.gameScore))
        
        // 如果分数达到最高分 屏幕显示名字
        if Int(self.gameScore) == GameState.sharedInstance.gamecenterSelfTopScore {
            print("破纪录")
            //                exceedTopScroeTip()
        }
        
        //        let score:CGFloat = max(gameScore, playerNode.position.x)
        //        self.gameScore = CGFloat(score * 0.02)
    }
    
    //MARK: 金币
    func updataGold() {
        let dt = Int(arc4random_uniform(2000))
        if dt == 1 {createGold() }
    }
    
    //MARK: 敌人
    func updataEmeny() {
        
        let dt = Int(arc4random_uniform(200))
        if dt == 1 {
            createBarrier()
//            createFireBallActivity()
        }
    }
    
    func updateScene(){
        
    }
    
    
//    var playerLastX:CGFloat!
    
    //MARK: update
    override func update(currentTime: CFTimeInterval) {
        
        //天气
        updateWater()
        
        // 游戏开始
        if !GameState.sharedInstance.gameOver {
            // 滚动远处背景
            scrollBackground()
            
            //  滚动前层关卡
            scrollPlayground()
            
            GameState.sharedInstance.lifeTimeCount -= 0.003
            self.gameSceneDelegate?.updateLifeTime(GameState.sharedInstance.lifeTimeCount)
            
            if GameState.sharedInstance.lifeTimeCount <= 0 {
                
                self.shakeCarema() //  震屏
                if GameState.sharedInstance.musicState { self.runAction(self.enemySoundAction) }
                self.gameEnd()
            }
            
            if  GameState.sharedInstance.isLoadingDone  {

//                self.playerNode.x += Player_Jump_Width
                
//                //update分数
//                updateGameScore()
                
                //update 金币
                //            updataGold()
                
                //update 敌人
//                updataEmeny()
            }
            
        } else {
//            print("GameState.sharedInstance.gameOver is ture")
            return
        }
        
    }
    
}



