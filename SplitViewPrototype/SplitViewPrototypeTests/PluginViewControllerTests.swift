//
//  SplitViewPrototypeTests.swift
//  SplitViewPrototypeTests
//
//  Created by Roben Kleene on 7/19/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest
import SplitViewPrototype

class PluginViewControllerTests: XCTestCase {
    var pluginViewController: PluginViewController!
    
    override func setUp() {
        super.setUp()
        let window = NSApplication.sharedApplication().windows.last as! NSWindow
        pluginViewController = window.contentViewController as! PluginViewController
    }
    
    override func tearDown() {
        pluginViewController = nil
        super.tearDown()
    }
    
    func testPluginViewController() {
        XCTAssertTrue(pluginViewController.logSplitViewItem.collapsed, "The  NSSplitViewItem should be collapsed")
        pluginViewController.toggleLogShown(nil)
        XCTAssertFalse(pluginViewController.logSplitViewItem.collapsed, "The  NSSplitViewItem should not be collapsed")
    }

}
