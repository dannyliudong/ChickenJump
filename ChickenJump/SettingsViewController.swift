//
//  SettingsViewController.swift
//  Space2001
//
//  Created by liudong on 15/10/30.
//  Copyright © 2015年 liudong. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var musicButton: UIButton!
    @IBOutlet weak var RecordButton: UIButton!
    
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var SoundLabel: UILabel!
    @IBOutlet weak var RecordLabel: UILabel!
    

    override func viewWillAppear(animated: Bool) {
        
        self.closeButton.alpha = 0
        self.musicButton.alpha = 0
        self.languageButton.alpha = 0
        self.RecordButton.alpha = 0
        
        self.languageLabel.alpha = 0
        self.SoundLabel.alpha = 0
        self.RecordLabel.alpha = 0
        
        
        UIView.animateWithDuration(0.1) { () -> Void in
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: View_MaskAlpha)
            
            self.closeButton.alpha = 1
            self.musicButton.alpha = 1
            self.languageButton.alpha = 1
            self.RecordButton.alpha = 1
            
            self.languageLabel.alpha = 1
            self.SoundLabel.alpha = 1
            self.RecordLabel.alpha = 1

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = UIModalPresentationStyle.Custom
        
//        self.musicButton.setImage(UIImage(named: "homeButton_sound_off"), forState: UIControlState.Normal)
        
        let music = GameState.sharedInstance.musicState
        
        if music {
            self.musicButton.setImage(UIImage(named: "homeButton_sound"), forState: UIControlState.Normal)
            
        } else {
            self.musicButton.setImage(UIImage(named: "homeButton_sound_off"), forState: UIControlState.Normal)
        }
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func backToHomeAction(sender: UIButton) {
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            self.closeButton.alpha = 0
            self.musicButton.alpha = 0
            self.languageButton.alpha = 0
            self.RecordButton.alpha = 0
            
            self.languageLabel.alpha = 0
            self.SoundLabel.alpha = 0
            self.RecordLabel.alpha = 0
            
            NSNotificationCenter.defaultCenter().postNotificationName("showHomeButtonNotification", object: nil)

            }) { (done) -> Void in
                
                self.dismissViewControllerAnimated(false) { () -> Void in
                }
        }
        

    }
    
    @IBAction func languageAction(sender: UIButton, forEvent event: UIEvent) {
        
    }
    
    @IBAction func recordAction(sender: UIButton) {
        sender.backgroundColor = UIColor.redColor()
    }
    
    @IBAction func musicButtonAction(sender: UIButton, forEvent event: UIEvent) {
        
        let music = GameState.sharedInstance.musicState
        
        if music {
            // 如果是开的 就暂停音乐
            SKTAudio.sharedInstance().pauseBackgroundMusic()
            GameState.sharedInstance.musicState = false
            GameState.sharedInstance.saveState()
            
            self.musicButton.setImage(UIImage(named: "homeButton_sound_off"), forState: UIControlState.Normal)
            
        } else {
            // 恢复音乐播放
            
            SKTAudio.sharedInstance().resumeBackgroundMusic()
            GameState.sharedInstance.musicState = true
            GameState.sharedInstance.saveState()
            
            self.musicButton.setImage(UIImage(named: "homeButton_sound"), forState: UIControlState.Normal)
        }
        
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
