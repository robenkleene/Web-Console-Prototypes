//
//  PluginsDirectoryManagerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/8/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation
import XCTest

@objc protocol TestPluginsDirectoryManagerDelegate: PluginsDirectoryManagerDelegate {
    optional func testPluginsDirectoryManager(testPluginsDirectoryManager: TestPluginsDirectoryManager, directoryWasCreatedOrModifiedAtPath path: NSString)
    optional func testPluginsDirectoryManager(testPluginsDirectoryManager: TestPluginsDirectoryManager, fileWasCreatedOrModifiedAtPath path: NSString)
    optional func testPluginsDirectoryManager(testPluginsDirectoryManager: TestPluginsDirectoryManager, itemWasRemovedAtPath path: NSString)
}

class TestPluginsDirectoryManager: PluginsDirectoryManager {
    var fileDelegate: TestPluginsDirectoryManagerDelegate?
    override var delegate: PluginsDirectoryManagerDelegate? {
        get {
            return fileDelegate
        }
        set {
            if newValue is TestPluginsDirectoryManagerDelegate {
                fileDelegate = newValue as? TestPluginsDirectoryManagerDelegate
            }
        }
    }
    
    override func directoryWatcher(directoryWatcher: WCLDirectoryWatcher!, directoryWasCreatedOrModifiedAtPath path: String!) {
        fileDelegate?.testPluginsDirectoryManager?(self, directoryWasCreatedOrModifiedAtPath: path)
        super.directoryWatcher(directoryWatcher, directoryWasCreatedOrModifiedAtPath: path)
    }
    
    override func directoryWatcher(directoryWatcher: WCLDirectoryWatcher!, fileWasCreatedOrModifiedAtPath path: String!) {
        fileDelegate?.testPluginsDirectoryManager?(self, fileWasCreatedOrModifiedAtPath: path)
        super.directoryWatcher(directoryWatcher, fileWasCreatedOrModifiedAtPath: path)
    }
    
    override func directoryWatcher(directoryWatcher: WCLDirectoryWatcher!, itemWasRemovedAtPath path: String!) {
        fileDelegate?.testPluginsDirectoryManager?(self, itemWasRemovedAtPath: path)
        super.directoryWatcher(directoryWatcher, itemWasRemovedAtPath: path)
    }
}

class PluginsDirectoryManagerTestManager: TestPluginsDirectoryManagerDelegate {
    var pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandlers: Array<(path: NSString) -> Void>
    var pluginInfoDictionaryWasRemovedAtPluginPathHandlers: Array<(path: NSString) -> Void>

    var fileWasCreatedOrModifiedAtPathHandlers: Array<(path: NSString) -> Void>
    var directoryWasCreatedOrModifiedAtPathHandlers: Array<(path: NSString) -> Void>
    var itemWasRemovedAtPathHandlers: Array<(path: NSString) -> Void>
    
    init () {
        self.pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandlers = Array<(path: NSString) -> Void>()
        self.pluginInfoDictionaryWasRemovedAtPluginPathHandlers = Array<(path: NSString) -> Void>()
        self.fileWasCreatedOrModifiedAtPathHandlers = Array<(path: NSString) -> Void>()
        self.directoryWasCreatedOrModifiedAtPathHandlers = Array<(path: NSString) -> Void>()
        self.itemWasRemovedAtPathHandlers = Array<(path: NSString) -> Void>()
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
    
    func testPluginsDirectoryManager(testPluginsDirectoryManager: TestPluginsDirectoryManager, fileWasCreatedOrModifiedAtPath path: NSString) {
        assert(fileWasCreatedOrModifiedAtPathHandlers.count > 0, "There should be at least one handler")
        
        if (fileWasCreatedOrModifiedAtPathHandlers.count > 0) {
            let handler = fileWasCreatedOrModifiedAtPathHandlers.removeAtIndex(0)
            handler(path: path)
        }
    }
    
    func testPluginsDirectoryManager(testPluginsDirectoryManager: TestPluginsDirectoryManager, directoryWasCreatedOrModifiedAtPath path: NSString) {
        assert(directoryWasCreatedOrModifiedAtPathHandlers.count > 0, "There should be at least one handler")
        
        if (directoryWasCreatedOrModifiedAtPathHandlers.count > 0) {
            let handler = directoryWasCreatedOrModifiedAtPathHandlers.removeAtIndex(0)
            handler(path: path)
        }
    }
    
    func testPluginsDirectoryManager(testPluginsDirectoryManager: TestPluginsDirectoryManager, itemWasRemovedAtPath path: NSString) {
        assert(itemWasRemovedAtPathHandlers.count > 0, "There should be at least one handler")
        
        if (itemWasRemovedAtPathHandlers.count > 0) {
            let handler = itemWasRemovedAtPathHandlers.removeAtIndex(0)
            handler(path: path)
        }
    }

    func addPluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler(handler: (path: NSString) -> Void) {
        pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandlers.append(handler)
    }
    
    func addPluginInfoDictionaryWasRemovedAtPluginPathHandler(handler: (path: NSString) -> Void) {
        pluginInfoDictionaryWasRemovedAtPluginPathHandlers.append(handler)
    }

    func addFileWasCreatedOrModifiedAtPathHandler(handler: (path: NSString) -> Void) {
        fileWasCreatedOrModifiedAtPathHandlers.append(handler)
    }

    func addDirectoryWasCreatedOrModifiedAtPathHandler(handler: (path: NSString) -> Void) {
        directoryWasCreatedOrModifiedAtPathHandlers.append(handler)
    }

    func addItemWasRemovedAtPathHandler(handler: (path: NSString) -> Void) {
        itemWasRemovedAtPathHandlers.append(handler)
    }
}

class PluginsDirectoryManagerTestCase: TemporaryPluginTestCase {
    var pluginsDirectoryManager: TestPluginsDirectoryManager?
    var pluginsDirectoryManagerTestManager: PluginsDirectoryManagerTestManager?
    var pluginsDirectoryPath: NSString?
    
    override func setUp() {
        super.setUp()
        if let temporaryDirectoryURL = temporaryDirectoryURL {
            pluginsDirectoryPath = temporaryDirectoryURL.path
            pluginsDirectoryManager = TestPluginsDirectoryManager(pluginsDirectoryURL: temporaryDirectoryURL)
            pluginsDirectoryManagerTestManager = PluginsDirectoryManagerTestManager()
            pluginsDirectoryManager?.delegate = pluginsDirectoryManagerTestManager
        }
    }
    
    override func tearDown() {
        pluginsDirectoryPath = nil
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

    // MARK: Create
    func createFileAtPathWithConfirmation(path: NSString) {
        let fileWasCreatedOrModifiedExpectation = expectationWithDescription("File was created")
        pluginsDirectoryManagerTestManager?.addFileWasCreatedOrModifiedAtPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == path) {
                fileWasCreatedOrModifiedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.createFileAtPath(path)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    func createDirectoryAtPathWithConfirmation(path: NSString) {
        let directoryWasCreatedOrModifiedExpectation = expectationWithDescription("Directory was created")
        pluginsDirectoryManagerTestManager?.addDirectoryWasCreatedOrModifiedAtPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == path) {
                directoryWasCreatedOrModifiedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.createDirectoryAtPath(path)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    
    // MARK: Remove
    func removeFileAtPathWithConfirmation(path: NSString) {
        let fileWasRemovedExpectation = expectationWithDescription("File was removed")
        pluginsDirectoryManagerTestManager?.addItemWasRemovedAtPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == path) {
                fileWasRemovedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.removeFileAtPath(path)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }
    func removeDirectoryAtPathWithConfirmation(path: NSString) {
        let directoryWasRemovedExpectation = expectationWithDescription("Directory was removed")
        pluginsDirectoryManagerTestManager?.addItemWasRemovedAtPathHandler({ returnedPath -> Void in
            if (self.dynamicType.resolveTemporaryDirectoryPath(returnedPath) == path) {
                directoryWasRemovedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.removeDirectoryAtPath(path)
        waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
    }

}

class PluginsDirectoryManagerFilesTests: PluginsDirectoryManagerTestCase {

    // TODO: These tests all have to be temporarily disabled and re-worked after sorting out issues around not being able to distinbuish between remove directory and file events
    func createValidPluginFileHeirarchy() {
        // Create a directory in the plugins directory, this should not cause a callback
        let testPluginDirectoryPath = pluginsDirectoryPath!.stringByAppendingPathComponent(testDirectoryName)
        createDirectoryAtPathWithConfirmation(testPluginDirectoryPath)
        
        // Create the contents directory, this should not cause a callback
        let testPluginContentsDirectoryPath = testPluginDirectoryPath.stringByAppendingPathComponent(testPluginContentsDirectoryName)
        createDirectoryAtPathWithConfirmation(testPluginContentsDirectoryPath)
        
        // Create the resource directory, this should not cause a callback
        let testPluginResourcesDirectoryPath = testPluginContentsDirectoryPath.stringByAppendingPathComponent(testPluginResourcesDirectoryName)
        createDirectoryAtPathWithConfirmation(testPluginResourcesDirectoryPath)
        
        // Create a file in the resource directory, this should not cause a callback
        let testPluginResourcesFilePath = testPluginResourcesDirectoryPath.stringByAppendingPathComponent(testFilename)
        createFileAtPathWithConfirmation(testPluginResourcesFilePath)

        // Create an info dictionary in the contents directory, this should cause a callback
        let testInfoDictionaryFilePath = testPluginContentsDirectoryPath.stringByAppendingPathComponent(testPluginInfoDictionaryFilename)
        createExpectationForPluginInfoDictionaryWasCreatedOrModifiedAtPluginPath(testPluginDirectoryPath)
        createFileAtPathWithConfirmation(testInfoDictionaryFilePath)
    }

    func removeValidPluginFileHeirarchy() {
        let testPluginDirectoryPath = pluginsDirectoryPath!.stringByAppendingPathComponent(testDirectoryName)
        let testPluginContentsDirectoryPath = testPluginDirectoryPath.stringByAppendingPathComponent(testPluginContentsDirectoryName)
        let testPluginResourcesDirectoryPath = testPluginContentsDirectoryPath.stringByAppendingPathComponent(testPluginResourcesDirectoryName)
        let testPluginResourcesFilePath = testPluginResourcesDirectoryPath.stringByAppendingPathComponent(testFilename)
        let testInfoDictionaryFilePath = testPluginContentsDirectoryPath.stringByAppendingPathComponent(testPluginInfoDictionaryFilename)
        
        // Remove the info dictionary in the contents directory, this should cause a callback
        createExpectationForPluginInfoDictionaryWasRemovedAtPluginPath(testPluginDirectoryPath)
        removeFileAtPathWithConfirmation(testInfoDictionaryFilePath)

        // Remove the file in the resource directory, this should not cause a callback
        removeFileAtPathWithConfirmation(testPluginResourcesFilePath)
        
        // Remove the resource directory, this should not cause a callback
        removeDirectoryAtPathWithConfirmation(testPluginResourcesDirectoryPath)
        
        // Remove the contents directory, this should cause a callback
        // because this could be the delete after move of a valid plugin's contents directory
        createExpectationForPluginInfoDictionaryWasRemovedAtPluginPath(testPluginDirectoryPath)
        removeDirectoryAtPathWithConfirmation(testPluginContentsDirectoryPath)
        
        // Remove the directory in the plugins directory, this should cause a callback
        // because this could be the delete after move of a valid plugin
        createExpectationForPluginInfoDictionaryWasRemovedAtPluginPath(testPluginDirectoryPath)
        removeDirectoryAtPathWithConfirmation(testPluginDirectoryPath)
    }

    
    func testValidPluginFileHeirarchy() {

        // Create a directory in the plugins directory, this should not cause a callback
        let testPluginDirectoryPath = pluginsDirectoryPath!.stringByAppendingPathComponent(testDirectoryName)
        createDirectoryAtPathWithConfirmation(testPluginDirectoryPath)
        
        // Create a file in the plugins directory, this should not cause a callback
        let testFilePath = pluginsDirectoryPath!.stringByAppendingPathComponent(testFilename)
        createFileAtPathWithConfirmation(testFilePath)
        
        // Create the contents directory, this should not cause a callback
        let testPluginContentsDirectoryPath = testPluginDirectoryPath.stringByAppendingPathComponent(testPluginContentsDirectoryName)
        createDirectoryAtPathWithConfirmation(testPluginContentsDirectoryPath)
        
        // Create a file in the contents directory, this should not cause a callback
        let testPluginContentsFilePath = testPluginContentsDirectoryPath.stringByAppendingPathComponent(testFilename)
        createFileAtPathWithConfirmation(testPluginContentsFilePath)
        
        // Create the resource directory, this should not cause a callback
        let testPluginResourcesDirectoryPath = testPluginContentsDirectoryPath.stringByAppendingPathComponent(testPluginResourcesDirectoryName)
        createDirectoryAtPathWithConfirmation(testPluginResourcesDirectoryPath)
        
        // Create a file in the resource directory, this should not cause a callback
        let testPluginResourcesFilePath = testPluginResourcesDirectoryPath.stringByAppendingPathComponent(testFilename)
        createFileAtPathWithConfirmation(testPluginResourcesFilePath)

        // Create an info dictionary in the contents directory, this should cause a callback
        let testInfoDictionaryFilePath = testPluginContentsDirectoryPath.stringByAppendingPathComponent(testPluginInfoDictionaryFilename)
        createExpectationForPluginInfoDictionaryWasCreatedOrModifiedAtPluginPath(testPluginDirectoryPath)
        createFileAtPathWithConfirmation(testInfoDictionaryFilePath)
        
        // Clean up
        
        // Remove the info dictionary in the contents directory, this should cause a callback
        createExpectationForPluginInfoDictionaryWasRemovedAtPluginPath(testPluginDirectoryPath)
        removeFileAtPathWithConfirmation(testInfoDictionaryFilePath)

        // Remove the file in the resource directory, this should not cause a callback
        removeFileAtPathWithConfirmation(testPluginResourcesFilePath)

        // Remove the resource directory, this should not cause a callback
        removeDirectoryAtPathWithConfirmation(testPluginResourcesDirectoryPath)
        
        // Remove the file in the contents directory, this should not cause a callback
        removeFileAtPathWithConfirmation(testPluginContentsFilePath)

        // Remove the contents directory, this should cause a callback
        // because this could be the delete after move of a valid plugin's contents directory
        createExpectationForPluginInfoDictionaryWasRemovedAtPluginPath(testPluginDirectoryPath)
        removeDirectoryAtPathWithConfirmation(testPluginContentsDirectoryPath)
        
        // Remove the file in the plugins directory, this should cause a callback
        // because for deletes we can't distinguish between files and directories
        createExpectationForPluginInfoDictionaryWasRemovedAtPluginPath(testFilePath)
        removeFileAtPathWithConfirmation(testFilePath)
        
        // Remove the directory in the plugins directory, this should cause a callback
        // because this could be the delete after move of a valid plugin
        createExpectationForPluginInfoDictionaryWasRemovedAtPluginPath(testPluginDirectoryPath)
        removeDirectoryAtPathWithConfirmation(testPluginDirectoryPath)
    }

    func testInvalidPluginFileHeirarchy() {
        // Create an invalid contents directory in the plugins path, this should not cause a callback
        let testInvalidPluginContentsDirectoryPath = pluginsDirectoryPath!.stringByAppendingPathComponent(testPluginContentsDirectoryName)
        createDirectoryAtPathWithConfirmation(testInvalidPluginContentsDirectoryPath)

        // Create a info dictionary in the invalid contents directory, this should not cause a callback
        let testInvalidInfoDictionaryPath = testInvalidPluginContentsDirectoryPath.stringByAppendingPathComponent(testPluginInfoDictionaryFilename)
        createFileAtPathWithConfirmation(testInvalidInfoDictionaryPath)
        

        // Clean Up
        
        // Remove the info dictionary in the invalid contents directory, this should not cause a callback
        removeFileAtPathWithConfirmation(testInvalidInfoDictionaryPath)
        
        // Remove the invalid contents directory in the plugins path, this should cause a callback
        // because this could be the delete after move of a valid plugin
        createExpectationForPluginInfoDictionaryWasRemovedAtPluginPath(testInvalidPluginContentsDirectoryPath)
        removeDirectoryAtPathWithConfirmation(testInvalidPluginContentsDirectoryPath)
    }

    func testFileForContentsDirectory() {
        // Create a directory in the plugins directory, this should not cause a callback
        let testPluginDirectoryPath = pluginsDirectoryPath!.stringByAppendingPathComponent(testDirectoryName)
        createDirectoryAtPathWithConfirmation(testPluginDirectoryPath)

        // Create the contents directory, this should not cause a callback
        let testPluginContentsFilePath = testPluginDirectoryPath.stringByAppendingPathComponent(testPluginContentsDirectoryName)
        createFileAtPathWithConfirmation(testPluginContentsFilePath)


        // Clean Up
        
        // Remove the contents directory, this should cause a callback
        // because this could be the delete after move of a valid plugin's contents directory
        createExpectationForPluginInfoDictionaryWasRemovedAtPluginPath(testPluginDirectoryPath)
        removeFileAtPathWithConfirmation(testPluginContentsFilePath)
    
        // Remove the directory in the plugins directory, this should cause a callback
        // because this could be the delete after move of a valid plugin
        createExpectationForPluginInfoDictionaryWasRemovedAtPluginPath(testPluginDirectoryPath)
        removeDirectoryAtPathWithConfirmation(testPluginDirectoryPath)
    }

    func testDirectoryForInfoDictionary() {
        // Create a directory in the plugins directory, this should not cause a callback
        let testPluginDirectoryPath = pluginsDirectoryPath!.stringByAppendingPathComponent(testDirectoryName)
        createDirectoryAtPathWithConfirmation(testPluginDirectoryPath)
        
        // Create the contents directory, this should not cause a callback
        let testPluginContentsDirectoryPath = testPluginDirectoryPath.stringByAppendingPathComponent(testPluginContentsDirectoryName)
        createDirectoryAtPathWithConfirmation(testPluginContentsDirectoryPath)
        
        // Create a directory for the info dictionary, this should not cause a callback
        let testPluginInfoDictionaryDirectoryPath = testPluginContentsDirectoryPath.stringByAppendingPathComponent(testPluginInfoDictionaryFilename)
        createDirectoryAtPathWithConfirmation(testPluginInfoDictionaryDirectoryPath)
        
        // Clean Up

        // Create a directory for the info dictionary, this should cause a callback
        createExpectationForPluginInfoDictionaryWasRemovedAtPluginPath(testPluginDirectoryPath)
        removeDirectoryAtPathWithConfirmation(testPluginInfoDictionaryDirectoryPath)
        
        // Remove the contents directory, this should cause a callback
        // because this could be the delete after move of a valid plugin's contents directory
        createExpectationForPluginInfoDictionaryWasRemovedAtPluginPath(testPluginDirectoryPath)
        removeDirectoryAtPathWithConfirmation(testPluginContentsDirectoryPath)
        
        // Remove the directory in the plugins directory, this should cause a callback
        // because this could be the delete after move of a valid plugin
        createExpectationForPluginInfoDictionaryWasRemovedAtPluginPath(testPluginDirectoryPath)
        removeDirectoryAtPathWithConfirmation(testPluginDirectoryPath)
    }

    // TODO: Test file for plugin directory
    // TODO: Move the resources directory, this should not cause a callback
    // TODO: Move the contents directory, this should cause two callbacks
    // TODO: Use those two new functions for these: createValidPluginFileHeirarchy, removeValidPluginFileHeirarchy
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