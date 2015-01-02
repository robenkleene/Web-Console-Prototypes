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

extension PluginsDirectoryManagerTests {
    
    // MARK: Move Helpers
    
    func movePluginAtPathWithConfirmation(pluginPath: NSString, destinationPluginPath: NSString) {
        let removeExpectation = expectationWithDescription("Info dictionary was removed")
        pluginsDirectoryEventManager.addPluginInfoDictionaryWasRemovedAtPluginPathHandler({ (path) -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == pluginPath) {
                removeExpectation.fulfill()
            }
        })
        
        let createExpectation = expectationWithDescription("Info dictionary was created")
        pluginsDirectoryEventManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler({ (path) -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == destinationPluginPath) {
                createExpectation.fulfill()
            }
        })
        
        SubprocessFileSystemModifier.moveItemAtPath(pluginPath, toPath: destinationPluginPath)
        
        // Wait for expectations
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    

    // MARK: Copy Helpers
    
    func copyPluginAtPathWithConfirmation(pluginPath: NSString, destinationPluginPath: NSString) {
        let createExpectation = expectationWithDescription("Info dictionary was created or modified")
        pluginsDirectoryEventManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler({ (path) -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == destinationPluginPath) {
                createExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.copyDirectoryAtPath(pluginPath, toPath: destinationPluginPath)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }


    // MARK: Remove Helpers
    
    func removePluginAtPathWithConfirmation(pluginPath: NSString) {
        let removeExpectation = expectationWithDescription("Info dictionary was removed")
        pluginsDirectoryEventManager.addPluginInfoDictionaryWasRemovedAtPluginPathHandler({ (path) -> Void in
            self.pluginsDirectoryManager.delegate = nil // Ignore subsequent remove events
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == pluginPath) {
                removeExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.removeDirectoryAtPath(pluginPath)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
}

class PluginsDirectoryManagerTests: TemporaryPluginsTestCase {
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
        let movedPluginFilename = temporaryPlugin.identifier
        let movedPluginPath = pluginPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(movedPluginFilename)
        movePluginAtPathWithConfirmation(pluginPath, destinationPluginPath: movedPluginPath)
        
        // Clean up
        // Copy the plugin back to it's original path so the tearDown delete of the temporary plugin succeeds
        movePluginAtPathWithConfirmation(movedPluginPath, destinationPluginPath: pluginPath)
    }
    
    func testCopyAndRemovePlugin() {

        // Setup Copy
        let pluginPath = temporaryPlugin.bundle.bundlePath
        let copiedPluginFilename = temporaryPlugin.identifier
        let copiedPluginPath = pluginPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(copiedPluginFilename)
        copyPluginAtPathWithConfirmation(pluginPath, destinationPluginPath: copiedPluginPath)
        
        // Clean up
        removePluginAtPathWithConfirmation(copiedPluginPath)
    }

    // TODO: Test copy from an unwatched directory to the watched directory
    // TODO: Test copy from the watched directory to the unwatched directory
    
    // TODO: Test modifying the plist
    // TODO: Test deleting and re-adding the plist

    // TODO: Test multiple move events?
    // TODO: Test potential false positive directories?
    
    func testMoveInfoDictionary() {
        
        let infoDictionaryPath: NSString! = temporaryPlugin.infoDictionaryURL.path
        let infoDictionaryDirectory: NSString! = infoDictionaryPath.stringByDeletingLastPathComponent
        let renamedInfoDictionaryFilename = temporaryPlugin.identifier
        let renamedInfoDictionaryPath = infoDictionaryDirectory.stringByAppendingPathComponent(renamedInfoDictionaryFilename)
        
        // Move
        let pluginPath = temporaryPlugin.bundle.bundlePath
        let expectation = expectationWithDescription("Info dictionary was removed")
        pluginsDirectoryEventManager.addPluginInfoDictionaryWasRemovedAtPluginPathHandler({ (path) -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == pluginPath) {
                expectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.moveItemAtPath(infoDictionaryPath, toPath: renamedInfoDictionaryPath)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
        
        // Move back
        let expectationTwo = expectationWithDescription("Info dictionary was created or modified")
        pluginsDirectoryEventManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler({ (path) -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == pluginPath) {
                expectationTwo.fulfill()
            }
        })
        SubprocessFileSystemModifier.moveItemAtPath(renamedInfoDictionaryPath, toPath: infoDictionaryPath)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }

}