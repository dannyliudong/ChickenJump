//
//  GameViewController.swift
//  Space2001
//
//  Created by liudong on 15/10/28.
//  Copyright (c) 2015年 liudong. All rights reserved.
//

import UIKit
import SpriteKit
import iAd
import ReplayKit


class GameViewController: UIViewController, ADInterstitialAdDelegate, GameSceneDelegate, EGCDelegate {
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var characterButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var replayButton: UIButton!
    //    @IBOutlet weak var showReplay: UIButton!
    
    @IBOutlet weak var leaderboardsButton: UIButton!
    @IBOutlet weak var shareGameButton: UIButton!
    @IBOutlet weak var tryAgainButton: UIButton!
    
//    @IBOutlet weak var giftButton: UIButton!
//    @IBOutlet weak var payContinueButton: UIButton!
//    @IBOutlet weak var watchAdsButton: UIButton!
    
    @IBOutlet weak var currentScoreLalbel: UILabel!
    @IBOutlet weak var topScroeLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var lblTimerMessage: UILabel!
    
    @IBOutlet weak var goldDisplayLabel: UILabel!
        
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private var secondsElapsed:Int = 3
    private var timer:NSTimer!
    
    var screenshotsImage:UIImage?
    
    //MARK: iAd
    
    var interstitialAd:ADInterstitialAd!
    var interstitialAdView: UIView = UIView()
    var closeButton:UIButton!

    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        EGC.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EGC.sharedInstance(self)
        EGC.debugMode = true
        
        self.characterButton.layer.cornerRadius  = Button_CornerRadius
        self.settingsButton.layer.cornerRadius  = Button_CornerRadius
        self.pauseButton.layer.cornerRadius  = Button_CornerRadius
        
        self.leaderboardsButton.layer.cornerRadius = Button_CornerRadius
        self.shareGameButton.layer.cornerRadius = Button_CornerRadius
        self.tryAgainButton.layer.cornerRadius = Button_CornerRadius
        
        self.hiddenGameOverButtons()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.showHomeButton), name: "showHomeButtonNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.pauseGame), name: "pauseGameNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.startGameNotificationAction), name: "startGameAnimationNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.gameOverNotificationAction), name: "gameOverNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.recoveryGameNotificationAction), name: "recoveryGameNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.loadingisDoneAction), name: "loadingisDoneNotification", object: nil)
        
        let skView = self.view as! SKView
        
        // Configure the view.
//        skView.showsFPS = true
//        skView.showsNodeCount = true
//        skView.showsDrawCount = true
        skView.showsPhysics = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
                
        GameState.sharedInstance.gameScene = GameScene(size: CGSizeMake(Screen_Width, Screen_Height))//GameScene(fileNamed:"GameScene")
        
        if let scene = GameState.sharedInstance.gameScene {
            
            scene.scaleMode = .AspectFit
            skView.presentScene(scene)
            
            scene.gameSceneDelegate = self
        }
        
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
        
    }
    
    // Init iAd
    
    // 三个按钮的作用 1， 不定时 赠送不定量的金币。 2， 10金币， 继续游戏。(在游戏中可以搜集金币)。金币不足时，等待一段时间登录，会赠送金币
    
    // 观看广告 赚金币 复活一次
    @IBAction func watchAdsAction(sender: UIButton) {
        loadInterstitialAd()
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
            
            let alertView = UIAlertView(title: "排行榜", message: "请登录GameCenter查看游戏排名", delegate: nil, cancelButtonTitle: "好")
            alertView.show()
        }

    }
    
    //MARK: loading Transitions
    var logo:UIImageView!
    func loadingTransitionsAnimation() {
        
        //1. 颜色 0 － 1 logo 从左至右 出现
        let loadingView = UIView(frame: self.view.frame)
        loadingView.backgroundColor = UIColor.blackColor()
        loadingView.alpha = 0
        self.view.addSubview(loadingView)
        
        // 2.
        logo = UIImageView(image: UIImage(named: "logo"))
        logo.frame = CGRectMake(-(logo.image?.size.width)!, self.view.frame.height * 0.5, logo.image!.size.width, logo.image!.size.height)
        self.view.addSubview(logo)
        
        
        UIView.animateWithDuration(1.0, delay: 0.1, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            loadingView.alpha = 1
            
            self.logo.frame =  CGRectMake(Screen_Width * 0.5, Screen_Height * 0.5, self.logo.image!.size.width, self.logo.image!.size.height)
            
            }) { (done) -> Void in

        }
        

        //等待场景加载完成后 消失
        let delayInSeconds:Double = 1
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            UIView.animateWithDuration(0.5, delay: 0.1, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                loadingView.alpha = 0
                }, completion: { (done) -> Void in
                    loadingView.removeFromSuperview()
            })
        }
        
    }
    
    // 重置游戏
    @IBAction func tryAgainGameAction(sender: UIButton, forEvent event: UIEvent) {
        
//        self.loadingView = UIView(frame: self.view.frame)
//        self.loadingView.alpha = 0
//        self.loadingView.backgroundColor = UIColor.whiteColor()
//        self.view.addSubview(self.loadingView)
//
//        UIView.animateWithDuration(0.2, delay: 0.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
//            self.loadingView.alpha = 1
//            }) { (done ) -> Void in
//        }
        
        self.spinner.startAnimating()
        
        self.hiddenGameOverButtons()
        self.resetHomeUINotificationAction()
        
        NSNotificationCenter.defaultCenter().postNotificationName("restartGameNotification", object: nil)
        
//        loadingTransitionsAnimation()
        
        // 点击重现开始游戏 出现过场动画
        // 当场景创建完成之后， 再消失动画， 开始游戏
        
        
//        UIView.animateWithDuration(1.5, delay: 0.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
//            loadingView.alpha = 1
//            }) { (done) -> Void in
//                loadingView.removeFromSuperview()
//        }
        
        //  用dispatch_after推迟任务
//        let delayInSeconds = 0.5
//        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
//        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
//
//        }
        
    }
    
    
    func loadingisDoneAction() {
        
        self.spinner.stopAnimating()
        
//        let gameView = self.view as! SKView
//        gameView.presentScene(GameState.sharedInstance.gameScene)

//        if (self.loadingView != nil) {
//            UIView.animateWithDuration(0.2, delay: 0.2, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
//                self.loadingView.alpha = 0
//                self.loadingView.removeFromSuperview()
//                }) { (done ) -> Void in
//                    
//            }
//        }

    }
    
    //MARK: 分享游戏Aciton
    @IBAction func shareGameSocialNetwork(sender: UIButton) {
        print("shareGameSocialNetwork ")
        shareGameActivity()
    }
    
    func shareGameActivity() {
        if let myWebsite = NSURL(string: AppStoreURL)
        {
            
            let messageStr:String  = "#\(Game_NameString)# \(GameState.sharedInstance.currentScore)分, 我的纪录是\(GameState.sharedInstance.gamecenterSelfTopScore!)分"
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
        
        self.settingsButton.hidden = true
        self.characterButton.hidden = true
        
        let vc = storyboard?.instantiateViewControllerWithIdentifier("SettingsVC") as! SettingsViewController
        vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.presentViewController(vc, animated: false) { () -> Void in
            
        }
        
    }
    
    // 选择角色
    @IBAction func characterSelectAction(sender: UIButton) {
        self.settingsButton.hidden = true
        self.characterButton.hidden = true
        
        let vc = storyboard?.instantiateViewControllerWithIdentifier("PeekPagedAVC") as! PeekPagedViewController
        vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.presentViewController(vc, animated: false) { () -> Void in
            
        }
    }
    
    
    //MARK: 录像
    @IBAction func replayAction(sender: UIButton) {
        print("replayAction")
        
        if !GameState.sharedInstance.isRecording {
            self.startRecording()
        } else if GameState.sharedInstance.isRecording {
            self.stopRecording()
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
       self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(GameViewController.showTimerMessage), userInfo: nil, repeats: true)
        
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
        self.characterButton.hidden = true
        
//        self.replayButton.setImage(UIImage(named: "cameraOff"), forState: UIControlState.Normal)
        
        self.replayButton.hidden = false
        
//        self.showReplay.hidden = true

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
        print("hiddenGameOverButtons() ")
        
        self.progressView.hidden = true

        self.characterButton.hidden = true

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
        
        self.replayButton.hidden = true
        
//        self.showReplay.hidden = true
    
    }
    
    func showGameOverButtons() {
        print("showGameOverButtons() ")
        self.progressView.hidden = true
        
//        self.giftButton.hidden = false
//        self.payContinueButton.hidden = false
//        self.watchAdsButton.hidden = false
        
        self.leaderboardsButton.hidden = false
        self.shareGameButton.hidden = false
        self.tryAgainButton.hidden = false
        self.currentScoreLalbel.hidden = false
        self.topScroeLabel.hidden = false
        
        self.pauseButton.hidden = true
        self.scoreLabel.hidden = true
        
        self.goldDisplayLabel.hidden = true
        
        self.replayButton.hidden = true
        
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
//        self.characterButton.hidden = false
        
        //  用dispatch_after推迟任务
//        let delayInSeconds = 0.5
//        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
//        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
//            GameState.sharedInstance.isLoadingDone = true
//        }
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
                    
                    GameState.sharedInstance.gamecenterSelfTopScore = tupleIsOk.score
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
    
    //MARK: iAd
    func loadInterstitialAd() {
        interstitialAd = ADInterstitialAd()
        interstitialAd.delegate = self
    }
    
    func interstitialAdWillLoad(interstitialAd: ADInterstitialAd!) {
        
    }
    
    func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) {
        interstitialAdView = UIView()
        interstitialAdView.frame = self.view.bounds
        view.addSubview(interstitialAdView)
        
        closeButton = UIButton(frame: CGRect(x: 25, y:  25, width: 25, height: 25))
        //add a cross shaped graphics into your project to use as close button
        closeButton.setBackgroundImage(UIImage(named: "homeButton_back"), forState: UIControlState.Normal)
        closeButton.addTarget(self, action: #selector(GameViewController.close), forControlEvents: UIControlEvents.TouchDown)
        
        self.view.addSubview(closeButton)
        
        interstitialAd.presentInView(interstitialAdView)
        UIViewController.prepareInterstitialAds()
    }
    
    func close() {
        interstitialAdView.removeFromSuperview()
        closeButton.removeFromSuperview()
        interstitialAd = nil
        
    }
    
    func interstitialAdActionDidFinish(interstitialAd: ADInterstitialAd!) {
        interstitialAdView.removeFromSuperview()
    }
    
    
    func interstitialAdActionShouldBegin(interstitialAd: ADInterstitialAd!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
    func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
        
    }
    
    func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
        interstitialAdView.removeFromSuperview()
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        //
        print("willRotateToInterfaceOrientation")
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        print("willAnimateRotationToInterfaceOrientation")
    }
    
    
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


