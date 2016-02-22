//
//  CharactersUIViewController.swift
//  Space2001
//
//  Created by liudong on 16/1/21.
//  Copyright © 2016年 liudong. All rights reserved.
//

import UIKit

class PeekPagedViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!

    @IBOutlet weak var closeButton: UIButton!
    
    var pageImages = [UIImage]()
    var pageViews = [UIImageView?]()

    override func viewWillAppear(animated: Bool) {
        
        UIView.animateWithDuration(0.1) { () -> Void in
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: View_MaskAlpha)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = UIModalPresentationStyle.Custom
        pageImages = [UIImage(named: "logo")!,
            UIImage(named: "logo")!,
            UIImage(named: "logo")!,
            UIImage(named: "logo")!,
            UIImage(named: "logo")!,
            UIImage(named: "logo")!,
            UIImage(named: "logo")!,
            UIImage(named: "logo")!,
            UIImage(named: "logo")!]
        
        let pageCount = pageImages.count
        pageControl.currentPage = 0
        pageControl.numberOfPages = pageCount
        
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }
        
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(pageImages.count), height: pagesScrollViewSize.height)
        
        loadVisiblePages()
    }
    
    @IBAction func closeVCAction(sender: UIButton) {
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            
            NSNotificationCenter.defaultCenter().postNotificationName("showHomeButtonNotification", object: nil)
            
            }) { (done) -> Void in
                
                self.dismissViewControllerAnimated(false) { () -> Void in
                }
        }
        
    }
    
    
    
    
    func loadVisiblePages() {
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // Update the page control
        pageControl.currentPage = page
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        // Purge anything before the first page
        for index in 0 ..< firstPage {
            purgePage(index)
        }
        
        // Load pages in our range
        for index in firstPage...lastPage {
            loadPage(index)
        }
        
        // Purge anything after the last page
        for index in lastPage+1 ..< pageImages.count {
            purgePage(index)
        }
    }
    
    func loadPage(page: Int) {
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Load an individual page, first checking if you've already loaded it
        if let _ = pageViews[page] {
            // Do nothing. The view is already loaded.
        } else {
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            frame = CGRectInset(frame, 10.0, 0.0)
            
            let newPageView = UIImageView(image: pageImages[page])
            newPageView.contentMode = .ScaleAspectFit
            newPageView.frame = frame
            scrollView.addSubview(newPageView)
            pageViews[page] = newPageView
        }
    }
    
    func purgePage(page: Int) {
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Remove a page from the scroll view and reset the container array
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()
    }

}
