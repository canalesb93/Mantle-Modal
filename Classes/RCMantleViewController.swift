//
//  RCMantleViewController.swift
//  Mantle
//
//  Created by Ricardo Canales on 11/11/15.
//  Copyright © 2015 canalesb. All rights reserved.
//

import UIKit


// Declare this protocol outside the class
public protocol RCMantleViewDelegate {
    // This method allows a child to tell the parent view controller
    // to change to a different child view
    func dismissView(_ animated: Bool)
}

open class RCMantleViewController: UIViewController, RCMantleViewDelegate, UIScrollViewDelegate {
    
    open var scrollView: UIScrollView!
    fileprivate var contentView: UIView!
    
    // A strong reference to the height contraint of the contentView
    var contentViewConstraint: NSLayoutConstraint!
    
    // ==================== CONFIGURATION VARIABLES - START ====================
    
    // draggable to the top/bottom
    open var bottomDismissible: Bool = false
    open var topDismissable: Bool = true
    
    fileprivate var mainView: Int = 1
    
    // show modal from the top
    open var appearFromTop: Bool = false
    open var appearOffset: CGFloat = 0
    
    // draggable to sides configuration variables
    open var draggableToSides: Bool = false
    fileprivate var draggableWidth: CGFloat = 0
    fileprivate var draggableMultiplier: CGFloat = 1.0
    
    fileprivate var glassScreens: Int = 1 // 1 + 1
    
    // ===================== CONFIGURATION VARIABLES - END =====================
    
    // A computed version of this reference
    var computedContentViewConstraint: NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .height, multiplier: CGFloat(controllers.count + glassScreens + 1), constant: 0)
        return constraint
    }
    
    // The list of controllers currently present in the scrollView
    var controllers = [UIViewController]()
    
    // setup initialization
    open func setUpScrollView(){
        self.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        glassScreens = 1
        if bottomDismissible && topDismissable {
            glassScreens = 2 // 2 + 1
            mainView = 1
        } else if topDismissable {
            mainView = 1
        } else if bottomDismissible {
            mainView = 0
        }  else {
            glassScreens = 0
            mainView = 0
        }
        
        if draggableToSides {
            draggableWidth = view.frame.width
            draggableMultiplier = CGFloat(3.0)
        }
        
        createMantleViewController()
        initScrollView()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Creates the ScrollView and the ContentView (UIView), don't move
    fileprivate func createMantleViewController() {
        view.backgroundColor = UIColor.clear
        scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.clear
        view.addSubview(scrollView)
        
        let top = NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
        let leading = NSLayoutConstraint(item: scrollView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0)
        let trailing = NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0)
        
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView = UIView()
        contentView.backgroundColor = UIColor.clear
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        let ctop = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 0)
        let cbottom = NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: 0)
        let cleading = NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: 0)
        let ctrailing = NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1.0, constant: 0)
        let cwidth = NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: draggableMultiplier, constant: 0)
        
        NSLayoutConstraint.activate([top, bottom, leading, trailing, ctop, cbottom, cleading, ctrailing, cwidth])
    }
    
    func initScrollView(){
        scrollView.isHidden = true
        scrollView.isScrollEnabled = false
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentViewConstraint = computedContentViewConstraint
        view.addConstraint(contentViewConstraint)
        
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        accomodateScrollView()
        scrollView.isHidden = false
        moveToView(mainView)
    }
    
    fileprivate func accomodateScrollView(){
        var xPos: CGFloat = 0
        var yPos: CGFloat = appearOffset
        if draggableToSides {
            xPos = self.view.frame.width
        }
        if appearFromTop {
            yPos = self.contentView.frame.height - self.view.frame.height - appearOffset
        }
        scrollView.setContentOffset(CGPoint(x: xPos, y: yPos), animated: false)
    }
    
    open func addToScrollViewNewController(_ controller: UIViewController) {
        controller.willMove(toParentViewController: self)
        
        contentView.addSubview(controller.view)
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstraint = NSLayoutConstraint(item: controller.view, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .height, multiplier: 1.0, constant: 0)
        
        let leadingConstraint = NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: controller.view, attribute: .leading, multiplier: 1.0, constant: -draggableWidth)
        let trailingConstraint = NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: controller.view, attribute: .trailing, multiplier: 1.0, constant: draggableWidth)
        
        // Setting all the constraints
        
        var bottomConstraint: NSLayoutConstraint!
        if controllers.isEmpty {
            // Since it's the first one, the trailing constraint is from the controller view to the contentView
            bottomConstraint = NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: controller.view, attribute: .bottom, multiplier: 1.0, constant: 0)
        }
        else {
            bottomConstraint = NSLayoutConstraint(item: controllers.last!.view, attribute: .top, relatedBy: .equal, toItem: controller.view, attribute: .bottom, multiplier: 1.0, constant: 0)
        }
        
        if bottomDismissible {
            bottomConstraint.constant = controller.view.frame.height
        }
        
        // Setting the new width constraint of the contentView
        view.removeConstraint(contentViewConstraint)
        contentViewConstraint = computedContentViewConstraint
        
        // Adding all the constraints to the view hierarchy
        view.addConstraint(contentViewConstraint)
        contentView.addConstraints([bottomConstraint, trailingConstraint, leadingConstraint])
        scrollView.addConstraints([heightConstraint])
        
        self.addChildViewController(controller)
        controller.didMove(toParentViewController: self)
        
        // Finally adding the controller in the list of controllers
        controllers.append(controller)
    }
    
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if(scrollView.contentOffset.y < view.frame.height-20){
            scrollView.isScrollEnabled = false
        } else if scrollView.contentOffset.y > scrollView.frame.height - view.frame.height + 20 {
            scrollView.isScrollEnabled = false
        }
    }
    
    // close view or not
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentHorizontalPage = floor(scrollView.contentOffset.x / scrollView.bounds.size.width + 0.5);
        let currentPage = floor(scrollView.contentOffset.y / scrollView.bounds.size.height + 0.5);
        // let lastPage = floor(contentView.frame.height / scrollView.bounds.size.height - 1);
        
        if(draggableToSides && (currentHorizontalPage == 0 || currentHorizontalPage == 2)){
            dismissView(false)
        }
        
        if(Int(currentPage) != mainView){
            dismissView(false)
        } else {
            scrollView.isScrollEnabled = true
        }
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let currentPage = floor(scrollView.contentOffset.y / scrollView.bounds.size.height + 0.5);
        if currentPage != CGFloat(mainView) {
            dismissView(false)
        } else {
            scrollView.isScrollEnabled = true
        }
    }
    
    fileprivate func moveToView(_ viewNum: Int) {
        // Determine the offset in the scroll view we need to move to
        scrollView.isScrollEnabled = false
        let yPos: CGFloat = (self.view.frame.height) * CGFloat(viewNum)
        self.scrollView.setContentOffset(CGPoint(x: self.scrollView.contentOffset.x ,y: yPos), animated: true)
    }
    
    open func dismissView(_ animated: Bool){
        if appearFromTop && animated {
            moveToView(mainView + 1)
            //self.dismissViewControllerAnimated(false, completion: nil)
        } else {
            self.dismiss(animated: animated, completion: nil)
        }
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
