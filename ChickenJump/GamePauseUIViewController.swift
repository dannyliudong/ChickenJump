//
//  GamePauseUIViewController.swift
//  Space2001
//
//  Created by liudong on 15/11/2.
//  Copyright © 2015年 liudong. All rights reserved.
//

import UIKit

class GamePauseUIViewController: UIViewController {

    @IBOutlet weak var pauseButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        self.pauseButton.alpha = 0
        
        UIView.animateWithDuration(0.5) { () -> Void in
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: View_MaskAlpha)
            self.pauseButton.alpha = 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.modalPresentationStyle = UIModalPresentationStyle.Custom

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func recoveryGameAction(sender: UIButton) {
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            self.pauseButton.alpha = 0
            
            NSNotificationCenter.defaultCenter().postNotificationName("recoveryGameNotification", object: nil)

            }) { (done) -> Void in
                self.dismissViewControllerAnimated(true) { () -> Void in
                    
                }
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
