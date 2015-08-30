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

class PluginViewController: NSSplitViewController, WebViewControllerDelegate, LogControllerDelegate {

    var logController: LogController!

    var logSplitViewItemDividerIndex: Int? {
        if let index = logController.logSplitViewItemIndex {
            return index - 1
        }
        return nil
    }
    
    // MARK: Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()

        logController = LogController(splitViewController: self, logSplitViewItem: splitViewItems.last as! NSSplitViewItem)
        logController.delegate = self
        
        for splitViewItem in splitViewItems {
            if let webViewController = splitViewItem.viewController as? WebViewController {
                webViewController.delegate = self
            }
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        logController.setCollapsed(true, animated: false)
    }
    
    // MARK: Actions
    
    @IBAction func toggleLogShown(sender: AnyObject?) {
        logController.toggleCollapsed(true)
    }

    // MARK: Validation
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
        case Selector("toggleLogShown:"):
            if let collapsed = logController.isLogCollapsed() {
                menuItem.title = collapsed ? "Show Log" : "Close Log"
                return true
            } else {
                return false
            }
        default:
            return super.validateMenuItem(menuItem)
        }
    }
    
    // MARK: NSSplitViewDelegate
    
    override func splitView(splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        if splitView != self.splitView {
            return false
        }
        
        return subview == logController.logSplitViewSubview
    }

    override func splitView(splitView: NSSplitView,
        shouldCollapseSubview subview: NSView,
        forDoubleClickOnDividerAtIndex dividerIndex: Int) -> Bool
    {
        if splitView != self.splitView {
            return false
        }
        
        return subview == logController.logSplitViewSubview
    }
    
    override func splitView(splitView: NSSplitView, shouldHideDividerAtIndex dividerIndex: Int) -> Bool {
        if dividerIndex == logSplitViewItemDividerIndex {
            if let collapsed = logController.isLogCollapsed() {
                return collapsed
            }
        }
        return false
    }

    override func splitViewDidResizeSubviews(notification: NSNotification) {
        if let collapsed = logController.isLogCollapsed() {
            if !collapsed {
                logController.saveFrame()
                logController.configureHeight()
            }
        }
    }

    // MARK: WebViewControllerDelegate

    func webViewControllerViewWillDisappear(webViewController: WebViewController) {
        // No-op only tests use this now
    }
    
    func webViewControllerViewWillAppear(webViewController: WebViewController) {
        if let superview = webViewController.view.superview {
            let view = webViewController.view
            
            let minimumHeightConstraint =  NSLayoutConstraint(item: view,
                attribute: .Height,
                relatedBy: .GreaterThanOrEqual,
                toItem: nil,
                attribute: .NotAnAttribute,
                multiplier: 1,
                constant: splitWebViewHeight)
            superview.addConstraint(minimumHeightConstraint)

            if view == logController.logView {
                logController.restoreFrame()
            }
        }
    }

    // MARK: LogControllerDelegate
    
    func savedFrameNameForLogController(logController: LogController) -> String {
        return logSavedFrameName
    }

}
