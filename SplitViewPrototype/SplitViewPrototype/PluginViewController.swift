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
    
    var logSplitViewSubView: NSView {
        return self.splitView.subviews.last as! NSView
    }
    
    lazy var logSplitViewItem: NSSplitViewItem = {
        return self.splitViewItems.last as! NSSplitViewItem
    }()

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

    // MARK: WebViewControllerDelegate
    
    func webViewControllerWillAppear(webViewController: WebViewController) {
        if let superview = webViewController.view.superview {
            let heightConstraint =  NSLayoutConstraint(item: webViewController.view,
                attribute: .Height,
                relatedBy: .GreaterThanOrEqual,
                toItem: nil,
                attribute: .NotAnAttribute,
                multiplier: 1,
                constant: 150)
            superview.addConstraint(heightConstraint)
        }
    }

}
