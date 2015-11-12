//
//  RCMantleViewController.swift
//  Mantle
//
//  Created by Ricardo Canales on 11/11/15.
//  Copyright © 2015 canalesb. All rights reserved.
//

import UIKit


// Declare this protocol outside the class
protocol RCMantleViewDelegate {
    // This method allows a child to tell the parent view controller
    // to change to a different child view
    func moveToView(viewNum: Int)
    func dismissView(animated: Bool)
}

class RCMantleViewController: UIViewController, RCMantleViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
    // A strong reference to the height contraint of the contentView
    var contentViewConstraint: NSLayoutConstraint!

    // A computed version of this reference
    var computedContentViewConstraint: NSLayoutConstraint {
        return NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: .Height, multiplier: CGFloat(controllers.count + 1), constant: 0)
    }
    
    // The list of controllers currently present in the scrollView
    var controllers = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initScrollView()
        
    }

    func initScrollView(){
        scrollView.delegate = self

        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentViewConstraint = computedContentViewConstraint
        view.addConstraint(contentViewConstraint)
        
        // Adding all the controllers you want in the scrollView
        let popUpViewController = storyboard!.instantiateViewControllerWithIdentifier("PopUpViewController") as! RCPopUpViewController
        let glassViewController = storyboard!.instantiateViewControllerWithIdentifier("GlassViewController") as! RCGlassViewController
        popUpViewController.delegate = self  
        
        addToScrollViewNewController(popUpViewController)
        addToScrollViewNewController(glassViewController)
    
        moveToView(1)
    }
    
    func addToScrollViewNewController(controller: UIViewController) {
        controller.willMoveToParentViewController(self)
        
        contentView.addSubview(controller.view)
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstraint = NSLayoutConstraint(item: controller.view, attribute: .Height, relatedBy: .Equal, toItem: scrollView, attribute: .Height, multiplier: 1.0, constant: 0)
        
        let leadingConstraint = NSLayoutConstraint(item: contentView, attribute: .Leading, relatedBy: .Equal, toItem: controller.view, attribute: .Leading, multiplier: 1.0, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: contentView, attribute: .Trailing, relatedBy: .Equal, toItem: controller.view, attribute: .Trailing, multiplier: 1.0, constant: 0)
    
        // Setting all the constraints
        var bottomConstraint: NSLayoutConstraint!
        if controllers.isEmpty {
            // Since it's the first one, the trailing constraint is from the controller view to the contentView
            bottomConstraint = NSLayoutConstraint(item: contentView, attribute: .Bottom, relatedBy: .Equal, toItem: controller.view, attribute: .Bottom, multiplier: 1.0, constant: 0)
        }
        else {
            bottomConstraint = NSLayoutConstraint(item: controllers.last!.view, attribute: .Top, relatedBy: .Equal, toItem: controller.view, attribute: .Bottom, multiplier: 1.0, constant: 0)
        }
        
        
        // Setting the new width constraint of the contentView
        view.removeConstraint(contentViewConstraint)
        contentViewConstraint = computedContentViewConstraint
        
        // Adding all the constraints to the view hierarchy
        view.addConstraint(contentViewConstraint)
        contentView.addConstraints([bottomConstraint, trailingConstraint, leadingConstraint])
        scrollView.addConstraints([heightConstraint])
        
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
        
        // Finally adding the controller in the list of controllers
        controllers.append(controller)
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        if(scrollView.contentOffset.y < view.frame.height-20){
            scrollView.scrollEnabled = false
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let currentPage = floor(scrollView.contentOffset.y / scrollView.bounds.size.height + 0.5);
        print("DRAGGED TO: \(currentPage)")
        if(currentPage == 0){
            dismissView(false)
        } else {
            scrollView.scrollEnabled = true
        }
    }
    
    func moveToView(viewNum: Int) {
        // Determine the offset in the scroll view we need to move to
        let yPos: CGFloat = (self.view.frame.height - 20) * CGFloat(viewNum)
        self.scrollView.setContentOffset(CGPointMake(0,yPos), animated: true)
    }
    
    func dismissView(animated: Bool){
        self.dismissViewControllerAnimated(animated, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
