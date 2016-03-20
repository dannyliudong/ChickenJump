//
//  GameViewController.swift
//  Space2001
//
//  Created by liudong on 15/10/28.
//  Copyright (c) 2015年 liudong. All rights reserved.
//

import UIKit
import SpriteKit
import ReplayKit
import iAd
import StoreKit

class GameViewController: UIViewController, SKPaymentTransactionObserver, SKProductsRequestDelegate, GameSceneDelegate, EGCDelegate {
    
    //MARK: 购买项目
    enum IAPItem {
        case IAP
    }
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var loadingBGView: UIImageView!
//    @IBOutlet weak var loadingBgUIView: UIView!
    @IBOutlet weak var loadingLogoView: UIImageView!
    @IBOutlet weak var gameOverMaskView: UIView!
    
    
//    @IBOutlet weak var characterButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var replayButton: UIButton!
    //    @IBOutlet weak var showReplay: UIButton!
    
    @IBOutlet weak var leaderboardsButton: UIButton!
    @IBOutlet weak var shareGameButton: UIButton!
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBAction func changeSceneButton(sender: UIButton) {
    }
    
//    @IBOutlet weak var giftButton: UIButton!
//    @IBOutlet weak var payContinueButton: UIButton!
//    @IBOutlet weak var watchAdsButton: UIButton!
    
    @IBOutlet weak var currentScoreLalbel: UILabel!
    @IBOutlet weak var topScroeLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var lblTimerMessage: UILabel!
    
    @IBOutlet weak var goldDisplayLabel: UILabel!
    
    private var secondsElapsed:Int = 3
    private var timer:NSTimer!
    
    var screenshotsImage:UIImage?
    
    
    // 显示loading ->等待场景加载完成-> 消失loading
    func showLoading() {
        self.loadingBGView.hidden = false
        self.loadingLogoView.hidden = false
        
        self.loadingLogoView.center.x = -loadingLogoView.bounds.size.width * 0.5
        
        
        UIView.animateWithDuration(0.5, animations: {
            self.loadingBGView.alpha = 1
            self.loadingLogoView.center.x += self.loadingLogoView.bounds.size.width * 0.5 + self.view.bounds.size.width * 0.5

            }, completion: { (done) in
        })
    }
    
    func disappearLoading() {
        
//        self.loadingLogoView.center.x = self.view.bounds.size.width * 0.5
        
        self.loadingBGView.hidden = false
        self.loadingLogoView.hidden = false
        
        UIView.animateWithDuration(0.5, animations: {
            self.loadingBGView.alpha = 0
            
            }, completion: { (done) in
                
                UIView.animateWithDuration(1.0, animations: {
                    self.loadingLogoView.center.x += self.view.bounds.size.width * 1.5
                    
                    }, completion: { (done) in
                        self.loadingBGView.hidden = true
                        self.loadingLogoView.hidden = true
                        
                        GameState.sharedInstance.isLoadingDone = true
                })
                
                print("disappearLoading")
        })
    }

    
    override func viewWillAppear(animated: Bool) {
        // 隐藏状态栏....
        UIApplication.sharedApplication().statusBarHidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        EGC.delegate = self
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isSupportReplay()
        
        self.showLoading()
        
        EGC.sharedInstance(self)
        EGC.debugMode = true
        
//        self.characterButton.layer.cornerRadius  = Button_CornerRadius
        self.settingsButton.layer.cornerRadius  = Button_CornerRadius
        self.pauseButton.layer.cornerRadius  = Button_CornerRadius
        
        self.leaderboardsButton.layer.cornerRadius = Button_CornerRadius
        self.shareGameButton.layer.cornerRadius = Button_CornerRadius
        self.tryAgainButton.layer.cornerRadius = Button_CornerRadius
        
        self.hiddenGameOverButtons()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showHomeButton", name: "showHomeButtonNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pauseGame", name: "pauseGameNotification", object: nil)// 后台挂起时发出
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startGameNotificationAction", name: "startGameAnimationNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gameOverNotificationAction", name: "gameOverNotification", object: nil)
        
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "recoveryGameNotificationAction", name: "recoveryGameNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadingisDoneAction", name: "loadingisDoneNotification", object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "payRemoveAds", name: "removeAdsPayNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "restorePay", name: "restoreAdsPayNotification", object: nil)
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        
//        GameState.sharedInstance.gameScene = nil
//        
//        GameState.sharedInstance.gameScene = GameScene(size: CGSizeMake(Screen_Width, Screen_Height))//GameScene(fileNamed:"GameScene")
        
        let scene = GameScene(size: CGSizeMake(Screen_Width, Screen_Height))

            let skView = self.view as! SKView
            
//     Configure the view.
//            skView.showsFPS = true
//            skView.showsNodeCount = true
//            skView.showsDrawCount = true
//            skView.showsPhysics = true
        
            skView.ignoresSiblingOrder = true
            
            scene.scaleMode = .AspectFill
            skView.presentScene(scene)
            
            scene.gameSceneDelegate = self
        
        
        // 获取game center 存档最高分数
        EGC.getHighScore(leaderboardIdentifier: Leader_Board_Identifier) { (tupleHighScore) in
            if let tupleIsOk = tupleHighScore {
                GameState.sharedInstance.gamecenterSelfTopScore = tupleIsOk.score
                GameState.sharedInstance.gameCenterPlayerName = tupleIsOk.playerName
                
                print("Player Name : \(tupleIsOk.playerName)")
                print("Score : \(tupleIsOk.score)")
                print("Rank :\(tupleIsOk.rank)") // 排名
            } else {
                print("EGC.getHighScore  error")
            }
        }
        
        
        //MARK: iAd
        // 底部横幅广告
//        self.canDisplayBannerAds = true
        
        // 
        /* Automatic presentation , you can't control when the ad loads */
        self.interstitialPresentationPolicy = ADInterstitialPresentationPolicy.Manual
        
        //
//        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
//        
//        requestProducts()
    }
    
    
    // Init iAd
    
    // 三个按钮的作用 1， 不定时 赠送不定量的金币。 2， 10金币， 继续游戏。(在游戏中可以搜集金币)。金币不足时，等待一段时间登录，会赠送金币
    
    // 观看广告 赚金币 复活一次
    @IBAction func watchAdsAction(sender: UIButton) {
//        loadInterstitialAd()
    }
    
    @IBAction func payGoldContinueGame(sender: UIButton) {
        // 支付金币 继续游戏
    }
    
    @IBAction func giftAction(sender: UIButton) {
        
    }
    
    //MARK: 展示游戏排行榜
    @IBAction func showGameCenterLeaderboard(sender: UIButton, forEvent event: UIEvent) {

        if EGC.isPlayerIdentified {
            // 如果授权成功
            EGC.showGameCenterLeaderboard(leaderboardIdentifier: Leader_Board_Identifier) { (isShow) -> Void in
                print("\n[MainViewController] Game Center Leaderboards Is show\n")
            }
            
        } else {
            print("game center 未登录")
            
//            let alertView = UIAlertView(title: "排行榜", message: "登录GameCenter查看游戏排名", delegate: nil, cancelButtonTitle: "好")
//            alertView.show()
            
            let alertController = UIAlertController(title: "Leader Board", message: "Please sign in GameCenter", preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancel = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                
            })
            
            alertController.addAction(cancel)
            
            self.presentViewController(alertController, animated: true, completion: nil)

        }
        
//        let vc = storyboard?.instantiateViewControllerWithIdentifier("LeaderBoardVC") as! LeaderBoardViewController
//        vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
//        self.presentViewController(vc, animated: true) { () -> Void in
//            
//        }
        
    }
    
    // 重置游戏
    @IBAction func tryAgainGameAction(sender: UIButton, forEvent event: UIEvent) {
        
        
        self.showLoading()
        
        self.scoreLabel.text = "0"
        self.currentScoreLalbel.text = "0"
        
        self.hiddenGameOverButtons()
        
        GameState.sharedInstance.isRecording = false
        self.replayButton.setImage(UIImage(named: "cameraOff"), forState: UIControlState.Normal)
        
        //等待场景加载完成后 消失
        let delayInSeconds:Double = 1
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("restartGameNotification", object: nil)
        }
        
    }
    
    
    @IBAction func changeSceneAction(sender: UIButton) {
        print("更换场景")
        
    }
    
    
    func loadingisDoneAction() {
        self.disappearLoading()
        
        self.resetHomeUINotificationAction()

    }
    
    //MARK: 分享游戏Aciton
    @IBAction func shareGameSocialNetwork(sender: UIButton) {
        print("shareGameSocialNetwork ")
        shareGameActivity()
    }
    
    func shareGameActivity() {
        if let myWebsite = NSURL(string: AppStoreURL)
        {
            let messageStr:String  = "#\(Game_NameString)# 获得\(GameState.sharedInstance.currentScore)分, 我的纪录是\(GameState.sharedInstance.gamecenterSelfTopScore!)分"
            //            let WXimg: UIImage = UIImage(named: "wxlogo")!
//            var screenView:UIImage! // = UIImage(named: "LaunchLogo")!
            
            var shareItems = [AnyObject]()
            if let image = self.screenshotsImage {
                shareItems = [messageStr, image, myWebsite]
            } else {
                shareItems = [messageStr, myWebsite]
            }
            
            let activityController = UIActivityViewController(activityItems:shareItems, applicationActivities: nil)
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                activityController.popoverPresentationController?.sourceView = self.view
            }
            self.presentViewController(activityController, animated: true,completion: nil)
        }
    }

    // 设置
    @IBAction func settingsAction(sender: UIButton, forEvent event: UIEvent) {
        
//        self.settingsButton.hidden = true
//        self.characterButton.hidden = true
        
//        let vc = storyboard?.instantiateViewControllerWithIdentifier("SettingsVC") as! SettingsViewController
//        vc.view.backgroundColor = BackgroudMaskColor//UIColor(red: 0, green: 0, blue: 0, alpha: 0)
//        self.presentViewController(vc, animated: true) { () -> Void in
//            
//        }
        
    }
    
    // 选择角色
    @IBAction func characterSelectAction(sender: UIButton) {
        
        
//        self.settingsButton.hidden = true
//        self.characterButton.hidden = true
//        
//        let vc = storyboard?.instantiateViewControllerWithIdentifier("PeekPagedAVC") as! PeekPagedViewController
//        vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
//        self.presentViewController(vc, animated: false) { () -> Void in
//            
//        }
    }
    
    
    //MARK: 录像
    @IBAction func replayAction(sender: UIButton) {
        
        if isSupportReplay() {
            
            print("replayAction")
            
            if !GameState.sharedInstance.isRecording {
                self.startRecording()
                
            } else if GameState.sharedInstance.isRecording {
                self.stopRecording()
            }
            
        }
        
    }
    
    //开始录像
    func startRecording() {
        
        let recorder = RPScreenRecorder.sharedRecorder()
        recorder.delegate = self;
        
        recorder.startRecordingWithMicrophoneEnabled(true) { (error) -> Void in
            if let error = error {
                print(error.localizedDescription)
                self.alert(error.localizedDescription)
            } else {
                //                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Stop", style: .Plain, target: self, action: #selector(ViewController.stopRecording))
                self.replayButton.setImage(UIImage(named: "cameraOn"), forState: UIControlState.Normal)
                
                GameState.sharedInstance.isRecording = true
            }
        }

    }
    
    //停止录像
    func stopRecording() {
//        pauseGame()
        
        let recorder = RPScreenRecorder.sharedRecorder()
        
        recorder.stopRecordingWithHandler { (previewController, error) -> Void in
            if let error = error {
                print(error.localizedDescription)
                self.alert(error.localizedDescription)
            } else {
//                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .Plain, target: self, action: #selector(ViewController.startRecording))
                self.replayButton.setImage(UIImage(named: "cameraOff"), forState: UIControlState.Normal)

                GameState.sharedInstance.isRecording = false
                
                if let preview = previewController {
                    preview.previewControllerDelegate = self
                    preview.prefersStatusBarHidden()
                    self.presentViewController(preview, animated: true, completion: nil)
                }
            }
        }
    }
    
    func alert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: 暂停游戏场景
    @IBAction func pauseGameAction(sender: UIButton, forEvent event: UIEvent) {
        pauseGame()
        
        //MARK: iAd
        // 底部横幅广告
//        self.canDisplayBannerAds = true
    }
    
    func pauseGame() {
        if !GameState.sharedInstance.gameOver {
            self.pauseButton.hidden = true
            
            let skView = self.view as! SKView
            skView.paused = true
            
            GameState.sharedInstance.isLoadingDone = false
            
//            NSNotificationCenter.defaultCenter().postNotificationName("pauseGameNotification", object: nil)
            
            let vc = storyboard?.instantiateViewControllerWithIdentifier("GamePauseUI") as! GamePauseUIViewController
            vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            
            self.presentViewController(vc, animated: false) { () -> Void in
                
            }
        }
    }
    
    //MARK: 恢复游戏场景
    func recoveryGameNotificationAction() {
        
        // 一秒调用一次
//       self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(GameViewController.showTimerMessage), userInfo: nil, repeats: true)
        
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "showTimerMessage", userInfo: nil, repeats: true)
        
//        let delayInSeconds:Double = 1
//        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
//        
//        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
//            let gameview = self.view as! SKView
//            gameview.paused = false
//            
//            self.pauseButton.hidden = false
//        }
        
        
    }
    
    // 倒计时
    func showTimerMessage() {
        print("showTimerMessage ")
        if secondsElapsed > 0 {
            
            self.lblTimerMessage.text = "\(self.secondsElapsed)"
            self.lblTimerMessage.hidden = false
            self.secondsElapsed -= 1
            
        } else {
            
            self.timer.invalidate()
            self.timer = nil
            
            self.lblTimerMessage.hidden = true
            self.secondsElapsed = 3
            
            let gameview = self.view as! SKView
            gameview.paused = false
            
            GameState.sharedInstance.isLoadingDone = true

            self.pauseButton.hidden = false
        }
    }
    
    //MARK: 开始游戏 隐藏 按钮
    func startGameNotificationAction() {
        
//        UIView.animateWithDuration(1.0, delay: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
//            self.logo.frame = CGRectMake(self.view.frame.width * 2.5, self.view.frame.height * 0.5, self.logo.image!.size.width, self.logo.image!.size.height)
//
//            }) { (done ) -> Void in
//                self.logo.removeFromSuperview()
//                self.logo = nil
//        }
        
        self.progressView.hidden = true

        self.scoreLabel.hidden = false
        self.pauseButton.hidden = false
        
        self.settingsButton.hidden = true
//        self.characterButton.hidden = true
        
//        self.replayButton.setImage(UIImage(named: "cameraOff"), forState: UIControlState.Normal)
        
        if isSupportReplay() {
            self.replayButton.hidden = false
        }
        
    }
    
    //MARK: 主页按钮
    func showHomeButton() {
        self.settingsButton.hidden = false
//        self.characterButton.hidden = false
    }
    
    //MARK: 游戏结束 结束界面
    func gameOverNotificationAction() {
        
        if GameState.sharedInstance.isRecording {
            
            let delayInSeconds = 1.0
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
            
            dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
                self.stopRecording()
            }
        } else {
        }
        
        // 游戏结束 截屏
//        self.screenshotsImage = getScreenCapture()        
        
        // 合成带logo图片

//        if let image = screenshotsImage {
//            
//            let nameLogog:UIImage = UIImage(named: "namelogo")!
//            
//            UIGraphicsBeginImageContext(self.view.bounds.size)
//           image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
//            nameLogog.drawInRect(CGRectMake(60, 60, nameLogog.size.width, nameLogog.size.height))
//            
//            screenshotsImage = UIGraphicsGetImageFromCurrentImageContext()
//            
//            UIGraphicsEndImageContext()
//            
//        }
        
        
        let delayInSeconds = 1.0
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))

        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            self.showGameOverButtons()
            
            if !GameState.sharedInstance.isRecording {
                
                let sometimes = Int(arc4random_uniform(10))
                if sometimes == 0 {
                    self.requestInterstitialAdPresentation()
                    print("iAd InterstitialAd ")
                    
                } else if sometimes == 1 {
                    if UnityAds.sharedInstance().canShow() {
                        UnityAds.sharedInstance().show()
                        print("UnityAds  show ")
                    }
                    else {
                        NSLog("%@","Cannot show it yet!")
                    }
                }
                
//                if GameState.sharedInstance.isHaveAds {
//                    self.requestInterstitialAdPresentation()
//                    print("没有移除广告 ，播放广告")
//                }
                
            }

        }
        
//        let delayInSeconds = 0.5
//        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
//        
//        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
//            
//            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("GameEndUIViewController") as! GameEndUIViewController
//            vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
//            self.presentViewController(vc, animated: true) { () -> Void in }
//        }
    }
    
    func gameOverScreenshots() {
        print("gameOverScreenshots")
        
        self.screenshotsImage = getScreenCapture()
    }
    
    //MARK: 截屏
    func getScreenCapture() ->UIImage {
        
        self.pauseButton.hidden = true
        self.replayButton.hidden = true
        self.progressView.hidden = true
        self.scoreLabel.hidden = true
        
        self.currentScoreLalbel.hidden = false
        self.topScroeLabel.hidden = false
        
        let view = self.view
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func hiddenGameOverButtons(){
        
        self.gameOverMaskView.hidden = true
        
        self.progressView.hidden = true

//        self.characterButton.hidden = true

//        self.giftButton.hidden = true
//        self.payContinueButton.hidden = true
//        self.watchAdsButton.hidden = true
        
        self.leaderboardsButton.hidden = true
        self.shareGameButton.hidden = true
        self.tryAgainButton.hidden = true
        
        self.currentScoreLalbel.hidden = true
        self.topScroeLabel.hidden = true
        
        self.pauseButton.hidden = true
        self.scoreLabel.hidden = true
        self.lblTimerMessage.hidden = true
        
        self.goldDisplayLabel.hidden = true
        
        if isSupportReplay() {
            self.replayButton.hidden = true
        }
        
//        self.replayButton.hidden = false
        
//        self.showReplay.hidden = true
        
        UIView.animateWithDuration(0.5, animations: {
            self.gameOverMaskView.alpha = 0.0
        }) { (done) in
            
        }
    
    }
    
    func showGameOverButtons() {
        
        self.gameOverMaskView.hidden = true
        
        self.leaderboardsButton.center.y = self.view.bounds.size.height * 1.1
        self.shareGameButton.center.y = self.view.bounds.size.height * 1.1
        self.tryAgainButton.center.y = self.view.bounds.size.height * 1.1
        
        self.leaderboardsButton.transform = CGAffineTransformMakeRotation(CGFloat.toAngle(180))
        self.shareGameButton.transform = CGAffineTransformMakeRotation(CGFloat.toAngle(180))
        self.tryAgainButton.transform = CGAffineTransformMakeRotation(CGFloat.toAngle(180))
        
        self.progressView.hidden = true
        
//        self.giftButton.hidden = false
//        self.payContinueButton.hidden = false
//        self.watchAdsButton.hidden = false
        
        self.gameOverMaskView.hidden = false
        
        self.leaderboardsButton.hidden = false
        self.shareGameButton.hidden = false
        self.tryAgainButton.hidden = false
        self.currentScoreLalbel.hidden = false
        self.topScroeLabel.hidden = false
        
        self.pauseButton.hidden = true
        self.scoreLabel.hidden = true
        
        self.goldDisplayLabel.hidden = true
        
        self.replayButton.hidden = true
        
        UIView.animateWithDuration(0.5, animations: {
            self.gameOverMaskView.alpha = 0.3
            }) { (done) in
                
        }
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            
            self.leaderboardsButton.center.y  -= self.view.bounds.size.height * 0.4
            self.shareGameButton.center.y  -= self.view.bounds.size.height * 0.4
            self.tryAgainButton.center.y  -= self.view.bounds.size.height * 0.4
            
            self.leaderboardsButton.transform = CGAffineTransformMakeRotation(CGFloat.toAngle(360))
            self.shareGameButton.transform = CGAffineTransformMakeRotation(CGFloat.toAngle(360))
            self.tryAgainButton.transform = CGAffineTransformMakeRotation(CGFloat.toAngle(360))
            
            }) { (done) in
                
        }
        
//        self.showReplay.hidden = false

    }
    
//    func showGameCenterLeaderboards() {
//        print("showGameCenterLeaderboards ()")
//        EGC.showGameCenterLeaderboard(leaderboardIdentifier: Leader_Board_Identifier) { (isShow) -> Void in
//        }
//    }
    
    func resetHomeUINotificationAction() {

        self.scoreLabel.hidden = true
        self.pauseButton.hidden = true
        
        self.settingsButton.hidden = false
        self.replayButton.hidden = false
        
    }
    
    func updateHUD(score:Int) {
        self.scoreLabel.text = "\(score)"
        self.scoreLabel.setNeedsDisplay()
        
        self.currentScoreLalbel.text = "\(GameState.sharedInstance.currentScore)"
        
        if let score = GameState.sharedInstance.gamecenterSelfTopScore {
            self.topScroeLabel.text = "TOP:\(score)"
        }
        
    }
    
    func updateGold(gold: Int) {
        self.goldDisplayLabel.text = "\(gold)★"
        self.scoreLabel.setNeedsDisplay()
    }
    
    func updateLifeTime(time: Float) {
        self.progressView.progress = time
        self.scoreLabel.setNeedsDisplay()
//        print("updateLifeTime \(progressView.progress)")
    }
    
    //MARK: Game Center 授权
    //MARK: Player conected to Game Center, Delegate Func of Easy Game Center
    func EGCAuthentified(authentified:Bool) {
        
        print("EGCAuthentified ()")
        
        if authentified {
            print("\n[MainViewController] Player Authentified = \(authentified)\n")

            EGC.getlocalPlayerInformation {
                (playerInformationTuple) -> () in
                //playerInformationTuple:(playerID:String,alias:String,profilPhoto:UIImage?)
            }
            
            // 获取game center 存档最高分数
            EGC.getHighScore(leaderboardIdentifier: Leader_Board_Identifier) {
                (tupleHighScore) -> Void in
                /// tupleHighScore = (playerName:String, score:Int,rank:Int)?
                if let tupleIsOk = tupleHighScore {
                    if GameState.sharedInstance.gamecenterSelfTopScore < tupleIsOk.score{
                        GameState.sharedInstance.gamecenterSelfTopScore = tupleIsOk.score
                    } else {
                        EGC.reportScoreLeaderboard(leaderboardIdentifier: Leader_Board_Identifier,
                                                   score: GameState.sharedInstance.gamecenterSelfTopScore!)
                    }
                    
                    GameState.sharedInstance.gameCenterPlayerName = tupleIsOk.playerName
                                        
                    print("Player Name : \(tupleIsOk.playerName)")
                    print("Score : \(tupleIsOk.score)")
                    print("Rank :\(tupleIsOk.rank)")
                }
            }
            
        } else {
            print("game center 未授权登陆")
            self.topScroeLabel.hidden = true
        }
    }
    
    //MARK: 支付相关
    // 询问苹果的服务器能够销售哪些商品
    func requestProducts() {
        getProductInfo()
    }
    
    //MARK: Pay Delegate Method
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .Purchasing:
                self.purchasing(transaction)
                break
                
            case .Purchased:
                self.completeTransaction(transaction)
                break
                
            case .Failed:
                self.failedTransaction(transaction)
                break
                
            case .Restored:
                self.restoreTransaction(transaction)
                break
                
            default:
                break
            }
        }
    }
    
    //MARK: 发起支付
    func payRemoveAds() {
        //判断是否支持内购
        if SKPaymentQueue.canMakePayments() {
//            self.getProductInfo()
//            buyProduct(SKProduct)
            
        } else {
            print("发起支付失败， 用户禁止应用内付费购买")
        }
    }
    
    // 购买对应的产品
    func buyProduct(product: SKProduct){
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    
    func restorePay() {
        print("恢复购买")
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }

    //MARK: SKProductsRequest Delegate Method
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        let product = response.products
        if product.count == 0 {
            print("无法获取产品信息,请检查itunes connect 中配置的商品ID是否与代码中一致")
            return
        }
        
        let payment = SKPayment(product: product[0])
        SKPaymentQueue.defaultQueue().addPayment(payment)
        
    }
    
    func getProductInfo() {
        let set:Set<String> = NSSet(array: [iAdProductID]) as! Set<String>
        let request = SKProductsRequest(productIdentifiers: set)
        
        request.delegate = self
        request.start()
    }
    

    
    func completeTransaction(transaction:SKPaymentTransaction) {
        print("交易完成 \(transaction)")
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        
        GameState.sharedInstance.isHaveAds = false
        NSUserDefaults.standardUserDefaults().setBool(GameState.sharedInstance.isHaveAds, forKey: "isHaveAds")
    }
    
    func restoreTransaction(transaction: SKPaymentTransaction) {
        print("已经购买过改商品 恢复交易  \(transaction)")
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        
        GameState.sharedInstance.isHaveAds = false
        NSUserDefaults.standardUserDefaults().setBool(GameState.sharedInstance.isHaveAds, forKey: "isHaveAds")
    }
    
    func failedTransaction(transaction: SKPaymentTransaction) {
        print("交易失败  \(transaction)")
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    func purchasing(transaction: SKPaymentTransaction) {
        print("商品添加进列表  \(transaction)")
    }
    
    
    let VERIFY_RECEIPT_URL = "https://buy.itunes.apple.com/verifyReceipt"
    let ITMS_SANDBOX_VERIFY_RECEIPT_URL = "https://sandbox.itunes.apple.com/verifyReceipt"
    
    //MARK: 验证购买
//    func verifyPruchase(){
//        // 验证凭据，获取到苹果返回的交易凭据
//        // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
//        let receiptURL = NSBundle.mainBundle().appStoreReceiptURL
//        // 从沙盒中获取到购买凭据
//        let receiptData = NSData(contentsOfURL: receiptURL!)
//        // 发送网络POST请求，对购买凭据进行验证
//        let url = NSURL(string: ITMS_SANDBOX_VERIFY_RECEIPT_URL)
//        // 国内访问苹果服务器比较慢，timeoutInterval需要长一点
//        let request = NSMutableURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 10.0)
//        request.HTTPMethod = "POST"
//        // 在网络中传输数据，大多情况下是传输的字符串而不是二进制数据
//        // 传输的是BASE64编码的字符串
//        /**
//         BASE64 常用的编码方案，通常用于数据传输，以及加密算法的基础算法，传输过程中能够保证数据传输的稳定性
//         BASE64是可以编码和解码的
//         */
//        let encodeStr = receiptData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed)
//        
//        let payload = NSString(string: "{\"receipt-data\" : \"" + encodeStr! + "\"}")
//        print(payload)
//        let payloadData = payload.dataUsingEncoding(NSUTF8StringEncoding)
//        
//        request.HTTPBody = payloadData;
//        
//        // 提交验证请求，并获得官方的验证JSON结果
////                let result = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
//        
//        _ = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
//            if error != nil {
//                print("验证失败")
//                print(error)
//                return
//            }
//            
//            let dict: AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
//            if (dict != nil) {
//                // 比对字典中以下信息基本上可以保证数据安全
//                // bundle_id&application_version&product_id&transaction_id
//                // 验证成功
//                print(dict)
//            }
//        }
//        
//        // 官方验证结果为空
////        if (result == nil) {
////            //验证失败
////            print("验证失败")
////            return
////        }
////        var dict: AnyObject? = NSJSONSerialization.JSONObjectWithData(result, options: NSJSONReadingOptions.AllowFragments)
////        if (dict != nil) {
////            // 比对字典中以下信息基本上可以保证数据安全
////            // bundle_id&application_version&product_id&transaction_id
////            // 验证成功
////            print(dict)
////        }
//    }
    
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    deinit {
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
    }
    
    
    //判断设备系统版本 9.0以上才支持录屏幕，否则按钮不会出现...
    func isSupportReplay() ->Bool {
        let version = UIDevice.currentDevice().systemVersion
        let iOS9orNewer = version.compare(version)
        
        switch iOS9orNewer {
            
        case .OrderedAscending:
            print("> iOS 9.0")
            return true
        case .OrderedDescending:
            print("< iOS 9.0")
            return false
        case .OrderedSame:
            print("= iOS 9.0")
            return true
        }
   
    }
    
}


//MARK: ReplayKit Extension
extension GameViewController: RPScreenRecorderDelegate {
    func screenRecorderDidChangeAvailability(screenRecorder: RPScreenRecorder) {
        print("screen recorder did change availability")
    }
    
    func screenRecorder(screenRecorder: RPScreenRecorder, didStopRecordingWithError error: NSError, previewViewController: RPPreviewViewController?) {
        print("screen recorder did stop recording : \(error.localizedDescription)")
    }
}

extension GameViewController: RPPreviewViewControllerDelegate {
    func previewControllerDidFinish(previewController: RPPreviewViewController) {
        print("preview controller did finish")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func previewController(previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
        print("preview controller did finish with activity types : \(activityTypes)")
        if activityTypes.contains("com.apple.UIKit.activity.SaveToCameraRoll") {
            // video has saved to camera roll
        } else {
            // cancel
        }
    }
}


