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

    func testExistingPlugins() {
        let pluginsDataController = PluginsDataController(testPluginsPaths, duplicatePluginDestinationDirectoryURL: Directory.Trash.URL())
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

extension TemporaryDirectoryTestCase {
    // MARK: Helpers
    
    func createFileWithConfirmationAtURL(URL: NSURL, contents: String) {
        let path = URL.path!
        var error: NSError?
        let createSuccess = NSFileManager.defaultManager().createFileAtPath(path,
            contents: testFileContents.dataUsingEncoding(NSUTF8StringEncoding),
            attributes: nil)
        XCTAssertTrue(createSuccess, "Creating the file should succeed.")
        XCTAssertNil(error, "The error should succeed.")
    }
    
    func contentsOfFileAtURLWithConfirmation(URL: NSURL) -> String {
        var error: NSError?
        let contents: NSString! = NSString(contentsOfURL: URL,
            encoding: NSUTF8StringEncoding,
            error: &error)
        XCTAssertNil(error, "The error should be nil")
        return contents
    }
    
    func confirmFileExistsAtURL(URL: NSURL) {
        var isDir: ObjCBool = false
        let exists = NSFileManager.defaultManager().fileExistsAtPath(URL.path!, isDirectory: &isDir)
        XCTAssertTrue(exists, "The file should exist")
        XCTAssertTrue(!isDir, "The file should not be a directory")
    }
}

class PluginsDataControllerTemporaryDirectoryTests: TemporaryDirectoryTestCase {
    
    func testCreateDirectoryIfMissing() {
        let directoryURL = temporaryDirectoryURL
            .URLByAppendingPathComponent(testDirectoryName)
            .URLByAppendingPathComponent(testDirectoryNameTwo)
        var error: NSError?
        let success = PluginsDataController.createDirectoryIfMissing(directoryURL, error: &error)
        XCTAssertNil(error, "The error should be nil")
        XCTAssertTrue(success, "The success should be true")
        var isDir: ObjCBool = false
        let exists = NSFileManager.defaultManager().fileExistsAtPath(directoryURL.path!, isDirectory: &isDir)
        XCTAssertTrue(exists, "The file should exist")
        XCTAssertTrue(isDir, "The file should be a directory")
        
        // Clean Up
        let rootDirectoryURL: NSURL! = directoryURL.URLByDeletingLastPathComponent
        removeTemporaryItemAtURL(rootDirectoryURL)
    }
    
    func testCreateDirectoryWithPathBlocked() {
        let directoryURL = temporaryDirectoryURL
            .URLByAppendingPathComponent(testDirectoryName)

        // Create the blocking file
        createFileWithConfirmationAtURL(directoryURL, contents: testFileContents)
        
        // Attempt
        var error: NSError?
        let success = PluginsDataController.createDirectoryIfMissing(directoryURL, error: &error)
        XCTAssertNotNil(error, "The error should not be nil")
        XCTAssertFalse(success, "The success should not be true")

        // Confirm the File Still Exists
        confirmFileExistsAtURL(directoryURL)
        
        // Confirm the Contents

        let contents = contentsOfFileAtURLWithConfirmation(directoryURL)
        XCTAssertEqual(testFileContents, contents, "The contents should be equal")
        
        // Clean Up
        removeTemporaryItemAtURL(directoryURL)
    }

    func testCreateDirectoryWithFirstPathComponentBlocked() {
        let directoryURL = temporaryDirectoryURL
            .URLByAppendingPathComponent(testDirectoryName)
            .URLByAppendingPathComponent(testDirectoryNameTwo)
        let blockingFileURL = directoryURL.URLByDeletingLastPathComponent!
        
        // Create the blocking file
        createFileWithConfirmationAtURL(blockingFileURL, contents: testFileContents)
        
        // Attempt
        var error: NSError?
        let success = PluginsDataController.createDirectoryIfMissing(directoryURL, error: &error)
        XCTAssertNotNil(error, "The error should not be nil")
        XCTAssertFalse(success, "The success should not be true")
        
        // Confirm the File Still Exists
        confirmFileExistsAtURL(blockingFileURL)
        
        // Confirm the Contents
        let contents = contentsOfFileAtURLWithConfirmation(blockingFileURL)
        XCTAssertEqual(testFileContents, contents, "The contents should be equal")
        
        // Clean Up
        removeTemporaryItemAtURL(blockingFileURL)
    }

    func testCreateDirectoryWithSecondPathComponentBlocked() {
        let directoryURL = temporaryDirectoryURL
            .URLByAppendingPathComponent(testDirectoryName)
            .URLByAppendingPathComponent(testDirectoryNameTwo)
        
        // Create the first path so creating the blocking file doesn't fail
        let containerDirectoryURL = directoryURL.URLByDeletingLastPathComponent!
        var error: NSError?
        let createContainerSuccess = PluginsDataController.createDirectoryIfMissing(containerDirectoryURL,
            error: &error)
        XCTAssertNil(error, "The error should be nil")
        XCTAssertTrue(createContainerSuccess, "The success should be true")
        
        // Create the blocking file
        createFileWithConfirmationAtURL(directoryURL, contents: testFileContents)
        
        // Attempt
        error = nil
        let success = PluginsDataController.createDirectoryIfMissing(directoryURL, error: &error)
        XCTAssertNotNil(error, "The error should not be nil")
        XCTAssertFalse(success, "The success should not be true")
        
        // Confirm the File Still Exists
        confirmFileExistsAtURL(directoryURL)
        
        // Confirm the Contents
        let contents = contentsOfFileAtURLWithConfirmation(directoryURL)
        XCTAssertEqual(testFileContents, contents, "The contents should be equal")
        
        // Clean Up
        removeTemporaryItemAtURL(containerDirectoryURL)
    }

}

class PluginsDataControllerTests: PluginsDataControllerEventTestCase {

    var duplicatePluginRootDirectoryURL: NSURL {
        return temporaryDirectoryURL
                .URLByAppendingPathComponent(testApplicationSupportDirectoryName)
    }
    
    override var duplicatePluginDestinationDirectoryURL: NSURL {
        return duplicatePluginRootDirectoryURL
            .URLByAppendingPathComponent(applicationName)
            .URLByAppendingPathComponent(pluginsDirectoryPathComponent)
    }

    func cleanUpDuplicatedPlugins() {
        removeTemporaryItemAtURL(duplicatePluginRootDirectoryURL)
    }
    
    func testDuplicateAndTrashPlugin() {
        XCTAssertEqual(PluginsManager.sharedInstance.pluginsDataController.plugins().count, 1, "The plugins count should be one")
        
        var newPlugin: Plugin!
        
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
        cleanUpDuplicatedPlugins()
    }

    func testDuplicatePluginWithBlockingFile() {
        var error: NSError?
        let createSuccess = NSFileManager.defaultManager().createFileAtPath(duplicatePluginRootDirectoryURL.path!,
            contents: nil,
            attributes: nil)
        XCTAssertTrue(createSuccess, "Creating the file should succeed.")
        XCTAssertNil(error, "The error should succeed.")
        
        var newPlugin: Plugin?
        let duplicateExpectation = expectationWithDescription("Plugin was duplicated")
        PluginsManager.sharedInstance.pluginsDataController.duplicatePlugin(plugin, handler: { (duplicatePlugin, error) -> Void in
            XCTAssertNil(duplicatePlugin, "The duplicate plugin should be nil")
            XCTAssertNotNil(error, "The error should not be nil")
            newPlugin = duplicatePlugin
            duplicateExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
        cleanUpDuplicatedPlugins()
    }

    func testDuplicatePluginWithEarlyBlockingFile() {
        var error: NSError?
        var createSuccess = PluginsDataController.createDirectoryIfMissing(duplicatePluginRootDirectoryURL.URLByDeletingLastPathComponent!, error: &error)
        XCTAssertTrue(createSuccess, "Creating the directory should succeed")
        XCTAssertNil(error, "The error should be nil")
        
        // Block the destination directory with a file
        error = nil
        createSuccess = NSFileManager.defaultManager().createFileAtPath(duplicatePluginRootDirectoryURL.path!,
            contents: nil,
            attributes: nil)
        XCTAssertTrue(createSuccess, "Creating the file should succeed.")
        XCTAssertNil(error, "The error should succeed.")
        
        var newPlugin: Plugin?
        let duplicateExpectation = expectationWithDescription("Plugin was duplicated")
        PluginsManager.sharedInstance.pluginsDataController.duplicatePlugin(plugin, handler: { (duplicatePlugin, error) -> Void in
            XCTAssertNil(duplicatePlugin, "The duplicate plugin should be nil")
            XCTAssertNotNil(error, "The error should not be nil")
            newPlugin = duplicatePlugin
            duplicateExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
        cleanUpDuplicatedPlugins()
    }

}