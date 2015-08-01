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

// TODO: When migrating to Swift 2, Replace all instances of `public` with `@testable`

public class PluginViewController: NSSplitViewController, WebViewControllerDelegate {

    // MARK: Properties

    var logSplitViewViewStartingHeightConstraint: NSLayoutConstraint?
    
    lazy var logSplitViewSubviewSavedFrameName: String = {
        // TODO: Replace this with a real name, different for each plugin
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
    
    public var logSplitViewItem: NSSplitViewItem {
        return self.splitViewItems.last as! NSSplitViewItem
    }

    // MARK: Life Cycle
    
    public override func awakeFromNib() {
        super.awakeFromNib()

        for splitViewItem in splitViewItems {
            if let webViewController = splitViewItem.viewController as? WebViewController {
                webViewController.delegate = self
            }
        }
    }
    
    public override func viewWillAppear() {
        super.viewWillAppear()

        // The log starts hidden
        logSplitViewItem.collapsed = true
    }

    // MARK: Saving & Restoring Frame

    func saveLogSplitViewFrame() {
        let frame = logSplitViewView.frame
        let frameString = NSStringFromRect(frame)
        let key = logSplitViewSubviewSavedFrameName

        NSUserDefaults.standardUserDefaults().setObject(frameString, forKey:key)
    }

    func savedLogSplitViewFrame() -> NSRect {
        let frameString = NSUserDefaults.standardUserDefaults().stringForKey(logSplitViewSubviewSavedFrameName)
        let frame = NSRectFromString(frameString)
        return frame
    }

    func configureLogViewHeight(height: CGFloat) {

        if let superview = logSplitViewView.superview {
            let logView = logSplitViewView
            if let logSplitViewViewStartingHeightConstraint = logSplitViewViewStartingHeightConstraint {
                superview.removeConstraint(logSplitViewViewStartingHeightConstraint)
            }

            let defaultHeightConstraint =  NSLayoutConstraint(item: logView,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: nil,
                attribute: NSLayoutAttribute.NotAnAttribute,
                multiplier: 1,
                constant: height)
            // Getting closer, this works for subsequent displays but not the first
            defaultHeightConstraint.priority = 300
            superview.addConstraint(defaultHeightConstraint)
            logSplitViewViewStartingHeightConstraint = defaultHeightConstraint
        }
        
    }
    
    // MARK: Actions
    
    @IBAction public func toggleLogShown(sender: AnyObject?) {
        logSplitViewItem.animator().collapsed = logSplitViewItem.collapsed ? false : true
    }

    // MARK: Validation
    
    public override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
        case Selector("toggleLogShown:"):
            menuItem.title = logSplitViewItem.collapsed ? "Show Log" : "Close Log"
            return true
        default:
            return super.validateMenuItem(menuItem)
        }
    }
    
    // MARK: NSSplitViewDelegate
    
    public override func splitView(splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        return splitView == self.splitView && subview == logSplitViewSubView
    }

    public override func splitView(splitView: NSSplitView,
        shouldCollapseSubview subview: NSView,
        forDoubleClickOnDividerAtIndex dividerIndex: Int) -> Bool {
        return splitView == self.splitView && subview == logSplitViewSubView
    }
    
    public override func splitView(splitView: NSSplitView, shouldHideDividerAtIndex dividerIndex: Int) -> Bool {
        return logSplitViewItem.collapsed
    }

    public override func splitViewDidResizeSubviews(notification: NSNotification) {
        if !logSplitViewItem.collapsed {
            saveLogSplitViewFrame()
            configureLogViewHeight(logSplitViewView.frame.size.height)
        }
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
                constant: splitWebViewHeight)
            superview.addConstraint(minimumHeightConstraint)

            if view == logSplitViewView {
                let frame = savedLogSplitViewFrame()
                configureLogViewHeight(frame.size.height)
            }
        }
    }

}
