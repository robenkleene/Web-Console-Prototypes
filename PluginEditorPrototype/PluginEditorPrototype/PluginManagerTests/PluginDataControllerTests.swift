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
    
}

class PluginDataControllerTests: XCTestCase {
    let pluginDataController = PluginDataController(testPluginsPaths)

    func testExistingPlugins() {
        let plugins = pluginDataController.plugins()
        
        var pluginPaths = [NSString]()
        for pluginsPath in testPluginsPaths {
            let paths = PluginDataController.pathsForPluginsAtPath(pluginsPath)
            pluginPaths += paths
        }
        
        XCTAssert(!plugins.isEmpty, "The plugins should not be empty")
        XCTAssert(plugins.count == pluginPaths.count, "The plugins count should match the plugin paths count")
    }
}

class PluginDataEventManager: PluginDataControllerDelegate {
    var pluginWasAddedHandlers: Array<(plugin: Plugin) -> Void>
    var pluginWasRemovedHandlers: Array<(plugin: Plugin) -> Void>
    
    init () {
        self.pluginWasAddedHandlers = Array<(plugin: Plugin) -> Void>()
        self.pluginWasRemovedHandlers = Array<(plugin: Plugin) -> Void>()
    }
    
    
    // MARK: PluginDataControllerDelegate
    
    func pluginDataController(pluginDataController: PluginDataController, didAddPlugin plugin: Plugin) {
        assert(pluginWasAddedHandlers.count > 0, "There should be at least one handler")
        
        if (pluginWasAddedHandlers.count > 0) {
            let handler = pluginWasAddedHandlers.removeAtIndex(0)
            handler(plugin: plugin)
        }
    }
    
    func pluginDataController(pluginDataController: PluginDataController, didRemovePlugin plugin: Plugin) {
        assert(pluginWasRemovedHandlers.count > 0, "There should be at least one handler")
        
        if (pluginWasRemovedHandlers.count > 0) {
            let handler = pluginWasRemovedHandlers.removeAtIndex(0)
            handler(plugin: plugin)
        }
    }
    
    
    // MARK: Handlers
    
    func addPluginWasAddedHandler(handler: (plugin: Plugin) -> Void) {
        pluginWasAddedHandlers.append(handler)
    }
    
    func addPluginWasRemovedHandler(handler: (plugin: Plugin) -> Void) {
        pluginWasRemovedHandlers.append(handler)
    }
    
}

extension PluginDataControllerTemporaryPluginsTests {
    
    // MARK: Move Helpers
    
    func movePluginWithConfirmation(plugin: Plugin, destinationPluginPath: NSString, handler: (plugin: Plugin?) -> Void) {
        let removeExpectation = expectationWithDescription("Plugin was removed")
        pluginDataEventManager.addPluginWasRemovedHandler({ (removedPlugin) -> Void in
            if (plugin == removedPlugin) {
                removeExpectation.fulfill()
            }
        })
        
        var newPlugin: Plugin?
        let createExpectation = expectationWithDescription("Plugin was added")
        pluginDataEventManager.addPluginWasAddedHandler({ (addedPlugin) -> Void in
            let path = addedPlugin.bundle.bundlePath
            if (path == destinationPluginPath) {
                newPlugin = addedPlugin
                handler(plugin: newPlugin)
                createExpectation.fulfill()
            }
        })
        
        let pluginPath = plugin.bundle.bundlePath
        SubprocessFileSystemModifier.moveItemAtPath(pluginPath, toPath: destinationPluginPath)
        
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    
    
    // MARK: Copy Helpers
    
    func copyPluginWithConfirmation(plugin: Plugin, destinationPluginPath: NSString, handler: (plugin: Plugin?) -> Void) {
        var newPlugin: Plugin?
        let createExpectation = expectationWithDescription("Plugin was added")
        pluginDataEventManager.addPluginWasAddedHandler({ (addedPlugin) -> Void in
            let path = addedPlugin.bundle.bundlePath
            if (path == destinationPluginPath) {
                newPlugin = addedPlugin
                handler(plugin: newPlugin)
                createExpectation.fulfill()
            }
        })
        
        
        let pluginPath = plugin.bundle.bundlePath
        SubprocessFileSystemModifier.copyDirectoryAtPath(pluginPath, toPath: destinationPluginPath)
        
        // TODO: Once the requirement that no two plugins have the same identifier is enforced, we'll also have to change the new plugins identifier here
        
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    
    
    // MARK: Remove Helpers
    
    func removePluginWithConfirmation(plugin: Plugin) {
        let removeExpectation = expectationWithDescription("Plugin was removed")
        pluginDataEventManager.addPluginWasRemovedHandler({ (removedPlugin) -> Void in
            if (plugin == removedPlugin) {
                removeExpectation.fulfill()
            }
        })
        
        let pluginPath = plugin.bundle.bundlePath
        SubprocessFileSystemModifier.removeDirectoryAtPath(pluginPath)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    
    
    // MARK: Modify Helpers
    
    func modifyPluginWithConfirmation(plugin: Plugin, handler: (plugin: Plugin?) -> Void) {
        let infoDictionaryPath: NSString! = temporaryPlugin.infoDictionaryURL.path
        var error: NSError?
        let infoDictionaryContents: NSString! = NSString(contentsOfFile: infoDictionaryPath, encoding: NSUTF8StringEncoding, error: &error)
        XCTAssertNil(error, "The error should be nil.")
        
        let removeExpectation = expectationWithDescription("Plugin was removed")
        pluginDataEventManager.addPluginWasRemovedHandler({ (removedPlugin) -> Void in
            if (plugin == removedPlugin) {
                removeExpectation.fulfill()
            }
        })
        
        let pluginPath = plugin.bundle.bundlePath
        var newPlugin: Plugin?
        let createExpectation = expectationWithDescription("Plugin was added")
        pluginDataEventManager.addPluginWasAddedHandler({ (addedPlugin) -> Void in
            let path = addedPlugin.bundle.bundlePath
            if (path == pluginPath) {
                newPlugin = addedPlugin
                handler(plugin: newPlugin)
                createExpectation.fulfill()
            }
        })
        
        SubprocessFileSystemModifier.writeToFileAtPath(infoDictionaryPath, contents: infoDictionaryContents)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
}

class PluginDataControllerTemporaryPluginsTests: TemporaryPluginsTestCase {
    var pluginDataController: PluginDataController!
    var pluginDataEventManager: PluginDataEventManager!
    var plugin: Plugin!
    
    override func setUp() {
        super.setUp()
        pluginDataController = PluginDataController([temporaryPluginsDirectoryPath], duplicatePluginDestinationDirectoryURL: temporaryPluginsDirectoryURL)
        pluginDataEventManager = PluginDataEventManager()
        pluginDataController.delegate = pluginDataEventManager
        XCTAssertEqual(pluginDataController.plugins().count, 1, "The plugins count should equal one")
        plugin = pluginDataController.plugins()[0]
    }
    
    override func tearDown() {
        pluginDataController.delegate = nil
        pluginDataEventManager = nil
        pluginDataController = nil // Make sure this happens after setting its delegate to nil
        super.tearDown()
    }
    
    func testAddAndDeletePlugin() {
        let pluginPath = plugin.bundle.bundlePath
        let destinationPluginFilename = plugin.identifier
        let destinationPluginPath = pluginPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(destinationPluginFilename)
        
        var newPlugin: Plugin!
        copyPluginWithConfirmation(plugin, destinationPluginPath: destinationPluginPath, handler: { (plugin) -> Void in
            newPlugin = plugin
        })
        XCTAssertNotNil(newPlugin, "The plugin should not be nil")
        XCTAssertTrue(contains(pluginDataController.plugins(), newPlugin), "The plugins should contain the plugin")
        removePluginWithConfirmation(newPlugin)
        XCTAssertFalse(contains(pluginDataController.plugins(), newPlugin), "The plugins should not contain the plugin")
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
        XCTAssertFalse(contains(pluginDataController.plugins(), plugin), "The plugins should not contain the plugin")
        XCTAssertTrue(contains(pluginDataController.plugins(), newPlugin), "The plugins should contain the plugin")
        
        // Move the plugin back
        var newPluginTwo: Plugin!
        movePluginWithConfirmation(newPlugin, destinationPluginPath: pluginPath, handler: { (plugin) -> Void in
            newPluginTwo = plugin
        })
        XCTAssertNotNil(newPluginTwo, "The plugin should not be nil")
        XCTAssertFalse(contains(pluginDataController.plugins(), newPlugin), "The plugins should not contain the plugin")
        XCTAssertTrue(contains(pluginDataController.plugins(), newPluginTwo), "The plugins should contain the plugin")
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
        XCTAssertFalse(contains(pluginDataController.plugins(), plugin), "The plugins should not contain the plugin")
        XCTAssertTrue(contains(pluginDataController.plugins(), newPlugin), "The plugins should contain the plugin")
    }
    
    func testDuplicateAndTrashPlugin() {
        let plugin = pluginDataController.plugins()[0]
        XCTAssertEqual(pluginDataController.plugins().count, 1, "The plugins count should be 1")
        
        var newPlugin: Plugin?
        
        let duplicateExpectation = expectationWithDescription("Plugin was duplicated")
        pluginDataController.duplicatePlugin(plugin, handler: { (duplicatePlugin) -> Void in
            newPlugin = duplicatePlugin
            duplicateExpectation.fulfill()
        })

        let addedExpectation = expectationWithDescription("Plugin was added")
        pluginDataEventManager.addPluginWasAddedHandler({ (addedPlugin) -> Void in
            addedExpectation.fulfill()
        })
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
        
        XCTAssertEqual(pluginDataController.plugins().count, 2, "The plugins count should be 1")
        XCTAssertTrue(contains(pluginDataController.plugins(), newPlugin!), "The plugins should contain the plugin")
        
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
        pluginDataController.movePluginToTrash(newPlugin!)
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
    
    // TODO: Test plugins made invalid are not loaded?
}