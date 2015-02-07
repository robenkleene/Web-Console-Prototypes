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
    
    // TODO: Waiting for default new plugin API, do tests with `PluginManager` `duplicatePlugin` API, using `PluginManager` `newPlugin`

}
