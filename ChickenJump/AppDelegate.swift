//
//  AppDelegate.swift
//  ChickenJump
//
//  Created by liudong on 16/2/22.
//  Copyright © 2016年 liudong. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UnityAdsDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //  判断是否第一次启动
        if !NSUserDefaults.standardUserDefaults().boolForKey("everLaunched") {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "everLaunched")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "firstLaunch")
            print("第一次启动")
            
            //GameState.sharedInstance.iCloudState = true
            GameState.sharedInstance.musicState = true
            
        } else {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "firstLaunch")
            print("不是第一次启动")
            
            //  读取用户的设置信息
            let userDefaults = NSUserDefaults.standardUserDefaults()
            
            GameState.sharedInstance.gamecenterSelfTopScore = userDefaults.integerForKey("gamecenterSelfTopScore")
            GameState.sharedInstance.gameCenterPlayerName = userDefaults.stringForKey("gameCenterPlayerName")
            GameState.sharedInstance.musicState = userDefaults.boolForKey("musicState")
            
//            GameState.sharedInstance.gold = userDefaults.integerForKey("myGold")
        }
        
//        UIViewController.prepareInterstitialAds()
        
        
        //MARK: Unity Ads
        
        UnityAds.sharedInstance().delegate = self
        UnityAds.sharedInstance().setTestMode(false)
        UnityAds.sharedInstance().setDebugMode(true)
        
        UnityAds.sharedInstance().startWithGameId("1046579", andViewController: self.window?.rootViewController)
        
//        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
//        
//        dispatch_after(delayTime, dispatch_get_main_queue()) {
//            if UnityAds.sharedInstance().canShow() {
//                UnityAds.sharedInstance().show()
//            }
//            else {
//                NSLog("%@","Cannot show it yet!")
//            }
//        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        NSNotificationCenter.defaultCenter().postNotificationName("pauseGameNotification", object: nil)
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func unityAdsVideoCompleted(rewardItemKey: String!, skipped: Bool) {
        print("Video completed: \(rewardItemKey) \(skipped)")
    }

    
}

