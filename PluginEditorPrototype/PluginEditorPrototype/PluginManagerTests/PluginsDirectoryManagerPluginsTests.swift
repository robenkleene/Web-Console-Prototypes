//
//  PluginsDirectoryManagerPluginsTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 12/14/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginsDirectoryEventManager: PluginsDirectoryManagerDelegate {
    var pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandlers: Array<(path: NSString) -> Void>
    var pluginInfoDictionaryWasRemovedAtPluginPathHandlers: Array<(path: NSString) -> Void>
    
    
    init () {
        self.pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandlers = Array<(path: NSString) -> Void>()
        self.pluginInfoDictionaryWasRemovedAtPluginPathHandlers = Array<(path: NSString) -> Void>()
    }
    
    func pluginsDirectoryManager(pluginsDirectoryManager: PluginsDirectoryManager, pluginInfoDictionaryWasCreatedOrModifiedAtPluginPath path: NSString) {
        assert(pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandlers.count > 0, "There should be at least one handler")
        
        if (pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandlers.count > 0) {
            let handler = pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandlers.removeAtIndex(0)
            handler(path: path)
        }
    }
    
    func pluginsDirectoryManager(pluginsDirectoryManager: PluginsDirectoryManager, pluginInfoDictionaryWasRemovedAtPluginPath path: NSString) {
        assert(pluginInfoDictionaryWasRemovedAtPluginPathHandlers.count > 0, "There should be at least one handler")
        
        if (pluginInfoDictionaryWasRemovedAtPluginPathHandlers.count > 0) {
            let handler = pluginInfoDictionaryWasRemovedAtPluginPathHandlers.removeAtIndex(0)
            handler(path: path)
        }
    }
    
    
    func addPluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler(handler: (path: NSString) -> Void) {
        pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandlers.append(handler)
    }
    
    func addPluginInfoDictionaryWasRemovedAtPluginPathHandler(handler: (path: NSString) -> Void) {
        pluginInfoDictionaryWasRemovedAtPluginPathHandlers.append(handler)
    }
    
}

class PluginsDirectoryManagerPluginsTests: TemporaryPluginsTestCase {

    var pluginsDirectoryManager: PluginsDirectoryManager!
    var pluginsDirectoryEventManager: PluginsDirectoryEventManager!
    
    override func setUp() {
        super.setUp()
        pluginsDirectoryManager = PluginsDirectoryManager(pluginsDirectoryURL: temporaryPluginsDirectoryURL)
        pluginsDirectoryEventManager = PluginsDirectoryEventManager()
        pluginsDirectoryManager.delegate = pluginsDirectoryEventManager
    }
    
    override func tearDown() {
        pluginsDirectoryManager.delegate = nil
        pluginsDirectoryEventManager = nil
        pluginsDirectoryManager = nil // Make sure this happens after setting its delegate to nil
        super.tearDown()
    }

    
    func testMovePlugin() {

        // Move the plugin
        let pluginPath = temporaryPlugin.bundle.bundlePath
        let newPluginFilename = temporaryPlugin.identifier
        let newPluginPath = pluginPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(newPluginFilename)

        let removeExpectation = expectationWithDescription("Info dictionary was removed")
        pluginsDirectoryEventManager.addPluginInfoDictionaryWasRemovedAtPluginPathHandler({ (path) -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == pluginPath) {
                removeExpectation.fulfill()
            }
        })

        let createExpectation = expectationWithDescription("Info dictionary was created")
        pluginsDirectoryEventManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler({ (path) -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == newPluginPath) {
                createExpectation.fulfill()
            }
        })

        SubprocessFileSystemModifier.moveItemAtPath(pluginPath, toPath: newPluginPath)

        // Wait for expectations
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)

        // Clean up
        // Copy the plugin back to it's original path so the tearDown delete of the temporary plugin succeeds
        let removeExpectationTwo = expectationWithDescription("Info dictionary was removed again")
        pluginsDirectoryEventManager.addPluginInfoDictionaryWasRemovedAtPluginPathHandler({ (path) -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == newPluginPath) {
                removeExpectationTwo.fulfill()
            }
        })

        let createExpectationTwo = expectationWithDescription("Info dictionary was created again")
        pluginsDirectoryEventManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler({ (path) -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == pluginPath) {
                createExpectationTwo.fulfill()
            }
        })
        SubprocessFileSystemModifier.moveItemAtPath(newPluginPath, toPath: pluginPath)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    
    // TODO: Disable this test until we have a method of handling rename events
    func testCopyAndRemovePlugin() {

        // Setup Copy
        let pluginPath = temporaryPlugin.bundle.bundlePath
        let newPluginFilename = temporaryPlugin.identifier
        let newPluginPath = pluginPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(newPluginFilename)
        let createExpectation = expectationWithDescription("Info dictionary was created one")
        pluginsDirectoryEventManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler({ (path) -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == newPluginPath) {
                createExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.copyDirectoryAtPath(pluginPath, toPath: newPluginPath)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)

        
        // Clean up

        let removeExpectation = expectationWithDescription("Info dictionary was removed again")
        pluginsDirectoryEventManager.addPluginInfoDictionaryWasRemovedAtPluginPathHandler({ (path) -> Void in
            self.pluginsDirectoryManager.delegate = nil // Ignore subsequent remove events
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == newPluginPath) {
                removeExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.removeDirectoryAtPath(newPluginPath)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }

    
    // TODO: Refactor hierarchy creators to take a path
    // TODO: Test copy plugin
    // TODO: Test copy from an unwatched directory to the watched directory
    // TODO: Test copy from the watched directory to the unwatched directory

    // TODO: Test multiple move events?
    // TODO: Test potential false positive directories
    
    //    func testMoveInfoDictionaryPath() {
    //        if let temporaryDirectoryURL = temporaryDirectoryURL {
    //            if let temporaryPlugin = temporaryPlugin {
    //                let pluginsDirectoryManager = PluginsDirectoryManager(pluginsDirectoryURL: temporaryDirectoryURL)
    
    //                let expectation = expectationWithDescription("Plugins Directory Event")
    
    // Move the plist
    //                var error: NSError?
    //                let oldInfoDictionaryURL = temporaryPlugin.infoDictionaryURL
    //                let newInfoDictionaryFilename = temporaryPlugin.identifier
    //                renameItemAtURL(oldInfoDictionaryURL, toName: newInfoDictionaryFilename)
    
    
    // TODO: Move it again
    
    //                waitForExpectationsWithTimeout(defaultTimeout, handler: { error in
    //                    println("Expectation")
    //                })
    //            }
    //        }
    //    }
    
    // TODO: Test moving into and from unwatched directories
    // TODO: Gets notified moving the file
    // TODO: Gets notified modifying the plist
}