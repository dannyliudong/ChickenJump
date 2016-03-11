//
//  AppDelegate.swift
//  TinyWings
//
//  Created by liudong on 15/5/26.
//  Copyright (c) 2015年 liudong. All rights reserved.
//

import Foundation
import UIKit

class GameState {
    
    var currentScore:Int
    var gamecenterSelfTopScore:Int?
    var gameCenterPlayerName:String?
    
    var lifeTimeCount:Float
    
    var gameOver:Bool = true // 游戏结束
    var isLoadingDone:Bool = true // 场景加载完成
    var canJump:Bool = true
    
    var isRecording:Bool = false
    
    var gameScene:GameScene?
    
    // 用户设置的状态
    var musicState: Bool = true// 游戏场景背景音乐开关
    
    class var sharedInstance :GameState {
        struct Singleton {
            static let instance = GameState()
        }
        
        return Singleton.instance
    }
    
    init() {
        
        self.currentScore = 0
        self.gamecenterSelfTopScore = 0
        self.lifeTimeCount = 1.0

    }
    
    func saveState() {

        // Update highScore if the current score is greater
        // 需要储存的用户设置数据 在app被杀掉后 被储存起来的设置数据
        
        // Store in user defaults
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let score = gamecenterSelfTopScore{
            self.gamecenterSelfTopScore = max(currentScore, score)
            defaults.setInteger(score, forKey: "gamecenterSelfTopScore")
        }

        if let name = gameCenterPlayerName {
            defaults.setObject(name, forKey: "gameCenterPlayerName")
        }

//        defaults.setInteger(self.gold, forKey: "myGold")
        
        // 保存设置状态
        defaults.setBool(musicState, forKey: "musicState")
        //defaults.setBool(iCloudState, forKey: "iCloudState")
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
}
