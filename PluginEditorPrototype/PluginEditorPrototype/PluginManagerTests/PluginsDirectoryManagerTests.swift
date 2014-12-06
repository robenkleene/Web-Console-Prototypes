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

class PluginsDirectoryManagerTestCase: TemporaryPluginTestCase {
    var pluginsDirectoryManager: PluginsDirectoryManager?
    var pluginsDirectoryManagerTestManager: PluginsDirectoryManagerTestManager?
    
    override func setUp() {
        super.setUp()
        if let temporaryDirectoryURL = temporaryDirectoryURL {
            pluginsDirectoryManager = PluginsDirectoryManager(pluginsDirectoryURL: temporaryDirectoryURL)
            pluginsDirectoryManagerTestManager = PluginsDirectoryManagerTestManager()
            pluginsDirectoryManager?.delegate = pluginsDirectoryManagerTestManager
        }
    }
    
    override func tearDown() {
        pluginsDirectoryManagerTestManager = nil
        pluginsDirectoryManager?.delegate = nil
        pluginsDirectoryManager = nil
        super.tearDown()
    }

    func createExpectationForPluginInfoDictionaryWasRemovedAtPluginPath(path: NSString) {
        let pluginInfoDictionaryWasRemovedExpectation = expectationWithDescription("Plugin info dictionary was removed")
        pluginsDirectoryManagerTestManager?.addPluginInfoDictionaryWasRemovedAtPluginPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == path) {
                pluginInfoDictionaryWasRemovedExpectation.fulfill()
            }
        })
    }


    func createExpectationForPluginInfoDictionaryWasCreatedOrModifiedAtPluginPath(path: NSString) {
        let pluginInfoDictionaryWasCreatedOrModifiedExpectation = expectationWithDescription("Plugin info dictionary was created or modified")
        pluginsDirectoryManagerTestManager?.addPluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == path) {
                pluginInfoDictionaryWasCreatedOrModifiedExpectation.fulfill()
            }
        })
    }
}

class PluginsDirectoryManagerFilesTests: PluginsDirectoryManagerTestCase {
    func testValidPluginFileHeirarchy() {
        if let pluginsDirectoryPath = temporaryDirectoryURL?.path {
            
            // Create a directory in the plugins directory, this should not cause a callback
            let testPluginDirectoryPath = pluginsDirectoryPath.stringByAppendingPathComponent(testDirectoryName)
            let createPluginDirectoryPathExpectation = expectationWithDescription("Create plugin directory")
            SubprocessFileSystemModifier.createDirectoryAtPath(testPluginDirectoryPath, handler: {
                createPluginDirectoryPathExpectation.fulfill()
            })
            waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
            
            // Create a file in the plugins directory, this should not cause a callback
            let testFilePath = pluginsDirectoryPath.stringByAppendingPathComponent(testFilename)
            let createFileExpectation = expectationWithDescription("Create file")
            SubprocessFileSystemModifier.createFileAtPath(testFilePath, handler: {
                createFileExpectation.fulfill()
            })
            waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
            
            // Create the contents directory, this should not cause a callback
            let testPluginContentsDirectoryPath = testPluginDirectoryPath.stringByAppendingPathComponent(testPluginContentsDirectoryName)
            let createPluginContentsDirectoryExpectation = expectationWithDescription("Create plugin contents directory")
            SubprocessFileSystemModifier.createDirectoryAtPath(testPluginContentsDirectoryPath, handler: {
                createPluginContentsDirectoryExpectation.fulfill()
            })
            waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
            
            // Create a file in the contents directory, this should not cause a callback
            let testPluginContentsFilePath = testPluginContentsDirectoryPath.stringByAppendingPathComponent(testFilename)
            let createPluginContentsFileExpectation = expectationWithDescription("Create plugin contents file")
            SubprocessFileSystemModifier.createFileAtPath(testPluginContentsFilePath, handler: {
                createPluginContentsFileExpectation.fulfill()
            })
            waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
            
            // Create the resource directory, this should not cause a callback
            let testPluginResourcesDirectoryPath = testPluginContentsDirectoryPath.stringByAppendingPathComponent(testPluginResourcesDirectoryName)
            let createPluginResourcesDirectoryExpectation = expectationWithDescription("Create plugin resources directory")
            SubprocessFileSystemModifier.createDirectoryAtPath(testPluginResourcesDirectoryPath, handler: {
                createPluginResourcesDirectoryExpectation.fulfill()
            })
            waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
            
            // Create a file in the resource directory, this should not cause a callback
            let testPluginResourcesFilePath = testPluginResourcesDirectoryPath.stringByAppendingPathComponent(testFilename)
            let createPluginResourcesFileExpectation = expectationWithDescription("Create plugin resources file")
            SubprocessFileSystemModifier.createFileAtPath(testPluginResourcesFilePath, handler: {
                createPluginResourcesFileExpectation.fulfill()
            })
            waitForExpectationsWithTimeout(defaultTimeout, handler: nil)


            // TODO: Create the info.plist in the contents directory, this should cause a callback
            // TODO: Create a directory at info.plist in the contents directory, this should not cause a callback
            // TODO: Create a file at the contents directory, this should not case a callback

            // TODO: Move the resources directory, this should not cause a callback
            // TODO: Move the contents directory, this should cause two callbacks


            // Clean up
            
            // Remove the file in the resource directory, this should not cause a callback
            let removePluginResourcesFileExpectation = expectationWithDescription("Remove plugin resources file")
            SubprocessFileSystemModifier.removeFileAtPath(testPluginResourcesFilePath, handler: {
                removePluginResourcesFileExpectation.fulfill()
            })
            waitForExpectationsWithTimeout(defaultTimeout, handler: nil)

            // Remove the resource directory, this should not cause a callback
            let removePluginResourcesDirectoryExpectation = expectationWithDescription("Remove plugin resources directory")
            SubprocessFileSystemModifier.removeDirectoryAtPath(testPluginResourcesDirectoryPath, handler: {
                removePluginResourcesDirectoryExpectation.fulfill()
            })
            waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
            
            // Remove the file in the contents directory, this should not cause a callback
            let removePluginContentsFileExpectation = expectationWithDescription("Remove plugin contents file")
            SubprocessFileSystemModifier.removeFileAtPath(testPluginContentsFilePath, handler: {
                removePluginContentsFileExpectation.fulfill()
            })
            waitForExpectationsWithTimeout(defaultTimeout, handler: nil)

            // Remove the contents directory, this should cause a callback
            // because this could be the delete after move of a valid plugin's contents directory
            createExpectationForPluginInfoDictionaryWasRemovedAtPluginPath(testPluginDirectoryPath)
            SubprocessFileSystemModifier.removeDirectoryAtPath(testPluginContentsDirectoryPath)
            waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
            
            // Remove the file in the plugins directory, this should not cause a callback
            let removeFileExpectation = expectationWithDescription("Remove file")
            SubprocessFileSystemModifier.removeFileAtPath(testFilePath, handler: {
                removeFileExpectation.fulfill()
            })
            waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
            
            // Remove the directory in the plugins directory, this should cause a callback
            // because this could be the delete after move of a valid plugin
            createExpectationForPluginInfoDictionaryWasRemovedAtPluginPath(testPluginDirectoryPath)
            SubprocessFileSystemModifier.removeDirectoryAtPath(testPluginDirectoryPath)
            waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
        }
    }

    func testInvalidPluginFileHeirarchy() {
        if let pluginsDirectoryPath = temporaryDirectoryURL?.path {
            // Create an invalid contents directory in the plugins path, this should not cause a callback
            let testInvalidPluginContentsDirectoryPath = pluginsDirectoryPath.stringByAppendingPathComponent(testPluginContentsDirectoryName)
            let createInvalidPluginContentsDirectoryExpectation = expectationWithDescription("Create plugin contents directory")
            SubprocessFileSystemModifier.createDirectoryAtPath(testInvalidPluginContentsDirectoryPath, handler: {
                createInvalidPluginContentsDirectoryExpectation.fulfill()
            })
            waitForExpectationsWithTimeout(defaultTimeout, handler: nil)

            // Create a info dictionary in the invalid contents directory, this should not cause a callback
            let testInvalidInfoDictionaryPath = testInvalidPluginContentsDirectoryPath.stringByAppendingPathComponent(testPluginInfoDictionaryFilename)
            let createInvalidInfoDictionaryExpectation = expectationWithDescription("Create invalid info dictionary")
            SubprocessFileSystemModifier.createFileAtPath(testInvalidInfoDictionaryPath, handler: {
                createInvalidInfoDictionaryExpectation.fulfill()
            })
            waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
            

            // Clean Up
            
            // Remove the info dictionary in the invalid contents directory, this should not cause a callback
            let removeInvalidInfoDictionaryExpectation = expectationWithDescription("Remove invalid info dictionary")
            SubprocessFileSystemModifier.removeFileAtPath(testInvalidInfoDictionaryPath, handler: {
                removeInvalidInfoDictionaryExpectation.fulfill()
            })
            waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
            
            // Remove the invalid contents directory in the plugins path, this should cause a callback
            // because this could be the delete after move of a valid plugin
            createExpectationForPluginInfoDictionaryWasRemovedAtPluginPath(testInvalidPluginContentsDirectoryPath)
            SubprocessFileSystemModifier.removeDirectoryAtPath(testInvalidPluginContentsDirectoryPath)
            waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
        }
    }
}

class PluginsDirectoryManagerPluginsTests: TemporaryPluginTestCase {

    // TODO: Puth this back when directory modified events are handled correctly
//    func testMovePlugin() {
//        if let temporaryDirectoryURL = temporaryDirectoryURL {
//            if let temporaryPlugin = temporaryPlugin {
//                let pluginsDirectoryManager = PluginsDirectoryManager(pluginsDirectoryURL: temporaryDirectoryURL)
//                let pluginsDirectoryManagerTestManager = PluginsDirectoryManagerTestManager()
//                pluginsDirectoryManager.delegate = pluginsDirectoryManagerTestManager
//                
//                // Move the plugin
//                let pluginPath = temporaryPlugin.bundle.bundlePath
//                let newPluginFilename = temporaryPlugin.identifier
//                let newPluginPath = pluginPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(newPluginFilename)
//
//                let removeExpectation = expectationWithDescription("Info dictionary was removed")
//                pluginsDirectoryManagerTestManager.addPluginInfoDictionoaryWasRemovedAtPluginPathHandler({ (path) -> Void in
//                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) == pluginPath) {
//                        removeExpectation.fulfill()
//                    }
//                })
//                
//                let createExpectation = expectationWithDescription("Info dictionary was created")
//                pluginsDirectoryManagerTestManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler({ (path) -> Void in
//                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) == newPluginPath) {
//                        createExpectation.fulfill()
//                    }
//                })
//                
//                SubprocessFileSystemModifier.moveItemAtPath(pluginPath, toPath: newPluginPath)
//
//                // Wait for expectations
//                waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
//
//                // Clean up
//                // Copy the plugin back to it's original path so the tearDown delete of the temporary plugin succeeds
//                let removeExpectationTwo = expectationWithDescription("Info dictionary was removed again")
//                pluginsDirectoryManagerTestManager.addPluginInfoDictionoaryWasRemovedAtPluginPathHandler({ (path) -> Void in
//                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) == newPluginPath) {
//                        removeExpectationTwo.fulfill()
//                    }
//                })
//                
//                    let createExpectationTwo = expectationWithDescription("Info dictionary was created again")
//                pluginsDirectoryManagerTestManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler({ (path) -> Void in
//                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) == pluginPath) {
//                        createExpectationTwo.fulfill()
//                    }
//                })
//                SubprocessFileSystemModifier.moveItemAtPath(newPluginPath, toPath: pluginPath)
//                waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
//            }
//        }
//    }

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
//                pluginsDirectoryManagerTestManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler({ (path) -> Void in
//                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) == newPluginPath) {
//                        createExpectationOne.fulfill()
//                    }
//                })
//
//                let createExpectationTwo = expectationWithDescription("Info dictionary was created two")
//                pluginsDirectoryManagerTestManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler({ (path) -> Void in
//                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) == newPluginPath) {
//                        createExpectationTwo.fulfill()
//                    }
//                })
//
//                let createExpectationThree = expectationWithDescription("Info dictionary was created three")
//                pluginsDirectoryManagerTestManager.addPluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler({ (path) -> Void in
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
//                pluginsDirectoryManagerTestManager.addPluginInfoDictionoaryWasRemovedAtPluginPathHandler({ (path) -> Void in
//                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) == newPluginPath) {
//                        removeExpectationOne.fulfill()
//                    }
//                })
//                let removeExpectationTwo = expectationWithDescription("Info dictionary was removed again")
//                pluginsDirectoryManagerTestManager.addPluginInfoDictionoaryWasRemovedAtPluginPathHandler({ (path) -> Void in
//                    if (self.dynamicType.resolveTemporaryDirectoryPath(path) == newPluginPath) {
//                        removeExpectationTwo.fulfill()
//                    }
//                })
//                let removeExpectationThree = expectationWithDescription("Info dictionary was removed again")
//                pluginsDirectoryManagerTestManager.addPluginInfoDictionoaryWasRemovedAtPluginPathHandler({ (path) -> Void in
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

    // TODO: Gets notified moving the file
    // TODO: Gets notified modifying the plist
}