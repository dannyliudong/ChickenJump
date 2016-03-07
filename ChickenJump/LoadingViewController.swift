//
//  LoadingViewController.swift
//  ChickenJump
//
//  Created by liudong on 16/3/7.
//  Copyright © 2016年 liudong. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    @IBOutlet weak var bgView: UIImageView!
    @IBOutlet weak var logoView: UIImageView!
    
    override func viewWillAppear(animated: Bool) {
        
        print("logoView.center.x  \(logoView.center.x)")
        
        UIView.animateWithDuration(1.0, animations: {
//            self.logoView.center.x += 100
            
        }) { (done) in
            UIView.animateWithDuration(1.0, animations: {
                self.logoView.center.x += 500
                self.view.alpha = 0
                self.view.backgroundColor = UIColor.clearColor()
                
                }, completion: { (done) in
                    
            })
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backLoading(segue:UIStoryboardSegue){
        
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
