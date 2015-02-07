//
//  PluginManagerFileSystemTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/11/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginsManagerFileSystemTests: PluginsDataControllerEventTestCase {

    func plugins() -> NSArray {
        return PluginsManager.sharedInstance.plugins() as NSArray
    }
    
    // MARK: File System Tests
    
    func testAddAndDeletePlugin() {
        let destinationPluginFilename = DuplicatePluginController.pluginFilenameFromName(plugin.identifier)
        let destinationPluginPath = pluginPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(destinationPluginFilename)
        
        var newPlugin: Plugin!
        copyPluginWithConfirmation(plugin, destinationPluginPath: destinationPluginPath, handler: { (plugin) -> Void in
            newPlugin = plugin
        })
        XCTAssertNotNil(newPlugin, "The plugin should not be nil")

        XCTAssertTrue(plugins().containsObject(newPlugin!), "The plugins should contain the plugin")
        XCTAssertEqual(PluginsManager.sharedInstance.pluginWithName(testPluginName)!, newPlugin, "The plugins should be equal")
        // Since both plugins have the same name, the new plugin should have replaced the original plugin
        // So the plugin count should still be one
        XCTAssertEqual(PluginsManager.sharedInstance.plugins().count, 1, "The plugins count should be one")
        
        // Clean Up
        removePluginWithConfirmation(newPlugin)
        XCTAssertFalse(plugins().containsObject(newPlugin), "The plugins should not contain the plugin")
        XCTAssertEqual(PluginsManager.sharedInstance.plugins().count, 0, "The plugins count should be zero")
        
        // Interesting here is that the plugin manager has no plugins loaded, even though the original plugin is still there.
        // This is because when multiple plugins are loaded with the same name, only the most recent plugin with the name is loaded.
        
        // Test that the original plugin can be reloaded by modifying it
        var originalPlugin: Plugin!
        modifyPluginWithConfirmation(plugin, handler: { (plugin) -> Void in
            originalPlugin = plugin
        })
        XCTAssertNotNil(originalPlugin, "The plugin should not be nil")
        XCTAssertTrue(plugins().containsObject(originalPlugin), "The plugins should contain the plugin")
        XCTAssertEqual(PluginsManager.sharedInstance.pluginWithName(testPluginName)!, originalPlugin, "The plugins should be equal")
        XCTAssertEqual(PluginsManager.sharedInstance.plugins().count, 1, "The plugins count should be one")
    }
    
    func testMovePlugin() {
        let pluginPath = plugin.bundle.bundlePath
        let destinationPluginFilename = DuplicatePluginController.pluginFilenameFromName(plugin.identifier)
        let destinationPluginPath = pluginPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(destinationPluginFilename)
        
        // Move the plugin
        var newPlugin: Plugin!
        movePluginWithConfirmation(plugin, destinationPluginPath: destinationPluginPath, handler: { (plugin) -> Void in
            newPlugin = plugin
        })
        XCTAssertNotNil(newPlugin, "The plugin should not be nil")
        XCTAssertTrue(plugins().containsObject(newPlugin), "The plugins should contain the plugin")
        XCTAssertEqual(PluginsManager.sharedInstance.pluginWithName(testPluginName)!, newPlugin, "The plugins should be equal")
        XCTAssertEqual(PluginsManager.sharedInstance.plugins().count, 1, "The plugins count should be one")
        
        // Move the plugin back
        var originalPlugin: Plugin!
        movePluginWithConfirmation(newPlugin, destinationPluginPath: pluginPath, handler: { (plugin) -> Void in
            originalPlugin = plugin
        })
        XCTAssertNotNil(originalPlugin, "The plugin should not be nil")
        XCTAssertTrue(plugins().containsObject(originalPlugin), "The plugins should contain the plugin")
        XCTAssertEqual(PluginsManager.sharedInstance.pluginWithName(testPluginName)!, originalPlugin, "The plugins should be equal")
        XCTAssertEqual(PluginsManager.sharedInstance.plugins().count, 1, "The plugins count should be one")
    }
    
    func testEditPlugin() {
        let pluginPath = plugin.bundle.bundlePath
        
        // Move the plugin
        var newPlugin: Plugin!
        modifyPluginWithConfirmation(plugin, handler: { (plugin) -> Void in
            newPlugin = plugin
        })
        XCTAssertNotNil(newPlugin, "The plugin should not be nil")
        XCTAssertFalse(plugins().containsObject(plugin), "The plugins should not contain the plugin")
        XCTAssertTrue(plugins().containsObject(newPlugin), "The plugins should contain the plugin")
    }

    // TODO: Test making the plugin info dictionary invalid removes it
    // TODO: Test that touching the plugin info dictionary does not cause it to reload (because the resulting plugin will still be equal) No way to test this now since there aren't any callbacks to wait for here
}
