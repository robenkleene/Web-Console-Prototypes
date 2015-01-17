//
//  PluginManagerFileSystemTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/11/15.
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

class PluginManagerFileSystemTests: PluginDataEventManagerTestCase {

    var pluginManager: PluginManager!
    var plugin: Plugin!
    
    override func setUp() {
        super.setUp()
        pluginManager = PluginManager([temporaryPluginsDirectoryPath],
            duplicatePluginDestinationDirectoryURL: temporaryPluginsDirectoryURL,
            pluginDataEventManager: pluginDataEventManager)
        plugin = pluginManager.pluginWithName(testPluginName)
        XCTAssertTrue(contains(pluginManager.plugins(), plugin), "The plugins should contain the plugin")
    }
    
    override func tearDown() {
        pluginManager.pluginDataController.delegate = nil
        pluginManager = nil
        plugin = nil
        super.tearDown()
    }

    
    // MARK: File System Tests
    
    func testAddAndDeletePlugin() {
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
    
    func testMovePlugin() {
        let pluginPath = plugin.bundle.bundlePath
        let destinationPluginFilename = plugin.identifier
        let destinationPluginPath = pluginPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(destinationPluginFilename)
        
        // Move the plugin
        var newPlugin: Plugin!
        movePluginWithConfirmation(plugin, destinationPluginPath: destinationPluginPath, handler: { (plugin) -> Void in
            newPlugin = plugin
        })
        XCTAssertNotNil(newPlugin, "The plugin should not be nil")
        XCTAssertTrue(contains(pluginManager.plugins(), newPlugin), "The plugins should contain the plugin")
        XCTAssertEqual(pluginManager.pluginWithName(testPluginName)!, newPlugin, "The plugins should be equal")
        XCTAssertEqual(pluginManager.plugins().count, 1, "The plugins count should be one")
        
        // Move the plugin back
        var originalPlugin: Plugin!
        movePluginWithConfirmation(newPlugin, destinationPluginPath: pluginPath, handler: { (plugin) -> Void in
            originalPlugin = plugin
        })
        XCTAssertNotNil(originalPlugin, "The plugin should not be nil")
        XCTAssertTrue(contains(pluginManager.plugins(), originalPlugin), "The plugins should contain the plugin")
        XCTAssertEqual(pluginManager.pluginWithName(testPluginName)!, originalPlugin, "The plugins should be equal")
        XCTAssertEqual(pluginManager.plugins().count, 1, "The plugins count should be one")
    }
    
    func testEditPlugin() {
        let pluginPath = plugin.bundle.bundlePath
        let destinationPluginFilename = plugin.identifier
        let destinationPluginPath = pluginPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(destinationPluginFilename)
        
        // Move the plugin
        var newPlugin: Plugin!
        modifyPluginWithConfirmation(plugin, handler: { (plugin) -> Void in
            newPlugin = plugin
        })
        XCTAssertNotNil(newPlugin, "The plugin should not be nil")
        XCTAssertFalse(contains(pluginManager.plugins(), plugin), "The plugins should not contain the plugin")
        XCTAssertTrue(contains(pluginManager.plugins(), newPlugin), "The plugins should contain the plugin")
    }

}
