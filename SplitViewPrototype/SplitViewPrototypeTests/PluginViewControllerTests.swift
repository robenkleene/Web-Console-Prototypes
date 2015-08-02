//
//  SplitViewPrototypeTests.swift
//  SplitViewPrototypeTests
//
//  Created by Roben Kleene on 7/19/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginViewControllerTests: XCTestCase {
    var pluginViewController: PluginViewController!
    var logViewHeight: CGFloat {
        return pluginViewController.logSplitViewView.frame.size.height
    }
    
    override func setUp() {
        super.setUp()
        PluginWindowsController.sharedInstance.openNewPluginWindow()
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

        XCTAssertEqual(logViewHeight, splitWebViewHeight, "The heights should be equal")

        let expectation = expectationWithDescription("NSUserDefaults did change")
        NSNotificationCenter.defaultCenter().addObserverForName(NSUserDefaultsDidChangeNotification, object: nil, queue: nil, usingBlock: {
            [unowned self] _ in
            expectation.fulfill()
            NSLog("NSUserDefaultsDidChangeNotification")
            })

        resizeLogViewHeight(testLogViewHeight)
        waitForExpectationsWithTimeout(testTimeout, handler: nil)
                
        // TODO: Wait for expectation with time out that the change gets saved?
        // TODO: Figure out how to resize the divider
        // TODO: Figure out whether the changed height is being saved to `NSUserDefaults`
        
        NSLog("logViewHeight = \(logViewHeight)")
    }

    
    func resizeLogViewHeight(height: CGFloat) {
        pluginViewController.configureLogViewHeight(height)
    }
}
