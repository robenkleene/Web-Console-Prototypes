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

    // MARK: Test Other Methods of Creating Plugins
    
    func testDuplicateAndTrashPlugin() {
        var newPlugin: Plugin?

        let addedExpectation = expectationWithDescription("Plugin was added")
        pluginDataEventManager.addPluginWasAddedHandler({ (addedPlugin) -> Void in
            addedExpectation.fulfill()
        })

        let duplicateExpectation = expectationWithDescription("Plugin was duplicated")
        pluginManager.duplicatePlugin(plugin, handler: { (duplicatePlugin) -> Void in
            newPlugin = duplicatePlugin
            duplicateExpectation.fulfill()
        })

        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
        
        XCTAssertEqual(pluginManager.plugins().count, 2, "The plugins count should be two")
        XCTAssertTrue(contains(pluginManager.plugins(), newPlugin!), "The plugins should contain the plugin")
        
        // Trash the duplicated plugin
        
        // Confirm that a matching directory does not exist in the trash
        let trashedPluginDirectoryName = newPlugin!.bundle.bundlePath.lastPathComponent
        let trashDirectory = NSSearchPathForDirectoriesInDomains(.TrashDirectory, .UserDomainMask, true)[0] as NSString
        let trashedPluginPath = trashDirectory.stringByAppendingPathComponent(trashedPluginDirectoryName)
        let beforeExists = NSFileManager.defaultManager().fileExistsAtPath(trashedPluginPath)
        XCTAssertTrue(!beforeExists, "The item should exist")
        
        // Trash the plugin
        let removeExpectation = expectationWithDescription("Plugin was removed")
        pluginDataEventManager.addPluginWasRemovedHandler({ (removedPlugin) -> Void in
            XCTAssertEqual(newPlugin!, removedPlugin, "The plugins should be equal")
            removeExpectation.fulfill()
        })
        pluginManager.movePluginToTrash(newPlugin!)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
        
        // Confirm that the directory does exist in the trash now
        var isDir: ObjCBool = false
        let afterExists = NSFileManager.defaultManager().fileExistsAtPath(trashedPluginPath, isDirectory: &isDir)
        XCTAssertTrue(afterExists, "The item should exist")
        XCTAssertTrue(isDir, "The item should be a directory")
        
        // Clean up trash
        var removeError: NSError?
        let success = NSFileManager.defaultManager().removeItemAtPath(trashedPluginPath, error: &removeError)
        XCTAssertTrue(success, "The remove should succeed")
        XCTAssertNil(removeError, "The error should be nil")
    }

    func testRenamePlugin() {
        let newPluginName = plugin.identifier
        plugin.name = newPluginName
        XCTAssertNotNil(pluginManager.pluginWithName(newPluginName), "The plugin should not be nil")
        XCTAssertNil(pluginManager.pluginWithName(testPluginName), "The plugin should be nil")
    }
    
    // TODO: Waiting for default new plugin API, do tests with `PluginManager` `duplicatePlugin` API, using `PluginManager` `newPlugin`

}
