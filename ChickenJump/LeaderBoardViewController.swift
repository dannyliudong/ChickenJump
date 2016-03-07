//
//  LeaderBoardViewController.swift
//  ChickenJump
//
//  Created by liudong on 16/3/7.
//  Copyright © 2016年 liudong. All rights reserved.
//

import UIKit

class LeaderBoardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalPresentationStyle = UIModalPresentationStyle.Custom

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeVCAction(sender: UIButton) {
        self.dismissViewControllerAnimated(true) { 
            
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
