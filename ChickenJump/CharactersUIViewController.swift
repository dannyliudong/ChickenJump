//
//  CharactersUIViewController.swift
//  Space2001
//
//  Created by liudong on 16/1/21.
//  Copyright © 2016年 liudong. All rights reserved.
//

import UIKit

class CharactersUIViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
        
    override func viewWillAppear(animated: Bool) {
        
        UIView.animateWithDuration(0.1) { () -> Void in
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: View_MaskAlpha)

        }
    }
    
    override func viewDidLoad() {
        self.modalPresentationStyle = UIModalPresentationStyle.Custom
        
    }
    
    @IBAction func closeVCAction(sender: UIButton) {
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            
            NSNotificationCenter.defaultCenter().postNotificationName("showHomeButtonNotification", object: nil)
            
            }) { (done) -> Void in
                
                self.dismissViewControllerAnimated(true) { () -> Void in
                }
        }
        
    }
    
}
