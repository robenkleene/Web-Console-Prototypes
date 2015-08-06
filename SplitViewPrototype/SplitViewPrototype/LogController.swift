//
//  LogController.swift
//  SplitViewPrototype
//
//  Created by Roben Kleene on 8/5/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Foundation
import AppKit

@objc protocol LogControllerDelegate: class {
    func savedFrameNameForLogController(logController: LogController) -> String
}

@objc class LogController {

    // MARK: Properties
    
    var splitViewItem: NSSplitViewItem
    private weak var splitViewController: NSSplitViewController?
    weak var delegate: LogControllerDelegate?

    var logHeightConstraint: NSLayoutConstraint?
    
    private var savedFrameName: String? {
        return delegate?.savedFrameNameForLogController(self)
    }
    
    private var logViewController: NSViewController? {
        return splitViewItem.viewController
    }
    
    private var logView: NSView? {
        return logViewController?.view
    }

    func isLogCollapsed() -> Bool? {
        return splitViewItem.collapsed
    }
    
    // MARK: Life Cycle
    
    
    // TODO: Remove this after setup is done in interface builder
    init(splitViewController: NSSplitViewController, splitViewItem: NSSplitViewItem) {
        self.splitViewController = splitViewController
        self.splitViewItem = splitViewItem
    }
    
    func setCollapsed(collapsed: Bool, animated: Bool) {
        if splitViewItem.collapsed != collapsed {
            if animated {
                splitViewItem.collapsed = collapsed
            } else {
                splitViewItem.animator().collapsed = collapsed
            }
        }
    }

    // MARK: Saving & Restoring Frame
    
    func restoreFrame() {
        if let frame = savedLogSplitViewFrame() {
            configureHeight(frame.size.height)
        }
    }
    
    func saveFrame() {
        if let logView = logView, key = savedFrameName {
            let frame = logView.frame
            let frameString = NSStringFromRect(frame)
            NSUserDefaults.standardUserDefaults().setObject(frameString, forKey:key)
        }
    }

    class func savedFrameForName(name: String) -> NSRect {
        let frameString = NSUserDefaults.standardUserDefaults().stringForKey(name)
        let frame = NSRectFromString(frameString)
        return frame
    }
    
    func savedLogSplitViewFrame() -> NSRect? {
        if let savedFrameName = savedFrameName {
            return self.dynamicType.savedFrameForName(savedFrameName)
        }
        return nil
    }

    // MARK: Constraints
    
    func configureHeight(height: CGFloat) {
        if let logView = logView, superview = logView.superview {
            if let logHeightConstraint = logHeightConstraint {
                superview.removeConstraint(logHeightConstraint)
            }
            
            let heightConstraint =  NSLayoutConstraint(item: logView,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: nil,
                attribute: NSLayoutAttribute.NotAnAttribute,
                multiplier: 1,
                constant: height)
            // Getting closer, this works for subsequent displays but not the first
            heightConstraint.priority = 300
            superview.addConstraint(heightConstraint)
            logHeightConstraint = heightConstraint
        }
    }

    
}