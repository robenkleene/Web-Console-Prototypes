//
//  PluginsDirectoryManagerPluginsTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 12/14/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

class PluginsDirectoryManagerPluginsTests: TemporaryPluginsTestCase {

    func testMovePlugin() {

        let pluginsDirectoryManager = PluginsDirectoryManager(pluginsDirectoryURL: temporaryPluginsDirectoryURL)
        let pluginsDirectoryManagerTestManager = PluginsDirectoryManagerTestManager()
        pluginsDirectoryManager.delegate = pluginsDirectoryManagerTestManager

        // Move the plugin
        let pluginPath = temporaryPlugin.bundle.bundlePath
        let newPluginFilename = temporaryPlugin.identifier
        let newPluginPath = pluginPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(newPluginFilename)

        let removeExpectation = expectationWithDescription("Info dictionary was removed")
        pluginsDirectoryManagerTestManager.addPluginInfoDictionaryWasRemovedAtPluginPathHandler({ (path) -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == pluginPath) {
                removeExpectation.fulfill()
            }
        })

        let createExpectation = expectationWithDescription("Info dictionary was created")
        pluginsDirectoryManagerTestManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler({ (path) -> Void in
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
        pluginsDirectoryManagerTestManager.addPluginInfoDictionaryWasRemovedAtPluginPathHandler({ (path) -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == newPluginPath) {
                removeExpectationTwo.fulfill()
            }
        })

        let createExpectationTwo = expectationWithDescription("Info dictionary was created again")
        pluginsDirectoryManagerTestManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler({ (path) -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == pluginPath) {
                createExpectationTwo.fulfill()
            }
        })
        SubprocessFileSystemModifier.moveItemAtPath(newPluginPath, toPath: pluginPath)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    
    // TODO: Disable this test until we have a method of handling rename events
    func testCopyAndRemovePlugin() {

        // Setup
        let pluginsDirectoryManager = PluginsDirectoryManager(pluginsDirectoryURL: temporaryPluginsDirectoryURL)
        let pluginsDirectoryManagerTestManager = PluginsDirectoryManagerTestManager()
        pluginsDirectoryManager.delegate = pluginsDirectoryManagerTestManager

        // Setup Copy
        let pluginPath = temporaryPlugin.bundle.bundlePath
        let newPluginFilename = temporaryPlugin.identifier
        let newPluginPath = pluginPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(newPluginFilename)
        let createExpectation = expectationWithDescription("Info dictionary was created one")
        pluginsDirectoryManagerTestManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler({ (path) -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == newPluginPath) {
                createExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.copyDirectoryAtPath(pluginPath, toPath: newPluginPath)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)

        
        // Clean up

        let removeExpectation = expectationWithDescription("Info dictionary was removed again")
        pluginsDirectoryManagerTestManager.addPluginInfoDictionaryWasRemovedAtPluginPathHandler({ (path) -> Void in
            pluginsDirectoryManager.delegate = nil // Ignore subsequent remove events
            if (self.dynamicType.resolveTemporaryDirectoryPath(path) == newPluginPath) {
                removeExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.removeDirectoryAtPath(newPluginPath)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    
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