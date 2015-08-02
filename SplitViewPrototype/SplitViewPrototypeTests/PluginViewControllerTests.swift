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
        pluginViewController = makeNewPluginViewController()
        NSUserDefaults.standardUserDefaults().removeObjectForKey(pluginViewController.logSplitViewSubviewSavedFrameName)
    }
    
    override func tearDown() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(pluginViewController.logSplitViewSubviewSavedFrameName)
        pluginViewController = nil
        super.tearDown()
    }
    
    func testPluginViewController() {
        // The log starts collapsed
        XCTAssertTrue(pluginViewController.logSplitViewItem.collapsed, "The  NSSplitViewItem should be collapsed")

        // Show the log
        pluginViewController.toggleLogShown(nil)
        XCTAssertFalse(pluginViewController.logSplitViewItem.collapsed, "The  NSSplitViewItem should not be collapsed")
        XCTAssertEqual(logViewHeight, splitWebViewHeight, "The heights should be equal")

        // Wait for the new frame to be saved
        let expectation = expectationWithDescription("NSUserDefaults did change")
        var observer: NSObjectProtocol?
        observer = NSNotificationCenter.defaultCenter().addObserverForName(NSUserDefaultsDidChangeNotification, object: nil, queue: nil) {
            [unowned self] _ in
            expectation.fulfill()
            if let observer = observer {
                NSNotificationCenter.defaultCenter().removeObserver(observer)
            }
            observer = nil
        }

        // Resize the log
        resizeLogViewHeight(testLogViewHeight)
        waitForExpectationsWithTimeout(testTimeout, handler: nil)
        XCTAssertEqual(logViewHeight, testLogViewHeight, "The heights should be equal")

        // Test that the frame has been saved
        let frame = pluginViewController.savedLogSplitViewFrame()
        XCTAssertEqual(frame.size.height, testLogViewHeight, "The heights should be equal")

        // Close and re-show the log
        pluginViewController.toggleLogShown(nil)
        XCTAssertTrue(pluginViewController.logSplitViewItem.collapsed, "The  NSSplitViewItem should be collapsed")
        pluginViewController.toggleLogShown(nil)
        XCTAssertFalse(pluginViewController.logSplitViewItem.collapsed, "The  NSSplitViewItem should not be collapsed")

        // TODO: Make helper method that makes it easy to make a new window
        // TODO: Make a helper method that makes it easy to wait for a save
        
        // TODO: Confirm the saved frame is accurate
        // TODO: Open and close the log, confirm it has the correct height
        // TODO: Open a new window and confirm it uses the correct height
        // TODO: Change the height in the second window then close it
        // TODO: Re-open the log in the first window, confirm it uses the new height
    }

    // MARK: Helpers
    
    func resizeLogViewHeight(height: CGFloat) {
        pluginViewController.configureLogViewHeight(height)
    }

    func makeNewPluginViewController() -> PluginViewController {
        PluginWindowsController.sharedInstance.openNewPluginWindow()
        let window = NSApplication.sharedApplication().windows.last as! NSWindow
        return window.contentViewController as! PluginViewController
    }
}
