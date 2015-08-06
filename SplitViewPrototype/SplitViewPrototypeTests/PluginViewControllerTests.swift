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
    
    override func setUp() {
        super.setUp()
        NSUserDefaults.standardUserDefaults().removeObjectForKey(logSavedFrameName)
    }
    
    override func tearDown() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(logSavedFrameName)
        super.tearDown()
    }
    
    func testPluginViewController() {
        
        let pluginViewController = makeNewPluginViewController()
        
        // The log starts collapsed
        XCTAssertTrue(pluginViewController.logSplitViewItem.collapsed, "The  NSSplitViewItem should be collapsed")
        
        // Show the log
        makeLogAppearForPluginViewController(pluginViewController)
        XCTAssertEqual(heightForPluginViewController(pluginViewController), splitWebViewHeight, "The heights should be equal")
        
        // Resize the log
        resizeLogForPluginViewController(pluginViewController, logHeight: testLogViewHeight)
        
        // Close and re-show the log
        makeLogDisappearForPluginViewController(pluginViewController)
        
        // Reshow the log
        makeLogAppearForPluginViewController(pluginViewController)
        
        // Test that the frame height was restored
        XCTAssertEqual(heightForPluginViewController(pluginViewController), testLogViewHeight, "The heights should be equal")


        // Make a second window and confirm it uses the saved height
        let secondPluginViewController = makeNewPluginViewController()
        XCTAssertTrue(secondPluginViewController.logSplitViewItem.collapsed, "The  NSSplitViewItem should be collapsed")
        makeLogAppearForPluginViewController(secondPluginViewController)
        XCTAssertEqual(heightForPluginViewController(secondPluginViewController), testLogViewHeight, "The heights should be equal")

        // Close the log in the first window
        makeLogDisappearForPluginViewController(pluginViewController)
        
        // Wait for the new frame to be saved
        resizeLogForPluginViewController(secondPluginViewController, logHeight: splitWebViewHeight)
        
        // Re-open the log in the first window and confirm it has the right height
        makeLogAppearForPluginViewController(pluginViewController)
        XCTAssertEqual(heightForPluginViewController(pluginViewController), splitWebViewHeight, "The heights should be equal")
    }
    
    // MARK: Helpers
    
    func resizeLogForPluginViewController(pluginViewController: PluginViewController, logHeight: CGFloat) {
        // Resize & Wait for Save
        makeFrameSaveExpectationForHeight(logHeight, name: pluginViewController.logSplitViewSubviewSavedFrameName)
        pluginViewController.configureLogViewHeight(logHeight)
        waitForExpectationsWithTimeout(testTimeout, handler: nil)

        // Test the height & saved frame
        XCTAssertEqual(heightForPluginViewController(pluginViewController), logHeight, "The heights should be equal")
        var frame = pluginViewController.savedLogSplitViewFrame()
        XCTAssertEqual(frame.size.height, logHeight, "The heights should be equal")
    }
    
    func makeLogAppearForPluginViewController(pluginViewController: PluginViewController) {
        makeLogViewWillAppearExpectationForPluginViewController(pluginViewController)
        pluginViewController.toggleLogShown(nil)
        waitForExpectationsWithTimeout(testTimeout, handler: nil)
        XCTAssertFalse(pluginViewController.logSplitViewItem.collapsed, "The  NSSplitViewItem should not be collapsed")
        confirmValuesForPluginViewController(pluginViewController, collapsed: false)
    }
    
    func makeLogDisappearForPluginViewController(pluginViewController: PluginViewController) {
        makeLogViewWillDisappearExpectationForPluginViewController(pluginViewController)
        pluginViewController.toggleLogShown(nil)
        waitForExpectationsWithTimeout(testTimeout, handler: nil)
        XCTAssertTrue(pluginViewController.logSplitViewItem.collapsed, "The  NSSplitViewItem should be collapsed")
        confirmValuesForPluginViewController(pluginViewController, collapsed: true)
    }

    func confirmValuesForPluginViewController(pluginViewController: PluginViewController, collapsed: Bool) {
        let logIndex: Int! = find(pluginViewController.splitViewItems as! [NSSplitViewItem], pluginViewController.logSplitViewItem)
        XCTAssertNotNil(logIndex, "The index should not be nil")
        
        var result = pluginViewController.splitView(pluginViewController.splitView, canCollapseSubview: pluginViewController.logSplitViewSubview)
        XCTAssertTrue(result, "The log NSView should be collapsable")
        result = pluginViewController.splitView(pluginViewController.splitView, canCollapseSubview: NSView())
        XCTAssertFalse(result , "The NSView should not be collapsable")
        result = pluginViewController.splitView(pluginViewController.splitView, shouldCollapseSubview: pluginViewController.logSplitViewSubview, forDoubleClickOnDividerAtIndex: logIndex)
        XCTAssertTrue(result, "The log NSView should be collapsable")
        result = pluginViewController.splitView(pluginViewController.splitView, shouldCollapseSubview: NSView(), forDoubleClickOnDividerAtIndex: logIndex + 1)
        XCTAssertFalse(result , "The NSView should not be collapsable")
        result = pluginViewController.splitView(pluginViewController.splitView, shouldHideDividerAtIndex: logIndex - 1)
        XCTAssertTrue(result == collapsed, "The divider should be hidden if the log view is hidden")
        result = pluginViewController.splitView(pluginViewController.splitView, shouldHideDividerAtIndex: logIndex)
        XCTAssertFalse(result, "The divider should never be hidden for the NSView")
    }
    
    func heightForPluginViewController(pluginViewController: PluginViewController) -> CGFloat {
        return pluginViewController.logSplitViewView.frame.size.height
    }
    
    func makeNewPluginViewController() -> PluginViewController {
        PluginWindowsController.sharedInstance.openNewPluginWindow()
        let window = NSApplication.sharedApplication().windows.last as! NSWindow
        return window.contentViewController as! PluginViewController
    }
    
    func makeLogViewWillAppearExpectationForPluginViewController(pluginViewController: PluginViewController) {
        let webViewController = pluginViewController.logSplitViewItem.viewController as! WebViewController
        let viewWillAppearExpectation = expectationWithDescription("WebViewController will appear")
        let webViewControllerEventManager = WebViewControllerEventManager(webViewController: webViewController, viewWillAppearBlock: { _ in
            viewWillAppearExpectation.fulfill()
        }, viewWillDisappearBlock: nil)
    }
    
    func makeLogViewWillDisappearExpectationForPluginViewController(pluginViewController: PluginViewController) {
        let webViewController = pluginViewController.logSplitViewItem.viewController as! WebViewController
        let viewWillDisappearExpectation = expectationWithDescription("WebViewController will appear")
        let webViewControllerEventManager = WebViewControllerEventManager(webViewController: webViewController, viewWillAppearBlock: nil) { _ in
            viewWillDisappearExpectation.fulfill()
        }
    }
    
    func makeFrameSaveExpectationForHeight(height: CGFloat, name: String) {
        let expectation = expectationWithDescription("NSUserDefaults did change")
        var observer: NSObjectProtocol?
        observer = NSNotificationCenter.defaultCenter().addObserverForName(NSUserDefaultsDidChangeNotification,
            object: nil,
            queue: nil)
        { [unowned self] _ in
            let frame = PluginViewController.savedLogSplitViewFrameForName(name)
            if frame.size.height == height {
                expectation.fulfill()
                if let observer = observer {
                    NSNotificationCenter.defaultCenter().removeObserver(observer)
                }
                observer = nil
            }
        }
    }

}
