//
//  PluginManagerTests.swift
//  PluginManagerTests
//
//  Created by Roben Kleene on 9/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginsDataControllerClassTests: XCTestCase {
    
    func testPluginPaths() {
        let pluginsPath = NSBundle.mainBundle().builtInPlugInsPath!
        let pluginPaths = PluginsDataController.pathsForPluginsAtPath(pluginsPath)

        // Test plugin path counts
        if let testPluginPaths = NSFileManager.defaultManager().contentsOfDirectoryAtPath(pluginsPath, error:nil) {
            XCTAssert(!testPluginPaths.isEmpty, "The test plugin paths count should be greater than zero")
            XCTAssert(testPluginPaths.count == pluginPaths.count, "The plugin paths count should equal the test plugin paths count")
        } else {
            XCTAssert(false, "The contents of the path should exist")
        }
        
        // Test plugins can be created from all paths
        var plugins = [Plugin]()
        for pluginPath in pluginPaths {
            if let plugin = Plugin.pluginWithPath(pluginPath) {
                plugins.append(plugin)
            } else {
                XCTAssert(false, "The plugin should exist")
            }
        }

        let testPluginsCount = PluginsDataController.pluginsAtPluginPaths(pluginPaths).count
        XCTAssert(plugins.count == testPluginsCount, "The plugins count should equal the test plugins count")
    }
    
}

class PluginsDataControllerBuiltInPluginsTests: XCTestCase {

    func testExistingPlugins() {
        let trashDirectoryPath = NSSearchPathForDirectoriesInDomains(.TrashDirectory, .UserDomainMask, true)[0] as NSString
        let trashDirectoryURL = NSURL(fileURLWithPath: trashDirectoryPath)
        let pluginsDataController = PluginsDataController(testPluginsPaths, duplicatePluginDestinationDirectoryURL: trashDirectoryURL!)
        let plugins = pluginsDataController.plugins()
        
        var pluginPaths = [NSString]()
        for pluginsPath in testPluginsPaths {
            let paths = PluginsDataController.pathsForPluginsAtPath(pluginsPath)
            pluginPaths += paths
        }
        
        XCTAssert(!plugins.isEmpty, "The plugins should not be empty")
        XCTAssert(plugins.count == pluginPaths.count, "The plugins count should match the plugin paths count")
    }
}

class PluginsDataControllerTests: PluginsDataControllerEventTestCase {
    
    // MARK: Test Other Methods of Creating Plugins
    
    func testDuplicateAndTrashPlugin() {
        let plugin = PluginsManager.sharedInstance.pluginsDataController.plugins()[0]
        XCTAssertEqual(PluginsManager.sharedInstance.pluginsDataController.plugins().count, 1, "The plugins count should be one")
        
        var newPlugin: Plugin?
        
        let addedExpectation = expectationWithDescription("Plugin was added")
        pluginDataEventManager.addPluginWasAddedHandler({ (addedPlugin) -> Void in
            addedExpectation.fulfill()
        })

        let duplicateExpectation = expectationWithDescription("Plugin was duplicated")
        PluginsManager.sharedInstance.pluginsDataController.duplicatePlugin(plugin, handler: { (duplicatePlugin, error) -> Void in
            XCTAssertNil(error, "The error should be nil")
            newPlugin = duplicatePlugin
            duplicateExpectation.fulfill()
        })

        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
        
        XCTAssertEqual(PluginsManager.sharedInstance.pluginsDataController.plugins().count, 2, "The plugins count should be two")
        XCTAssertTrue(contains(PluginsManager.sharedInstance.pluginsDataController.plugins(), newPlugin!), "The plugins should contain the plugin")
        
        // Trash the duplicated plugin
        let removeExpectation = expectationWithDescription("Plugin was removed")
        pluginDataEventManager.addPluginWasRemovedHandler({ (removedPlugin) -> Void in
            XCTAssertEqual(newPlugin!, removedPlugin, "The plugins should be equal")
            removeExpectation.fulfill()
        })

        movePluginToTrashAndCleanUpWithConfirmation(newPlugin!)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
}