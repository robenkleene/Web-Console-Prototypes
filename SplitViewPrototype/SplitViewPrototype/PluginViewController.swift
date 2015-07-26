//
//  WebSplitViewController.swift
//  SplitViewPrototype
//
//  Created by Roben Kleene on 7/19/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import WebKit
import AppKit

class PluginViewController: NSSplitViewController, WebViewControllerDelegate {

    // MARK: Properties

    lazy var logSplitViewSubviewSavedFrameName: String = {
        // TODO: Replace this with a real name
        return "TestAutosaveName"
    }()

    var logSplitViewView: NSView {
        return self.logSplitViewViewController.view
    }
    
    var logSplitViewViewController: NSViewController {
        let splitViewItem = self.splitViewItems.last as! NSSplitViewItem
        return splitViewItem.viewController
    }
    
    var logSplitViewSubView: NSView {
        return self.splitView.subviews.last as! NSView
    }
    
    var logSplitViewItem: NSSplitViewItem {
        return self.splitViewItems.last as! NSSplitViewItem
    }

    // MARK: Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()

        for splitViewItem in splitViewItems {
            if let webViewController = splitViewItem.viewController as? WebViewController {
                webViewController.delegate = self
            }
        }

        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()

        // The log starts hidden
        logSplitViewItem.collapsed = true
    }

    // MARK: Saving & Restoring Frame

    func saveLogSplitViewFrame() {
        let frame = logSplitViewView.frame
        let frameString = NSStringFromRect(frame)
        let key = logSplitViewSubviewSavedFrameName
//        NSUserDefaults.standardUserDefaults().setObject(frameString, forKey:key)
    }

    func savedLogSplitViewFrame() -> NSRect {
        return NSZeroRect
    }
    
    // MARK: Actions
    
    @IBAction func toggleLogShown(sender: AnyObject?) {
        logSplitViewItem.animator().collapsed = logSplitViewItem.collapsed ? false : true
    }

    // MARK: Validation
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
        case Selector("toggleLogShown:"):
            menuItem.title = logSplitViewItem.collapsed ? "Show Log" : "Close Log"
            return true
        default:
            return super.validateMenuItem(menuItem)
        }
    }
    
    // MARK: NSSplitViewDelegate
    
    override func splitView(splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        return splitView == self.splitView && subview == logSplitViewSubView
    }

    override func splitView(splitView: NSSplitView,
        shouldCollapseSubview subview: NSView,
        forDoubleClickOnDividerAtIndex dividerIndex: Int) -> Bool {
        return splitView == self.splitView && subview == logSplitViewSubView
    }
    
    override func splitView(splitView: NSSplitView, shouldHideDividerAtIndex dividerIndex: Int) -> Bool {
        return logSplitViewItem.collapsed
    }

    override func splitViewDidResizeSubviews(notification: NSNotification) {
        saveLogSplitViewFrame()
    }

    // MARK: WebViewControllerDelegate
    
    func webViewControllerWillAppear(webViewController: WebViewController) {
        if let superview = webViewController.view.superview {
            let view = webViewController.view
            
            let minimumHeightConstraint =  NSLayoutConstraint(item: view,
                attribute: .Height,
                relatedBy: .GreaterThanOrEqual,
                toItem: nil,
                attribute: .NotAnAttribute,
                multiplier: 1,
                constant: 150)
            // Constraint method breaks resizing
//            let defaultHeightConstraint =  NSLayoutConstraint(item: view,
//                attribute: .Height,
//                relatedBy: .Equal,
//                toItem: nil,
//                attribute: .NotAnAttribute,
//                multiplier: 1,
//                constant: 300)
//            view.setContentCompressionResistancePriority(250, forOrientation: .Vertical)
//            view.setContentHuggingPriority(250, forOrientation: .Vertical)
//            superview.addConstraints([minimumHeightConstraint, defaultHeightConstraint])
            
            superview.addConstraint(minimumHeightConstraint)

//            // Frame method doesn't work
//            if view == logSplitViewView {
//                NSLog("Setting the frame")
//                var frame = view.frame
//                frame.size.height = 300
//                view.frame = frame
//            }
        }
    }

}
