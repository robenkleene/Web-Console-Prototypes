//
//  PluginManagerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/6/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

extension PluginManager {
    convenience init(_ paths: [String],
        duplicatePluginDestinationDirectoryURL: NSURL,
        pluginDataEventManager: PluginDataEventManager)
    {
        self.init(paths, duplicatePluginDestinationDirectoryURL: duplicatePluginDestinationDirectoryURL)
        self.pluginDataController.delegate = pluginDataEventManager
        pluginDataEventManager.delegate = self
    }
}

class PluginManagerTests: PluginDataEventManagerTestCase {
    var pluginManager: PluginManager!
    var plugin: Plugin!
    
    override func setUp() {
        super.setUp()
        pluginManager = PluginManager([temporaryPluginsDirectoryPath],
            duplicatePluginDestinationDirectoryURL: temporaryPluginsDirectoryURL,
            pluginDataEventManager: pluginDataEventManager)
        plugin = pluginManager.pluginWithName(testPluginName)
    }

    override func tearDown() {
        pluginManager.pluginDataController.delegate = nil
        pluginManager = nil
        plugin = nil
        super.tearDown()
    }

    func testAddAndDeletePlugin() {
        let pluginIdentifier = plugin.identifier
        let pluginPath = plugin.bundle.bundlePath
        let destinationPluginFilename = plugin.identifier
        let destinationPluginPath = pluginPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(destinationPluginFilename)
        
        var newPlugin: Plugin!
        copyPluginWithConfirmation(plugin, destinationPluginPath: destinationPluginPath, handler: { (plugin) -> Void in
            newPlugin = plugin
        })
        XCTAssertNotNil(newPlugin, "The plugin should not be nil")
        XCTAssertTrue(contains(pluginManager.plugins(), newPlugin), "The plugins should contain the plugin")
        XCTAssertEqual(pluginManager.pluginWithName(testPluginName)!, newPlugin, "The plugins should be equal")
        // Since both plugins have the same name, the new plugin should have replaced the original plugin
        // So the plugin count should still be one
        XCTAssertEqual(pluginManager.plugins().count, 1, "The plugins count should be one")

        // Clean Up
        removePluginWithConfirmation(newPlugin)
        XCTAssertFalse(contains(pluginManager.plugins(), newPlugin), "The plugins should not contain the plugin")
        XCTAssertEqual(pluginManager.plugins().count, 0, "The plugins count should be zero")
        
        // Interesting here is that the plugin manager has no plugins loaded, even though the original plugin is still there.
        // This is because when multiple plugins are loaded with the same name, only the most recent plugin with the name is loaded.

        // Test that the original plugin can be reloaded by modifying it
        var originalPlugin: Plugin!
        modifyPluginWithConfirmation(plugin, handler: { (plugin) -> Void in
            originalPlugin = plugin
        })
        XCTAssertNotNil(originalPlugin, "The plugin should not be nil")
        XCTAssertTrue(contains(pluginManager.plugins(), originalPlugin), "The plugins should contain the plugin")
        XCTAssertEqual(pluginManager.pluginWithName(testPluginName)!, originalPlugin, "The plugins should be equal")
        XCTAssertEqual(pluginManager.plugins().count, 1, "The plugins count should be one")
    }

    // TODO: Make all the same `PluginDataControllerTests` work here and confirm `pluginWithName` behaves as it should for each
    // TODO: Test that after renaming a plugin `pluginWithName` works with the new name and not the old name
    // This should work now!
}
