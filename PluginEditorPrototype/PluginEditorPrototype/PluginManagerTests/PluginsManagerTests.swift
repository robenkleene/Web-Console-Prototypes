//
//  PluginManagerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/6/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginsManagerTests: PluginsManagerTestCase {

    func testTestPlugins() {
        let plugins = PluginsManager.sharedInstance.plugins() as [Plugin]
        for plugin in plugins {
            XCTAssertEqual(plugin.pluginType, Plugin.PluginType.Other, "The plugin type should be built-in")
            XCTAssertEqual(plugin.type as String, Plugin.PluginType.Other.name(), "The type should equal the name")
        }
    }
    
    func testDuplicateAndTrashPlugin() {
        let newPlugin = newPluginWithConfirmation()
        
        XCTAssertEqual(PluginsManager.sharedInstance.plugins().count, 2, "The plugins count should be two")
        let plugins = PluginsManager.sharedInstance.plugins() as NSArray
        XCTAssertTrue(plugins.containsObject(newPlugin), "The plugins should contain the plugin")

        // Edit the new plugin
        newPlugin.command = testPluginCommandTwo

        // Create another plugin from this plugin
        let newPluginTwo = newPluginFromPluginWithConfirmation(newPlugin)
        
        // Test Properties

        XCTAssertEqual(newPluginTwo.command!, newPlugin.command!, "The commands should be equal")
        XCTAssertNotEqual(plugin.command!, newPlugin.command!, "The names should not be equal")
        
        // Trash the duplicated plugin
        movePluginToTrashAndCleanUpWithConfirmation(newPlugin)
        movePluginToTrashAndCleanUpWithConfirmation(newPluginTwo)
    }

    func testRenamePlugin() {
        let newPluginName = plugin.identifier
        plugin.name = newPluginName
        XCTAssertNotNil(PluginsManager.sharedInstance.pluginWithName(newPluginName), "The plugin should not be nil")
        XCTAssertNil(PluginsManager.sharedInstance.pluginWithName(testPluginName), "The plugin should be nil")
    }
}

class PluginsManagerBuiltInPluginsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        let pluginsManager = PluginsManager([Directory.BuiltInPlugins.path()],
            duplicatePluginDestinationDirectoryURL: Directory.Trash.URL())
        PluginsManager.setOverrideSharedInstance(pluginsManager)
    }
    
    override func tearDown() {
        PluginsManager.setOverrideSharedInstance(nil)
        super.tearDown()
    }
    
    func testBuiltInPlugins() {
        let plugins = PluginsManager.sharedInstance.plugins() as [Plugin]
        for plugin in plugins {
            XCTAssertEqual(plugin.pluginType, Plugin.PluginType.BuiltIn, "The plugin type should be built-in")
            XCTAssertEqual(plugin.type as String, Plugin.PluginType.BuiltIn.name(), "The type should equal the name")
        }
    }
}