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
    

    // MARK: PluginsDirectoryManagerDelegate
    
    func pluginsDirectoryManager(pluginsDirectoryManager: PluginsDirectoryManager, pluginInfoDictionaryWasCreatedOrModifiedAtPluginPath pluginPath: NSString) {
        assert(pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandlers.count > 0, "There should be at least one handler")
        
        if (pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandlers.count > 0) {
            let handler = pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandlers.removeAtIndex(0)
            handler(path: pluginPath)
        }
    }
    
    func pluginsDirectoryManager(pluginsDirectoryManager: PluginsDirectoryManager, pluginInfoDictionaryWasRemovedAtPluginPath pluginPath: NSString) {
        assert(pluginInfoDictionaryWasRemovedAtPluginPathHandlers.count > 0, "There should be at least one handler")
        
        if (pluginInfoDictionaryWasRemovedAtPluginPathHandlers.count > 0) {
            let handler = pluginInfoDictionaryWasRemovedAtPluginPathHandlers.removeAtIndex(0)
            handler(path: pluginPath)
        }
    }
    
    
    // MARK: Handlers
    
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

    func movePluginAtPathWithConfirmation(pluginPath: NSString, toUnwatchedDestinationPluginPath destinationPluginPath: NSString) {
        let removeExpectation = expectationWithDescription("Info dictionary was removed")
        pluginsDirectoryEventManager.addPluginInfoDictionaryWasRemovedAtPluginPathHandler({ (path) -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == pluginPath) {
                removeExpectation.fulfill()
            }
        })
        
        let moveExpectation = expectationWithDescription("Move finished")
        SubprocessFileSystemModifier.moveItemAtPath(pluginPath, toPath: destinationPluginPath, handler: {
            moveExpectation.fulfill()
        })
        
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
    func copyPluginAtPath(pluginPath: NSString, destinationPluginPath: NSString) {
        let copyExpectation = expectationWithDescription("Copy finished")
        SubprocessFileSystemModifier.copyDirectoryAtPath(pluginPath, toPath: destinationPluginPath, handler: {
            copyExpectation.fulfill()
        })
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
    var pluginInfoDictionaryPath: NSString!
    
    override func setUp() {
        super.setUp()
        pluginsDirectoryManager = PluginsDirectoryManager(pluginsDirectoryURL: pluginsDirectoryURL)
        pluginsDirectoryEventManager = PluginsDirectoryEventManager()
        pluginsDirectoryManager.delegate = pluginsDirectoryEventManager
        pluginInfoDictionaryPath = Plugin.infoDictionaryURLForPluginURL(pluginURL).path!
    }
    
    override func tearDown() {
        pluginsDirectoryManager.delegate = nil
        pluginsDirectoryEventManager = nil
        pluginsDirectoryManager = nil // Make sure this happens after setting its delegate to nil
        pluginInfoDictionaryPath = nil
        super.tearDown()
    }
    

    // MARK: Plugin Directory Tests
    
    func testMovePlugin() {
        // Move the plugin
        let movedPluginFilename = testPluginDirectoryName
        let movedPluginPath = pluginPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(movedPluginFilename)
        movePluginAtPathWithConfirmation(pluginPath, destinationPluginPath: movedPluginPath)
        
        // Clean up
        // Copy the plugin back to it's original path so the tearDown delete of the temporary plugin succeeds
        movePluginAtPathWithConfirmation(movedPluginPath, destinationPluginPath: pluginPath)
    }
    
    func testCopyAndRemovePlugin() {
        let copiedPluginFilename = testPluginDirectoryName
        let copiedPluginPath = pluginPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(copiedPluginFilename)
        copyPluginAtPathWithConfirmation(pluginPath, destinationPluginPath: copiedPluginPath)
        
        // Clean up
        removePluginAtPathWithConfirmation(copiedPluginPath)
    }

    func testCopyToUnwatchedDirectory() {
        let pluginFilename = pluginPath.lastPathComponent
        let copiedPluginPath = temporaryDirectoryPath.stringByAppendingPathComponent(pluginFilename)
        copyPluginAtPath(pluginPath, destinationPluginPath: copiedPluginPath)
        removeTemporaryItemAtPath(copiedPluginPath)
    }
    
    func testCopyFromUnwatchedDirectory() {
        // Move the plugin to unwatched directory
        let pluginFilename = pluginPath.lastPathComponent
        let movedPluginPath = temporaryDirectoryPath.stringByAppendingPathComponent(pluginFilename)
        movePluginAtPathWithConfirmation(pluginPath, toUnwatchedDestinationPluginPath: movedPluginPath)

        // Copy back to original location
        copyPluginAtPathWithConfirmation(movedPluginPath, destinationPluginPath: pluginPath)

        // Cleanup
        removeTemporaryItemAtPath(movedPluginPath)
    }
    
    
    // MARK: Info Dictionary Tests
    
    func testMoveInfoDictionary() {

        let infoDictionaryDirectory: NSString! = pluginInfoDictionaryPath.stringByDeletingLastPathComponent
        let renamedInfoDictionaryFilename = testDirectoryName
        let renamedInfoDictionaryPath = infoDictionaryDirectory.stringByAppendingPathComponent(renamedInfoDictionaryFilename)
        
        // Move
        let expectation = expectationWithDescription("Info dictionary was removed")
        pluginsDirectoryEventManager.addPluginInfoDictionaryWasRemovedAtPluginPathHandler({ (path) -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == self.pluginPath) {
                expectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.moveItemAtPath(pluginInfoDictionaryPath, toPath: renamedInfoDictionaryPath)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
        
        // Move back
        let expectationTwo = expectationWithDescription("Info dictionary was created or modified")
        pluginsDirectoryEventManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler({ (path) -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == self.pluginPath) {
                expectationTwo.fulfill()
            }
        })
        SubprocessFileSystemModifier.moveItemAtPath(renamedInfoDictionaryPath, toPath: pluginInfoDictionaryPath)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    
    func testRemoveAndAddInfoDictionary() {
        // Read in the contents of the info dictionary
        var error: NSError?
        let infoDictionaryContents: NSString! = NSString(contentsOfFile: pluginInfoDictionaryPath, encoding: NSUTF8StringEncoding, error: &error)
        XCTAssertNil(error, "The error should be nil.")
        
        // Remove the info dictionary
        let expectation = expectationWithDescription("Info dictionary was removed")
        pluginsDirectoryEventManager.addPluginInfoDictionaryWasRemovedAtPluginPathHandler({ (path) -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == self.pluginPath) {
                expectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.removeFileAtPath(pluginInfoDictionaryPath)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)

        // Add back the info dictionary
        let expectationTwo = expectationWithDescription("Info dictionary was created or modified")
        pluginsDirectoryEventManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler({ (path) -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == self.pluginPath) {
                expectationTwo.fulfill()
            }
        })
        SubprocessFileSystemModifier.writeToFileAtPath(pluginInfoDictionaryPath, contents: infoDictionaryContents)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }

    func testModifyInfoDictionary() {
        // Read in the contents of the info dictionary
        var error: NSError?
        let infoDictionaryContents: NSString! = NSString(contentsOfFile: pluginInfoDictionaryPath, encoding: NSUTF8StringEncoding, error: &error)
        XCTAssertNil(error, "The error should be nil.")
        
        // Remove the info dictionary
        let expectation = expectationWithDescription("Info dictionary was created or modified")
        pluginsDirectoryEventManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler({ (path) -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == self.pluginPath) {
                expectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.writeToFileAtPath(pluginInfoDictionaryPath, contents: testFileContents)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
        
        // Remove the info dictionary
        let expectationTwo = expectationWithDescription("Info dictionary was created or modified")
        pluginsDirectoryEventManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler({ (path) -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == self.pluginPath) {
                expectationTwo.fulfill()
            }
        })
        SubprocessFileSystemModifier.writeToFileAtPath(pluginInfoDictionaryPath, contents: infoDictionaryContents)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
}