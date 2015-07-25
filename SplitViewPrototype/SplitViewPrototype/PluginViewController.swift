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

class PluginViewController: NSSplitViewController {

    @IBAction func toggleConsoleShown(sender: AnyObject?) {
        NSLog("toggleConsoleShown called")
    }

    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
        case Selector("toggleConsoleShown:"):
            NSLog("toggleConsoleShown validated")
            return true
        default:
            return super.validateMenuItem(menuItem)
        }
    }
}
