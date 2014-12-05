//
//  PluginsDirectoryManagerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/8/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation
import XCTest

class PluginsDirectoryManagerTestManager: PluginsDirectoryManagerDelegate {
    var pluginInfoDictionaryWasCreatedOrModifiedAtPathHandlers: Array<(path: NSString) -> Void>
    var pluginInfoDictionaryWasRemovedAtPathHandlers: Array<(path: NSString) -> Void>
    init () {
        self.pluginInfoDictionaryWasCreatedOrModifiedAtPathHandlers = Array<(path: NSString) -> Void>()
        self.pluginInfoDictionaryWasRemovedAtPathHandlers = Array<(path: NSString) -> Void>()
    }

    func pluginsDirectoryManager(pluginsDirectoryManager: PluginsDirectoryManager, pluginInfoDictionaryWasCreatedOrModifiedAtPath path: NSString) {
        assert(pluginInfoDictionaryWasCreatedOrModifiedAtPathHandlers.count > 0, "There should be at least one handler")
        
        if (pluginInfoDictionaryWasCreatedOrModifiedAtPathHandlers.count > 0) {
            let handler = pluginInfoDictionaryWasCreatedOrModifiedAtPathHandlers.removeAtIndex(0)
            handler(path: path)
        }

    }

    func pluginsDirectoryManager(pluginsDirectoryManager: PluginsDirectoryManager, pluginInfoDictionaryWasRemovedAtPath path: NSString) {
        assert(pluginInfoDictionaryWasRemovedAtPathHandlers.count > 0, "There should be at least one handler")
        
        if (pluginInfoDictionaryWasRemovedAtPathHandlers.count > 0) {
            let handler = pluginInfoDictionaryWasRemovedAtPathHandlers.removeAtIndex(0)
            handler(path: path)
        }
    }

    func addPluginInfoDictionaryWasCreatedOrModifiedAtPathHandler(handler: ((path: NSString) -> Void)) {
        pluginInfoDictionaryWasCreatedOrModifiedAtPathHandlers.append(handler)
    }
    
    func addPluginInfoDictionoaryWasRemovedAtPathHandler(handler: ((path: NSString) -> Void)) {
        pluginInfoDictionaryWasRemovedAtPathHandlers.append(handler)
    }
}


class PluginsDirectoryManagerTestCase: TemporaryPluginTestCase {

    func testMovePlugin() {
        if let temporaryDirectoryURL = temporaryDirectoryURL {
            if let temporaryPlugin = temporaryPlugin {
                let pluginsDirectoryManager = PluginsDirectoryManager(pluginsDirectoryURL: temporaryDirectoryURL)
                let pluginsDirectoryManagerTestManager = PluginsDirectoryManagerTestManager()
                pluginsDirectoryManager.delegate = pluginsDirectoryManagerTestManager
                
                // Move the plugin
                let pluginPath = temporaryPlugin.bundle.bundlePath
                let newPluginFilename = temporaryPlugin.identifier
                let newPluginPath = pluginPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(newPluginFilename)

                let removeExpectation = expectationWithDescription("Info dictionary was removed")
                pluginsDirectoryManagerTestManager.addPluginInfoDictionoaryWasRemovedAtPathHandler({ (path) -> Void in
                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) == pluginPath) {
                        removeExpectation.fulfill()
                    }
                })
                
                let createExpectation = expectationWithDescription("Info dictionary was created")
                pluginsDirectoryManagerTestManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPathHandler({ (path) -> Void in
                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) == newPluginPath) {
                        createExpectation.fulfill()
                    }
                })
                
                SubprocessFileSystemModifier.moveFileAtPath(pluginPath, toPath: newPluginPath)

                // Wait for expectations
                waitForExpectationsWithTimeout(defaultTimeout, handler: nil)

                // Clean up
                // Copy the plugin back to it's original path so the tearDown delete of the temporary plugin succeeds
                let removeExpectationTwo = expectationWithDescription("Info dictionary was removed again")
                pluginsDirectoryManagerTestManager.addPluginInfoDictionoaryWasRemovedAtPathHandler({ (path) -> Void in
                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) == newPluginPath) {
                        removeExpectationTwo.fulfill()
                    }
                })
                
                    let createExpectationTwo = expectationWithDescription("Info dictionary was created again")
                pluginsDirectoryManagerTestManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPathHandler({ (path) -> Void in
                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) == pluginPath) {
                        createExpectationTwo.fulfill()
                    }
                })
                SubprocessFileSystemModifier.moveFileAtPath(newPluginPath, toPath: pluginPath)
                waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
            }
        }
    }

    // TODO: Disable this test until we have a method of handling rename events
//    func testCopyAndRemovePlugin() {
//        if let temporaryDirectoryURL = temporaryDirectoryURL {
//            if let temporaryPlugin = temporaryPlugin {
//                let pluginsDirectoryManager = PluginsDirectoryManager(pluginsDirectoryURL: temporaryDirectoryURL)
//                let pluginsDirectoryManagerTestManager = PluginsDirectoryManagerTestManager()
//                pluginsDirectoryManager.delegate = pluginsDirectoryManagerTestManager
//                
//                // Copy the plugin
//                let pluginPath = temporaryPlugin.bundle.bundlePath
//                let newPluginFilename = temporaryPlugin.identifier
//                let newPluginPath = pluginPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(newPluginFilename)
//
//                
//                // Create expectations
//                // 1. For the info.plist
//                // 2. For the contents directory
//                // 3. For the plugin directory
//                let createExpectationOne = expectationWithDescription("Info dictionary was created one")
//                pluginsDirectoryManagerTestManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPathHandler({ (path) -> Void in
//                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) == newPluginPath) {
//                        createExpectationOne.fulfill()
//                    }
//                })
//
//                let createExpectationTwo = expectationWithDescription("Info dictionary was created two")
//                pluginsDirectoryManagerTestManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPathHandler({ (path) -> Void in
//                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) == newPluginPath) {
//                        createExpectationTwo.fulfill()
//                    }
//                })
//
//                let createExpectationThree = expectationWithDescription("Info dictionary was created three")
//                pluginsDirectoryManagerTestManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPathHandler({ (path) -> Void in
//                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) == newPluginPath) {
//                        createExpectationThree.fulfill()
//                    }
//                })
//
//                SubprocessFileSystemModifier.copyFileAtPath(pluginPath, toPath: newPluginPath)
//                
//                // Wait for expectations
//                waitForExpectationsWithTimeout(0.5, handler: nil)
//                
//                // Clean up
//
//                // Remove expectations
//                // 1. For the info.plist
//                // 2. For the contents directory
//                // 3. For the plugin directory
//                let removeExpectationOne = expectationWithDescription("Info dictionary was removed again")
//                pluginsDirectoryManagerTestManager.addPluginInfoDictionoaryWasRemovedAtPathHandler({ (path) -> Void in
//                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) == newPluginPath) {
//                        removeExpectationOne.fulfill()
//                    }
//                })
//                let removeExpectationTwo = expectationWithDescription("Info dictionary was removed again")
//                pluginsDirectoryManagerTestManager.addPluginInfoDictionoaryWasRemovedAtPathHandler({ (path) -> Void in
//                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) == newPluginPath) {
//                        removeExpectationTwo.fulfill()
//                    }
//                })
//                let removeExpectationThree = expectationWithDescription("Info dictionary was removed again")
//                pluginsDirectoryManagerTestManager.addPluginInfoDictionoaryWasRemovedAtPathHandler({ (path) -> Void in
//                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) == newPluginPath) {
//                        removeExpectationThree.fulfill()
//                    }
//                })
//                SubprocessFileSystemModifier.removeDirectoryAtPath(newPluginPath)
//                waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
//            }
//        }
//    }

    // TODO: Test multiple move events?
    // TODO: Test potential false positive directories
    
    func testMoveInfoDictionaryPath() {
        if let temporaryDirectoryURL = temporaryDirectoryURL {
            if let temporaryPlugin = temporaryPlugin {
                let pluginsDirectoryManager = PluginsDirectoryManager(pluginsDirectoryURL: temporaryDirectoryURL)
                
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
            }
        }
    }

    // TODO: Gets notified moving the file
    // TODO: Gets notified modifying the plist
}