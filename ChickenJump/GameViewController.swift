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



class GameViewController: UIViewController, ADInterstitialAdDelegate, GameSceneDelegate, EGCDelegate {
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var characterButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
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
    
    var gameScreenCapture:UIImage?
    
    
//    var gameScene:GameScene!
    
    //MARK: iAd
    
    var interstitialAd:ADInterstitialAd!
    var interstitialAdView: UIView = UIView()
    var closeButton:UIButton!
    
//    var gameCenterHighScore:Int = 0

//    var cloudHighScore:Int?
//    var topHighScore:Int?
    
//    var loadingView:UIView!
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        EGC.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let vc = storyboard?.instantiateViewControllerWithIdentifier("LoadingVC") as! LoadingViewController
//        vc.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
//        self.presentViewController(vc, animated: false) { () -> Void in
//            
//        }
        
        
        EGC.sharedInstance(self)
        EGC.debugMode = true
        
        print("my gold:  \(GameState.sharedInstance.gold)")
        self.goldDisplayLabel.text = "\(GameState.sharedInstance.gold)★"
        
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
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true
        skView.showsPhysics = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
                
        GameState.sharedInstance.gameScene = GameScene(fileNamed:"GameScene")
        
        if let scene = GameState.sharedInstance.gameScene {
            
            scene.scaleMode = .AspectFill
            skView.presentScene(scene)
            
            scene.gameSceneDelegate = self
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
    
    // 展示游戏排行榜
    @IBAction func showGameCenterLeaderboard(sender: UIButton, forEvent event: UIEvent) {

        if EGC.isPlayerIdentified {
            // 如果授权成功
            EGC.showGameCenterLeaderboard(leaderboardIdentifier: Leader_Board_Identifier) { (isShow) -> Void in
                print("\n[MainViewController] Game Center Leaderboards Is show\n")
            }
            
        } else {
            print("game center 未登录")
            self.leaderboardsButton.backgroundColor = UIColor.lightGrayColor()
            EGC.sharedInstance(self)
            EGC.debugMode = true

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
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            // 通知重置游戏场景

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                self.maskView.hidden = true
//                self.hiddenGameOverButtons()
//                self.resetHomeUINotificationAction()
            })
        })
        
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
    
    
    
    // 分享游戏
    @IBAction func shareGameSocialNetwork(sender: UIButton) {
        print("shareGameSocialNetwork ")
        
        if let myWebsite = NSURL(string: "https://itunes.apple.com/us/app/frank2016/id941582714?l=zh&ls=1&mt=8")
        {
            let messageStr:String  = "Play this game with me"
//            let WXimg: UIImage = UIImage(named: "wxlogo")!
            let icon:UIImage = UIImage(named: "LaunchLogo")!
            
//            let image = gameScreenCapture!
            let shareItems:Array = [messageStr, icon, myWebsite]
            let activityController = UIActivityViewController(activityItems:shareItems, applicationActivities: nil)
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                activityController.popoverPresentationController?.sourceView = self.view
            }
            self.presentViewController(activityController, animated: true,completion: nil)
        }
        
    }
    
    // 截屏
    func screenCapture(view:UIView) ->UIImage {
        let rect = view.frame
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        view.layer.renderInContext(context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
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
        
        self.progressView.hidden = false

        self.scoreLabel.hidden = false
        self.pauseButton.hidden = false
        
        self.settingsButton.hidden = true
        self.characterButton.hidden = true
        
    }
    
    //MARK: 主页按钮
    func showHomeButton() {
        self.settingsButton.hidden = false
//        self.characterButton.hidden = false
    }
    
    //MARK: 游戏结束 结束界面
    func gameOverNotificationAction() {
        
//        let topScroe:Int = max(GameState.sharedInstance.localHighScore, gameCenterHighScore)
        
        self.currentScoreLalbel.text = "\(GameState.sharedInstance.currentScore)"
        self.topScroeLabel.text = "TOP:\(GameState.sharedInstance.gamecenterSelfTopScore)"
        
        
        // 游戏结束 截屏
//        gameScreenCapture = screenCapture(self.view)
        
        let delayInSeconds = 0.5
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))

        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            self.showGameOverButtons()
        }
        
        if GameState.sharedInstance.currentScore > GameState.sharedInstance.gamecenterSelfTopScore {
            // 如果本地最高分数大于game center 分数 上传新的游戏分数
            EGC.reportScoreLeaderboard(leaderboardIdentifier: Leader_Board_Identifier, score: GameState.sharedInstance.currentScore)
            print("\n[LeaderboardsActions] Score send to Game Center \(EGC.isPlayerIdentified)")
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
//                    GameState.sharedInstance.gold = 
                    
                    print("Player Name : \(tupleIsOk.playerName)")
                    print("Score : \(tupleIsOk.score)")
                    print("Rank :\(tupleIsOk.rank)")
                }
            }
            
        } else {
            print("game center 未授权登陆")
            self.topScroeLabel.hidden = true
            self.leaderboardsButton.backgroundColor = UIColor.grayColor()
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
