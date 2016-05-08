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
    func gameOverScreenshots()
}

class GameScene: SKScene, SKPhysicsContactDelegate, UIGestureRecognizerDelegate {
    //MARK: SpriteTextureAlats
    let bgSheet = BGSpriteTextureAltas()
    let platfromAtlats = PlatfromTextureAlats()

    weak var gameSceneDelegate: GameSceneDelegate?
    
    // MARK: Properties let
    private let playerOffset:CGFloat = 64 * 4 + 32 // 角色在屏幕中的偏移位置
    
    //场景移动速度
    private var ScrollBG_Move_Speed:CGFloat = 1.0

    // MARK: private game data
    private var dayTime = DayType.Day
    private var land = SceneLandType.Amazon
    private var weather = WeatherType.Sunny
    
    //MARK: 场景node
    private var guideFigerNode: SKNode! // 指引手指
    
    private var skyColor:UIColor!
    
    var sunshineTimer:NSTimer!
    
    var flashLightNode:SKNode!
    
    // 最远层
    private var bg_HillDepth0_node: SKNode!
    //  近层
    private var bg_HillDepth1_A_node: SKNode!
    private var bg_HillDepth1_B_node: SKNode!
    //  远层
    private var bg_HillDepth2_A_node: SKNode!
    private var bg_HillDepth2_B_node: SKNode!
    
    private var platfromsTupleArray = [(SKNode, CGFloat)]() // 模板数据 每次更新从此数组复制
    private var platfromsTupleUpdateArray = [(SKNode, CGFloat)]() // 在场景中显示的实时更新数据
    
    private var playergroundNode:SKNode!

    private var platfromInterval:CGFloat = 0 // 等于组件的宽度, 不短减小 当值小于0 视为移动了宽度的距离 与playergroundNode 移动的位置同步
    
    private var playerNode: SKNode!
    private var magicNode: SKEmitterNode!
    
    //MARK: 共享纹理
    private var floorTexture:SKTexture! //= setPlatformTextureWithFloor(self.land)
    
    private var wallTexture1:SKTexture!
    private var wallTexture2:SKTexture!
    private var wallTexture3:SKTexture!
    private var wallTexture4:SKTexture!
    
//    let wallTexture1 = setPlatformTextureWithWall(self.land)
//    let wallTexture2 = setPlatformTextureWithWall(self.land)
//    let wallTexture3 = setPlatformTextureWithWall(self.land)
//    let wallTexture4 = setPlatformTextureWithWall(self.land)
//    
    
    //MARK: 从sks场景文件获取node
    let long_SectionNode:SKNode = {
        let scene = SKScene(fileNamed: "Long_Section.sks")!
        let node = scene.childNodeWithName("longSection")!

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
    
    let bridgeMovingInX_SectionNode:SKNode = {
        let scene = SKScene(fileNamed: "BridgeMovingInX_Section.sks")!
        let node = scene.childNodeWithName("movingBrdgeX")!
        return node
    }()
    
    let bridgeMovingInY_Section:SKNode = {
        let scene = SKScene(fileNamed: "BridgeMovingInY_Section.sks")!
        let node = scene.childNodeWithName("bridgeMovingInYNode")!
        return node
    }()
    
    let spring_Section:SKNode = {
        let scene = SKScene(fileNamed: "Spring_Section.sks")!
        let node = scene.childNodeWithName("springNode")! //as! PlatfromNode
        return node
    }()
    
    // 独立组件
    // 带刺柱子
    let terrorPillar:SKNode = {
        let scene = SKScene(fileNamed: "independent.sks")!
        let node = scene.childNodeWithName("pillarNode")! //as! PlatfromNode
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
    let jumpSoundAction:SKAction = {
        switch arc4random() % 11 {
            
        case 0: return SKAction.playSoundFileNamed("yeah_01.mp3", waitForCompletion: false)
            
        case 1: return SKAction.playSoundFileNamed("yeah_02.mp3", waitForCompletion: false)
        case 2: return SKAction.playSoundFileNamed("yeah_03.mp3", waitForCompletion: false)
        case 3: return SKAction.playSoundFileNamed("yeah_04.mp3", waitForCompletion: false)
        case 4: return SKAction.playSoundFileNamed("yeah_05.mp3", waitForCompletion: false)
        case 5: return SKAction.playSoundFileNamed("yeah_flam01.mp3", waitForCompletion: false)
            
        case 6: return SKAction.playSoundFileNamed("yeah_flam04.mp3", waitForCompletion: false)
        case 7: return SKAction.playSoundFileNamed("yeah_flam09.mp3", waitForCompletion: false)
        case 8: return SKAction.playSoundFileNamed("yeah_flam10.mp3", waitForCompletion: false)
        case 9: return SKAction.playSoundFileNamed("yeah_owell01.mp3", waitForCompletion: false)
        case 10: return SKAction.playSoundFileNamed("yeah_owell03.mp3", waitForCompletion: false)
            
        default : return SKAction.playSoundFileNamed("inGame_action_jump.mp3", waitForCompletion: false)
        }
    }()
    
    let lostSound:SKAction = SKAction.playSoundFileNamed("fever_lost.mp3", waitForCompletion: false)

    
    let getGlodSoundAction = SKAction.playSoundFileNamed("inGame_function_star.mp3", waitForCompletion: false)
    let getdoorKeySoundAction = SKAction.playSoundFileNamed("catch_star02.mp3", waitForCompletion: false)
    
    let enemySoundAction = SKAction.playSoundFileNamed("dieSound.mp3", waitForCompletion: false)
    let waterSoundAction = SKAction.playSoundFileNamed("luoshui.mp3", waitForCompletion: false)
    let downSoundAction = SKAction.playSoundFileNamed("inGame_event_deathMonster_1.mp3", waitForCompletion: false)
    let springSoundAction = SKAction.playSoundFileNamed("springSound.mp3", waitForCompletion: false)
    
    let eagleSoundAction = SKAction.playSoundFileNamed("eagleSound.mp3", waitForCompletion: false)
    let chickenSoundAction = SKAction.playSoundFileNamed("chicken.mp3", waitForCompletion: false)
    
    let thunderSoundAction = SKAction.playSoundFileNamed("thunderSound.mp3", waitForCompletion: false)
    
    //MARK: Did Move To View
    override func didMoveToView(view: SKView) {

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameScene.restartGame), name: "restartGameNotification", object: nil)
        
        // 监测天气变化
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameScene.rainNotificationFunc), name: "RainNotificationNotification", object: nil)

        
        self.physicsWorld.gravity = CGVectorMake(0.0, Scene_Gravity)
        self.physicsWorld.contactDelegate = self
        
        self.userInteractionEnabled = true
        
        self.addGesture()
        self.setupGame()
        
    }
    
    //MARK: 自定义手势
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
        self.touchControll(CGVector(dx: 10, dy: 40))
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if sender.direction == .Left {
            
            self.touchControll(CGVector(dx: -10, dy: 40))
            
        } else {            
            self.touchControll(CGVector(dx: 10, dy: 40))
            
        }
    }
    
    func touchControll(impulse:CGVector) {
        
        // 加载完成 才可点击屏幕
        if GameState.sharedInstance.isLoadingDone && !GameState.sharedInstance.tiemsUp {
            
            if !GameState.sharedInstance.gameOver  {
                
                if GameState.sharedInstance.canJump {
                    
                    GameState.sharedInstance.canJump = false
                    GameState.sharedInstance.lifeTimeCount = 1.0
                    
                    //duration 大于等于 0.2 时， 出现错误
//                    self.playerNode.physicsBody?.applyImpulse(impulse)
//                    self.playerNode.runAction(SKAction.moveBy(move, duration: 0.1))
                    self.playerNode.physicsBody?.applyImpulse(impulse)

                    if GameState.sharedInstance.musicState { self.runAction(self.jumpSong())}
                    
                    //update分数
                    updateGameScore()
                }
                
            } else if GameState.sharedInstance.gameOver {
                self.startGame()
            }
        }
    }
    
    
//    func playerMoveAnimation(impulse:CGVector, move:CGVector) {
//        
//        //        playerNode.moveToParent(self)
//        
//        //duration 大于等于 0.2 时， 出现错误
//        self.playerNode.physicsBody?.applyImpulse(impulse)
//        self.playerNode.runAction(SKAction.moveBy(move, duration: 0.2))
//        
//        if GameState.sharedInstance.musicState { self.runAction(self.jumpSoundAction)}
//        
//    }
    
    
    //MARK:-----------------------------  SetupGame
    func setupGame() {
        
        if sunshineTimer != nil {
            self.sunshineTimer.invalidate()
            self.sunshineTimer = nil
        }
        
        self.platfromInterval = 0
        GameState.sharedInstance.tiemsUp = false

        GameState.sharedInstance.currentScore = 0
        
        self.platfromsTupleUpdateArray.removeAll()
        
        self.playergroundNode = SKNode()
        self.playergroundNode.position = CGPointMake(0, PlatformHight)
        self.addChild(playergroundNode)
        
        self.setupColorsAndSceneLandAndWeather() // 设置颜色 天气
        self.setGlobalPlatfrmoTexture()
        
        self.initBackgroud()
        
        self.initPlaygroud()

        self.setupStartPlatfroms()
        
//        self.sceneEdgeBottom()
        
        self.createWater()
        
        self.createPlayer()
        self.figerNode()
        
        if self.weather != .Rain && self.dayTime != .Night {
            self.sunshineTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(CGFloat.random(min: 3, max: 6)),
                                                                        target: self,
                                                                        selector: #selector(GameScene.createDynamicSunshine),
                                                                        userInfo: nil,
                                                                        repeats: true)
            
            let dt1 = Int(arc4random_uniform(200))
            if dt1 == 1 { createDynamicSunshine() } // 动态光线
        }

//        GameState.sharedInstance.gameOver = true
        
        // 2. 游戏开始后的音乐
//        let music = GameState.sharedInstance.musicState
        if GameState.sharedInstance.musicState {
            // 播放背景音乐
            if self.weather == .Rain {
                SKTAudio.sharedInstance().playBackgroundMusic(GameBGSongAudioName.RainAudioName.rawValue)
            } else {
                SKTAudio.sharedInstance().playBackgroundMusic(GameBGSongAudioName.NormalAudioName.rawValue)
            }
            
        }
        
        GameState.sharedInstance.lifeTimeCount = 1.0
//        GameState.sharedInstance.isLoadingDone = true

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
        
        self.weather = {
            switch arc4random() % 4 {
            case 0: return .Sunny
            case 1: return .Rain
            case 2: return .Snow
            case 3: return .Sandstorm
            default: return .Sunny
            }
            }()
        
        self.dayTime = {
            switch arc4random() % 2 {
            case 0: return .Day
            case 1: return .Night
            default: return .Day
            }
        }()
        
        print("self.land : \(self.land)")
        print("self.weather : \(self.weather)")
        print("self.dayTime : \(self.dayTime)")
        
        if self.dayTime == .Day {
            skyColor = setSceneSkyColor_Day(self.land)
        } else {
            skyColor = setSceneSkyColor_Night(self.land)
        }
        
        self.setSceneWeather(self.weather)
//        self.setSceneDay(self.dayTime)
        
        self.backgroundColor = skyColor
    }
    
    //MARK: 天气
    func setSceneWeather(type:WeatherType) {
        
        switch type {
        case .Sunny:
            print("晴天......")
        case .Rain:
            print("雨......")
            NSNotificationCenter.defaultCenter().postNotificationName("RainNotificationNotification", object: nil)
        case .Snow:
            print("雪......")
        case .Sandstorm:
            print("沙尘......")
        }
        
    }
    
    func setSceneDay(type: DayType) {
        
        switch type {
        case .Day:
            print("Day......")
        case .Night:
            print("Night......")
        }
    }
    
    func setGlobalPlatfrmoTexture() {
        self.floorTexture = setPlatformTextureWithFloor(self.land)
        
        self.wallTexture1 = setPlatformTextureWithWall(self.land)
        self.wallTexture2 = setPlatformTextureWithWall(self.land)
        self.wallTexture3 = setPlatformTextureWithWall(self.land)
        self.wallTexture4 = setPlatformTextureWithWall(self.land)
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
//        createBG_layer()
//        if self.land == .Amazon || self.land == .Volcanic || self.land == .SnowMountain || self.land == .Iceberg || self.land == .Nightsky {
//            createBG_HillDepth0_Layer()
//        }
        
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
        
    }
    
    
    // 创建模版数据
    func initPlaygroud() {
        
        self.platfromsTupleArray.removeAll()
        
        let nodeLong_Section = createPlatfromNodeWithSKS(self.long_SectionNode)
        self.platfromsTupleArray.append(nodeLong_Section, Long_SectionWidth)
        
        let nodeDoor_Section = createPlatfromNodeWithSKS(self.door_SectionNode)
        self.platfromsTupleArray.append(nodeDoor_Section, Door_SectionWidth)
        
        let nodeDown_Section = createPlatfromNodeWithSKS(self.down_SectionNode)
        self.platfromsTupleArray.append(nodeDown_Section, Down_SectionWidth)
        
        let nodeMovingBridgeX_Section = createPlatfromNodeWithSKS(self.bridgeMovingInX_SectionNode)
        self.platfromsTupleArray.append(nodeMovingBridgeX_Section, BridgeMovingInX_SectionWidth)
        
        let nodeBridgeMovingInY_Section = createPlatfromNodeWithSKS(self.bridgeMovingInY_Section)
        self.platfromsTupleArray.append(nodeBridgeMovingInY_Section, BridgeMovingInY_SectionWidth)
        
        let nodeSpring_Section = createPlatfromNodeWithSKS(self.spring_Section)
        self.platfromsTupleArray.append(nodeSpring_Section, Spring_SectionWidth)
    
    }
    
    
    func setupStartPlatfroms() {
        
        var lastNodeX:CGFloat = -64
        
        let longSectionNode = createPlatfromNodeWithSKS(self.long_SectionNode)
//        let count = Int(Screen_Width / 64)
        for _ in 0...6 {
            
            let node = longSectionNode.copy() as! SKNode // 复制一排
            
            self.playergroundNode.addChild(node)
            
            self.platfromsTupleUpdateArray.append((node, 64))
            
            node.position.x = lastNodeX + 64
            
            lastNodeX = node.position.x
            
        }
        
        
        for _ in 0...4 {
            
            // 从模版数组取数据
            
            let platfromNodeTuple:(SKNode, CGFloat) = {
                switch arc4random() % 5 {
                case 0:
                    return platfromsTupleArray[1]
                case 1:
                    return platfromsTupleArray[2]
                case 2:
                    return platfromsTupleArray[3]
                case 3:
                    return platfromsTupleArray[4]
                case 4:
                    return platfromsTupleArray[5]
                default:
                    return platfromsTupleArray[1]
                }
            }()
            
            let node = platfromNodeTuple.0.copy() as! SKNode
            node.setAnimiation(node)
            
            // 获取上一个在场景中的node的位置
            let lastNode = self.platfromsTupleUpdateArray.last
            
            node.position.x = self.platfromsTupleUpdateArray.last!.0.position.x + (lastNode?.1)!
            
            self.playergroundNode.addChild(node)
            
            self.platfromsTupleUpdateArray.append((node, platfromNodeTuple.1))
            
            self.platfromInterval = (self.platfromsTupleUpdateArray.last?.1)!
        }

    }
    
    
    func createLongSectionWith(count:Int, node:SKNode) -> (SKNode, CGFloat) {
        var lastNodeX:CGFloat = -64
        
//        let longSectionNode = createPlatfromNodeWithSKS(self.long_SectionNode)
        
        let nodeParent = SKNode()
        
        for _ in 0...count {
            
            let node = node.copy() as! SKNode // 复制一排
            node.position.x = lastNodeX + 64
            nodeParent.addChild(node)
            
            lastNodeX = node.position.x
        }
        
        return (nodeParent,  64.0 * CGFloat(count + 1))
        
    }
    
    func createPlatfromNodeTupleRandom() {
        // 从模版数组取数据
        let platfromNodeTuple = platfromsTupleArray[Int.random(min: 0, max: platfromsTupleArray.count - 1)]
        
        // 如果是 Long_Section 复制一排
        if platfromNodeTuple.1 ==  Long_SectionWidth {
            let count = Int.random(min: 1, max: 5)
            let nodeTuple = createLongSectionWith(count, node: platfromNodeTuple.0)
            
            let newNode = nodeTuple.0
            // 获取上一个在场景中的node的位置
            let lastNode = self.platfromsTupleUpdateArray.last
            
            newNode.position.x = self.platfromsTupleUpdateArray.last!.0.position.x + (lastNode?.1)!
            
            self.playergroundNode.addChild(nodeTuple.0)
            
            self.platfromsTupleUpdateArray.append(nodeTuple)
            
            
        } else {
            
            let node = platfromNodeTuple.0.copy() as! SKNode
            
            //MARK: 设置关卡动画时间
            node.setAnimiation(node)
            
            // 获取上一个在场景中的node的位置
            let lastNode = self.platfromsTupleUpdateArray.last
            
            node.position.x = self.platfromsTupleUpdateArray.last!.0.position.x + (lastNode?.1)!
            
            self.playergroundNode.addChild(node)
            
            self.platfromsTupleUpdateArray.append((node, platfromNodeTuple.1))
            
        }
        
        self.platfromInterval = (self.platfromsTupleUpdateArray.last?.1)!
    }

    
    
    //MARK: 实时刷新关卡地图 增加一个新的放到最后面
    func updatePlatfroms() {

        if platfromInterval <= 10 {
            //更新Platfroms
            print("更新Platfroms")
            
            self.createPlatfromNodeTupleRandom()
            
        } else {
            self.platfromInterval -= ScrollBG_Move_Speed
        }
        
        if let firstNode = platfromsTupleUpdateArray.first {
            let firstNodePostionInScene = self.convertPoint(self.position, fromNode: firstNode.0)
            
            // 如果第一个node的相对场景位置 <= -自身宽度 视为出屏幕
            if firstNodePostionInScene.x <= -firstNode.1 {
                platfromsTupleUpdateArray.removeAtIndex(0)
                firstNode.0.removeFromParent()
            }
        }
        
    }
    


    //MARK: 从SKS文件创建场景 设置场景纹理
    func createPlatfromNodeWithSKS(node:SKNode) ->SKNode {
        
//        let floorTexture = setPlatformTextureWithFloor(self.land)
//        
//        let wallTexture1 = setPlatformTextureWithWall(self.land)
//        let wallTexture2 = setPlatformTextureWithWall(self.land)
//        let wallTexture3 = setPlatformTextureWithWall(self.land)
//        let wallTexture4 = setPlatformTextureWithWall(self.land)
        
        let platfromNode = node.copy() as! SKNode
        
        if let nodes = platfromNode.childNodeWithName("floorNodes") {

            for node in nodes.children {
                
                let _node = node as! SKSpriteNode
                _node.texture = floorTexture
                
                _node.physicsBody?.restitution = 0
            }
        }
        
        // 左右移动的平台
        if let nodes = platfromNode.childNodeWithName("floorMoveXNodes") {
            
            for node in nodes.children {
                
                let _node = node as! SKSpriteNode
                _node.texture = floorTexture//setPlatformTextureWithFloor(self.land)
                
                _node.physicsBody?.restitution = 0
                
            }
        }
        
        // 上下移动的平台
        
        if let nodes = platfromNode.childNodeWithName("floorMoveYNodes") {
            
            for node in nodes.children {
                
                let _node = node as! SKSpriteNode
                _node.texture = floorTexture//setPlatformTextureWithFloor(self.land)
                
                _node.physicsBody?.restitution = 0
                
                //                _node.physicsBody?.friction = 0
                //                _node.physicsBody?.charge = 0
                //                _node.physicsBody?.linearDamping = 0
                //                _node.physicsBody?.angularDamping = 0
                
//                let wait = SKAction.waitForDuration(NSTimeInterval(CGFloat.random(min: 1.0, max: 2.0)))
//                let sequence = SKAction.sequence([wait, SKAction.moveToY_Cycle(64 * 5, time: NSTimeInterval(CGFloat.random(min: 1.5, max: 2.0)))])
//                
//                _node.runAction(sequence)
                
            }
        }
        
        if let nodes = platfromNode.childNodeWithName("downFloorNodes") {
            
            for node in nodes.children {
                
                let _node = node as! SKSpriteNode
                _node.texture = setPlatformTextureWithDownFloor(self.land)
                
                
//                _node.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(48, 20), center: CGPointMake(0, _node.size.height * 0.3))
//                _node.physicsBody?.dynamic = false
//                _node.physicsBody?.allowsRotation = false
//                
//                _node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Down_Floor
//                _node.physicsBody?.collisionBitMask = CollisionCategoryBitmask.None //  对任何物体碰撞直接穿过
//
//                _node.physicsBody?.restitution = 0
                
                //                _node.physicsBody?.friction = 0
                //                _node.physicsBody?.charge = 0
                //                _node.physicsBody?.linearDamping = 0
                //                _node.physicsBody?.angularDamping = 0
            }
        }
        
        // 设置钥匙的 随机高度
        if let nodes = platfromNode.childNodeWithName("doorNode") {
            
            if let doorWalls = nodes.childNodeWithName("doorWalls") {
                for node in doorWalls.children {
                    let node = node as! SKSpriteNode
                    
                    let texture:SKTexture = {
                        
                        switch arc4random() % 5 {
                        case 0:
                            return self.wallTexture1
                        case 1:
                            return self.wallTexture2
                        case 2:
                            return self.wallTexture3
                        case 3:
                            return self.wallTexture4
                        default:
                            return self.wallTexture1
                        }
                    }()
                    
                    node.texture = texture
                }
            }
            
            if let keyNode = node.childNodeWithName("doorkeynode") {

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
        }
        
        // 设置纹理层次
        if let nodes = platfromNode.childNodeWithName("wallNodes") {
            
            if let wall1 = nodes.childNodeWithName("wallChildNode1") {
                for node in wall1.children {
                    let _node = node as! SKSpriteNode
                    _node.texture = wallTexture1
                }
            }
            
            if let wall2 = nodes.childNodeWithName("wallChildNode2") {
                for node in wall2.children {
                    let _node = node as! SKSpriteNode
                    _node.texture = wallTexture2
                }
            }
            
            if let wall3 = nodes.childNodeWithName("wallChildNode3") {
                for node in wall3.children {
                    let _node = node as! SKSpriteNode
                    _node.texture = wallTexture3
                }
            }
            
            if let wall4 = nodes.childNodeWithName("wallChildNode4") {
                for node in wall4.children {
                    let _node = node as! SKSpriteNode
                    _node.texture = wallTexture4
                }
            }
            
        }
        
        if let nodes = platfromNode.childNodeWithName("knifeNodes") {
            
            for node in nodes.children {
                
                let _node = node as! SKSpriteNode
//                _node.s
                _node.texture = platfromAtlats.kifne()
                
                _node.physicsBody?.restitution = 0
                
                //                _node.physicsBody?.friction = 0
                //                _node.physicsBody?.charge = 0
                //                _node.physicsBody?.linearDamping = 0
                //                _node.physicsBody?.angularDamping = 0
                
//                let wait = SKAction.waitForDuration(NSTimeInterval(CGFloat.random(min: 0.0, max: 2.0)))
//                let sequence = SKAction.sequence([wait, SKAction.moveToY_Cycle(380, time: NSTimeInterval(CGFloat.random(min: 2.5, max: 4.0)))])
//                _node.runAction(sequence)
                
            }
        }
        
        if let nodes = platfromNode.childNodeWithName("knifeOffNodes") {
            
            for node in nodes.children {
                
                let _node = node as! SKSpriteNode
                _node.texture = platfromAtlats.kifne()
                
                _node.physicsBody?.restitution = 0
                
                //                _node.physicsBody?.friction = 0
                //                _node.physicsBody?.charge = 0
                //                _node.physicsBody?.linearDamping = 0
                //                _node.physicsBody?.angularDamping = 0
            }
        }
        
        if let nodes = platfromNode.childNodeWithName("hiddenNodes") {
            
            for node in nodes.children {
                
                let _node = node as! SKSpriteNode
                _node.texture = floorTexture//setPlatformTextureWithFloor(self.land)
                
//                _node.hidden = true
//                _node.physicsBody?.friction = 0
//                _node.physicsBody?.charge = 0
//                _node.physicsBody?.restitution = 0
//                _node.physicsBody?.linearDamping = 0
//                _node.physicsBody?.angularDamping = 0

            }
        }
        
        if let nodes = platfromNode.childNodeWithName("spingNodes") {
   
            for node in nodes.children {
                
                let _node = node as! SKSpriteNode
                _node.color = UIColor.clearColor()

                _node.physicsBody?.restitution = 0
            }
        }
        
        if let nodes = platfromNode.childNodeWithName("skphyNodes") {
            
            for _node in nodes.children {
                
                _node.physicsBody?.restitution = 0

            }
        }
        
        return platfromNode
    }
    
    //MARK: 场景边缘
    func sceneEdgeBottom() {
        
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
    func createWater() {
        
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
                return SKColorWithRGB(166, g: 232, b: 255)
            case .MayaPyramid:
                return SKColorWithRGB(9, g: 132, b: 130)
            case .Iceberg:
                return SKColorWithRGB(179, g: 242, b: 253)
            case .BuildingShenshe:
                return SKColorWithRGB(12, g: 155, b: 206)
            case .Cemetery:
                return SKColorWithRGB(38, g: 56, b: 85)
            case .Nightsky:
                return SKColorWithRGB(105, g: 10, b: 188)
            }
        }()
        
        let water = GameSpriteNodeWithWaterBackgroud(waterColor)
        addChild(water)
    }
    
    // 背景渐变层
    func createBG_layer() {
        
        let texture = SKTexture(imageNamed: "BGLayerLine")
        let bg = SKSpriteNode(texture: texture, color: self.skyColor, size: CGSizeMake(Screen_Width * 1.01, texture.size().height))
        bg.position = CGPointMake(Screen_Width * 0.5, Screen_Height * 0.3)
        bg.anchorPoint = CGPointMake(0.5, 1)
        bg.zPosition = -300
        bg.colorBlendFactor = SceneSprite_ColorBlendFactor_Mountain
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
                count = Int.random(min: 1, max: 3)//Int(CGFloat.random(min: 1, max: 2)) CGFloat.random
                dt = CGFloat.random(min:200, max: 300)
                ScaleRadio = CGFloat.random(min: 1.6, max: 1.8)

            case .LayerB:
                count =  Int.random(min: 1, max: 3)
                dt = CGFloat.random(min: 100, max: 200)
                ScaleRadio = CGFloat.random(min: 1.2, max: 1.4)
            }

        case .Grove:
            switch depth {
            case .LayerA:
                count = Int.random(min: 2, max: 4)
                dt = CGFloat.random(min: 200, max: 300)
                ScaleRadio = CGFloat.random(min: 1.6, max: 1.8)
  
            case .LayerB:
                count =  Int.random(min: 4, max: 6)
                dt = CGFloat.random(min: 100, max: 200)
                ScaleRadio = CGFloat.random(min: 1.4, max: 1.6)
            }
            
        case .Volcanic:
            switch depth {
            case .LayerA:
                count = Int.random(min: 1, max: 3)
                dt = CGFloat.random(min:200, max: 300)
                ScaleRadio = CGFloat.random(min: 1.6, max: 1.8)
            case .LayerB:
                count =  Int.random(min: 1, max: 3)
                dt = CGFloat.random(min: 100, max: 200)
                ScaleRadio = CGFloat.random(min: 1.2, max: 1.4)
            }
        case .LahontanValley:
            switch depth {
            case .LayerA:
                count = Int.random(min: 1, max: 3)
                dt = CGFloat.random(min:200, max: 300)
                ScaleRadio = CGFloat.random(min: 1.4, max: 1.6)
            case .LayerB:
                count =  Int.random(min: 1, max: 3)
                dt = CGFloat.random(min: 100, max: 200)
                ScaleRadio = CGFloat.random(min: 1.2, max: 1.4)
            }
        case .SnowMountain:
            switch depth {
            case .LayerA:
                count = Int.random(min: 1, max: 3)
                dt = CGFloat.random(min:200, max: 300)
                ScaleRadio = CGFloat.random(min: 1.4, max: 1.6)
            case .LayerB:
                count =  Int.random(min: 1, max: 3)
                dt = CGFloat.random(min: 100, max: 200)
                ScaleRadio = CGFloat.random(min: 1.2, max: 1.4)
            }
        case .MayaPyramid:
            switch depth {
            case .LayerA:
                count = Int.random(min: 1, max: 3)
                dt = CGFloat.random(min:200, max: 300)
                ScaleRadio = CGFloat.random(min: 1.4, max: 1.6)
            case .LayerB:
                count =  Int.random(min: 1, max: 3)
                dt = CGFloat.random(min: 100, max: 200)
                ScaleRadio = CGFloat.random(min: 1.0, max: 1.2)
            }
        case .Iceberg:
            switch depth {
            case .LayerA:
                count = Int.random(min: 1, max: 3)
                dt = CGFloat.random(min:200, max: 300)
                ScaleRadio = CGFloat.random(min: 1.4, max: 1.6)
            case .LayerB:
                count = Int.random(min: 1, max: 3)
                dt = CGFloat.random(min: 100, max: 200)
                ScaleRadio = CGFloat.random(min: 1.2, max: 1.4)
            }
        case .BuildingShenshe:
            switch depth {
            case .LayerA:
                count = Int.random(min: 1, max: 3)
                dt = CGFloat.random(min: 200, max: 300)
                ScaleRadio = CGFloat.random(min: 0.8, max: 1.0)
            case .LayerB:
                count = Int.random(min: 1, max: 3)
                dt = CGFloat.random(min: 100, max: 200)
                ScaleRadio = CGFloat.random(min: 0.6, max: 0.8)
            }
        case .Cemetery:
            switch depth {
            case .LayerA:
                count = Int.random(min: 2, max: 4)
                dt = CGFloat.random(min: 200, max: 300)
                ScaleRadio = CGFloat.random(min: 0.8, max: 1.0)
            case .LayerB:
                count = Int.random(min: 2, max: 4)
                dt = CGFloat.random(min: 100, max: 200)
                ScaleRadio = CGFloat.random(min: 0.6, max: 0.8)
            }
        case .Nightsky:
            
            switch depth {
            case .LayerA:
                count = Int.random(min: 2, max: 3)
                dt = CGFloat.random(min:200, max: 300)
                ScaleRadio = CGFloat.random(min: 1.2, max: 1.4)
            case .LayerB:
                count = Int.random(min: 2, max: 3)
                dt = CGFloat.random(min: 100, max: 200)
                ScaleRadio = CGFloat.random(min: 1.0, max: 1.2)
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
    
    
    
    //MARK:天气 效果
    
    func rainNotificationFunc() {
        // 雨
        self.sceneWithRain()
        
        if GameState.sharedInstance.musicState {
            SKTAudio.sharedInstance().playBackgroundMusic(GameBGSongAudioName.RainAudioName.rawValue)
        }
    }
    
    // 雨
    func sceneWithRain() {
        let rainEmitter = SKEmitterNode.emitterNamed("Rain")
        rainEmitter.position = CGPointMake(Screen_Width/2, Screen_Height * 1.1)
        rainEmitter.zPosition = 50
        rainEmitter.alpha = 0.3
        rainEmitter.zRotation = CGFloat(-15 * M_PI / 180)
        
        self.addChild(rainEmitter)
    }
    
    
    // 飘叶
    func sceneWithSandstorm() {
        
        let rainEmitter = SKEmitterNode.emitterNamed("Sandstorm")
        rainEmitter.position = CGPointMake(Screen_Width, Screen_Height)
        rainEmitter.alpha = 1.0
        self.addChild(rainEmitter)
        
        
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
    

    
    // 背景闪烁星
    func createStarStar() {
        // 在屏幕上随机生成100-200个星星
        // 星星自身闪烁
        // 跟随背景移动
        
        let width = CGFloat.random(min: 3, max: 8)
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
    
    // 闪电
    func createLightning() {
        // CGFloat.random(min: Screen_Width * 0.2, max: Screen_Width * 0.8)
        flashLightNode = SKNode()
        flashLightNode.position = CGPointMake(Screen_Width * 0.5, Screen_Height * 1.1)
        addChild(flashLightNode)
        //        flashLightNode.hidden = true
        
        //        let flashX = CGFloat.random(min: 20, max: Screen_Width)
        
        let flash = SKSpriteNode(texture: randomFlashTexture())
        flash.setScale(CGFloat.random(min: 0.8, max: 1.0))
        flash.anchorPoint = CGPointMake(0.5, 1.1)
        flash.zRotation = CGFloat.toAngle(Double(CGFloat.random(min: -25, max: 35)))
        flash.zPosition = -50
        flashLightNode.addChild(flash)
        
        let halo = SKSpriteNode(imageNamed: "flashhalo")
        halo.alpha = 0.8
        halo.setScale(1.5)
        halo.anchorPoint = CGPointMake(0.5, 1)
        halo.zPosition = -50
        flashLightNode.addChild(halo)
        
        let alpha = SKAction.fadeAlphaTo(0, duration: 1.0)
        let remove = SKAction.removeFromParentAfterDelay(0.5)
        
        flashLightNode.runAction(SKAction.sequence([alpha, remove]))
    }
    
    
    //  背景动态光线
    func createDynamicSunshine() {
        
        let lineNode = SKNode()
        lineNode.position = CGPointMake(Screen_Width, Screen_Height * 0.7)
        lineNode.zPosition = -200
        self.addChild(lineNode)
        
        let lineSpriteA = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(120, Screen_Height * 1.2))
        let lineSpriteB = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(120, Screen_Height * 1.2))
        lineNode.addChild(lineSpriteA)
        lineNode.addChild(lineSpriteB)
        
        lineSpriteA.colorBlendFactor  = 0.5
        lineSpriteB.colorBlendFactor  = 0.5
        
        lineSpriteA.alpha = 0.0
        lineSpriteB.alpha = 0.0
        
        lineSpriteA.zRotation = CGFloat.toAngle(-30)
        lineSpriteB.zRotation = CGFloat.toAngle(-30)
        
        lineSpriteA.position.x = -60
        
        lineSpriteA.runAction(SKAction.moveAnimationToDisappear(CGFloat.random(min: -Screen_Width, max: -Screen_Width * 0.2),
            waitTime: NSTimeInterval(CGFloat.random(min: 3, max: 5)),
            removeDelay: 1))
        
        lineSpriteB.runAction(SKAction.moveAnimationToDisappear(CGFloat.random(min: -Screen_Width, max: -Screen_Width * 0.2),
            waitTime: NSTimeInterval(CGFloat.random(min: 3, max: 5)),
            removeDelay: 1))
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
    
    // 掉落的怪物 会砸死角色 (砸在地面上时，成为地面子物体，跟随地面移动)
    func createEmenyDown(){
        let randomEnemyX = CGFloat.random(min: 64.0 * 4 , max: 64.0 * 12)
        
        let node = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(30, 30))
        node.position = CGPointMake(randomEnemyX, Screen_Height * 1.2)
        node.zPosition = 200
        
        addChild(node)
        
        node.physicsBody = SKPhysicsBody(rectangleOfSize: node.size)
        node.physicsBody?.dynamic = true
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Enemy
        node.physicsBody?.collisionBitMask = CollisionCategoryBitmask.Normal_Floor
        node.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Normal_Floor
        
        node.physicsBody?.mass = 0
        node.physicsBody?.friction = 1.0  // 摩擦
        node.physicsBody?.charge = 1000
        node.physicsBody?.restitution = 100
        node.physicsBody?.linearDamping = 10
        node.physicsBody?.angularDamping = 10
        
//        node.runAction(SKAction.moveToY(<#T##y: CGFloat##CGFloat#>, duration: <#T##NSTimeInterval#>))
        
//        node.physicsBody?.applyImpulse(CGVectorMake(50, 0))
//        node.runAction(SKAction.removeFromParentAfterDelay(3.5))
    }
    
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
    
    // 停留时间过长 被掉落的尖柱刺死
    func flopTerrorPillar() {
        let terrorPillar = self.terrorPillar.copy() as! SKNode
        
        if let doorWalls = terrorPillar.childNodeWithName("doorWalls") {
            for node in doorWalls.children {
                let node = node as! SKSpriteNode
                
                let texture:SKTexture = {
                    
                    switch arc4random() % 5 {
                    case 0:
                        return self.wallTexture1
                    case 1:
                        return self.wallTexture2
                    case 2:
                        return self.wallTexture3
                    case 3:
                        return self.wallTexture4
                    default:
                        return self.wallTexture1
                    }
                }()
                
                node.texture = texture
            }
        }
        
        let playerPostion = convertPoint(self.position, fromNode: self.playerNode)
        
        terrorPillar.position = CGPointMake(playerPostion.x, Screen_Height)
        
        self.addChild(terrorPillar)
        
        let down = SKAction.moveBy(CGVectorMake(0, -(64 * 10 - 32)), duration: 0.5)
//        let down = SKAction.moveTo(CGPointMake(playerPostion.x, playerPostion.y + 32), duration: 0.5)
        
//        let remove = SKAction.removeFromParentAfterDelay(1.5)
        terrorPillar.runAction(SKAction.sequence([down]))
    }
    
    //MARK: --------------------构建player
    func createPlayer() {
        
        
        
//        self.playerNode = SKNode()
//        
//        let fingerSprite = SKSpriteNode(imageNamed: "pixelMan01")
//        self.playerNode.addChild(fingerSprite)
//        
//        var fingersps = [SKTexture]()
//        fingersps.append(SKTexture(imageNamed: "pixelMan01"))
//        fingersps.append(SKTexture(imageNamed: "pixelMan02"))
//        
//        let fingerTouch = SKAction.animateWithTextures(fingersps, timePerFrame: 0.3)
//        let fingerTouchAni = SKAction.repeatAction(fingerTouch, count: 2)
//        let fingerTouchSequence = SKAction.repeatActionForever(SKAction.sequence([fingerTouchAni]))
//        fingerSprite.runAction(fingerTouchSequence)
        
        self.playerNode = GameSpriteNodeWithPlayerNode(SKTexture(imageNamed: "pixelMan01")) //choseChaterName(playertype)
        self.playerNode.position = CGPointMake(Long_SectionWidth * 7 - 32, PlayerStartHigth) //playerHight + playerNode.height * 0.5
        self.playerNode.xScale = -1
        //        playerNode.zRotation = CGFloat.toAngle(-10)
        self.playerNode.zPosition = 220
        self.playergroundNode.addChild(playerNode)
        
        
//        self.birdWink()
        
//        self.playerNode = Player(texture: SKTexture(imageNamed:"pixelMan"), color: SKColor.whiteColor())
//        self.playerNode.position = CGPointMake(playerOffset, 400 )
//        self.playerNode.zPosition = 220
//        
//        self.addChild(playerNode)
        
    }
    
//    var playershadow:SKSpriteNode!
    
//    func choseChaterName(type:PlayerType) ->SKTexture{
//        switch type {
//        case .A: return sheet.katoonA01()
//        case .B: return poc.PocRuning1()
//        case .C: return sheet.katoonA01()
//            
//        }
//    }
    
//    func choseChaterAnimation(type:PlayerType) ->[SKTexture] {
//        switch type {
//        case .A: return sheet.katoonA()
//        case .B: return poc.PocRuning()
//        case .C: return sheet.katoonA()
//        }
//    }
    
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
    
    //  引导手指
    func figerNode() {
        guideFigerNode = SKNode()
        
        self.guideFigerNode.zPosition = 300
//        self.setScale(1.2)
        self.guideFigerNode.position = CGPoint(x: Screen_Width * 0.6, y: Screen_Height * 0.3)
        self.addChild(guideFigerNode)
        
        let fingerSprite = SKSpriteNode(imageNamed: "touch01")
        self.guideFigerNode.addChild(fingerSprite)
        
        var fingersps = [SKTexture]()
        fingersps.append(SKTexture(imageNamed: "touch01"))
        fingersps.append(SKTexture(imageNamed: "touch02"))
        
        let fingerTouch = SKAction.animateWithTextures(fingersps, timePerFrame: 0.3)
        let fingerTouchAni = SKAction.repeatAction(fingerTouch, count: 2)
        let fingerTouchSequence = SKAction.repeatActionForever(SKAction.sequence([fingerTouchAni]))
        fingerSprite.runAction(fingerTouchSequence)
    }
    
    //MARK: 角色动画
    // 眨眼动画
    func birdWink() -> SKAction {
        
        
//        let birdWinkSprite = SKSpriteNode(imageNamed: "pixelMan01")
//        
//        self.playerNode.addChild(birdWinkSprite)
        
        var birdWinkTextures = [SKTexture]()
        birdWinkTextures.append(SKTexture(imageNamed: "pixelMan01"))
        birdWinkTextures.append(SKTexture(imageNamed: "pixelMan02"))
        
        let fingerTouch = SKAction.animateWithTextures(birdWinkTextures, timePerFrame: 0.3)
        let fingerTouchAni = SKAction.repeatAction(fingerTouch, count: 2)
        let fingerTouchSequence = SKAction.repeatActionForever(SKAction.sequence([fingerTouchAni]))
        
        return fingerTouchSequence
    }
    
     //MARK: 踩踏地面
    func contactFloorEvent(node:SKNode) {
        
        GameState.sharedInstance.canJump = true
        
        self.playerNode.removeFromParent()
        self.playerNode.position = CGPointMake(0, 32)

        node.addChild(playerNode)
        
        print(self.playerNode.position)
    }
    
    var lastContactNode:SKPhysicsBody?
    // MARK:碰撞委托方法 protocol Method
    // 碰撞开始
    func didBeginContact(contact: SKPhysicsContact) {
        
        if !GameState.sharedInstance.gameOver {
            
            let otherA = (contact.bodyA.categoryBitMask == CollisionCategoryBitmask.Player ? contact.bodyB : contact.bodyA)

            if let node = otherA.node {
                
                if otherA == lastContactNode {
                    return
                } else {

                    switch otherA.categoryBitMask {
                        
                    case CollisionCategoryBitmask.Normal_Floor :
                        print("Contact Floor")
                        
//                        self.playerNode.runAction(self.birdWink())
                        
                        contactFloorEvent(node)
                        showplayerMagic(convertPoint(self.position, fromNode: self.playerNode))
                        
                        // 角色长时间不动时 会发出叫声
                        
//                        let wait = SKAction.waitForDuration(NSTimeInterval(CGFloat.random(min: 1.0, max: 3.0)))
//                        
//                        runAction(SKAction.sequence([wait, chickenSoundAction]))
                        
//                        self.playerNode.doStayAnimation()
                        
                    case CollisionCategoryBitmask.Gold :
                        print("Contact Gold")
                        
                        if GameState.sharedInstance.musicState { runAction(getGlodSoundAction) }
                        
                        node.runAction(getGoldAction)
                        
//                        GameState.sharedInstance.gold += 1
//                        self.gameSceneDelegate?.updateGold(Int(GameState.sharedInstance.gold))
                        
                    case CollisionCategoryBitmask.Enemy :
                        print("Contact Enemy")
                        
                        self.shakeCarema() //  震屏
//
                        self.showParticlesForEnemy(convertPoint(self.position, fromNode: self.playerNode)) // 爆炸特效
                        self.gameEndPlayerDeath()
                        
//                        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
//                            self.gameSceneDelegate?.gameOverScreenshots()
//                            
//                            dispatch_async(dispatch_get_main_queue(), {
//                                //  震屏
//                                
//                                self.showParticlesForEnemy(self.convertPoint(self.position, fromNode: self.playerNode)) // 爆炸特效
//                                self.gameEndPlayerDeath()
//                                self.shakeCarema() //  震屏
//                                
//                                if GameState.sharedInstance.musicState { self.runAction(self.enemySoundAction) }
//                                
//                                let delay:Double = 0.2
//                                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
//                                
//                                dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
//                                    self.gameEnd()
//                                }
//                                
//                            })
//                        })
                        
                        let timea = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
                        
                        dispatch_after(timea, dispatch_get_main_queue()) { () -> Void in
                            self.gameSceneDelegate?.gameOverScreenshots()
                        }

                        if GameState.sharedInstance.musicState { self.runAction(self.enemySoundAction) }

                        let delay:Double = 0.2
                        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
                        
                        dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
                            self.gameEnd()
                        }
//
                        
                        //////////.....
                        
//                        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
//                            let timea = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
//                            
//                            dispatch_after(timea, dispatch_get_main_queue()) { () -> Void in
//                                self.gameSceneDelegate?.gameOverScreenshots()
//                            }
//                            
//                            if GameState.sharedInstance.musicState { self.runAction(self.enemySoundAction) }
//                            
//                            let delay:Double = 0.2
//                            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
//                            
//                            dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
//                                self.gameEnd()
//                            }
//                            
//                            dispatch_async(dispatch_get_main_queue(), {
//                                self.shakeCarema() //  震屏
//                                self.showParticlesForEnemy(self.convertPoint(self.position, fromNode: self.playerNode)) // 爆炸特效
//                                self.gameEndPlayerDeath()
//                            })
//                            
//                        })

                        
                    case CollisionCategoryBitmask.Wather :
                        print("Contact Wather")
                        
                        self.shakeCarema() //  震屏
                        
                        self.showParticlesForEnemy(convertPoint(self.position, fromNode: self.playerNode)) // 爆炸特效
                        self.gameEndPlayerDeath()
                        
                        let timea = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
                        dispatch_after(timea, dispatch_get_main_queue()) { () -> Void in
                            self.gameSceneDelegate?.gameOverScreenshots()
                        }
                        
                        if GameState.sharedInstance.musicState { runAction(waterSoundAction) }

                        let delay:Double = 0.2
                        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
                        
                        dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
                            self.gameEnd()
                        }
                        
                    case CollisionCategoryBitmask.DoorKey_Button:
                        print("Contact 开门 按钮")
                        node.runAction(doorKeyAction)
                        
                        if GameState.sharedInstance.musicState { self.runAction(getdoorKeySoundAction)}
                        
                        if let parentNode = node.parent {
                            parentNode.runAction(doorOpenAction)
                        }
//                        let door = node.parent! as SKNode
                        
                    case CollisionCategoryBitmask.Down_Floor:
                        print("Contact 踩踏 下落")
                        contactFloorEvent(node)
                        showplayerMagic(convertPoint(self.position, fromNode: self.playerNode))
                        
                        if GameState.sharedInstance.musicState { self.runAction(downSoundAction) }
                        
                        let delay:Double = 0.3
                        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
                        
                        dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
                            node.physicsBody?.dynamic = true
                        }
                        
                    case CollisionCategoryBitmask.Invisible:
                        print("Contact 隐形的")
                        contactFloorEvent(node)
                        showplayerMagic(convertPoint(self.position, fromNode: self.playerNode))
                        
                        node.hidden = false
                        
                    case CollisionCategoryBitmask.Spring:
                        print("Contact 弹簧")
//                        contactFloorEvent(node)
//                        playerMagic(node)
                        
                        self.playerNode.physicsBody?.applyImpulse(CGVectorMake(20, 60))

//                        self.playerNode.runAction(SKAction.moveBy(CGVectorMake(64 * 3, 0), duration: 0.2))
                        
                        if GameState.sharedInstance.musicState { self.runAction(springSoundAction) }

                        
                    default:
                        break
                    }
                    
                    lastContactNode = otherA

                }
                
            }
        }
        
    }
    //MARK: 声音特效
    func jumpSong() ->SKAction  {
        switch arc4random() % 11 {
            
        case 0: return SKAction.playSoundFileNamed("yeah_owell26.mp3", waitForCompletion: false)
            
        case 1: return SKAction.playSoundFileNamed("yeah_02.mp3", waitForCompletion: false)
        case 2: return SKAction.playSoundFileNamed("yeah_03.mp3", waitForCompletion: false)
        case 3: return SKAction.playSoundFileNamed("yeah_peli20.mp3", waitForCompletion: false)
        case 4: return SKAction.playSoundFileNamed("yeah_05.mp3", waitForCompletion: false)
        case 5: return SKAction.playSoundFileNamed("yeah_owell26.mp3", waitForCompletion: false)
            
        case 6: return SKAction.playSoundFileNamed("yeah_flam04.mp3", waitForCompletion: false)
        case 7: return SKAction.playSoundFileNamed("yeah_flam09.mp3", waitForCompletion: false)
        case 8: return SKAction.playSoundFileNamed("yeah_flam10.mp3", waitForCompletion: false)
        case 9: return SKAction.playSoundFileNamed("yeah_owell01.mp3", waitForCompletion: false)
        case 10: return SKAction.playSoundFileNamed("yeah_owell03.mp3", waitForCompletion: false)
            
        default : return SKAction.playSoundFileNamed("inGame_action_jump.mp3", waitForCompletion: false)
        }
    }
    //MARK: 粒子特效
    
    //MARK: 踩踏地面特效
    func showplayerMagic(postion:CGPoint) {
        print("playerMagic")
        self.magicNode = SKEmitterNode.emitterNamed("playerMagic")
        self.magicNode.particleTexture!.filteringMode = .Nearest
        self.magicNode.position = CGPointMake(postion.x - 50, postion.y)
        self.magicNode.zPosition = 400
        self.magicNode.targetNode = self
        
        addChild(self.magicNode)
        
        magicNode.runAction(SKAction.removeFromParentAfterDelay(1.8))
        
    }
    
    // 灾难特效
    func showDistress(postion:CGPoint) {
        let emitter = SKEmitterNode.emitterNamed("distressParticle")
        emitter.particleTexture!.filteringMode = .Nearest
        emitter.position = position//CGPointMake(playerNode.position.x + self.playerNode.size.width, playerNode.position.y + 50)
        emitter.zPosition = 300
        
        addChild(emitter)
        
//        emitter.runAction(SKAction.removeFromParentAfterDelay(1.8))
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
    
    //  震屏
    func shakeCarema() {
        let sceneView = self.view
        if let view = sceneView {
            view.shakeC(5, delta: 8, interval: 0.02, shakeDirection: ShakeDirection.ShakeDirectionVertical)
        }
    }
    
    // 水波特效
    func showWaterWave(rect:CGRect, point: CGPoint) {
        let shapeNode = SKShapeNode()
        
        let path = UIBezierPath(rect: rect)//UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: 10, height: 10))
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
        print("startGame()...")
        NSNotificationCenter.defaultCenter().postNotificationName("startGameAnimationNotification", object: nil)
        
        self.guideFigerNode.removeFromParent()
        
        self.playerNode.physicsBody?.dynamic = true
        
//        self.playerNode.physicsBody?.applyImpulse(CGVectorMake(0, 20))
        self.playerNode.xScale = 1

//        self.playerMoveAnimation(CGVectorMake(Player_Jump_Width, Player_Jump_Hight))
        
        GameState.sharedInstance.gameOver = false
//        GameState.sharedInstance.isLoadingDone = false
        
    }
    
    //MARK: 游戏结束
    func gameEnd() {
        
        GameState.sharedInstance.gameOver = true
        GameState.sharedInstance.canJump = false
        GameState.sharedInstance.isLoadingDone = false
        
//        SKTAudio.sharedInstance().pauseBackgroundMusic()
        
        self.gameSceneDelegate?.updateHUD(GameState.sharedInstance.currentScore)
        
        // 保存游戏状态 分数等信息
        GameState.sharedInstance.saveState()
        
        NSNotificationCenter.defaultCenter().postNotificationName("gameOverNotification", object: nil)
        
    }
    
    
    func gameEndPlayerDeath() {
        
        
        
        self.playerNode.physicsBody?.collisionBitMask = CollisionCategoryBitmask.None

//        self.playerNode.physicsBody?.applyImpulse(CGVectorMake(-5, 30))
        
        self.playerNode.physicsBody?.dynamic = false

        self.playerNode.yScale = -1
        
        let delay:Double = 1.0
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        
        dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
            self.playerNode.physicsBody?.dynamic = true
            
            if GameState.sharedInstance.musicState { self.runAction(self.lostSound)}

        }
    }
    
    //MARK: 点击事件
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
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
    
    //MARK: 天气
    func updateWater() {
        // 夜 没有下雨
        if self.weather != .Rain && self.dayTime != .Day {
            let dt1 = Int(arc4random_uniform(20))
            if dt1 == 1 { createStarStar() } // 星星
            
            let dt2 = Int(arc4random_uniform(1000))
            if dt2 == 1 { createMeteor() } // 流星
        }
        
//        if self.weather != .Rain && self.dayTime != .Night {
//            let dt1 = Int(arc4random_uniform(200))
//            if dt1 == 1 { createDynamicSunshine() } // 动态光线
//        }
        
        // 闪电
        if self.weather == .Rain {
            let dt1 = Int(arc4random_uniform(500))
            if dt1 == 1 {
                self.createLightning()
                if GameState.sharedInstance.musicState { self.runAction(thunderSoundAction) }
            }
        }
        
    }
    
    func exceedTopScroeTip() {
        print("破纪录")
        if let name = GameState.sharedInstance.gameCenterPlayerName {
            let label = SKLabelNode(fontNamed: Font_Name)
            label.text = "\(name)"
            label.fontSize = 30
            label.position = CGPointMake(Screen_Width * 1.1, Screen_Height * 0.8)
            self.playergroundNode.addChild(label)
            
            let wait = SKAction.waitForDuration(10)
            let alp = SKAction.fadeAlphaTo(0, duration: 1.0)
            let remove = SKAction.removeFromParent()
            label.runAction(SKAction.sequence([wait, alp, remove]))
            
            print("破纪录  label \(label.position.x)")

        }
    }
    
    //MARK: 更新 分数
    func updateGameScore() {
        GameState.sharedInstance.currentScore += 1
        gameSceneDelegate?.updateHUD(GameState.sharedInstance.currentScore)
        
        // 如果分数达到最高分 屏幕显示名字
        if GameState.sharedInstance.currentScore > GameState.sharedInstance.gamecenterSelfTopScore {
            GameState.sharedInstance.gamecenterSelfTopScore = GameState.sharedInstance.currentScore
            GameState.sharedInstance.saveState()
            
            // 如果当前分数大于game center 分数 上传新的游戏分数
            EGC.reportScoreLeaderboard(leaderboardIdentifier: Leader_Board_Identifier, score: GameState.sharedInstance.gamecenterSelfTopScore!)
            
//            exceedTopScroeTip()

        }

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
        }
    }
    
    func updateEmenyDown() {
        
        let dt = Int(arc4random_uniform(200))
        if dt == 1 {
            createEmenyDown()
        }
    }
    
    
    //MARK: update
    override func update(currentTime: CFTimeInterval) {
        
        //天气
        updateWater()
        
        // 游戏开始
        if !GameState.sharedInstance.gameOver && !GameState.sharedInstance.tiemsUp {
            // 滚动远处背景
            self.scrollBackground()
            
            self.updatePlatfroms()
            
            let playerPostionInScene = convertPoint(self.position, fromNode: self.playerNode) // 角色在场景坐标系的位置
            
//            if playerPostionInScene.x <= Screen_Width * 0.6 {
//                self.ScrollBG_Move_Speed = 0.5
//
//            } else if playerPostionInScene.x >= Screen_Width * 0.8 {
//                self.ScrollBG_Move_Speed = playerPostionInScene.x * 0.01
//
//            } else {
//                self.ScrollBG_Move_Speed = playerPostionInScene.x * 0.005
//            }
            
            if playerPostionInScene.x <= Screen_Width * 0.35 {
                self.ScrollBG_Move_Speed = playerPostionInScene.x * 0.0015
            } else {
                self.ScrollBG_Move_Speed = playerPostionInScene.x * 0.005
            }
            
            
            
            self.playergroundNode.position.x -= ScrollBG_Move_Speed
//            self.playerNode.position.x -= ScrollBG_Move_Speed
            
//            if GameState.sharedInstance.canJump {
//                self.playerNode.position.x -= ScrollBG_Move_Speed
//            }
            
            GameState.sharedInstance.lifeTimeCount -= 0.005

            
            self.gameSceneDelegate?.updateLifeTime(GameState.sharedInstance.lifeTimeCount)
            
            //MARK: 如果停留时间过长 被掉落物刺死
            if GameState.sharedInstance.lifeTimeCount <= 0 {
                
                self.flopTerrorPillar()
                
                GameState.sharedInstance.tiemsUp = true


//                if GameState.sharedInstance.musicState { self.runAction(self.eagleSoundAction) }
                
//                self.gameEnd()
//                
//                self.playerNode.physicsBody?.applyImpulse(CGVectorMake(5, 30))
//
//                let delay:Double = 0.1
//                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
//                
//                dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
//                    self.playerNode.physicsBody?.collisionBitMask = CollisionCategoryBitmask.None
//                    
//                    self.playerNode.physicsBody?.dynamic = false
//
//                    let delay:Double = 0.5
//                    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
//                    
//                    dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
//                        self.playerNode.physicsBody?.dynamic = true
//                    }
//
//                }
            }
            
        } else {
//            print("GameState.sharedInstance.gameOver is ture")
            return
        }
        
    }
    
}



