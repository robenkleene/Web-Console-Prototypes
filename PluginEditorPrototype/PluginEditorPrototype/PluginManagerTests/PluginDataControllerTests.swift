//
//  PluginManagerTests.swift
//  PluginManagerTests
//
//  Created by Roben Kleene on 9/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginDataControllerClassTests: XCTestCase {
    
    func testPluginPaths() {
        let pluginsPath = NSBundle.mainBundle().builtInPlugInsPath!
        let pluginPaths = PluginDataController.pathsForPluginsAtPath(pluginsPath)

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

        let testPluginsCount = PluginDataController.pluginsAtPluginPaths(pluginPaths).count
        XCTAssert(plugins.count == testPluginsCount, "The plugins count should equal the test plugins count")
    }
    
    func testBuiltInPluginsPath() {
        XCTAssert(PluginsDirectory.BuiltIn.path() == NSBundle.mainBundle().builtInPlugInsPath!, "The paths should match")
    }
    
    func testApplicationSupportPluginsPath() {
        let pluginsPathComponent = "PlugIns"
        let applicationSupportPath = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)[0] as String
        let nameKey = kCFBundleNameKey as NSString
        let applicationName = NSBundle.mainBundle().infoDictionary[nameKey] as NSString
        let applicationSupportPluginsPath = applicationSupportPath
            .stringByAppendingPathComponent(applicationName)
            .stringByAppendingPathComponent(pluginsPathComponent)
        XCTAssert(applicationSupportPluginsPath == PluginsDirectory.ApplicationSupport.path(), "The paths should match")
    }
}


class PluginDataControllerTests: TemporaryDirectoryTestCase {
    let pluginDataController = PluginDataController(testPluginPaths)

    func testExistingPlugins() {
        let plugins = pluginDataController.existingPlugins()
        
        let pluginPaths = PluginDataController.pathsForPluginsAtPaths(testPluginPaths)
        
        XCTAssert(!plugins.isEmpty, "The plugins should not be empty")
        XCTAssert(plugins.count == pluginPaths.count, "The plugins count should match the plugin paths count")
    }
    
    func testNewPluginFromPlugin() {
        let pluginManager = PluginManager(testPluginPaths)
        let plugin = pluginManager.pluginWithName(testPluginName)
        
        pluginDataController.newPluginFromPlugin(plugin!)
    }

}
